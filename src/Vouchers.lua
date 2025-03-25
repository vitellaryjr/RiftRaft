SMODS.Voucher{
    key = "negative_hone",
    loc_txt = {
        name = "Negation",
        text = {
            "{C:dark_edition}Negative{} cards",
            "appear {C:attention}#1#X{} more often",
        },
    },
    loc_vars = function(self, info_queue, voucher)
        info_queue[#info_queue+1] = {key = "e_negative", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {
            vars = {voucher.ability.mult}
        }
    end,
    config = {
        mult = 3,
    },
    atlas = "RiftShop",
    pos = {x = 1, y = 1},
    set_ability = function(self, card, initial, delay_sprites)
        card:set_edition({negative = true}, true, true)
    end,
    redeem = function(self, voucher)
        G.GAME.riftraft_negative_rate = math.max(G.GAME.riftraft_negative_rate or 0, voucher.ability.mult)
    end,
}
local negative_weight = G.P_CENTERS['e_negative'].get_weight
G.P_CENTERS['e_negative'].get_weight = function(center)
    return negative_weight(center) * (G.GAME.riftraft_negative_rate or 1)
end
SMODS.Voucher{
    key = "negative_consume",
    loc_txt = {
        name = "Vastness",
        text = {
            "All shop cards can",
            "be {C:dark_edition}Negative{}",
        },
    },
    loc_vars = function(self, info_queue, voucher)
        info_queue[#info_queue+1] = {key = "e_negative_consumable", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
        return {}
    end,
    atlas = "RiftShop",
    pos = {x = 2, y = 1},
    set_ability = function(self, card, initial, delay_sprites)
        card:set_edition({negative = true}, true, true)
    end,
    requires = {"v_riftraft_negative_hone"},
}

SMODS.Voucher{
    key = "riftshop_retrieve",
    loc_txt = {
        name = "Teleporter",
        text = {
            "{C:riftraft_void}Rift{} cards can",
            "be purchased",
            "from the {C:attention}shop{}",
        },
    },
    atlas = "RiftShop",
    pos = {x = 3, y = 1},
    redeem = function(self, voucher)
        G.GAME.rift_rate = 2 -- same as spectral
    end,
}
SMODS.Voucher{
    key = "riftshop_send",
    -- loc_txt = {
    --     name = "Wormhole",
    --     text = {
    --         "{C:attention}Shop{} cards can be",
    --         "sent to the {C:riftraft_void}Void{}",
    --     },
    -- },
    atlas = "RiftShop",
    pos = {x = 4, y = 1},
    requires = {"v_riftraft_riftshop_retrieve"},
}

SMODS.Voucher{
    key = "booster_plus",
    loc_txt = {
        name = "Gacha",
        text = {
            "{C:attention}+1{} booster pack",
            "per {C:attention}shop{}",
        },
    },
    atlas = "RiftShop",
    pos = {x = 1, y = 2},
    redeem = function(self, voucher)
        G.GAME.modifiers.extra_boosters = (G.GAME.modifiers.extra_boosters or 0) + 1
        -- loosely copied from change_shop_size (used by overstock)
        if not G.GAME.shop then return end
        if G.shop_booster and G.shop_booster.cards then
            G.shop_booster.config.card_limit = G.GAME.starting_params.boosters_in_shop + (G.GAME.modifiers.extra_boosters or 0)
            for i = #G.shop_booster.cards + 1, G.shop_booster.config.card_limit do
                G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key
                local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(card, 'Booster', G.shop_booster)
                card.ability.booster_pos = i
                G.shop_booster:emplace(card)
            end
        end
    end,
}
SMODS.Voucher{
    key = "booster_slut",
    loc_txt = {
        name = "Microtransaction",
        text = {
            -- "Rerolls include",
            -- "booster packs,",
            -- "rerolls increase",
            -- "by {C:money}$3{} {C:red}each{}"
            "{C:attention}+1{} booster pack",
            "per {C:attention}shop{},",
            "shop always has",
            "a {C:riftraft_void}Void{} Pack",
        },
    },
    atlas = "RiftShop",
    pos = {x = 2, y = 2},
    requires = {"v_riftraft_booster_plus"},
    redeem = function(self, voucher)
        G.GAME.modifiers.extra_boosters = (G.GAME.modifiers.extra_boosters or 0) + 1
        -- loosely copied from change_shop_size (used by overstock)
        if not G.GAME.shop then return end
        if G.shop_booster and G.shop_booster.cards then
            G.shop_booster.config.card_limit = G.GAME.starting_params.boosters_in_shop + (G.GAME.modifiers.extra_boosters or 0)
            for i = #G.shop_booster.cards + 1, G.shop_booster.config.card_limit do
                G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key
                local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(card, 'Booster', G.shop_booster)
                card.ability.booster_pos = i
                G.shop_booster:emplace(card)
            end
        end
    end,
}

SMODS.Voucher{
    key = "cardpack_card",
    loc_txt = {
        name = "Card Counting",
        text = {
            "{C:attention}+1{} card per",
            "booster pack",
        },
    },
    atlas = "RiftShop",
    pos = {x = 3, y = 2},
    redeem = function(self, voucher)
        if not G.GAME.shop then return end
        if G.shop_booster and G.shop_booster.cards then
            for _, booster in ipairs(G.shop_booster.cards) do
                booster.ability.extra = (booster.ability.extra or 2) + 1
            end
        end
    end,
}
SMODS.Voucher{
    key = "cardpack_choose",
    loc_txt = {
        name = "Sleight of Hand",
        text = {
            "{C:attention}+1 choice{} per",
            "booster pack",
        },
    },
    atlas = "RiftShop",
    pos = {x = 4, y = 2},
    requires = {"v_riftraft_cardpack_card"},
    redeem = function(self, voucher)
        if not G.GAME.shop then return end
        if G.shop_booster and G.shop_booster.cards then
            for _, booster in ipairs(G.shop_booster.cards) do
                booster.ability.choose = (booster.ability.choose or 1) + 1
            end
        end
    end,
}

-- tier 3s
if next(SMODS.find_mod('Cryptid')) then
    SMODS.Voucher{
        key = "negative_curate",
        loc_txt = {
            name = "Negative Infinity",
            text = {
                "{C:dark_edition}Negative{} cards",
                "appear {C:attention}#1#X{} more often",
            },
        },
        loc_vars = function(self, info_queue, voucher)
            info_queue[#info_queue+1] = {key = "e_negative", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
            return {
                vars = {voucher.ability.mult}
            }
        end,
        config = {
            mult = 30,
        },
        atlas = "RiftShop",
        pos = {x = 1, y = 3},
        set_ability = function(self, card, initial, delay_sprites)
            card:set_edition({negative = true}, true, true)
        end,
        redeem = function(self, voucher)
            G.GAME.riftraft_negative_rate = math.max(G.GAME.riftraft_negative_rate or 0, voucher.ability.mult)
        end,
        requires = {"v_riftraft_negative_consume"},
        dependencies = {
            items = {
                "set_cry_tier3",
            },
        },
        pools = { ["Tier3"] = true },
    }

    SMODS.Voucher{
        key = "riftshop_copy",
        loc_txt = {
            name = "Inversion Invasion",
            text = {
                "Shops may contain",
                "an {C:attention}addtional copy{}",
                "of a {C:riftraft_void}Void{} card",
            },
        },
        atlas = "RiftShop",
        pos = {x = 2, y = 3},
        requires = {"v_riftraft_riftshop_send"},
        dependencies = {
            items = {
                "set_cry_tier3",
            },
        },
        pools = { ["Tier3"] = true },
    }

    SMODS.Voucher{
        key = "booster_gluttony",
        loc_txt = {
            name = "Booster Pass",
            text = {
                "Shops always contain 1",
                "of {C:attention}each{} booster pack type",
            },
        },
        atlas = "RiftShop",
        pos = {x = 3, y = 3},
        requires = {"v_riftraft_booster_slut"},
        dependencies = {
            items = {
                "set_cry_tier3",
            },
        },
        pools = { ["Tier3"] = true },
    }

    SMODS.Voucher{
        key = "cardpack_max",
        loc_txt = {
            name = "Rigged",
            text = {
                "{C:attention}Maximum choices{}",
                "per booster pack",
            },
        },
        atlas = "RiftShop",
        pos = {x = 4, y = 3},
        requires = {"v_riftraft_cardpack_card"},
        redeem = function(self, voucher)
            if not G.GAME.shop then return end
            if G.shop_booster and G.shop_booster.cards then
                for _, booster in ipairs(G.shop_booster.cards) do
                    booster.ability.choose = booster.ability.extra or 2
                end
            end
        end,
    }
end