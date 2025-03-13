RIFTRAFT.VoidCardArea = CardArea:extend()

function RIFTRAFT.VoidCardArea:init(...)
    CardArea.init(self, ...)
    table.insert(G.I.CARDAREA, self)

    self.states.collide.can = true
    self.states.hover.can = true
    self.states.click.can = true

    self.being_hovered = false
    self.send_active = false
    self.selecting_shop = false
    self.override_show = 0

    self.ARGS.invisible_area_types = {void = 1}

    self:create_sprites()
end

function RIFTRAFT.VoidCardArea:hard_set_VT()
    Moveable.hard_set_VT(self)
    -- re-set sprite's position
    self.children.portal:hard_set_T(self.T.x, self.T.y, self.T.w, self.T.h)
    self.orig_t = {
        x = self.T.x,
        y = self.T.y,
        w = self.T.w,
        h = self.T.h,
    }
    self.portal_orig_t = {
        x = self.children.portal.T.x,
        y = self.children.portal.T.y,
        w = self.children.portal.T.w,
        h = self.children.portal.T.h,
    }
end

function RIFTRAFT.VoidCardArea:create_sprites()
    if self.children.portal then return end
    self.children.portal = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["riftraft_RiftPortal"], {x = 0, y = 0})
    self.children.portal.tilt_var = {mx = 0, my = 0, dx = 0, dy = 0, amt = 0}
    self.children.portal.hover_tilt = 1
    self.ambient_tilt = 0.3

    self.text_node = simple_text_container({type = 'variable', key = "k_riftraft_send"}, {scale = 0.5, colour = HEX("6b8286"), shadow = true})
    self.children.text = UIBox{
        definition = {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes = {self.text_node}},
        config = { align = 'cm', offset = {x=0,y=0}, major = self, parent = self}
    }
    self.children.text.states = self.states
    self.children.text.click = function() self:click() end
end

function RIFTRAFT.VoidCardArea:update(dt)
    CardArea.update(self, dt)

    self.children.portal.T.r = self.children.portal.T.r - dt * 0.2
    if self:should_show() then
        self.T.x = self.orig_t.x
    else
        self.T.x = G.discard.T.x
    end
    self.children.portal.T.x = self.T.x

    -- scaling concept, didn't work
    -- if self:should_show() then
    --     self.children.portal.T.x = self.portal_orig_t.x
    --     self.children.portal.T.w = G.CARD_W
    -- else
    --     self.children.portal.T.x = self.portal_orig_t.x + (self.portal_orig_t.w / 2)
    --     self.children.portal.T.w = 0
    -- end

    local was_active = self.send_active
    local was_shop = self.selecting_shop
    self.send_active = self:can_send()
    if was_shop ~= self.selecting_shop then
        self:set_text_to_shop(self.selecting_shop)
    end
    if was_active ~= self.send_active then
        self:set_text_active(self.send_active)
    end
    if not self.being_hovered and self.states.hover.is then
        self.children.portal:set_sprite_pos{x = 1, y = 0}
        self.being_hovered = true
    elseif self.being_hovered and not self.states.hover.is then
        self.children.portal:set_sprite_pos{x = 0, y = 0}
        self.being_hovered = false
    end
end

function RIFTRAFT.VoidCardArea:set_text_active(state)
    local color = G.C.WHITE
    if not state then
        color = HEX("6b8286")
    end
    for _,node in ipairs(self.text_node.nodes) do
        node.nodes[1].config.colour = color
    end
end

function RIFTRAFT.VoidCardArea:set_text_to_shop(state)
    self.children.text:remove_group()
    local text = {type = 'variable', key = "k_riftraft_send"}
    if state then
        local cost = 0
        local shop_card = (G.shop_jokers and G.shop_jokers.highlighted and G.shop_jokers.highlighted[1])
                        or (G.shop_booster and G.shop_booster.highlighted and G.shop_booster.highlighted[1])
                        or (G.shop_vouchers and G.shop_vouchers.highlighted and G.shop_vouchers.highlighted[1])
        if shop_card then
            cost = shop_card.cost
            if RIFTRAFT.allow_buy_always and not G.GAME.used_vouchers.v_riftraft_riftshop_send then cost = math.max(cost*2, 1) end
        end
        text = {type = 'variable', key = "k_riftraft_buy", vars = {cost}}
    end
    self.text_node = simple_text_container(text, {scale = 0.5, colour = HEX("6b8286"), shadow = true})
    self.children.text:add_child({n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes = {self.text_node}})
    self.children.text:hard_set_VT()
