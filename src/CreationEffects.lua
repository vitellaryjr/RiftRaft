RIFTRAFT.creation_buffer_types = {"joker", "consumeable"}
RIFTRAFT.creation_skip_calc = false
RIFTRAFT.overflow_buffer_size = 100000
RIFTRAFT.creation_watched_cards = {}

local prev_creation_buffers = {}
local checking_creation_buffer = false
local checking_creation_buffer_disabled = false
local overflow_temp_extra_space = 0

function RIFTRAFT.get_creation_buffer(_type)
	return G.GAME[_type.."_buffer"]
end

function RIFTRAFT.set_creation_buffer(_type, amt)
	G.GAME[_type.."_buffer"] = amt
end

function RIFTRAFT.check_valid_creation_area(area)
	if not area then return false end
	return area == G.jokers
		or area == G.consumeables
		or area == G.hand
		or area == G.deck
		or area == G.play
		or area == G.riftraft_rifthand
		or area == G.riftraft_void
end

function RIFTRAFT.check_valid_creation_card(card)
	return not card.created_from_split -- Incantation support
end

function RIFTRAFT.is_area_limited(area)
	return area and area.config.type == 'joker'
end

function RIFTRAFT.should_area_add_to_deck(area)
	return area ~= G.riftraft_rifthand
		and area ~= G.riftraft_void
end

function RIFTRAFT.can_creation_overflow(area)
	return G.GAME.riftraft_overflow and G.GAME.riftraft_overflow > 0
		and area ~= nil
		and RIFTRAFT.check_valid_creation_area(area)
		and RIFTRAFT.is_area_limited(area)
end

local orig_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)
	local new_card = orig_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)

	if not RIFTRAFT.creation_skip_calc then
		RIFTRAFT.creation_watched_cards[new_card] = {}
	end

	return new_card
end

local orig_copy_card = copy_card
function copy_card(other, new_card, card_scale, playing_card, strip_edition, ...)
	local _new_card = orig_copy_card(other, new_card, card_scale, playing_card, strip_edition, ...)

	if not new_card and not RIFTRAFT.creation_skip_calc then
		RIFTRAFT.creation_watched_cards[_new_card] = {copy = other}
	end

	return _new_card
end

local orig_create_playing_card = create_playing_card
function create_playing_card(card_init, area, skip_materialize, silent, colours, skip_emplace, ...)
	local card = orig_create_playing_card(card_init, area, skip_materialize, silent, colours, skip_emplace, ...)

	if not RIFTRAFT.creation_skip_calc then
		if area and not skip_emplace then
			if RIFTRAFT.check_valid_creation_card(card) and RIFTRAFT.check_valid_creation_area(area) then
				SMODS.calculate_context({riftraft_creation = {
					card = card,
					area = area
				}})
			end
		else
			RIFTRAFT.creation_watched_cards[card] = {}
		end
	end

	return card
end

