-- name, choose, extra, cost (cost will be +5 ingame), weight
local booster_types = {
    {"Void Pack", 1, 3, 2, 1},
    {"Void Pack", 1, 3, 2, 1},
    {"Jumbo Void Pack", 1, 5, 4, 1},
    {"Mega Void Pack", 2, 5, 7, 0.25},
}
for i,v in ipairs(booster_types) do
    SMODS.Booster{
        key = "voidpack"..i,
        loc_txt = {
            name = v[1],
            text = {
                "Choose {C:attention}#1#{} of up to",
                "{C:attention}#2#{C:riftraft_void} Rift{} cards to",
                "be used immediately",
            },
            group_name = "Void Pack",
        },
        loc_vars = function(self, info_queue, pack)
            return {
                vars = {
                    pack.ability.choose,
                    pack.ability.extra,
                }
            }
        end,
        config = {
            choose = v[2],
            extra = v[3],
        },
        create_card = function(self, booster, i)
            local data = {
                set = "Rift",
                area = G.pack_cards,
                no_edition = true,
                skip_materialize = true,
                soulable = true,
            }
            if (i == 1) and (#G.riftraft_void:get_next_cards() > 0) then
                local forced_keys = {}
                local has = G.riftraft_void:has_card_types_in()
                if has.consumeable and not G.GAME.banned_keys["c_riftraft_decay"] then
                    table.insert(forced_keys, "c_riftraft_decay")
                end
                if has.playing_card and not G.GAME.banned_keys["c_riftraft_cipher"] then
                    table.insert(forced_keys, "c_riftraft_cipher")
                end
                if has.joker then
                    if not G.GAME.banned_keys["c_riftraft_facade"] then
                        table.insert(forced_keys, "c_riftraft_facade")
                    end
                    if not G.GAME.banned_keys["c_riftraft_static"] then
                        table.insert(forced_keys, "c_riftraft_static")
                    end
                end
                if #forced_keys > 0 then
                    data.key = forced_keys[pseudorandom(pseudoseed('voidpack_firstcard'), 1, #forced_keys)]
                end
            end
            -- for testing
            -- if i == 2 then
            --     data.key = "c_riftraft_canyon"
            -- end
            return SMODS.create_card(data)
        end,
        ease_background_colour = function(self)
            ease_background_colour{new_colour = HEX("252d2e"), special_colour = {0,0,0,1}, contrast = 3}
        end,
        particles = function(self)
            -- mostly done to make the music change to the celestial pack music without any hooks because i'm lazy
            G.booster_pack_meteors = Particles(1, 1, 0,0, {
                timer = 2,
                scale = 0.05,
                lifespan = 1.5,
                speed = 4,
                attach = G.ROOM_ATTACH,
                colours = {G.C.BLACK},
                fill = true
            })
        end,
        set_ability = function(self, card, initial, delay_sprites)
            if not card.edition then
                card:set_edition({negative = true}, true, true)
            end
        end,
        update_pack = function(self, dt)
            if G.buttons then G.buttons:remove(); G.buttons = nil end
            if G.shop then G.shop.alignment.offset.y = G.ROOM.T.y+11 end
        
            if not G.STATE_COMPLETE then
                G.STATE_COMPLETE = true
                G.CONTROLLER.interrupt.focus = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        if self.particles and type(self.particles) == "function" then self:particles() end
                        G.booster_pack = UIBox{
                            definition = self:create_UIBox(),
                            config = {align="tmi", offset = {x=0,y=G.ROOM.T.y + 9}, major = G.riftraft_rifthand, bond = 'Weak'}
                        }
                        G.booster_pack.alignment.offset.y = -2.2
                        G.ROOM.jiggle = G.ROOM.jiggle + 3
                        self:ease_background_colour()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                RIFTRAFT.draw_from_void_to_rift()
        
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.5,
                                    func = function()
                                        G.CONTROLLER:recall_cardarea_focus('pack_cards')
                                        return true
                                    end}))
                                return true
                            end
                        }))  
                        return true
                    end
                }))  
            end
        end,
        atlas = "RiftShop",
        pos = {x = i, y = 0},
        cost = v[4],
        weight = v[5],
        kind = "Rift",
        in_pool = function() return false end, -- only spawn them manually
        -- cryptid compatibility
        cry_digital_hallucinations = {
            colour = HEX("526469"),
            loc_key = "k_plus_riftraft_rift",
            create = function()
                -- local v = create_card("Rift", G.consumeables, nil, nil, nil, nil, nil, "diha")
                local v = SMODS.create_card{set = 'Rift', area = G.consumeables, key_append = 'diha'}
                v:set_edition({negative = true}, true, true)
                v:add_to_deck()
                G.consumeables:emplace(v)
            end,
        }
    }
