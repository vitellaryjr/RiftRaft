------------
-- Common --
------------
SMODS.Joker{
    key = "bundle",
    loc_txt = {
        name = "Bundle",
        text = {
            "{C:mult}+#1#{} Mult per",
            "card in the {C:riftraft_void}Void{}",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)"
        },
    },
    config = {
        -- extra = {chips = 0, chip_gain = 5},
        extra = {mult = 0, mult_gain = 1},
    },
    loc_vars = function(self, info_queue, card)
        -- return {vars = {card.ability.extra.chip_gain, card.ability.extra.chips}}
        return {vars = {card.ability.extra.mult_gain, card.ability.extra.mult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 3, y = 0},
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    update = function(self, card, dt)
        card.ability.extra.mult = card.ability.extra.mult_gain * (G.riftraft_void and (#G.riftraft_void.cards + #G.riftraft_rifthand.cards) or 0)
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            return {mult = card.ability.extra.mult}
        end
    end,
}

--------------
-- Uncommon --
--------------
SMODS.Joker{
    key = "flint",
    loc_txt = {
        name = "Flint and Steel",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult for every",
            "consumable used during round,",
            "resets at end of round",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
        },
    },
    config = {
        extra = {xmult = 1, xmult_gain = 0.5},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 2, y = 1},
    rarity = 2,
    cost = 8,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if not context.blueprint then
            if context.using_consumeable and context.cardarea == G.jokers and G.GAME.blind.in_blind then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {message = "Upgrade!"}
            end
            if context.end_of_round and context.cardarea == G.jokers then
                card.ability.extra.xmult = 1
                return {message = "Reset!"}
            end
        end
        if context.joker_main and context.cardarea == G.jokers then
            return {
                x_mult = card.ability.extra.xmult
            }
        end
    end,
}
SMODS.Joker{
    key = "refund",
    loc_txt = {
        name = "Receipt",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult for every",
            "{C:dark_edition}Negative{} Joker sold",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
        },
    },
    config = {
        extra = {xmult = 1, xmult_gain = 0.25},
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "e_negative", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 3, y = 1},
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.selling_card and context.cardarea == G.jokers and not context.blueprint then
            if context.card.edition and context.card.edition.negative then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {message = "X"..card.ability.extra.xmult_gain.." Mult"}
            end
        elseif context.joker_main and context.cardarea == G.jokers then
            return {x_mult = card.ability.extra.xmult}
        end
    end,
}
SMODS.Joker{
    key = "negativesixth",
    loc_txt = {
        name = "Supercollider",
        text = {
            "When {C:attention}Blind{} is selected, destroy",
            "all {C:dark_edition}Negative{} consumables and",
            "replace them with a {C:riftraft_void}Rift{} card",
            "{s:0.8,C:dark_edition}Negative {s:0.8,C:riftraft_void}Rift {s:0.8}cards excluded{}",
        },
    },
    config = {},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "e_negative_consumable", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {}
    end,
    atlas = "RiftJokers",
    pos = {x = 5, y = 0},
    rarity = 2,
    cost = 6,
    blueprint_compat = false,
    calculate = function(self, card, context)
        -- orig behavior
        -- if context.destroying_card and not context.blueprint then
        --     if #context.full_hand == 1 and context.full_hand[1].edition and context.full_hand[1].edition.negative then
        --         G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        --         G.E_MANAGER:add_event(Event({
        --             trigger = 'before',
        --             delay = 0.0,
        --             func = function()
        --                     local card = create_card('Rift',G.consumeables, nil, nil, nil, nil, nil, 'nsixth')
        --                     card:add_to_deck()
        --                     card:set_edition({negative = true}, true, true)
        --                     G.consumeables:emplace(card)
        --                     G.GAME.consumeable_buffer = 0
        --                 return true
        --             end}))
        --         return {message = localize('k_plus_riftraft_rift'), colour = HEX("526469")}
        --     end
        -- end

        if context.setting_blind and context.cardarea == G.jokers and not context.blueprint then
            local destroyed_any = false
            for i,v in ipairs(G.consumeables.cards) do
                if v.edition and v.edition.negative and v.ability.set ~= "Rift" then
                    destroyed_any = true
                    break
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    for i,v in ipairs(G.consumeables.cards) do
                        if v.edition and v.edition.negative and v.ability.set ~= "Rift" then
                            v:start_dissolve(nil, i > 1)
                        end
                    end
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    if destroyed_any then
                        local card = create_card('Rift',G.consumeables, nil, nil, nil, nil, nil, 'nsixth')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    return true
                end
            }))
            if destroyed_any then
                return {message = localize('k_plus_riftraft_rift'), colour = HEX("526469")}
            end
        end
    end,
}
local function calculate_collector_mult(card)
    -- i could do this more optimally and only check the newly added stuff but this is easier
    local keys = {}
    local prev_xmult = card.ability.extra.xmult
    card.ability.extra.xmult = 1
    local to_check = {}
    for i,v in ipairs(G.riftraft_void and G.riftraft_void.cards or {}) do to_check[#to_check+1] = v end
    for i,v in ipairs(G.riftraft_rifthand and G.riftraft_rifthand.cards or {}) do to_check[#to_check+1] = v end
    for i,v in ipairs(to_check) do
        if v.ability.set == "Joker" and not keys[v.config.center.key] then
            keys[v.config.center.key] = true
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
        end
    end
    if prev_xmult < card.ability.extra.xmult then
        return "X"..(card.ability.extra.xmult - prev_xmult).." Mult"
    elseif prev_xmult > card.ability.extra.xmult then
        return "-X"..(prev_xmult - card.ability.extra.xmult).." Mult"
    end
end
SMODS.Joker{
    key = "collector",
    loc_txt = {
        name = "Collector",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult for every",
            "{C:attention}unique{} Joker in the {C:riftraft_void}Void{}",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
        },
    },
    config = {
        extra = {xmult = 1, xmult_gain = 0.2},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 0, y = 2},
    rarity = 2,
    cost = 7,
    blueprint_compat = true,
    set_ability = function(self, card, initial, delay_sprites)
        calculate_collector_mult(card)
    end,
    calculate = function(self, card, context)
        if (context.add_to_void or context.remove_from_void) and context.cardarea == G.jokers and not context.blueprint then
            local msg = calculate_collector_mult(card)
            if msg then return {message = msg} end
        end
        if context.joker_main and context.cardarea == G.jokers then
            return {x_mult = card.ability.extra.xmult}
        end
    end,
}

----------
-- Rare --
----------
function RIFTRAFT.get_extra_card_limit(card)
    return (card.edition and card.edition.card_limit or 0)
        + (card.config.center.key == 'j_riftraft_joke' and card.ability.extra.amount or 0)
end
SMODS.Joker{
    key = "joke",
    loc_txt = {
        name = "Joke ",
        text = {
            "{C:attention}+#1#{} Joker slot",
        },
    },
    config = {
        extra = {amount = 1},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.amount}}
    end,
    atlas = "RiftJokers",
    pos = {x = 2, y = 0},
    rarity = 3,
    cost = 2,
    blueprint_compat = false,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.amount
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then
            G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.amount
        end
    end,
}
SMODS.Joker{
    key = "magnify",
    loc_txt = {
        name = "Magnifying Glass",
        text = {
            "Each {C:attention}unique{}",
            "consumable held",
            "gives {X:mult,C:white} X#1# {} Mult",
        },
    },
    config = {
        extra = {xmult = 1.5, keys = {}},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 1, y = 1},
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.other_consumeable then
            for k,v in ipairs(G.consumeables.cards) do
                if v.config.center.key == context.other_consumeable.config.center.key then
                    if v == context.other_consumeable then
                        return {
                            x_mult = card.ability.extra.xmult
                        }
                    else
                        break
                    end
                end
            end
        end
    end,
}
-- original behavior: +100 chips, +20 mult, and X2 mult if played hand contains all 3 editions
SMODS.Joker{
    key = "trifecta",
    loc_txt = {
        name = "Trifecta",
        text = {
            -- "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult, and {X:mult,C:white} X#3# {} Mult",
            -- "if played hand contains a scoring",
            -- "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, and",
            -- "{C:dark_edition}Polychrome{} card",

            "{C:dark_edition}Foil{} cards give {C:mult}+#2#{} Mult and {X:mult,C:white} X#3# {} Mult",
            "{C:dark_edition}Holographic{} cards give {C:chips}+#1#{} Chips and {X:mult,C:white} X#3# {} Mult",
            "{C:dark_edition}Polychrome{} cards give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
        },
    },
    config = {
        extra = {chips = 25, mult = 5, xmult = 1.25},
    },
    loc_vars = function(self, info_queue, card)
        for _,v in ipairs({"foil", "holo", "polychrome"}) do
            local t = G.P_CENTERS['e_'..v]
            info_queue[#info_queue + 1] = t
            -- if G.P_CENTERS['e_'..v].loc_vars and type(G.P_CENTERS['e_'..v].loc_vars) == 'function' then
            --     local res = G.P_CENTERS['e_'..v]:loc_vars(info_queue, card) or {}
            --     t.vars = res.vars
            --     t.key = res.key or t.key
            --     t.set = res.set or t.set
            -- end
        end
        return {vars = {card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.xmult}}
    end,
    atlas = "RiftJokers",
    pos = {x = 4, y = 1},
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    calculate = function(self, card, context)
        -- [[ orig behavior ]]
        -- if context.joker_main and context.cardarea == G.jokers then
        --     local has_edition = {}
        --     for k,v in ipairs(context.scoring_hand) do
        --         if v.edition then
        --             for kk,vv in pairs(v.edition) do
        --                 if vv == true then
        --                     has_edition[kk] = true
        --                 end
        --             end
        --         end
        --     end
        --     if has_edition.foil and has_edition.holo and has_edition.polychrome then
        --         return {
        --             chips = card.ability.extra.chips,
        --             mult = card.ability.extra.mult,
        --             x_mult = card.ability.extra.xmult,
        --         }
        --     end
        -- end

        local played = nil
        if context.individual and context.cardarea == G.play and context.other_card and context.other_card.edition then
            played = context.other_card
        elseif context.other_joker and context.other_joker.edition then
            played = context.other_joker
        end
        if played ~= nil then
            if played.edition.foil then
                return {
                    mult = card.ability.extra.mult,
                    x_mult = card.ability.extra.xmult,
                }
            elseif played.edition.holo then
                return {
                    chips = card.ability.extra.chips,
                    x_mult = card.ability.extra.xmult,
                }
            elseif played.edition.polychrome then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                }
            end
        end
    end,
}
local function pick_void_joker(exclude)
    local jokers = {}
    for _, v in ipairs(G.riftraft_void and G.riftraft_void.cards or {}) do
        if v ~= exclude and v.ability.set == "Joker" and v.config.center.key ~= "j_riftraft_abyss" then
            table.insert(jokers, v)
        end
    end
    for _, v in ipairs(G.riftraft_rifthand and G.riftraft_rifthand.cards or {}) do
        if v ~= exclude and v.ability.set == "Joker" and v.config.center.key ~= "j_riftraft_abyss" then
            table.insert(jokers, v)
        end
    end
    if #jokers == 0 then return nil end
    local picked = pseudorandom_element(jokers, pseudoseed('abyss_choice'))
    return picked, picked.config.center.key, picked.unique_val