end

function RIFTRAFT.VoidCardArea:should_show()
    if self.override_show > 0 then return true end
    if (G.GAME.used_vouchers.v_riftraft_riftshop_send or RIFTRAFT.allow_buy_always) and G.STATE == G.STATES.SHOP then return true end
    if G.STATE == G.STATES.TAROT_PACK
    or G.STATE == G.STATES.SPECTRAL_PACK
    or G.STATE == G.STATES.PLANET_PACK
    or G.STATE == G.STATES.BUFFOON_PACK
    or (RIFTRAFT.negative_playing_cards and G.STATE == G.STATES.STANDARD_PACK)
    or (G.STATE == G.STATES.SMODS_BOOSTER_OPENED and not RIFTRAFT.in_void_pack())
    then return true end
    return false
end

function RIFTRAFT.VoidCardArea:can_send()
    self.selecting_shop = false
    local send_card = nil
    if (G.GAME.used_vouchers.v_riftraft_riftshop_send or RIFTRAFT.allow_buy_always) and G.STATE == G.STATES.SHOP then
        -- support all shop card areas in case some funny mods put valid cards in them
        send_card = (G.shop_jokers and G.shop_jokers.highlighted and G.shop_jokers.highlighted[1])
                or (G.shop_booster and G.shop_booster.highlighted and G.shop_booster.highlighted[1])
                or (G.shop_vouchers and G.shop_vouchers.highlighted and G.shop_vouchers.highlighted[1])
        if not send_card then return false end
        self.selecting_shop = true
        local cost = send_card.cost
        if RIFTRAFT.allow_buy_always and not G.GAME.used_vouchers.v_riftraft_riftshop_send then cost = math.max(cost*2, 1) end
        if (to_big(cost) > G.GAME.dollars - G.GAME.bankrupt_at) and (cost > 0) then return false end
    else
        if not (G.STATE == G.STATES.TAROT_PACK
        or G.STATE == G.STATES.SPECTRAL_PACK
        or G.STATE == G.STATES.PLANET_PACK
        or G.STATE == G.STATES.BUFFOON_PACK
        or (RIFTRAFT.negative_playing_cards and G.STATE == G.STATES.STANDARD_PACK)
        or (G.STATE == G.STATES.SMODS_BOOSTER_OPENED and not RIFTRAFT.in_void_pack()))
        then return false end
        send_card = G.pack_cards and G.pack_cards.highlighted and G.pack_cards.highlighted[1]
        if not send_card then return false end
    end
    if send_card.ability.riftraft_from_void then
        self.selecting_shop = false; return false
    end
    if (not send_card.ability.consumeable) and (send_card.config.center.set ~= 'Joker')
    and (not RIFTRAFT.negative_playing_cards or (send_card.config.center.set ~= 'Default' and send_card.config.center.set ~= 'Enhanced')) then
        self.selecting_shop = false; return false
    end
    if send_card.config.center.set == 'Rift' then
        self.selecting_shop = false; return false
    end
    if send_card.config.center.key == "c_soul" or send_card.config.center.key == "c_black_hole" or send_card.config.center.soul_rate then
        self.selecting_shop = false; return false
    end
    return true
end

function RIFTRAFT.VoidCardArea:get_next_cards(amount)
    amount = amount or G.hand.config.card_limit
    local cards = {}
    for i=1, amount do
        table.insert(cards, self.cards[i])
    end
    return cards
end

function RIFTRAFT.VoidCardArea:has_card_types_in(amount)
    local has = {}
    for i,v in ipairs(self:get_next_cards(amount)) do
        if v.ability.consumeable then
            has.consumeable = true
        end
        if v.ability.set == "Default" or v.ability.set == "Enhanced" then
            has.playing_card = true
        end
        if v.ability.set == "Joker" then
            has.joker = true
        end
    end
    return has
end

