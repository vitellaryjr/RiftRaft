RIFTRAFT = {}

SMODS.Atlas{
    key = 'RiftCards',
    path = 'voidcards_atlas.png',
    px = 71,
    py = 95
}
SMODS.UndiscoveredSprite({
	key = "Rift",
	atlas = "RiftCards",
	path = "voidcards_atlas.png",
	pos = {x = 9, y = 0},
    overlay_pos = {x = 9, y = 1},
	px = 71,
	py = 95,
})
SMODS.Atlas{
    key = 'RiftShop',
    path = 'shop_atlas.png',
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = 'RiftEnhance',
    path = 'enhancements_atlas.png',
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = 'RiftPortal',
    path = 'portal_frames.png',
    px = 71,
    py = 71
}
SMODS.Atlas{
    key = 'RiftTags',
    path = 'tags_atlas.png',
    px = 34,
    py = 34
}
SMODS.Atlas{
    key = 'RiftJokers',
    path = 'joker_atlas.png',
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "modicon",
    path = "mod_icon.png",
    px = 34,
    py = 34
}
SMODS.Gradient{
    key = "void",
    colours = {{0,0,0,1}, HEX("6b8286")},
    cycle = 3,
}

local mod = SMODS.current_mod
local config = mod.config

G.FUNCS.riftraft_voidrate_config = function(e)
    RIFTRAFT.void_pack_rate = e.to_key/5
    config.void_pack_rate = e.to_key
    SMODS.save_mod_config(mod)
end
G.FUNCS.riftraft_allowbuy_config = function(e, save)
    RIFTRAFT.allow_buy_always = e
    if RIFTRAFT.allow_buy_always then
        SMODS.process_loc_text(G.localization.descriptions.Voucher, "v_riftraft_riftshop_send", {
            name = "Wormhole",
            text = {
                "{C:attention}Shop{} cards can be",
                "sent to the {C:riftraft_void}Void{}",
                "for their original",
                "price",
            },
        })
    else
        SMODS.process_loc_text(G.localization.descriptions.Voucher, "v_riftraft_riftshop_send", {
            name = "Wormhole",
            text = {
                "{C:attention}Shop{} cards can be",
                "sent to the {C:riftraft_void}Void{}",
            },
        })
    end
    init_localization()
    if save then SMODS.save_mod_config(mod) end
end

RIFTRAFT.negative_playing_cards = config.negative_cards
RIFTRAFT.void_pack_rate = config.void_pack_rate / 5
G.FUNCS.riftraft_allowbuy_config(config.allow_buy, false)

function RIFTRAFT.in_void_pack()
    local voidpack_prefix = "p_riftraft_voidpack"
    return G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER and SMODS.OPENED_BOOSTER.config.center.key:sub(1, #voidpack_prefix) == voidpack_prefix
end

-- support for talisman / cryptid
to_big = to_big or function(value) return value end
RIFTRAFT.get_prob = function(card, den)
    local num = G.GAME.probabilities.normal
    if cry_prob ~= nil then
        num = cry_prob(card.ability.cry_prob, den, card.ability.cry_rigged)
    end
    return num
end

assert(SMODS.load_file("src/RiftCards.lua"))()
assert(SMODS.load_file("src/VoidPacks.lua"))()
assert(SMODS.load_file("src/Vouchers.lua"))()
assert(SMODS.load_file("src/Jokers.lua"))()
assert(SMODS.load_file("src/Challenges.lua"))()

assert(SMODS.load_file("src/VoidCardArea.lua"))()
assert(SMODS.load_file("src/RiftHand.lua"))()

assert(SMODS.load_file("src/CreationEffects.lua"))()
assert(SMODS.load_file("src/VoidDeckUI.lua"))()

mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, minw = 4, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
        {n = G.UIT.C, config = {r = 0.1, minw = 4, align = "tc", padding = 0.2, colour = G.C.BLACK}, nodes =
            {
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        r = 0.1,
                        emboss = 0.1,
                        outline = 1,
                        padding = 0.2
                    },
                    nodes = {
                        create_toggle({
                            label = localize("c_riftraft_negative_cards"),
                            info = localize("c_riftraft_negative_cards_desc"),
                            ref_table = config,
                            ref_value = 'negative_cards',
                            callback = function() SMODS.save_mod_config(mod) end
                        }),
                        create_option_cycle({
                            label = localize("c_riftraft_voidrate"),
                            info = localize("c_riftraft_voidrate_desc"),
                            options = {"20%", "40%", "60%", "80%", "100%"},
                            ref_table = config,
                            ref_value = 'void_pack_rate',
                            opt_callback = 'riftraft_voidrate_config',
                            current_option = config.void_pack_rate,
                        }),
                        create_toggle({
                            label = localize("c_riftraft_allow_buy"),
                            info = localize("c_riftraft_allow_buy_desc"),
                            ref_table = config,
                            ref_value = 'allow_buy',
                            callback = function(e) G.FUNCS.riftraft_allowbuy_config(e, true) end
                        }),
                    },
                },
            }
        },
    }}
end

local orig_EventManager_update = EventManager.update
function EventManager:update(dt, forced, ...)
    orig_EventManager_update(self, dt, forced, ...)
    RIFTRAFT.e_manager_index = nil
end