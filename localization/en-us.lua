return {
    descriptions = {
        Edition = {
            e_negative_generic = {
                name = "Negative",
                text = {
                    "{C:dark_edition}+#1#{} slot",
                },
            },
            e_negative_booster = {
                name = "Negative",
                text = {
                    "{C:dark_edition}+#1#{} Booster Pack",
                },
            }
        },
        Joker = {
            -- unused
            j_riftraft_copy_name = {
                name = "Joker(#1#)",
                text = {},
            }
        },
        Other = {
            riftraft_rift_seal = {
                name = "Black Seal",
                text = {
                    "Creates a {C:dark_edition}Negative {C:riftraft_void}Rift{}",
                    "card when destroyed",
                },
            },
            riftraft_win_negative = {
                name = "Negative Sticker",
                text = {
                    "Reached Ante 12",
                    "with a {C:dark_edition}Negative{}",
                    "edition of",
                    "this Joker",
                },
            },
            riftraft_win_duplicate = {
                name = "Duplication Sticker",
                text = {
                    "Reached Ante 12",
                    "with {C:attention}more than{}",
                    "{C:attention}one{} of this Joker",
                },
            },
            riftraft_paleflower_remove = {
                name="n",
                text={
                    "{C:inactive,s:0.8}(Owned {C:dark_edition,s:0.8}Negative{C:inactive,s:0.8} cards are destroyed at end of shop)",
                },
            },
        },
        Mod = {
            RiftRaft = {
                name = "Rift-Raft",
                text = {
                    "adding new ways to",
                    "use negative cards",
                    " ",
                    "{C:inactive}(booster reroll code{}",
                    "{C:inactive}by sunsetquasar){}",
                    " ",
                    "{C:inactive}('Overflow' code{}",
                    "{C:inactive}by SylviBlossom){}",
                    " ",
                    "{C:inactive}('Forget' and 'Ditch' concepts{}",
                    "{C:inactive}by Worldwaker2){}",
                },
            }
        }
    },
    misc = {
        dictionary = {
            k_riftraft_void_empty = {"OPEN BOOSTER PACKS", "TO FILL THE VOID"},
            k_plus_riftraft_rift = "+1 Rift",
            k_riftraft_changed = "Changed!",
            b_riftraft_void = "The Void",

            -- config
            c_riftraft = "Config",
            c_riftraft_negative_cards = "Negative Playing Cards",
            c_riftraft_negative_cards_desc = {
                "adds content for making playing cards negative.",
                "it can be a bit overpowered by vanilla standards,",
                "so you can disable it here if you want.",
                "(requires game restart)"
            },
            c_riftraft_voidrate = "Void Pack Rate",
            c_riftraft_voidrate_desc = {
                "the likelihood of Void Packs",
                "appearing in the Shop."
            },
            c_riftraft_allow_buy = "Always Allow Send From Shop",
            c_riftraft_allow_buy_desc = {
                "allows you to buy & send from void",
                "without the Wormhole voucher.",
                "will cost 2x by default;",
                "Wormhole reduces the price back to 1x.",
            },
        },
        v_dictionary = {
            k_riftraft_buy = {"Buy ($#1#)", "& Send", "to Void"},
            k_riftraft_send = {"Send to", "Void"},
            k_riftraft_nope = {"Nope!"},
        },
        v_text = {
            ch_c_riftraft_no_void = {
                "{C:riftraft_void}Void{} Packs no longer appear in the {C:attention}shop{}"
            },
            ch_c_riftraft_only_retrieval_tag = {
                "All tags are {C:attention}Retrieval{} Tags"
            },
            ch_c_riftraft_only_void = {
                "Only {C:riftraft_void}Void{} Packs and {C:riftraft_void}Rift{} Cards appear in the {C:attention}shop{}"
            },
        }
    },
}