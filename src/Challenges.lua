SMODS.Back{
    key = "abyssal",
    loc_txt = {
        name = "Abyssal Deck",
        text = {
            "Every booster pack is {C:attention}Mega{}-sized",
            "Every shop contains a {C:riftraft_void}Void{} Pack",
            "{C:red}-1{} booster pack per shop",
        },
    },
    atlas = "RiftEnhance",
    pos = {x = 1, y = 0},
    apply = function(self, back)
        G.GAME.riftraft_abyssal_deck = true
        G.GAME.starting_params.boosters_in_shop = 1
    end,
}

SMODS.Challenge{
    key = "retrieve",
    loc_txt = {name = "Retrieve"},
    rules = {
        custom = {
            {id = "riftraft_no_void"},
            {id = "riftraft_only_retrieval_tag"},
        },
    },
    restrictions = {
        -- banning useless rift cards for the sake of still allowing Teleporter
        banned_cards = {
            {id = "c_riftraft_decay", ids = {"c_riftraft_decay", "c_riftraft_cipher"}},
            {id = "c_riftraft_facade"},
            {id = "c_riftraft_static"},
            {id = "c_riftraft_wither"},
            {id = "c_riftraft_mimicry"},
            {id = "c_riftraft_moment"},
            {id = "c_riftraft_shell"},
            {id = "c_riftraft_amnesia"},
            {id = "c_riftraft_canyon"},
            {id = "c_riftraft_oblivion"},
            {id = "c_riftraft_debt"},
            {id = "c_riftraft_entropy"},
        },
    },
}

SMODS.Challenge{
    key = "pitchblack",
    loc_txt = {name = "Pitch Black"},
    rules = {
        custom = {
            {id = "riftraft_only_void"},
        },
        modifiers = {
            {id = "joker_slots", value = 2},
            {id = "consumable_slots", value = 1},
        },
    },
    vouchers = {
        {id = "v_clearance_sale"},
        {id = "v_liquidation"},
        {id = "v_riftraft_riftshop_retrieve"},
    },
    restrictions = {
        banned_cards = {
            {id = "v_riftraft_riftshop_send"},
            {id = "v_riftraft_negative_hone"},
            {id = "v_riftraft_negative_consume"},
            {id = "v_blank"},
            {id = "v_antimatter"},
            {id = "v_crystal_ball"},
            {id = "v_omen_globe"},
            {id = "v_tarot_merchant"},
            {id = "v_tarot_tycoon"},
            {id = "v_planet_merchant"},
            {id = "v_planet_tycoon"},
            {id = "v_magic_trick"},
            {id = "v_illusion"},
        },
    },
}

SMODS.Challenge{
    key = "stare_too_long",
    loc_txt = {name = "Stare Too Long"},
    rules = {
        modifiers = {
            {id = "joker_slots", value = 0},
        },
    },
    jokers = {
        {id = "j_riftraft_abyss", eternal = true},
        {id = "j_riftraft_abyss", eternal = true},
        {id = "j_riftraft_abyss", eternal = true},
        {id = "j_riftraft_abyss", eternal = true},
        {id = "j_riftraft_abyss", eternal = true},
    },
    vouchers = {
        {id = "v_riftraft_riftshop_retrieve"},
        {id = "v_riftraft_riftshop_send"},
    },
    restrictions = {
        banned_cards = {
            {id = "v_blank"},
            {id = "v_antimatter"},
            {id = "c_riftraft_facade"},
            {id = "c_riftraft_static"},
            {id = "c_riftraft_amnesia"},
            {id = "c_riftraft_dream"},
        },
    },
}