end
local function get_current_void_joker(card)
    if not card.ability.copied_joker then return nil end
    if not card.riftraft_cache_copied_joker then
        for i,v in ipairs(G.I.CARD) do
            if v.unique_val == card.ability.copied_joker_id then
                card.riftraft_cache_copied_joker = v
                break
            end
        end
    end
    return card.riftraft_cache_copied_joker
end
function RIFTRAFT.call_abyss_joker(card, f)
    local result
    local void_joker = get_current_void_joker(card)
    if void_joker then
        local prev_config, prev_ability, prev_edition, prev_added = card.config, card.ability, card.edition, card.added_to_deck
        card.config = void_joker.config
        card.ability = void_joker.ability
        card.edition = nil
        card.added_to_deck = prev_ability.added_copied_joker or false
        result = f(void_joker, prev_config, prev_ability, prev_edition, prev_added)
        card.config = prev_config
        card.ability = prev_ability
        card.edition = prev_edition
        card.added_to_deck = prev_added
    end
    return result
end
function RIFTRAFT.reset_abyss_joker(card, exclude)
    local old_copied_joker = get_current_void_joker(card)
    local new_copied_joker, new_copied_joker_key, new_copied_joker_id = pick_void_joker(exclude)

    if old_copied_joker == new_copied_joker and card.ability.copied_joker == new_copied_joker_key then
        return
    end

    if card.ability.copied_joker then
        RIFTRAFT.call_abyss_joker(card, function()
            card:remove_from_deck(false)
        end)
        card.ability.added_copied_joker = false
    end

    card.riftraft_cache_copied_joker = new_copied_joker
    card.ability.copied_joker = new_copied_joker_key
    card.ability.copied_joker_id = new_copied_joker_id

    if card.ability.copied_joker then
        RIFTRAFT.call_abyss_joker(card, function()
            card:add_to_deck(false)
        end)
        card.ability.added_copied_joker = true
    end

    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_riftraft_changed')})
