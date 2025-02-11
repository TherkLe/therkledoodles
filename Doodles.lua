--- STEAMODDED HEADER
--- MOD_NAME: TherkLe's Doodles
--- MOD_ID: THERKDOODLES
--- MOD_AUTHOR: [TherkLe]
--- MOD_DESCRIPTION: Random jokers from the depths of my mind
--- BADGE_COLOR: 42f5b0
--- PREFIX: doodl
--- VERSION: 1.0.0
SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true
    }
end

SMODS.Atlas{
    key = 'jokers',
    path = 'jokers.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'bigones',
    path = 'bigones.png',
    px = 142,
    py = 190
}

SMODS.Atlas{
	key = 'modicon',
	path = 'icon.png',
	px = 35,
	py = 35
}

SMODS.Joker{
	key = 'breakingnews',
  	loc_txt = {
    	name = 'Breaking News',
    	text = {
      	"{X:mult,C:white}X3{} mult if played",
	  	"{C:attention}poker hand{} hasn't",
	  	"been played this round"
    	}
  	},
  	config = { extra = { Xmult = 3 } },
  	rarity = 2,
  	atlas = 'jokers',
  	pos = { x = 0, y = 0 },
  	cost = 7,
  	loc_vars = function(card, info_queue, card)
    return { vars = { card.ability.extra.Xmult } }
  	end,
  	calculate = function(self, card, context)
		if context.joker_main then
			if context.cardarea == G.jokers and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round <= 1 then		
				return {
					message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
					Xmult_mod = card.ability.extra.Xmult
				}
			end
		end
	end
}

SMODS.Joker{
	key = 'wellused',
  	loc_txt = {
    	name = 'Well-Used Joker',
    	text = {
      	"Gains {C:money}$7{} of", 
		"{C:attention}sell value{} at end of round",
		"{C:green}#1# in #2#{} chance this joker is",
		"destroyed at end of round."
    	}
  	},
  	config = { extra = { odds = 3, extra_value = 7, extra = 7 } },
  	rarity = 1,
  	atlas = 'jokers',
  	pos = { x = 1, y = 0 },
  	cost = 7,
  	loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra_value } }
  	end,
  	calculate = function(self, card, context)
		if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
			-- Another pseudorandom thing, randomly generates a decimal between 0 and 1, so effectively a random percentage.
			if pseudorandom('wellused') < G.GAME.probabilities.normal / card.ability.extra.odds then
			  -- This part plays the animation.
			  G.E_MANAGER:add_event(Event({
				func = function()
				  play_sound('tarot1')
				  card.T.r = -0.2
				  card:juice_up(0.3, 0.4)
				  card.states.drag.is = true
				  card.children.center.pinch.x = true
				  -- This part destroys the card.
				  G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.3,
					blockable = false,
					func = function()
					  G.jokers:remove_card(card)
					  card:remove()
					  card = nil
					  return true;
					end
				  }))
				  return true
				end
			  }))
			  return {
				message = 'Gone!'
			  }
			elseif context.end_of_round and context.cardarea == G.jokers then
				card.ability.extra_value = card.ability.extra_value + 7
				card:set_cost()
				return {
					message = localize('k_val_up'),
					colour = G.C.MONEY
				}
			end
		end
	end
}

SMODS.Joker{
	key = 'viral',
  	loc_txt = {
    	name = 'Viral Joker',
    	text = {
      	"Gains {C:mult}+#2#{} mult for every",
		"{C:attention}enhanced {c:hearts}Heart{} card scored.",
		"{C:inactive}(Currently {C:mult}+#1#{C:inactive} mult.)"
    	}
  	},
  	config = { extra = { mult = 0, mult_gain = 2 } },
  	rarity = 2,
  	atlas = 'jokers',
  	pos = { x = 2, y = 0 },
  	cost = 7,
  	loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
  	end,
	calculate = function(self, card, context)
		if context.joker_main then
			if card.ability.extra.mult > 0 then
				return {
					mult_mod = card.ability.extra.mult,
					message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
				}
			end
		end
		if context.cardarea == G.play and context.individual then
			if context.other_card.ability.set == 'Enhanced' and context.other_card:is_suit('Hearts') then
				card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
      			return {
        			message = 'Liked!',
        			colour = G.C.MULT,
        			card = card
      			}
			end
		end

	end
}

