RIFTRAFT.RiftHand = CardArea:extend()

function RIFTRAFT.RiftHand:init(...)
    CardArea.init(self, ...)
    table.insert(G.I.CARDAREA, self)

    self.ARGS.invisible_area_types = {rifthand = 1}
end

if next(SMODS.find_mod('Cryptid')) then
    local banned_areas = Card.get_banned_force_popup_areas
    function Card:get_banned_force_popup_areas()
        local result = banned_areas(self)
        table.insert(result, G.riftraft_rifthand)
        return result
    end
end

function RIFTRAFT.RiftHand:update(dt)
    CardArea.update(self, dt)
    if (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and #G.hand.cards > 0 then
        self.T.y = G.TILE_H - self.T.h + 1
    else
        self.T.y = G.TILE_H - self.T.h
    end
end

function RIFTRAFT.RiftHand:draw()
    CardArea.draw(self)
    for _,v in ipairs{'shadow', 'card'} do
        for i = 1, #self.cards do
            if self.cards[i] ~= G.CONTROLLER.focused.target then
                if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
            end
        end
    end
end

function RIFTRAFT.RiftHand:align_cards()
    for k, card in ipairs(self.cards) do
        if not card.states.drag.is then 
            card.T.r = 0.4*(-#self.cards/2 - 0.5 + k)/(#self.cards)+ (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T.x)
            local max_cards = math.max(#self.cards, self.config.temp_limit)
            card.T.x = self.T.x + (self.T.w-self.card_w)*((k-1)/math.max(max_cards-1, 1) - 0.5*(#self.cards-max_cards)/math.max(max_cards-1, 1)) + 0.5*(self.card_w - card.T.w)
            local highlight_height = G.HIGHLIGHT_H
            if not card.highlighted then highlight_height = 0 end
            card.T.y = self.T.y - 1.8*G.CARD_H + (G.CARD_H - card.T.h)/2 - highlight_height + (G.SETTINGS.reduced_motion and 0 or 1)*0.1*math.sin(0.666*G.TIMERS.REAL+card.T.x) + math.abs(1.3*(-#self.cards/2 + k-0.5)/(#self.cards))^2-0.3
            card.T.x = card.T.x + card.shadow_parrallax.x/30
            card.T.scale = 1
        end
    end
    table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end) 
end

function RIFTRAFT.RiftHand:can_highlight(card)
    return true
end