end
SMODS.Joker{
    key = "abyss",
    loc_txt = {
        name = "Staring Back",
        text = {
            "Copies a random Joker",
            "currently in the {C:riftraft_void}Void{}",
            "{s:0.8,C:attention}Staring Back{s:0.8} excluded",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive})",
        },
    },
    config = {},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.copied_joker and localize{type = 'name_text', key = card.ability.copied_joker, set = 'Joker'} or localize('k_none')}}
    end,
    atlas = "RiftJokers",
    pos = {x = 1, y = 2},
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            card.riftraft_cache_copied_joker, card.ability.copied_joker, card.ability.copied_joker_id = pick_void_joker()

            if card.ability.copied_joker then
                RIFTRAFT.call_abyss_joker(card, function()
                    card:add_to_deck(false)
                end)
                card.ability.added_copied_joker = true
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        RIFTRAFT.call_abyss_joker(card, function()
            card:remove_from_deck(from_debuff)
        end)

        card.ability.added_copied_joker = false

        if not from_debuff then
            card.riftraft_cache_copied_joker, card.ability.copied_joker, card.ability.copied_joker_id = nil, nil, nil
        end
    end,
    update = function(self, card, dt)
        RIFTRAFT.call_abyss_joker(card, function()
            card:update(dt)
        end)
    end,
    calculate = function(self, card, context)
        local effect = RIFTRAFT.call_abyss_joker(card, function()
            return card:calculate_joker(context)
        end)

        if context.blueprint then
            return effect
        end

        if context.setting_blind and not card.getting_sliced then
            RIFTRAFT.reset_abyss_joker(card)

        elseif context.remove_from_void and card.ability.copied_joker ~= nil then
            local void_joker = get_current_void_joker(card)

            local copied_check = false
            for _, other in ipairs(context.added or {}) do
                if other == void_joker then
                    copied_check = true
                    break
                end
            end

            if copied_check then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        RIFTRAFT.reset_abyss_joker(card, void_joker)
                        return true
                    end
                }))
            end

        elseif context.add_to_void and card.ability.copied_joker == nil then
            G.E_MANAGER:add_event(Event({
                func = function()
                    RIFTRAFT.reset_abyss_joker(card)
                    return true
                end
            }))
        end

        return effect
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if not card then
            return SMODS.Joker.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        end

        RIFTRAFT.call_abyss_joker(card, function()
            local void_loc_vars, void_main_start, void_main_end = card:generate_UIBox_ability_table(true)

            local prev_name = full_UI_table.name
            full_UI_table.name = prev_name or true

            generate_card_ui(card.config.center, full_UI_table, void_loc_vars, card.ability.set or "None", nil, false, void_main_start, void_main_end, card)

            full_UI_table.name = prev_name
        end)

        return SMODS.Joker.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
    end
}
SMODS.Joker{
    key = "overflow",
    loc_txt = {
        name = "Overflow",
        text = {
            "Creating a card with no",
            "available card slots",
            "sends it to the {C:riftraft_void}Void{}",
        },
    },
    config = {},
    atlas = "RiftJokers",
    pos = {x = 2, y = 2},
    rarity = 3,
    cost = 9,
    blueprint_compat = false,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.riftraft_overflow = (G.GAME.riftraft_overflow or 0) + 1
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.riftraft_overflow = (G.GAME.riftraft_overflow or 1) - 1
    end,
}

