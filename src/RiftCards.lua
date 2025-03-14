SMODS.ConsumableType{
    key = "Rift",
    primary_colour = HEX("c4dade"),
    secondary_colour = HEX("526469"),
    loc_txt = {
        name = "Rift",
        collection = "Rift Cards",
        undiscovered = {
            name = "Not Discovered",
            text = {
                "Purchase or use",
                "this card in an",
                "unseeded run to",
                "learn what it does",
            },
        },
    },
    default = "c_riftraft_canyon",
    collection_rows = {5,6},
    create_UIBox_your_collection = function(self)
        local type_buf = {}
        for _, v in ipairs(SMODS.ConsumableType.ctype_buffer) do
            if not v.no_collection and (not G.ACTIVE_MOD_UI or modsCollectionTally(G.P_CENTER_POOLS[v]).of > 0) then type_buf[#type_buf + 1] = v end
        end
        return SMODS.card_collection_UIBox(G.P_CENTER_POOLS[self.key], self.collection_rows, {
            back_func = #type_buf>3 and 'your_collection_consumables' or nil
        })
    end,
    shop_rate = 0, -- can be increased with the Wormhole voucher
}
RIFTRAFT.RiftCard = SMODS.Consumable:extend {
    set = 'Rift',
    atlas = 'riftraft_RiftCards',
    set_ability = function(self, card, initial, delay_sprites)
        if not card.edition then
            card:set_edition({negative = true}, true, true)
        end
    end
}

RIFTRAFT.RiftCard{
    key = "decay",
    loc_txt = {
        name = "Decay",
        text = {
            "Retrieve up to",
            "{C:attention}#1#{} {C:attention}Consumables{}",
            "from the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 3},
    },
    pos = {x = 1, y = 0},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and G.riftraft_void:has_card_types_in().consumeable then
            return true
        end
        return false
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            if not v.ability.consumeable then return false end
        end
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            v:add_to_deck()
            draw_card(G.riftraft_rifthand, G.consumeables, i*100/#G.riftraft_rifthand.highlighted, "up", false, v)
            G.GAME.used_jokers[v.config.center.key] = true
            table.insert(added, v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({remove_from_void = true, added = added})
            return true
        end}))
    end,
}
if RIFTRAFT.negative_playing_cards then
    RIFTRAFT.RiftCard{
        key = "cipher",
        loc_txt = {
            name = "Cipher",
            text = {
                "Retrieve {C:attention}#1#{} random {C:attention}Playing{}",
                "{C:attention}Cards{} from the {C:riftraft_void}Void{} hand",
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.extra.select,
                }
            }
        end,
        config = {
            extra = {select = 5},
        },
        pos = {x = 2, y = 0},
        cost = 1,
        in_pool = function(self, args)
            if G.riftraft_void and G.riftraft_void:has_card_types_in().playing_card then
                return true
            end
            return false
        end,
        can_use = function(self, card)
            if not RIFTRAFT.in_void_pack() then return false end
            for i,v in ipairs(G.riftraft_rifthand.cards) do
                if v.ability.set == "Default" or v.ability.set == "Enhanced" then
                    return true
                end
            end
            return false
        end,
        use = function(self, card, area)
            local selected_cards = {}
            local temp_hand = {}
            for i,v in ipairs(G.riftraft_rifthand.cards) do
                if v.ability.set == "Default" or v.ability.set == "Enhanced" then
                    temp_hand[#temp_hand+1] = v
                end
            end
            pseudoshuffle(temp_hand, pseudoseed('cipher'))
            local added = {}
            for i=1,math.min(card.ability.extra.select, #temp_hand) do
                local v = temp_hand[i]
                v:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, v)
                table.insert(added, v)
                draw_card(G.riftraft_rifthand, G.deck, i*100/#G.riftraft_rifthand.cards, "up", false, v)
            end
            G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                playing_card_joker_effects(added)
                SMODS.calculate_context({remove_from_void = true, added = added})
                return true
            end}))
        end,
    }