function RIFTRAFT.VoidCardArea:click()
    if self.send_active then
        if self.selecting_shop then
            local to_send = G.shop_jokers.highlighted[1] or G.shop_booster.highlighted[1] or G.shop_vouchers.highlighted[1]
            draw_card(to_send.area, self, 1, 'up', false, to_send)

            -- do the buying before we set it to negative, otherwise you lose a lot more money!
            SMODS.calculate_context({buying_card = true, card = to_send})
            play_sound('card1')
            local cost = to_send.cost
            if RIFTRAFT.allow_buy_always and not G.GAME.used_vouchers.v_riftraft_riftshop_send then cost = math.max(cost*2, 1) end
            inc_career_stat('c_shop_dollars_spent', cost)
            if cost ~= 0 then
                ease_dollars(-cost)
            end

            if not to_send.edition or not to_send.edition.negative then
                to_send:set_edition({negative = true}, true, true)
            end

            if to_send.children.price then to_send.children.price:remove() end
            to_send.children.price = nil
            if to_send.children.buy_button then to_send.children.buy_button:remove() end
            to_send.children.buy_button = nil
            remove_nils(to_send.children)

            if not to_send.config.center.discovered then
                discover_card(to_send.config.center)
            end
            if not next(SMODS.find_card(to_send.config.center.key)) then
                G.GAME.used_jokers[to_send.config.center.key] = nil
            end

            G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                SMODS.calculate_context({add_to_void = true, added = {to_send}})
                return true
            end}))
        else
            local to_send = G.pack_cards.highlighted[1]
            draw_card(G.pack_cards, self, 1, 'up', false, to_send)
            G.pack_cards:change_size(-1)
            -- G.pack_cards.T.w = G.pack_cards.config.card_limit * G.CARD_W
            to_send:set_edition({negative = true}, true, true)

            if to_send.children.use_button then to_send.children.use_button:remove(); to_send.children.use_button = nil end
            remove_nils(to_send.children)

            if not to_send.config.center.discovered then
                discover_card(to_send.config.center)
            end
            if not next(SMODS.find_card(to_send.config.center.key)) then
                G.GAME.used_jokers[to_send.config.center.key] = nil
            end

            G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                SMODS.calculate_context({add_to_void = true, added = {to_send}})
                return true
            end}))
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    -- if G.pack_cards.config.card_limit == 0 then
                    if #G.pack_cards.cards == 0 then
                        G.FUNCS.end_consumeable()
                    end
                    return true
                end
            }))
        end
    end
end

function RIFTRAFT.VoidCardArea:draw()
    CardArea.draw(self)
    -- i don't like that i'm doing this in draw but it's consistent with vanilla
    local tilt_angle = G.TIMERS.REAL*(1.56 + (1/1.14212)%1) + 1/1.35122
    self.children.portal.tilt_var.mx = ((0.5 + 0.5*self.ambient_tilt*math.cos(tilt_angle))*self.children.portal.VT.w+self.children.portal.VT.x+G.ROOM.T.x)*G.TILESIZE*G.TILESCALE
    self.children.portal.tilt_var.my = ((0.5 + 0.5*self.ambient_tilt*math.sin(tilt_angle))*self.children.portal.VT.h+self.children.portal.VT.y+G.ROOM.T.y)*G.TILESIZE*G.TILESCALE
    self.children.portal.tilt_var.amt = self.ambient_tilt*(0.5+math.cos(tilt_angle))*0.3

    self.children.portal:draw_shader('dissolve', 0.075)
    self.children.portal:draw_shader('dissolve', nil)
    if self:should_show() then
        self.children.text:draw()
    end

    for _,v in ipairs{'shadow', 'card'} do
        for i = 1, #self.cards do
            if self.cards[i] ~= G.CONTROLLER.focused.target then
                if math.abs(self.cards[i].VT.x - self.T.x) > 0.5 then 
                    if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
                end
            end
        end
    end
end

function RIFTRAFT.VoidCardArea:align_cards()
    for k, card in ipairs(self.cards) do
        if card.facing == 'front' then card:flip() end

        if not card.states.drag.is then 
            card.T.x = self.T.x + (self.T.w - card.T.w)*card.discard_pos.x
            card.T.y = self.T.y + (self.T.h - card.T.h)*card.discard_pos.y
            card.T.scale = 0.5
            card.T.r = card.discard_pos.r
        end
    end
end

function RIFTRAFT.VoidCardArea:load(cardAreaTable)
    CardArea.load(self, cardAreaTable)
    self:create_sprites()
end