-----------------------------------
-- (Negative Playing Cards Only) --
-----------------------------------

if RIFTRAFT.negative_playing_cards then
    SMODS.Joker{
        key = "painter",
        loc_txt = {
            name = "Artist",
            text = {
                "{C:mult}+#1#{} Mult per",
                "hand size above #2#",
                "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
            },
        },
        config = {
            extra = {size = 5, mult = 0, mult_gain = 4},
        },
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.mult_gain, card.ability.extra.size, card.ability.extra.mult}}
        end,
        atlas = "RiftJokers",
        pos = {x = 4, y = 0},
        rarity = 1,
        cost = 4,
        blueprint_compat = true,
        update = function(self, card, dt)
            card.ability.extra.mult = card.ability.extra.mult_gain * math.max((G.hand and G.hand.config.card_limit or 8) - 5, 0)
        end,
        calculate = function(self, card, context)
            if context.cardarea == G.jokers and context.joker_main then
                return {mult = card.ability.extra.mult}
            end
        end,
    }
    SMODS.Joker{
        key = "backwards",
        loc_txt = {
            name = "Backwards",
            text = {
                "For each {C:dark_edition}Negative{} card",
                "scored, {C:red}lose{} its Chips, then",
                "gain its Chips as Mult",
            },
        },
        config = {},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
            return {}
        end,
        atlas = "RiftJokers",
        pos = {x = 0, y = 1},
        rarity = 2,
        cost = 6,
        blueprint_compat = false,
        in_pool = function(self, args)
            for k, v in pairs(G.playing_cards) do
                if v.edition and v.edition.negative then
                    return true
                end
            end
            return false
        end,
        add_to_deck = function(self, card, from_debuff)
            G.GAME.j_riftraft_backwards = (G.GAME.j_riftraft_backwards or 0) + 1
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.GAME.j_riftraft_backwards = (G.GAME.j_riftraft_backwards or 1) - 1
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and not context.blueprint then
                local played = context.other_card
                if played.edition and played.edition.negative then
                    local chips = played:get_chip_bonus()
                    local _hand_chips = to_number and to_number(hand_chips) or hand_chips
                    return {
                        chips = math.max(-chips, -(_hand_chips - 1)),
                        mult = chips,
                    }
                end
            end
        end,
    }
    -- local card_getchips = Card.get_chip_bonus
    -- function Card:get_chip_bonus()
    --     local orig_chips = card_getchips(self)
    --     if (G.GAME.j_riftraft_backwards or 0) > 0 then
    --         local _hand_chips = to_number and to_number(hand_chips) or hand_chips
    --         return math.max(-orig_chips, -(_hand_chips - 1))
    --     end
    --     return orig_chips
    -- end
    SMODS.Joker{
        key = "tupperware",
        loc_txt = {
            name = "Tupperware",
            text = {
                "{C:red}#1#{} hand size",
                "All cards held in hand",
                "at end of round",
                "become {C:dark_edition}Negative{}"
            },
        },
        config = {h_size = -2},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
            return {vars = {card.ability.h_size}}
        end,
        atlas = "RiftJokers",
        pos = {x = 5, y = 1},
        rarity = 3,
        cost = 8,
        blueprint_compat = false,
        calculate = function(self, card, context)
            if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.5,
                    func = function()
                        for i,v in ipairs(G.hand.cards) do
                            v:set_edition({negative = true}, true, i ~= 1)
                            v:juice_up(0.3, 0.3)
                        end
                        return true
                    end,
                }))
            end
        end,
    }
    SMODS.Joker{
        key = "carrythetwo",
        loc_txt = {
            name = "Carry The 2",
            text = {
                "If {C:attention}poker hand{} is a",
                "{C:attention}#1#{}, turn the",
                "lowest ranking card",
                "{C:dark_edition}Negative{}",
            },
        },
        config = {
            extra = {poker_hand = "Straight Flush"},
        },
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
            return {vars = {localize(card.ability.extra.poker_hand, 'poker_hands')}}
        end,
        atlas = "RiftJokers",
        pos = {x = 3, y = 2},
        rarity = 2,
        cost = 6,
        blueprint_compat = false,
        calculate = function(self, card, context)
            if context.after and context.cardarea == G.jokers and next(context.poker_hands[card.ability.extra.poker_hand]) and not context.blueprint then
                local lowest
                for i,v in ipairs(context.scoring_hand) do
                    if not lowest or (SMODS.Ranks[v.base.value].id <= SMODS.Ranks[lowest.base.value].id) then
                        lowest = v
                    end
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.5,
                    func = function()
                        lowest:set_edition({negative = true}, true)
                        lowest:juice_up(0.3, 0.3)
                        return true
                    end,
                }))
            end
        end,
    }