end
RIFTRAFT.RiftCard{
    key = "facade",
    loc_txt = {
        name = "Facade",
        text = {
            "Retrieve {C:attention}#1#{} selected",
            "{C:attention}Joker{} from the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 1},
    },
    pos = {x = 3, y = 0},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and G.riftraft_void:has_card_types_in().joker then
            return true
        end
        return false
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            if v.ability.set ~= "Joker" then return false end
        end
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            v:add_to_deck()
            draw_card(G.riftraft_rifthand, G.jokers, 1, "up", false, v)
            G.GAME.used_jokers[v.config.center.key] = true
            table.insert(added, v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({remove_from_void = true, added = added})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "static",
    loc_txt = {
        name = "Static",
        text = {
            "Retrieve up to {C:attention}#1# random{}",
            "cards from the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 3},
    },
    pos = {x = 1, y = 2},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        return #G.riftraft_rifthand.cards > 0
    end,
    use = function(self, card, area)
        -- orig version: create a copy of a card not in void hand
        -- local temp_hand = {}
        -- for k, v in ipairs(G.riftraft_void.cards) do temp_hand[#temp_hand+1] = v end
        -- pseudoshuffle(temp_hand, pseudoseed('static'))
        -- local v = temp_hand[1]

        -- local new_card = copy_card(v)
        -- new_card:add_to_deck()
        -- local added_playing = {}
        -- if new_card.ability.consumeable then
        --     G.consumeables:emplace(new_card)
        --     new_card:hard_set_VT()
        --     new_card:start_materialize()
        -- elseif new_card.ability.set == "Default" or new_card.ability.set == "Enhanced" then
        --     G.deck.config.card_limit = G.deck.config.card_limit + 1
        --     table.insert(G.playing_cards, new_card)
        --     table.insert(added_playing, new_card)
        --     G.riftraft_rifthand:emplace(new_card)
        --     new_card:start_materialize()
        --     G.E_MANAGER:add_event(Event({
        --         trigger = 'after',
        --         delay = 0.0,
        --         func = function()
        --             draw_card(G.riftraft_rifthand, G.deck, nil,'down', nil, new_card, 0.08)
        --             return true
        --         end
        --     }))
        -- elseif new_card.ability.set == "Joker" then
        --     G.jokers:emplace(new_card)
        --     new_card:hard_set_VT()
        --     new_card:start_materialize()
        -- end
        -- playing_card_joker_effects(added_playing)

        local temp_hand = {}
        for k, v in ipairs(G.riftraft_rifthand.cards) do temp_hand[#temp_hand+1] = v end
        pseudoshuffle(temp_hand, pseudoseed('static'))

        local added = {}
        local added_playing = {}
        for i=1, math.min(#temp_hand, card.ability.extra.select) do
            local v = temp_hand[i]
            v:add_to_deck()
            if v.ability.consumeable then
                draw_card(G.riftraft_rifthand, G.consumeables, 1, "up", false, v)
                G.GAME.used_jokers[v.config.center.key] = true
            elseif v.ability.set == "Default" or v.ability.set == "Enhanced" then
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, v)
                table.insert(added_playing, v)
                draw_card(G.riftraft_rifthand, G.deck, 1, "up", false, v)
            elseif v.ability.set == "Joker" then
                draw_card(G.riftraft_rifthand, G.jokers, 1, "up", false, v)
                G.GAME.used_jokers[v.config.center.key] = true
            end
            table.insert(added, v)
        end
        playing_card_joker_effects(added_playing)
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({remove_from_void = true, added = added})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "wither",
    loc_txt = {
        name = "Wither",
        text = {
            "{C:attention}Instantly{} use up to",
            "{C:attention}#1#{} selected {C:attention}Consumables{}",
            "from the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 5},
    },
    pos = {x = 3, y = 2},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void then
            for i,v in ipairs(G.riftraft_void:get_next_cards()) do
                if v.ability.consumeable and v:can_use_consumeable(true, true) then
                    return true
                end
            end
        end
        return false
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            if not v.ability.consumeable then return false end
            if not v:can_use_consumeable(true) then return false end
        end
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            v:use_consumeable(v.area)
            SMODS.calculate_context({using_consumeable = true, consumeable = card, area = card.from_area})
            table.insert(added, v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            for i,v in ipairs(added) do
                v:start_dissolve(nil, i > 1)
            end
            SMODS.calculate_context({remove_from_void = true, added = added})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "mimicry",
    loc_txt = {
        name = "Mimicry",
        text = {
            "Retrieve a {C:attention}non-{C:dark_edition}Negative{}",
            "{C:attention}copy{} of {C:attention}any{} selected",
            "card from the {C:riftraft_void}Void{} hand",
            "{C:inactive}(Must have room){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "e_negative_generic", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {}
    end,
    config = {},
    pos = {x = 4, y = 0},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if #G.riftraft_rifthand.highlighted ~= 1 then return false end
        local v = G.riftraft_rifthand.highlighted[1]
        if v.ability.consumeable then return #G.consumeables.cards < G.consumeables.config.card_limit or RIFTRAFT.can_creation_overflow(G.consumeables) end
        if v.ability.set == "Default" or v.ability.set == "Enhanced" then return true end
        if v.ability.set == "Joker" then return #G.jokers.cards < G.jokers.config.card_limit or RIFTRAFT.can_creation_overflow(G.jokers) end
        return false
    end,
    use = function(self, card, area)
        local v = G.riftraft_rifthand.highlighted[1]
        local new_card = copy_card(v, nil, nil, nil, true)
        new_card:add_to_deck()
        local added_playing = {}
        if new_card.ability.consumeable then
            G.consumeables:emplace(new_card)
            new_card:hard_set_VT()
            new_card:start_materialize()
        elseif new_card.ability.set == "Default" or new_card.ability.set == "Enhanced" then
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, new_card)
            table.insert(added_playing, new_card)
            G.riftraft_rifthand:emplace(new_card)
            new_card:start_materialize()
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.0,
                func = function()
                    draw_card(G.riftraft_rifthand, G.deck, nil,'down', nil, new_card, 0.08)
                    return true
                end
            }))
        elseif new_card.ability.set == "Joker" then
            G.jokers:emplace(new_card)
            new_card:hard_set_VT()
            new_card:start_materialize()
        end
        playing_card_joker_effects(added_playing)
    end,
}
RIFTRAFT.RiftCard{
    key = "moment",
    loc_txt = {
        name = "Moment",
        text = {
            "Create a copy",
            "of {C:attention}#1#{} random cards",
            "in the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
            }
        }
    end,
    config = {
        extra = {amount = 5},
    },
    pos = {x = 5, y = 0},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        return #G.riftraft_rifthand.cards > 0
    end,
    use = function(self, card, area)
        -- based on immolate code
        local temp_hand = {}
        for k, v in ipairs(G.riftraft_rifthand.cards) do temp_hand[#temp_hand+1] = v end
        pseudoshuffle(temp_hand, pseudoseed('moment'))
        local first_dissolve = false
        local added = {}
        for i=1, math.min(#temp_hand, card.ability.extra.amount) do
            local v = temp_hand[i]
            local new_card = copy_card(v)
            G.riftraft_rifthand:emplace(new_card)
            new_card:start_materialize(nil, first_dissolve)
            first_dissolve = true
            table.insert(added, v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "shell",
    loc_txt = {
        name = "Shell",
        text = {
            "Create {C:attention}#1#{} copies of",
            "{C:attention}#2#{} selected card",
            "in the {C:riftraft_void}Void{} hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {amount = 2, select = 1},
    },
    pos = {x = 6, y = 0},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            local first_dissolve = false
            for i=1, card.ability.extra.amount do
                local new_card = copy_card(v)
                G.riftraft_rifthand:emplace(new_card)
                new_card:start_materialize(nil, first_dissolve)
                first_dissolve = true
                table.insert(added, new_card)
            end
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "loss",
    loc_txt = {
        name = "Loss",
        text = {
            "Add {C:attention}#1#{} random {C:tarot}Tarot{}",
            "cards to the {C:riftraft_void}Void{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
            }
        }
    end,
    config = {
        extra = {amount = 5},
    },
    pos = {x = 1, y = 1},
    cost = 1,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i=1, card.ability.extra.amount do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                play_sound('timpani')
                local new_card = create_card('Tarot', G.riftraft_rifthand, nil, nil, nil, nil, nil, 'loss')
                new_card:set_edition({negative = true}, true, true)
                G.riftraft_rifthand:emplace(new_card)
                card:juice_up(0.3, 0.5)
                table.insert(added, new_card)
                return true
            end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        if not RIFTRAFT.in_void_pack() then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                for i,v in ipairs(G.riftraft_rifthand.cards) do
                    draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                end
                return true
            end}))
        end
    end,
}
RIFTRAFT.RiftCard{
    key = "crater",
    loc_txt = {
        name = "Crater",
        text = {
            "Add {C:attention}#1#{} {C:planet}Planet{} cards for",
            "your {C:attention}most played{} hand",
            "to the {C:riftraft_void}Void{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
            }
        }
    end,
    config = {
        extra = {amount = 3},
    },
    pos = {x = 2, y = 1},
    cost = 1,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area)
        local _planet, _hand, _tally = nil, nil, 0
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                _hand = v
                _tally = G.GAME.hands[v].played
            end
        end
        if _hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == _hand then
                    _planet = v.key
                end
            end
        end
        local added = {}
        for i=1, card.ability.extra.amount do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                play_sound('timpani')
                local new_card = create_card("Planet", G.riftraft_rifthand, nil, nil, true, true, _planet, 'crater')
                new_card:set_edition({negative = true}, true, true)
                G.riftraft_rifthand:emplace(new_card)
                card:juice_up(0.3, 0.5)
                table.insert(added, new_card)
                return true
            end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        if not RIFTRAFT.in_void_pack() then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                for i,v in ipairs(G.riftraft_rifthand.cards) do
                    draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                end
                return true
            end}))
        end
    end,
}
RIFTRAFT.RiftCard{
    key = "banishment",
    loc_txt = {
        name = "Banishment",
        text = {
            "Add {C:attention}#1#{} random {C:spectral}Spectral{}",
            "cards to the {C:riftraft_void}Void{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
            }
        }
    end,
    config = {
        extra = {amount = 3},
    },
    pos = {x = 3, y = 1},
    cost = 1,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i=1, card.ability.extra.amount do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                play_sound('timpani')
                local new_card = create_card('Spectral', G.riftraft_rifthand, nil, nil, nil, nil, nil, 'banish')
                new_card:set_edition({negative = true}, true, true)
                G.riftraft_rifthand:emplace(new_card)
                card:juice_up(0.3, 0.5)
                table.insert(added, new_card)
                return true
            end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        if not RIFTRAFT.in_void_pack() then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                for i,v in ipairs(G.riftraft_rifthand.cards) do
                    draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                end
                return true
            end}))
        end
    end,
}
if next(SMODS.find_mod('Cryptid')) then
    RIFTRAFT.RiftCard{
        key = "null",
        loc_txt = {
            name = "Null",
            text = {
                "Add {C:attention}#1#{} random {C:cry_code}Code{}",
                "{C:cry_code}Cards{} to the {C:riftraft_void}Void{}",
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.extra.amount,
                }
            }
        end,
        config = {
            extra = {amount = 3},
        },
        pos = {x = 8, y = 2},
        cost = 1,
        can_use = function(self, card)
            return true
        end,
        use = function(self, card, area)
            local added = {}
            for i=1, card.ability.extra.amount do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                    play_sound('timpani')
                    local new_card = create_card('Code', G.riftraft_rifthand, nil, nil, nil, nil, nil, 'null')
                    new_card:set_edition({negative = true}, true, true)
                    G.riftraft_rifthand:emplace(new_card)
                    card:juice_up(0.3, 0.5)
                    table.insert(added, new_card)
                    return true
                end}))
            end
            G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                SMODS.calculate_context({add_to_void = true, added = added})
                return true
            end}))
            if not RIFTRAFT.in_void_pack() then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                    for i,v in ipairs(G.riftraft_rifthand.cards) do
                        draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                    end
                    return true
                end}))
            end
        end,
    }
