function RIFTRAFT.view_void_deck()
	G.VIEWING_DECK = true

	local area_width, area_height = 6.5*G.CARD_W, 0.6*G.CARD_H

	local view_deck_order = {"joker", "other", "consumeable", "playing"}
	local view_decks = {}

	local all_cards = {}
	for _, card in ipairs(G.riftraft_void.cards) do
		table.insert(all_cards, card)
	end
	for _, card in ipairs(G.riftraft_rifthand.cards) do
		table.insert(all_cards, card)
	end

	for _, card in ipairs(all_cards) do
		local set = "other"
		if card.ability.set == "Default" or card.ability.set == "Enhanced" then
			set = "playing"
		elseif card.ability.set == "Joker" then
			set = "joker"
		elseif card.ability.consumeable then
			set = "consumeable"
		end

		local view_deck
		if not view_decks[set] then
			view_deck = CardArea(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, area_width, area_height, {
				card_limit = 8,
				type = 'title',
				view_deck = true,
				highlight_limit = 0,
				card_w = G.CARD_W*0.7,
				draw_layers = {'card'}
			})

			view_decks[set] = view_deck
		else
			view_deck = view_decks[set]

			if view_deck.config.card_limit == #view_deck.cards then
				view_deck.config.card_limit = view_deck.config.card_limit + 1
			end
		end

		local copy = copy_card(card, nil, 0.7)
		--copy.greyed = (card.area and card.area == G.riftraft_rifthand)
		copy.T.x = view_deck.T.x + view_deck.T.w/2
		copy.T.y = view_deck.T.y

		copy:hard_set_T()
		view_deck:emplace(copy)
	end

	for k, v in pairs(view_decks) do
		if k == "playing" then
			table.sort(v.cards, function(a, b) return a:get_nominal("suit") > b:get_nominal("suit") end)
		else
			local fallback_order = 10000
			table.sort(v.cards, function(a, b)
				local a_center, b_center = a.config.center, b.config.center
				if a_center.set ~= b_center.set then
					return a_center.set < b_center.set
				elseif (a_center.order or fallback_order) ~= (b_center.order or fallback_order) then
					return (a_center.order or fallback_order) < (b_center.order or fallback_order)
				else
					return a_center.key < b_center.key
				end
			end)
		end
		v:set_ranks()
	end

	local deck_tables = {}
	for _, set in ipairs(view_deck_order) do
		if view_decks[set] then
			table.insert(deck_tables,
				{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
					{n=G.UIT.O, config={object = view_decks[set]}}
				}}
			)
		end
	end

	if #deck_tables == 0 then
		table.insert(deck_tables, simple_text_container("k_riftraft_void_empty", {scale = 0.5, align = "cm", colour = G.C.WHITE}))
	end

	local t =
		{n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
			{n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={}},
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.C, config={align = "cm", minw = area_width, minh = area_height*3.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}
			}}
		}}
	return t
end