local orig_CardArea_emplace = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped, ...)
	local no_space = #self.cards >= self.config.card_limit + RIFTRAFT.get_extra_card_limit(card) + overflow_temp_extra_space

	orig_CardArea_emplace(self, card, location, stay_flipped, ...)

	if no_space and RIFTRAFT.can_creation_overflow(self) then
		G.riftraft_void.override_show = G.riftraft_void.override_show + 1

		if card.added_to_deck then
			card:remove_from_deck()
		end
		card.riftraft_dont_add = true

		G.E_MANAGER:add_event(Event({
			func = function()
				if RIFTRAFT.get_extra_card_limit(card) > 0 then
					card.riftraft_dont_add = nil

					if RIFTRAFT.should_area_add_to_deck(self) and (card.ability.set ~= "Default" and card.ability.set ~= "Enhanced") and not card.added_to_deck then
						card:add_to_deck()
					end

					G.riftraft_void.override_show = G.riftraft_void.override_show - 1
					return true
				end

				local draw_event = Event({
					blockable = false,
					func = function()
						if RIFTRAFT.in_void_pack() then
							draw_card(card.area, G.riftraft_rifthand, nil, 'up', nil, card, 0.08)
						else
							draw_card(card.area, G.riftraft_void, nil, 'down', nil, card, 0.08)
						end
						G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
							SMODS.calculate_context({add_to_void = true, added = {main_v}})
							return true
						end}))

						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 1,
							blockable = false,
							blocking = false,
							func = function()
								G.riftraft_void.override_show = G.riftraft_void.override_show - 1
								return true
							end
						}))
						return true
					end
				})

				if not card.edition or not card.edition.negative then
					G.E_MANAGER:add_event(Event({
						trigger = "before",
						delay = 0.08,
						func = function()
							card:set_edition({negative = true}, true, true)
							play_sound('tarot1', nil, 0.6)
							card:juice_up(1, 0.5)

							G.E_MANAGER:add_event(draw_event)
							return true
						end
					}))
				else
					G.E_MANAGER:add_event(Event({
						func = function()
							G.E_MANAGER:add_event(draw_event)
						end
					}))
				end

				return true
			end
		}))
	end

	local watched_card = RIFTRAFT.creation_watched_cards[card]
	if watched_card then
		RIFTRAFT.creation_watched_cards[card] = nil

		if not RIFTRAFT.creation_skip_calc and RIFTRAFT.check_valid_creation_card(card) and RIFTRAFT.check_valid_creation_area(self) then
			watched_card.card = card
			watched_card.area = self

			SMODS.calculate_context({riftraft_creation = watched_card})
		end
	end
end

-- Bad hack for generically handling joker/consumeable creation buffers (to avoid over-drawing when duplicated)
local orig_EventManager_add_event = EventManager.add_event
EventManager.add_event = function(...)
	if checking_creation_buffer and not checking_creation_buffer_disabled then
		for _,_type in ipairs(RIFTRAFT.creation_buffer_types) do
			local buffer = RIFTRAFT.get_creation_buffer(_type)
			local prev_buffer = prev_creation_buffers[_type] or buffer

			if buffer > prev_buffer then
				checking_creation_buffer_disabled = true

				SMODS.calculate_context({
					riftraft_pre_creation = true,
					riftraft_pre_creation_type = _type,
					riftraft_pre_creation_amount = buffer - prev_buffer
				})

				checking_creation_buffer_disabled = false

				prev_creation_buffers[_type] = RIFTRAFT.get_creation_buffer(_type)

				--print("Buffer (" .. _type .. ") | Created: " .. buffer - prev_buffer .. " | New: " .. RIFTRAFT.get_creation_buffer(_type))
			end
		end
	end
	return orig_EventManager_add_event(...)
end

local orig_eval_card = eval_card
eval_card = function(card, context, ...)
	if not checking_creation_buffer_disabled then
		checking_creation_buffer = true

		for _,_type in ipairs(RIFTRAFT.creation_buffer_types) do
			if G.GAME.riftraft_overflow and G.GAME.riftraft_overflow > 0 then
				RIFTRAFT.set_creation_buffer(_type, -RIFTRAFT.overflow_buffer_size)
			end

			prev_creation_buffers[_type] = RIFTRAFT.get_creation_buffer(_type)
		end
	end

	-- prevent inherent overflow of Invisible Joker
	local free_space = context.selling_self and card and RIFTRAFT.get_extra_card_limit(card) == 0
	if free_space then
		overflow_temp_extra_space = overflow_temp_extra_space + 1
	end

	local results = {orig_eval_card(card, context, ...)}

	if free_space then
		overflow_temp_extra_space = overflow_temp_extra_space - 1
	end

	if not checking_creation_buffer_disabled then
		checking_creation_buffer = false
	end

	return unpack(results)
end

local orig_Card_add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff, ...)
	if self.riftraft_dont_add then
		return
	end
	orig_Card_add_to_deck(self, from_debuff, ...)
end