end
RIFTRAFT.RiftCard{
    key = "solitude",
    loc_txt = {
        name = "Solitude",
        text = {
            "Add {C:attention}#1#{} random Joker",
            "to the {C:riftraft_void}Void{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
            }
        }
    end,
    config = {
        extra = {amount = 1},
    },
    pos = {x = 2, y = 2},
    cost = 1,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area)
        local added = {}
        for i=1, card.ability.extra.amount do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                local new_card = create_card('Joker', G.riftraft_rifthand, nil, nil, nil, nil, nil, 'sol')
                new_card:set_edition({negative = true}, true, true)
                G.riftraft_rifthand:emplace(new_card)
                card:juice_up(0.3, 0.5)
                table.insert(added, new_card)
            return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        if not RIFTRAFT.in_void_pack() then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                for i,v in ipairs(G.riftraft_rifthand.cards) do
                    draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                end
                return true
            end}))
        end
    end,
}
RIFTRAFT.RiftCard{
    key = "ditch",
    loc_txt = {
        name = "Ditch",
        text = {
            "Trade {C:attention}#1#{} {C:attention}owned{} Joker for",
            "{C:attention}#1# {C:riftraft_void}Void{} Joker of {C:attention}equal rarity{}",
            "{C:inactive}(Swaps editions){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 1},
    },
    pos = {x = 6, y = 2},
    cost = 1,
    in_pool = function(self, args)
        if not G.jokers or #G.jokers.cards == 0 then return false end
        return G.riftraft_void and G.riftraft_void:has_card_types_in().joker
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.jokers.highlighted == 0) or (#G.jokers.highlighted > card.ability.extra.select) then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        if #G.jokers.highlighted ~= #G.riftraft_rifthand.highlighted then return false end
        for i = 1, card.ability.extra.select do
            if not G.jokers.highlighted[i] then break end
            if G.jokers.highlighted[i].ability and G.jokers.highlighted[i].ability.eternal then return false end
            if G.jokers.highlighted[i].config.center.rarity ~= G.riftraft_rifthand.highlighted[i].config.center.rarity then return false end
        end
        return true
    end,
    use = function(self, card, area)
        local added, removed = {}, {}
        for i = 1, card.ability.extra.select do
            local main_v, void_v = G.jokers.highlighted[i], G.riftraft_rifthand.highlighted[i]
            if not main_v then break end
            local main_edition = main_v.edition
    
            void_v:set_edition(main_edition, true)
            void_v:add_to_deck()
            G.GAME.used_jokers[void_v.config.center.key] = true
            draw_card(G.riftraft_rifthand, G.jokers, 1, "up", false, void_v)
    
            main_v:set_edition({negative = true}, true, true)
            main_v:remove_from_deck()
            G.GAME.used_jokers[main_v.config.center.key] = nil
            draw_card(G.jokers, G.riftraft_rifthand, 1, "down", false, main_v)
    
            table.insert(added, main_v)
            table.insert(removed, void_v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({remove_from_void = true, added = removed})
            return true
        end}))
    end,
}
local joker_tags = {'tag_foil','tag_holo','tag_polychrome','tag_negative','tag_top_up','tag_uncommon','tag_rare'}
if next(SMODS.find_mod('Cryptid')) then
    -- wow cryptid adds a lot of these
    for _,v in ipairs{
        'tag_cry_epic', 'tag_cry_schematic', 'tag_cry_glitched', 'tag_cry_oversat', 'tag_cry_mosaic', 'tag_cry_gold', 'tag_cry_glass', 'tag_cry_blur',
        'tag_cry_astral', 'tag_cry_m', 'tag_cry_double_m', 'tag_cry_banana', 'tag_cry_gourmand', 'tag_cry_bettertop_up',
    } do table.insert(joker_tags, v) end