end

---------------
-- Legendary --
---------------
local function check_creation_area_requirements(card, area)
    return RIFTRAFT.check_valid_creation_area(area)
        and (not RIFTRAFT.is_area_limited(area)
        or #area.cards < area.config.card_limit + RIFTRAFT.get_extra_card_limit(card)
        or RIFTRAFT.can_creation_overflow(area))
end
local function add_event_immediate(offset, event)
    if not RIFTRAFT.e_manager_index then
        G.E_MANAGER:add_event(event)
    else
        table.insert(G.E_MANAGER.queues.base, RIFTRAFT.e_manager_index + offset, event)
    end
end
SMODS.Joker{
    key = "riftraft",
    loc_txt = {
        name = "Rift-Raft",
        text = {
            "All cards created by {C:attention}card{}",
            "{C:attention}effects{} are created {C:attention}again{}",
        },
    },
    config = {
        extra = {amount = 1},
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.amount}}
    end,
    atlas = "RiftJokers",
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    rarity = 4,
    cost = 20,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.riftraft_pre_creation then
            local buffer = RIFTRAFT.get_creation_buffer(context.riftraft_pre_creation_type)
            local extras = context.riftraft_pre_creation_amount

            RIFTRAFT.set_creation_buffer(context.riftraft_pre_creation_type, buffer + extras)

            return nil, true

        elseif context.riftraft_creation and not context.riftraft_creation.from_copy then
            local _card = context.riftraft_creation.card
            local area = context.riftraft_creation.area

            -- fail conditions:
                -- trying to copy another riftraft (can lead to infinite loops and crashes)
                -- trying to copy a voucher (has a really weird interaction in cryptid)
                -- area isn't valid for copying (check against a manually constructed list that excludes eg. shop card areas)
                -- area is full (and we don't have overflow)
            if _card.config.center.key == "j_riftraft_riftraft"
            or _card.ability.set == 'Voucher'
            or not check_creation_area_requirements(_card, area) then
                return nil, true
            end

            local add_to_deck = RIFTRAFT.should_area_add_to_deck(area)
            local playing_card = _card.ability.set == "Default" or _card.ability.set == "Enhanced"

            if playing_card then
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            end

            local prev_skip_calc = RIFTRAFT.creation_skip_calc
            RIFTRAFT.creation_skip_calc = true

            local new_card = copy_card(_card, nil, nil, playing_card and G.playing_card)
            new_card.states.visible = false

            RIFTRAFT.creation_skip_calc = prev_skip_calc

            if add_to_deck then
                if _card.added_to_deck then
                    new_card:add_to_deck()
                end

                if playing_card then
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, new_card)
                end
            end

            area:emplace(new_card)

            add_event_immediate(1, Event({
                trigger = "after",
                delay = 0.6,
                blockable = false,
                func = function() return true end
            }))
            add_event_immediate(2, Event({
                trigger = "before",
                delay = 0.6,
                func = function()
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_again_ex'), instant = true})

                    copy_card(_card, new_card)
                    if add_to_deck and _card.added_to_deck and not new_card.add_to_deck then                        
                        new_card:add_to_deck()
                    end
                    new_card:start_materialize()

                    return true
                end
            }))

            if playing_card then
                playing_card_joker_effects({new_card})
            end

            return nil, true
        end
    end,
}

