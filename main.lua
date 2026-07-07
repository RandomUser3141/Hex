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
    key = "hex_joker",
    loc_txt = {
        name = "Hex Joker",
        text = {
            "{X:mult,C:white}X#1#{} Mult"
        }
    },
    config = { extra = { Xmult = 5 } },
    atlas = "HexJokers",
    pos = { x = 0, y = 0 }, -- first frame in the atlas
    rarity = 3,             -- 1 common, 2 uncommon, 3 rare, 4 legendary
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,

    -- Fires during the main scoring pass
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
                message = "X" .. card.ability.extra.Xmult .. " Mult!",
            }
        end
    end,

    -- Fills the #1# placeholder in the description text
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
}