end

RIFTRAFT.rifthand_active = false

RIFTRAFT.draw_from_void_to_rift = function()
    G.riftraft_rifthand.config.card_limit = G.hand.config.card_limit
    RIFTRAFT.rifthand_active = true
    -- i don't remember what this was supposed to be doing?
    -- G.riftraft_void:has_card_types_in(G.riftraft_rifthand.config.card_limit)
    delay(0.3)
    for i=1, G.riftraft_rifthand.config.card_limit do
        draw_card(G.riftraft_void,G.riftraft_rifthand, i*100/G.riftraft_rifthand.config.card_limit, 'up', false)
    end
end

RIFTRAFT.draw_from_rift_to_void = function()
    local hand_count = #G.riftraft_rifthand.cards
    for i=1, hand_count do
        draw_card(G.riftraft_rifthand, G.riftraft_void, i*100/hand_count,'down', nil, nil, 0.08)
    end
    RIFTRAFT.rifthand_active = false
end

-- make the packs appear negative in the collection
-- local orig_card_collection_UIBox = SMODS.card_collection_UIBox
-- SMODS.card_collection_UIBox = function(_pool, rows, args)
--     if _pool == G.P_CENTER_POOLS.Booster then
--         args = args or {}
--         local orig_modify_card = args.modify_card or function() end
--         args.modify_card = function(card, center, i, j)
--             orig_modify_card(card, center, i, j)
--             -- set Void Packs to be negative
--             if center.key:find("p_riftraft_voidpack") then
--                 card:set_edition({negative = true}, true, true)
--             end
--         end
--     end
--     return orig_card_collection_UIBox(_pool, rows, args)
-- end

SMODS.Tag{
    key = "voidpack",
    loc_txt = {
        name = "Void Tag",
        text = {
            "Gives a free",
            "{C:riftraft_void}Mega Void Pack",
        },
    },
    atlas = "RiftTags",
    pos = {x = 0, y = 0},
    min_ante = 2,
    in_pool = function(self, args)
        return G.riftraft_void and #G.riftraft_void.cards > 0
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', HEX("526469"), function()
                local key = 'p_riftraft_voidpack4'
                local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                card.cost = 0
                card.from_tag = true
                G.FUNCS.use_card({config = {ref_table = card}})
                card:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}
SMODS.Tag{
    key = "voidpull",
    loc_txt = {
        name = "Retrieval Tag",
        text = {
            "Retrieves copies of",
            "{C:attention}#1#{} random {C:riftraft_void}Void{} cards",
        },
    },
    loc_vars = function(self, info_queue, tag)
        return {
            vars = {
                tag.config.amount,
            }
        }
    end,
    config = {amount = 2},
    atlas = "RiftTags",
    pos = {x = 1, y = 0},
    min_ante = 2,
    in_pool = function(self, args)
        return G.GAME.modifiers["riftraft_only_retrieval_tag"] or (G.riftraft_void and #G.riftraft_void.cards > 0)
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            local copied = {}
            tag:yep('+', HEX("526469"), function()
                local temp_hand = {}
                for k, v in ipairs(G.riftraft_void.cards) do temp_hand[#temp_hand+1] = v end
                pseudoshuffle(temp_hand, pseudoseed('tag_pull'))
                
                local void_copy = function(to_copy)
                    local new_card = copy_card(to_copy)
                    new_card:add_to_deck()
                    if new_card.ability.consumeable then
                        G.consumeables:emplace(new_card)
                        new_card:hard_set_VT()
                        new_card:start_materialize()
                    elseif new_card.ability.set == "Default" or new_card.ability.set == "Enhanced" then
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, new_card)
                        G.riftraft_rifthand:emplace(new_card)
                        new_card:start_materialize()
                    elseif new_card.ability.set == "Joker" then
                        G.jokers:emplace(new_card)
                        new_card:hard_set_VT()
                        new_card:start_materialize()
                    end
                    table.insert(copied, new_card)
                end
                for i=1, math.min(#temp_hand, tag.config.amount) do
                    local v = temp_hand[i]
                    void_copy(v)
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    for i,v in ipairs(copied) do
                        if v.ability.set == "Default" or v.ability.set == "Enhanced" then
                            draw_card(G.riftraft_rifthand, G.deck, nil,'down', nil, v, 0.08)
                        end
                    end
                    return true
                end
            }))
            tag.triggered = true
            return true
        end
    end,
}