if next(SMODS.find_mod('Cryptid')) then
    local said_erased = false
    local function destroy_negative(card, flower)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                card:start_dissolve({G.C.WHITE, HEX("cdedf4"), HEX("a9d0d9")})
                G.jokers.config.card_limit = G.jokers.config.card_limit + flower.ability.extra.slots
                if card.area == G.hand then
                    SMODS.calculate_context({remove_playing_cards = true, removed = {card}})
                end
                return true
            end,
        }))
        if not said_erased then
            said_erased = true
            G.E_MANAGER:add_event(Event({
                -- trigger = 'after',
                -- delay = 0.2,
                trigger = 'immediate',
                func = function()
                    said_erased = false
                    card_eval_status_text(flower, 'extra', nil, nil, nil, {message = "Erased", colour = G.C.DARK_EDITION})
                    return true
                end,
            }))
        end
    end
    SMODS.Joker{
        key = "paleflower",
        loc_txt = {
            name = "Me'hon",
            text = {
                "If a {C:dark_edition}Negative{} card or booster pack",
                "appears, {C:attention}destroy{} it and {C:attention}permanently{}",
                "gain {C:dark_edition}+#1# {C:attention}Joker{} slots",
                "Fills empty {C:attention}Joker{} slots with {C:attention}copies{}",
                "of owned {C:attention}Jokers{} at start of round",
                "{s:0.8,C:inactive}Will not copy Me'hon, cannot become Negative{}"
            },
        },
        config = {extra = {slots = 2}},
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.slots, card.ability.extra.emult}}
        end,
        atlas = "RiftJokers",
        pos = {x = 0, y = 3},
        soul_pos = {x = 2, y = 3, extra = {x = 1, y = 3}},
        rarity = "cry_exotic",
	    cost = 50,
        blueprint_compat = false,
        add_to_deck = function(self, card, from_debuff)
            for k,v in ipairs(G.jokers.cards) do
                if v.edition and v.edition.negative and (not v.ability or not v.ability.eternal) then
                    destroy_negative(v, card)
                end
            end
            for k,v in ipairs(G.consumeables.cards) do
                if v.edition and v.edition.negative and (not v.ability or not v.ability.eternal) then
                    destroy_negative(v, card)
                end
            end
        end,
        calculate = function(self, card, context)
            if context.setting_blind and context.cardarea == G.jokers and not context.repetition and not context.blueprint then
                local copy_pool, copy_i = nil, nil
                for i=1,(G.jokers.config.card_limit - #G.jokers.cards) do
                    if not copy_pool then
                        copy_pool = {}
                        copy_i = 1
                        for k,v in ipairs(G.jokers.cards) do
                            if not v.config or v.config.center.key ~= 'j_riftraft_paleflower' then
                                copy_pool[#copy_pool+1] = v
                            end
                        end
                        if #copy_pool == 0 then break end
                        pseudoshuffle(copy_pool, pseudoseed('paleflower'))
                    end
                    local to_copy = copy_pool[copy_i]
                    if to_copy then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_card = copy_card(to_copy)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                                return true
                            end,
                        }))
                    end
                    copy_i = copy_i + 1
                    if copy_i > #copy_pool then copy_pool = nil end
                end
                -- orig behavior: ^1.1 mult for each empty joker slot
                -- return {
                --     func = function()
                --         for i=1,(G.jokers.config.card_limit - #G.jokers.cards) do
                --             SMODS.calculate_individual_effect({card = card, emult_message = {
                --                 message = localize({
                --                     type = "variable",
                --                     key = "a_powmult",
                --                     vars = {
                --                         number_format(card.ability.extra.emult),
                --                     }
                --                 }),
                --                 colour = G.C.DARK_EDITION,
                --                 sound = 'talisman_emult', -- idk why i have to implement all of this manually i think i'm doing something wrong
                --             }}, card, "e_mult", card.ability.extra.emult)
                --             percent = (percent or 0) + (percent_delta or 0.08)
                --         end
                --     end,
                -- }
            end
        end,
    }

    local valid_areas = {'jokers', 'hand', 'shop_jokers', 'shop_booster', 'consumeables', 'pack_cards'}
    local card_add = Card.set_card_area
    function Card:set_card_area(area)
        card_add(self, area)
        local flower = SMODS.find_card("j_riftraft_paleflower")[1]
        if self.edition and self.edition.negative and (not self.ability or not self.ability.eternal) and flower then
            local is_valid = false
            for k,v in ipairs(valid_areas) do
                if area == G[v] then is_valid = true; break end
            end
            if is_valid then
                destroy_negative(self, flower)
            end
        end
    end

    local card_set_edition = Card.set_edition
    function Card:set_edition(edition, immediate, silent)
        if self.config and self.config.center.key == 'j_riftraft_paleflower' and edition and edition.negative then
            if not silent then
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = self,
                    backdrop_colour = G.C.DARK_EDITION,
                    align = 'bm',
                    offset = {x = 0, y = 0.2},
                    silent = true
                })
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4)
                    return true
                end}))
                play_sound('tarot2', 1, 0.4)
                self:juice_up(0.3, 0.5)
            end
            return
        end
        card_set_edition(self, edition, immediate, silent)
        local flower = SMODS.find_card("j_riftraft_paleflower")[1]
        if self.area and self.edition and self.edition.negative and (not self.ability or not self.ability.eternal) and flower then
            destroy_negative(self, flower)
        end
    end
