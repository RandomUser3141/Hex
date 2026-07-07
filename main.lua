SMODS.current_mod = SMODS.current_mod or {}

SMODS.current_mod.init = function()
    print("Hex initialized")
end

-- Atlas for your joker sprite sheet.
-- Put jokers.png in YourMod/assets/1x/jokers.png (71x95 px per frame)
SMODS.Atlas{
    key = "HexJokers",
    path = "jokers.png",
    px = 71,
    py = 95,
}

SMODS.Joker{
    key = "green_screen",
    loc_txt = {
        name = "Green Screen",
        text = {
            "This Joker gains {X:mult,C:white}X1{} Mult",
            "every time you play a",
            "{C:attention}Full House{}",
            "(Currently {X:mult,C:white}X#1#{} Mult)"
        }
    },
    config = { extra = { Xmult = 1, Xmult_gain = 1 } },
    atlas = "HexJokers",
    pos = { x = 0, y = 0 }, -- first frame in the atlas
    rarity = 4,             -- 1 common, 2 uncommon, 3 rare, 4 legendary
    cost = 20,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,

    calculate = function(self, card, context)
        -- Apply the current Xmult when this joker scores
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
            }
        end

        -- Grow permanently whenever a Full House is played
        if context.before and next(context.poker_hands["Full House"]) and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.MULT,
            }
        end
    end,

    -- Fills the #1# placeholder in the description text with the current Xmult
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
}