end
RIFTRAFT.RiftCard{
    key = "amnesia",
    loc_txt = {
        name = "Forget",
        text = {
            "Add {C:attention}all{} owned {C:attention}Jokers{} to the {C:riftraft_void}Void{},",
            "gain a {C:attention}Joker tag{} for each added {C:attention}Joker{}",
            "{C:inactive}(eg. Foil Tag, Uncommon Tag, etc.)",
        }
    },
    config = {},
    pos = {x = 4, y = 2},
    cost = 1,
    in_pool = function(self, args)
        return G.jokers and #G.jokers.cards > 0
    end,
    can_use = function(self, card)
        for k,v in ipairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.ability or not v.ability.eternal) then return true end
        end
        return false
    end,
    use = function(self, card, area)
        local added = {}
        -- G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
        --     for i,v in ipairs(G.jokers.cards) do
        --         if v.ability.set == 'Joker' and (not v.ability or not v.ability.eternal) then
        --             v:set_edition({negative = true}, true, true)
        --             v:remove_from_deck()
        --             draw_card(G.jokers, G.riftraft_rifthand, 1, "down", false, v)
        --             table.insert(added, v)
        --         end
        --     end
        --     return true
        -- end}))
        for i,v in ipairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.ability or not v.ability.eternal) then
                v:set_edition({negative = true}, true, true)
                v:remove_from_deck()
                draw_card(G.jokers, G.riftraft_rifthand, 1, "down", false, v)
                G.GAME.used_jokers[v.config.center.key] = nil
                table.insert(added, v)
            end
        end
        local tag_pool = {}
        for k,key in ipairs(joker_tags) do
            local v = G.P_TAGS[key]
            if not G.GAME.banned_keys[key] and (not v.requires or (G.P_CENTERS[v.requires] and G.P_CENTERS[v.requires].discovered)) and 
            (not v.min_ante or v.min_ante <= G.GAME.round_resets.ante) then
                table.insert(tag_pool, key)
            end
        end
        if #tag_pool == 0 then -- not sure if this is reasonably possible but i'll include it anyway
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = card,
                    backdrop_colour = HEX("526469"),
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0},
                    silent = true
                })
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4)
                    return true
                end}))
                play_sound('tarot2', 1, 0.4)
                card:juice_up(0.3, 0.5)
                return true
            end}))
            return
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
            for i=1,#added do
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        add_tag(Tag(pseudorandom_element(tag_pool, pseudoseed('ditch'))))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end)
                }))
            end
            return true
        end}))

        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            SMODS.calculate_context({add_to_void = true, added = added})
            return true
        end}))
        if not RIFTRAFT.in_void_pack() then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                for i,v in ipairs(G.riftraft_rifthand.cards) do
                    draw_card(G.riftraft_rifthand, G.riftraft_void, nil,'down', nil, v, 0.08)
                end
                return true
            end}))
        end
    end,
}
RIFTRAFT.RiftCard{
    key = "canyon",
    loc_txt = {
        name = "Canyon",
        text={
            "Destroys up to",
            "{C:attention}#1#{} selected cards",
            "from the {C:riftraft_void}Void{} hand",
        },
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 3},
    },
    pos = {x = 0, y = 1},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if (#G.riftraft_rifthand.highlighted == 0) or (#G.riftraft_rifthand.highlighted > card.ability.extra.select) then return false end
        for k,v in ipairs(G.riftraft_rifthand.highlighted) do
            if v.ability and v.ability.eternal then
                return false
            end
        end
        return true
    end,
    use = function(self, card, area)
        local destroyed_cards = {}
        for i,v in ipairs(G.riftraft_rifthand.highlighted) do
            table.insert(destroyed_cards, v)
        end

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function() 
                for i=#destroyed_cards, 1, -1 do
                    local to_break = destroyed_cards[i]
                    if SMODS.has_enhancement(to_break, 'm_glass') then
                        to_break:shatter()
                    else
                        to_break:start_dissolve(nil, i == #destroyed_cards)
                    end
                end
                return true end }))
        delay(0.5)
        for i,v in ipairs(destroyed_cards) do
            RIFTRAFT.check_destroy_for_seal(v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
            SMODS.calculate_context({remove_from_void = true, added = destroyed_cards})
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "oblivion",
    loc_txt = {
        name = "Oblivion",
        text = {
            "Destroys {C:attention}#1#{} random",
            "cards in the {C:riftraft_void}Void{} hand,",
            "adds a random {C:red}Rare{}",
            "{C:attention}Joker{} to the {C:riftraft_void}Void{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
                card.ability.extra.dollars,
            }
        }
    end,
    config = {
        extra = {amount = 5},
    },
    pos = {x = 4, y = 1},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        if #G.riftraft_rifthand.cards == 0 then return false end
        for k,v in ipairs(G.riftraft_rifthand.cards) do
            if not v.ability or not v.ability.eternal then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        -- based on immolate code
        local destroyed_cards = {}
        local temp_hand = {}
        for k, v in ipairs(G.riftraft_rifthand.cards) do
            if not v.ability or not v.ability.eternal then
                temp_hand[#temp_hand+1] = v
            end
        end
        pseudoshuffle(temp_hand, pseudoseed('moment'))

        for i = 1, math.min(card.ability.extra.amount, #temp_hand) do destroyed_cards[#destroyed_cards+1] = temp_hand[i] end

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function() 
                for i=#destroyed_cards, 1, -1 do
                    local to_break = destroyed_cards[i]
                    if SMODS.has_enhancement(to_break, 'm_glass') then
                        to_break:shatter()
                    else
                        to_break:start_dissolve(nil, i == #destroyed_cards)
                    end
                end
                return true end }))
        delay(0.5)
        for i,v in ipairs(destroyed_cards) do
            RIFTRAFT.check_destroy_for_seal(v)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
            SMODS.calculate_context({remove_from_void = true, added = destroyed_cards})
            return true
        end}))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            local new_card = create_card('Joker', G.riftraft_rifthand, nil, 0.99, nil, nil, nil, 'obl')
            new_card:set_edition({negative = true}, true, true)
            G.riftraft_rifthand:emplace(new_card)
            card:juice_up(0.3, 0.5)
        return true end }))
    end,
}
RIFTRAFT.RiftCard{
    key = "absence",
    loc_txt = {
        name = "Absence",
        text = {
            "Destroy every {C:riftraft_void}Void{} card",
            "{C:attention}not{} in hand, gain {C:money}$#1#{}",
            "for every card destroyed",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.dollars,
            }
        }
    end,
    config = {
        extra = {dollars = 2},
    },
    pos = {x = 0, y = 2},
    cost = 1,
    in_pool = function(self, args)
        -- only appear in void packs if there's more cards than your hand size
        if G.riftraft_void and RIFTRAFT.in_void_pack() and ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) <= G.hand.config.card_limit) then
            return false
        end
        return true
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area)
        local destroyed_cards = {}
        for k, v in ipairs(G.riftraft_void.cards) do
            if not v.ability or not v.ability.eternal then
                destroyed_cards[#destroyed_cards+1] = v
            end
        end
        local dollars = #destroyed_cards * card.ability.extra.dollars

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            play_sound('whoosh2', math.random()*0.2 + 0.9,0.5)
            play_sound('crumple'..math.random(1, 5), math.random()*0.2 + 0.9,0.5)
            card:juice_up(0.3, 0.5)
            return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function() 
                for i=#destroyed_cards, 1, -1 do
                    local to_break = destroyed_cards[i]
                    to_break:start_dissolve(nil, true)
                end
                return true end }))
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
            SMODS.calculate_context({remove_from_void = true, added = destroyed_cards})
            return true
        end}))
        ease_dollars(dollars)
    end,
}
RIFTRAFT.RiftCard{
    key = "debt",
    loc_txt = {
        name = "Debt",
        text = {
            "Gives the total sell",
            "value of all cards",
            "in the {C:riftraft_void}Void{} hand",
            "{C:inactive}(Max of {C:money}$#1#{C:inactive},",
            "{C:inactive}currently {C:money}$#2#{C:inactive})",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.max,
                card.ability.extra.current,
            }
        }
    end,
    config = {
        extra = {max = 50, current = 0},
    },
    pos = {x = 5, y = 1},
    cost = 1,
    in_pool = function(self, args)
        if G.riftraft_void and RIFTRAFT.in_void_pack() then
            return ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0)
        end
        return true
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        return true
    end,
    update = function(self, card, dt)
        if not G.riftraft_rifthand then return end
        card.ability.extra.current = 0
        for i,v in ipairs(G.riftraft_rifthand.cards) do
            card.ability.extra.current = card.ability.extra.current + v.sell_cost
        end
        card.ability.extra.current = math.min(card.ability.extra.current, card.ability.extra.max)
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            card:juice_up(0.3, 0.5)
            ease_dollars(card.ability.extra.current, true)
            return true end }))
        delay(0.6)
    end,
}
RIFTRAFT.RiftCard{
    key = "entropy",
    loc_txt = {
        name = "Entropy",
        text = {
            "Discard current {C:riftraft_void}Void{} hand",
            "and redraw",
        }
    },
    config = {},
    pos = {x = 6, y = 1},
    cost = 1,
    in_pool = function(self, args)
        -- only appear in a pack if you have more than 1 card choice
        if SMODS.OPENED_BOOSTER and ((not G.GAME.pack_choices) or G.GAME.pack_choices <= 1) then
            return false
        end
        -- also only appear if there's more cards than your hand can fit
        return G.riftraft_void and ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > G.hand.config.card_limit)
    end,
    can_use = function(self, card)
        if not RIFTRAFT.in_void_pack() then return false end
        return true
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            RIFTRAFT.draw_from_rift_to_void()
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                RIFTRAFT.draw_from_void_to_rift()
                return true
            end}))
            return true
        end}))
    end,
}
RIFTRAFT.RiftCard{
    key = "misfortune",
    loc_txt = {
        name = "Misfortune",
        text = {
            "{C:green}#1# in #2#{} chance to add",
            "{C:dark_edition}Negative{} to a random {C:attention}Joker{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "e_negative", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {
            vars = {
                RIFTRAFT.get_prob(card, card.ability.extra.chance),
                card.ability.extra.chance,
            }
        }
    end,
    config = {
        extra = {chance = 4},
    },
    pos = {x = 5, y = 2},
    cost = 1,
    in_pool = function(self, args)
        return true
    end,
    can_use = function(self, card)
        for k,v in ipairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and not v.edition then return true end
        end
        return false
    end,
    use = function(self, card, area)
        if pseudorandom('wheel_of_fortune') < (RIFTRAFT.get_prob(card, card.ability.extra.chance) / card.ability.extra.chance) then
            local temp_pool = {}
            for k,v in ipairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and not v.edition then
                    table.insert(temp_pool, v)
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                local target = pseudorandom_element(temp_pool, pseudoseed('misfortune'))
                target:set_edition({negative = true}, true)
                card:juice_up(0.3, 0.5)
                return true
            end}))
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = card,
                    backdrop_colour = HEX("526469"),
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0},
                    silent = true
                })
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4)
                    return true
                end}))
                play_sound('tarot2', 1, 0.4)
                card:juice_up(0.3, 0.5)
                return true
            end}))
        end
    end,
}
RIFTRAFT.RiftCard{
    key = "mindless",
    loc_txt = {
        name = "Missing",
        text = {
            "Creates the last",
            "{C:riftraft_void}Rift{} card used",
            "during this run",
            "{s:0.8,C:riftraft_void}Missing{s:0.8} excluded",
        }
    },
    pos = {x = 7, y = 2},
    cost = 1,
    in_pool = function(self, args)
        return true
    end,
    can_use = function(self, card) return (G.GAME.riftraft_last_rift ~= nil and G.GAME.riftraft_last_rift ~= 'c_riftraft_mindless') end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            local new_card = create_card('Rift', G.consumeables, nil, nil, nil, nil, G.GAME.riftraft_last_rift, 'echo')
            new_card:add_to_deck()
            G.consumeables:emplace(new_card)
            card:juice_up(0.3, 0.5)
            return true
        end}))
        delay(0.6)
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        RIFTRAFT.RiftCard.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)

        local rift_c = G.GAME.riftraft_last_rift and G.P_CENTERS[G.GAME.riftraft_last_rift] or nil
        local last_rift = rift_c and localize{type = 'name_text', key = rift_c.key, set = rift_c.set} or localize('k_none')
        if G.GAME.riftraft_last_rift == 'c_riftraft_mindless' then rift_c = nil end
        local colour = not rift_c and G.C.RED or HEX("526469")

        table.insert(desc_nodes, {
            {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                    {n=G.UIT.T, config={text = ' '..last_rift..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                }}
            }}
        })

        if rift_c then
            table.insert(info_queue, rift_c)
        end
    end,
}