end

--------------
-- Stickers --
--------------
SMODS.Sticker{
    key = "negative_clear",
    loc_txt = {
        name = "Negative Sticker",
        text = {
            "Won with a {C:dark_edition}Negative{}",
            "edition of this Joker",
        },
    },
    atlas = "RiftEnhance",
    pos = {x = 2, y = 0},
    sets = {["Joker"] = true},
    rate = 0,
    hide_badge = true,
    draw = function(self, card, layer)
        G.shared_stickers[self.key].role.draw_major = card
        G.shared_stickers[self.key]:draw_shader('dissolve', nil, nil, nil, card.children.center)
        G.shared_stickers[self.key]:draw_shader('negative', nil, card.ARGS.send_to_shader, nil, card.children.center)
        G.shared_stickers[self.key]:draw_shader('negative_shine', nil, card.ARGS.send_to_shader, nil, card.children.center)
    end,
    no_collection = true,
}
SMODS.Sticker{
    key = "duplicate_clear",
    loc_txt = {
        name = "Duplication Sticker",
        text = {
            "Won with {C:attention}more than{}",
            "{C:attention}one{} of this Joker",
        },
    },
    atlas = "RiftEnhance",
    pos = {x = 3, y = 0},
    sets = {["Joker"] = true},
    rate = 0,
    hide_badge = true,
    draw = function(self, card, layer)
        G.shared_stickers[self.key].role.draw_major = card
        G.shared_stickers[self.key]:draw_shader('dissolve', nil, nil, nil, card.children.center)
        G.shared_stickers[self.key]:draw_shader('negative', nil, card.ARGS.send_to_shader, nil, card.children.center)
        G.shared_stickers[self.key]:draw_shader('negative_shine', nil, card.ARGS.send_to_shader, nil, card.children.center)
    end,
    no_collection = true,
}
function RIFTRAFT.get_win_sticker(center)
    if G.PROFILES[G.SETTINGS.profile].joker_usage[center.key] then
        local index = G.PROFILES[G.SETTINGS.profile].joker_usage[center.key].riftraft_win_key
        if index and index > 0 then
            return (index == 1 and 'riftraft_negative_clear') or (index == 2 and 'riftraft_duplicate_clear')
        end
    end
end