SMODS.Joker{
	key = '3d',
  	loc_txt = {
    	name = 'The Third Dimension',
    	text = {
      	"Gains {C:chips}+33{} chips for every",
		"held {C:attention}3{} in hand.",
		"{C:inactive}(Currently {C:chips}+#1#{C:inactive} chips)"
    	}
  	},
	atlas = 'bigones',
	rarity = 3,
	cost = 10,
	loc_vars = function(self, info_queue, card)
		return {vars = { card.ability.extra.chips, card.ability.extra.chip_gain }}
	end,
	config = { extra = { chips = 0, chip_gain = 33 }},
	calculate = function(self, card, context)
		if context.joker_main then
			if card.ability.extra.chips > 0 then
				return {
					chip_mod = card.ability.extra.chips,
					message = localize { type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips} }
				}
			end
		end
		if context.individual and context.cardarea == G.hand then
			if context.other_card:get_id() == 3 then
				if context.other_card.debuff then
						return {
						message = localize('k_debuffed'),
						colour = G.C.CHIPS,
						card = card,
					}
				else
					card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
					return {
						message = 'Upgraded!',
						colour = G.C.CHIPS,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker{
	key = 'retexture',
  	loc_txt = {
    	name = 'Retexture',
    	text = {
      	"Every face card in hand",
		"gives an extra",
		"{C:chips}+30{} chips."
    	}
  	},
	atlas = 'jokers',
	pos = { x = 3, y = 0},
	rarity = 1,
	cost = 10,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.hand and not context.end_of_round then
			if context.other_card:get_id() == 11 or context.other_card:get_id() == 12 or context.other_card:get_id() == 13 then
				if context.other_card.debuff then
					return {
					message = localize('k_debuffed'),
					colour = G.C.CHIPS,
					card = card,
					}
				else
					return {
						h_chips = 30,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker{
	key = 'mishmash',
  	loc_txt = {
    	name = 'Mish-Mash',
    	text = {
      	"After {C:attention}5{} rounds,",
		"sell his joker for a",
		"{C:green}#1# in #2#{} chance to",
		"{C:attention}duplicate{} the Joker to",
		"the left.",
		"{C:inactive}({}#3#/{C:attention}5{C:inactive} rounds left)"
    	}
  	},
  	config = { extra = { odds = 3, mishmash_rounds = 0 } },
  	rarity = 3,
  	atlas = 'jokers',
  	pos = { x = 0, y = 1 },
  	cost = 12,
	blueprint_compat = false,
  	loc_vars = function(card, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.mishmash_rounds } }
  	end,
	calculate = function(self, card, context)
		if context.selling_self then
			if card.ability.extra.mishmash_rounds >= 5 and not context.blueprint and pseudorandom('mishmash') < G.GAME.probabilities.normal / card.ability.extra.odds then
				local selected = G.jokers.cards[1]
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i] == self then selected = G.jokers.cards[i-1] end
				end
				local card = copy_card(selected, nil, nil, nil, selected.edition and selected.edition.negative)
    	        if card.ability.mishmash_rounds then card.ability.mishmash_rounds = 0 end
   	  	    	card:add_to_deck()
      			G.jokers:emplace(card)
			end
		end
		if card.ability.extra.mishmash_rounds >= 5 and not context.blueprint then
			local eval = function(card) return card.ability.extra.mishmash_rounds >= 5 end
            juice_card_until(card, eval, true)
		end
		if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
			card.ability.extra.mishmash_rounds = card.ability.extra.mishmash_rounds + 1
		end
	end
}

SMODS.Joker{
	key = 'crashlog',
	loc_txt = {
		name = 'Crash Log',
		text = {
			'{C:inactive}Oops! The game crashed:',
			'Gains {X:mult,C:white}X#2#{} mult for every', 
			'Joker {C:attention}destroyed.{}',
			'{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} mult)'
		}
	},
	atlas = 'jokers',
	rarity = 3,
	cost = 10,
	unlocked = true,
	discovered = false,
	blueprint_compat = true, 
    eternal_compat = true, 
    perishable_compat = true,
	pos = {x = 1, y = 1},
	config = {extra = { Xmult = 1, Xmult_gain = 0.5} },
	loc_vars = function(card, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gain } }
	end,
	calculate = function(self, card, context)
		if context.joker_main and card.ability.extra.Xmult > 1 then
			return {
				Xmult_mod = card.ability.extra.Xmult,
				message = 'X' .. card.ability.extra.Xmult,
				colour = G.C.MULT
			}
		end
		local destroycheck = Card.remove
		function Card.remove(self)
			if self.added_to_deck and card.ability.set == 'Joker' and not G.CONTROLLER.locks.selling_card then
				SMODS.calculate_context({
					destroying_joker = true,
					destroyed_joker = self
				})
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
				return {
					message = 'X' .. card.ability.extra.Xmult,
					colour = G.C.MULT
				}
			end

			return destroycheck(self)
		end
	end
}

SMODS.Joker{
	key = 'solidgold',
	loc_txt = {
		name = 'Solid Gold',
		text = {
			'Retrigger played {C:money}Gold Seals{}',
			'{C:attention}#1#{} times.'
		}
	},
	atlas = 'jokers',
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = false,
	blueprint_compat = true, 
    eternal_compat = true, 
    perishable_compat = true,
	pos = {x = 2, y = 1},
	config = {extra = { retriggers = 2 } },
	loc_vars = function(card, info_queue, card)
		return { vars = { card.ability.extra.retriggers } }
	end,
	calculate = function(self, card, context)
		if context.repetition and context.cardarea == G.play then
			if context.other_card.seal == 'Gold' then
				return{
				repetitions = card.ability.extra.retriggers,
				message = localize('k_again_ex'),
				card = card
				}
			end
		end
	end
}