--------------
-- SPECTRAL --
--------------

if RIFTRAFT.negative_playing_cards then
    SMODS.Spectral{
        key = "haunt",
        loc_txt = {
            name = "Haunt",
            text = {
                "Add {C:dark_edition}Negative{} edition",
                "to {C:attention}#1#{} selected",
                "card in hand",
            }
        },
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
            return {
                vars = {
                    card.ability.extra.select,
                }
            }
        end,
        config = {
            extra = {select = 1},
        },
        atlas = 'RiftCards',
        pos = {x = 7, y = 0},
        cost = 3,
        can_use = function(self, card)
            if (#G.hand.highlighted == 0) or (#G.hand.highlighted > card.ability.extra.select) then return false end
            return true
        end,
        use = function(self, card, area)
            for i,v in ipairs(G.hand.highlighted) do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    v:set_edition({negative = true}, true)
                    card:juice_up(0.3, 0.5)
                    return true
                end}))
            end
        end,
    }
end
SMODS.Spectral{
    key = "exorcism",
    loc_txt = {
        name = "Exorcism",
        text = {
            "Add a {C:riftraft_void}Black Seal{}",
            "to {C:attention}#1#{} selected",
            "card in your hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "riftraft_rift_seal", set = "Other"}
        return {
            vars = {
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {select = 1},
    },
    atlas = 'RiftCards',
    pos = {x = 8, y = 0},
    cost = 3,
    can_use = function(self, card)
        if (#G.hand.highlighted == 0) or (#G.hand.highlighted > card.ability.extra.select) then return false end
        return true
    end,
    use = function(self, card, area)
        for i,v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                v:set_seal("riftraft_rift", nil, true)
                return true end }))
        end
        
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end,
}
SMODS.Spectral{
    key = "echo",
    loc_txt = {
        name = "Echo",
        text = {
            "Retrieve {C:attention}#1# copy{} of {C:attention}#2#{}",
            "random {C:riftraft_void}Void{} card",
            "{s:0.8}(Cannot retrieve Echo){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amount,
                card.ability.extra.select,
            }
        }
    end,
    config = {
        extra = {amount = 1, select = 1},
    },
    atlas = 'RiftCards',
    pos = {x = 7, y = 1},
    cost = 3,
    can_use = function(self, card)
        for k,v in ipairs(G.riftraft_void.cards) do
            if v.config.center.key ~= 'c_riftraft_echo' then return true end
        end
        for k,v in ipairs(G.riftraft_rifthand.cards) do
            if v.config.center.key ~= 'c_riftraft_echo' then return true end
        end
    end,
    use = function(self, card, area)
        local temp_hand = {}
        for k, v in ipairs(G.riftraft_void.cards) do
            if v.config.center.key ~= 'c_riftraft_echo' then temp_hand[#temp_hand+1] = v end
        end
        for k, v in ipairs(G.riftraft_rifthand.cards) do
            if v.config.center.key ~= 'c_riftraft_echo' then temp_hand[#temp_hand+1] = v end
        end
        pseudoshuffle(temp_hand, pseudoseed('echo'))
        for i=1,card.ability.extra.select do
            local v = temp_hand[i]
            for j=1,card.ability.extra.amount do
                local new_card = copy_card(v)
                new_card:add_to_deck()
                local added_playing = {}
                if new_card.ability.consumeable then
                    G.consumeables:emplace(new_card)
                    new_card:hard_set_VT()
                    new_card:start_materialize()
                elseif new_card.ability.set == "Default" or new_card.ability.set == "Enhanced" then
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, new_card)
                    table.insert(added_playing, new_card)
                    G.riftraft_rifthand:emplace(new_card)
                    new_card:start_materialize()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.0,
                        func = function()
                            draw_card(G.riftraft_rifthand, G.deck, nil,'down', nil, new_card, 0.08)
                            return true
                        end
                    }))
                elseif new_card.ability.set == "Joker" then
                    G.jokers:emplace(new_card)
                    new_card:hard_set_VT()
                    new_card:start_materialize()
                end
                playing_card_joker_effects(added_playing)
            end
        end
    end,
}

SMODS.Spectral{
    key = "dream",
    loc_txt = {
        name = "Dream",
        text = {
            "Retrieve a {C:attention}copy{} of {C:legendary,E:1}every{}",
            "card in the {C:riftraft_void}Void{} hand",
        }
    },
    config = {},
    atlas = 'RiftCards',
    pos = {x = 8, y = 1},
    cost = 3,
    hidden = true,
    soul_set = "Rift",
    soul_rate = 0.003,
    can_use = function(self, card) return true end,
    in_pool = function(self, args)
        -- dont spawn it if theres 0 cards in the void. it would suck
        if not G.riftraft_void or not ((#G.riftraft_void.cards + #G.riftraft_rifthand.cards) > 0) then
            return false
        end
        -- we don't actually want it to be added to spectral packs, only void packs
        return G.STATE ~= G.STATES.SPECTRAL_PACK
    end,
    use = function(self, card, area)
        local copied = {}
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
        for i,v in ipairs(G.riftraft_rifthand.cards) do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                void_copy(v)
                return true
            end}))
        end
        -- also copies cards from void. nerfed it to not do this after some playtesting
        -- for i,v in ipairs(G.riftraft_void.cards) do
        --     G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
        --         void_copy(v)
        --         return true
        --     end}))
        -- end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.0,
            func = function()
                local added_playing = {}
                for i,v in ipairs(copied) do
                    if v.ability.set == "Default" or v.ability.set == "Enhanced" then
                        table.insert(added_playing, v)
                        draw_card(G.riftraft_rifthand, G.deck, nil,'down', nil, v, 0.08)
                    end
                end
                playing_card_joker_effects(added_playing)
                return true
            end
        }))
    end,
}

SMODS.Seal{
    name = "Black Seal",
    key = "rift",
    badge_colour = HEX("526469"),
    loc_txt = {
        label = "Black Seal",
    },
    atlas = "RiftEnhance",
    pos = {x = 0, y = 0},
    draw = function(self, card, layer)
        G.shared_seals[card.seal].role.draw_major = card
        G.shared_seals[card.seal]:draw_shader('negative', nil, card.ARGS.send_to_shader, nil, card.children.center)
    end,
}
RIFTRAFT.check_destroy_for_seal = function(card)
    if card.seal == "riftraft_rift" then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            local new_card = create_card('Rift', G.consumeables)
            new_card:add_to_deck()
            G.consumeables:emplace(new_card)
            return true
        end}))
    end
end