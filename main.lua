print("I LOVE YURI!!!!!")

-- the Steammodded version is smods-1.0.0-beta-1620a
-- ALSO arrow(1,x) is always is to the power while tetartion uses arrow(2,x)


local mod = SMODS.current_mod

mod.optional_features = {
    quantum = true
}

-- Amulet (Talisman-compatible) big-number support.
-- `to_big` is provided globally by Amulet; it converts a plain number into
-- an OmegaNum (cdata) value that can scale past the double-precision limit
-- of ~1.7e308. If Amulet's OmegaNum feature is turned off, `to_big` still
-- exists but just hands the plain number back, so it's always safe to call.
-- `big()` here is just a defensive wrapper in case Amulet isn't loaded at all.
local function big(n)
    if to_big then
        return to_big(n)
    end
    return n
end

-- Converts a (possibly OmegaNum/big) value into a plain Lua number,
-- best-effort. Declared up here (not just further down near the scoring
-- calculation code) so every joker/consumable in this file -- even ones
-- defined earlier in the file, like Exponent Joker -- can safely turn a
-- big value back into a plain number wherever one is required (e.g.
-- string.format, which cannot accept OmegaNum cdata directly). Amulet's
-- OmegaNum cdata doesn't expose one single guaranteed accessor across
-- versions, so we try the common method names before falling back to
-- string parsing (tostring on an OmegaNum prints something Lua's
-- tonumber can still read, e.g. "1.23e+45").
local function hex_to_plain_number(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "table" or type(value) == "cdata" then
        if value.to_number then
            local ok, n = pcall(function() return value:to_number() end)
            if ok and type(n) == "number" then return n end
        end
        if value.toNumber then
            local ok, n = pcall(function() return value:toNumber() end)
            if ok and type(n) == "number" then return n end
        end
    end
    local n = tonumber(tostring(value))
    return n or 0
end

-- Formats a (possibly big/OmegaNum) Hex point value for the on-screen
-- counter. Values at or below 9,999,999,999 are shown as a plain integer;
-- anything past that switches to scientific notation with exactly 2
-- digits after the decimal point (e.g. "1.00e21"), so the counter never
-- grows into an unreadable wall of digits once Hex points start scaling
-- past double-precision-friendly ranges.
local HEX_DISPLAY_SCI_THRESHOLD = 9999999999

local function hex_format_points(value)
    local n = hex_to_plain_number(value)

    if n ~= n then -- NaN guard
        n = 0
    end

    if math.abs(n) <= HEX_DISPLAY_SCI_THRESHOLD then
        return tostring(math.floor(n))
    end

    local exponent = math.floor(math.log(math.abs(n), 10))
    local mantissa = n / (10 ^ exponent)

    -- Round the mantissa to 2 decimals first, then correct for rounding
    -- pushing it to/past 10 (e.g. 9.999 -> "10.00e5" should be "1.00e6").
    mantissa = tonumber(string.format("%.2f", mantissa))

    if math.abs(mantissa) >= 10 then
        mantissa = mantissa / 10
        exponent = exponent + 1
    elseif mantissa ~= 0 and math.abs(mantissa) < 1 then
        mantissa = mantissa * 10
        exponent = exponent - 1
    end

    return string.format("%.2fe%d", mantissa, exponent)
end

-- Vanilla's default cap on how many cards can be highlighted at once to
-- play or discard (G.hand.config.highlighted_limit). Used by Polydactyly
-- to restore the normal limit once it's no longer owned.
local HEX_POLY_DEFAULT_HAND_LIMIT = 5

G.C.MYTHIC = HEX("1ABC9C")
G.C.TRANSCENDENTAL = HEX("6817ff")
G.C.DIVINE = HEX("ebb12a")
G.C.RITUAL = HEX("8f0d0d")
G.C.STAR = HEX("0045b5")

G.C.ABSOLUTE = {1, 0, 0, 1} -- initial color

local absolute_rainbow_time = 0

local old_update = Game.update
function Game:update(dt)
    old_update(self, dt)

    absolute_rainbow_time = absolute_rainbow_time + dt

    local hue = (absolute_rainbow_time * 0.25) % 1

    -- convert HSV -> RGB
    local i = math.floor(hue * 6)
    local f = hue * 6 - i
    local q = 1 - f

    local r, g, b

    if i % 6 == 0 then r, g, b = 1, f, 0
    elseif i == 1 then r, g, b = q, 1, 0
    elseif i == 2 then r, g, b = 0, 1, f
    elseif i == 3 then r, g, b = 0, q, 1
    elseif i == 4 then r, g, b = f, 0, 1
    elseif i == 5 then r, g, b = 1, 0, q
    end

    G.C.ABSOLUTE[1] = r
    G.C.ABSOLUTE[2] = g
    G.C.ABSOLUTE[3] = b
    G.C.ABSOLUTE[4] = 1
end



local old_loc_colour = loc_colour
function loc_colour(_c, _default)
    if _c == "mythic" then
        return G.C.MYTHIC
    end
    if _c == "transcendental" then
        return G.C.TRANSCENDENTAL
    end
    if _c == "divine" then
        return G.C.DIVINE
    end
    if _c == "absolute" then
        return G.C.ABSOLUTE
    end
    if _c == "ritual" then
        return G.C.RITUAL
    end
    if _c == "star" then
        return G.C.STAR
    end
    return old_loc_colour(_c, _default)
end


SMODS.Atlas{
    key = "HexJokers",
    path = "Jokers.png",
    px = 71,
    py = 95,
}

<<<<<<< HEAD
SMODS.Atlas{
    key = "HexPlanetsSpectrals",
    path = "Planets_and_Spectrals.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexEnhancers",
    path = "Enhancers.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexRitualsQuantums",
    path = "rituals_and_quantums.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexBoosters",
    path = "boosters.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexBlindChips",
    path = "BlindChips.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexStarsGalaxies",
    path = "Stars_and_Galaxies.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexTags",
    path = "tags.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexVouchers",
    path = "Vouchers.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexStickers",
    path = "stickers.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexNebulasBlackholes",
    path = "Nebulas_and_Blackholes.png",
    px = 71,
    py = 95,
}

SMODS.Atlas{
    key = "HexCelestialsCosmics",
    path = "Celestials_and_Cosmics.png",
    px = 71,
    py = 95,
}


local R_HEX_MYTHIC = SMODS.Rarity{
    key = "hex_mythic",
    loc_txt = {
        name = "Mythic"
    },
    default_weight = 0.0001,
    badge_colour = G.C.MYTHIC
}

local R_HEX_TRANSCENDENTAL = SMODS.Rarity{
    key = "hex_transcendental",
    loc_txt = {
        name = "Transcendental"
    },
    default_weight = 0.00001, -- rarer than mythic (0.0001) — tune as you like
    badge_colour = G.C.TRANSCENDENTAL
}


local R_HEX_DIVINE = SMODS.Rarity{
    key = "hex_divine",
    loc_txt = {
        name = "Divine"
    },
    default_weight = 0.000001, -- rarer than mythic (0.0001) — tune as you like
    badge_colour = G.C.DIVINE
}


local R_HEX_ABSOLUTE = SMODS.Rarity{
    key = "hex_absolute",
    loc_txt = {
        name = "Absolute"
    },
    default_weight = 0.0000001, -- rarer than mythic (0.0001) — tune as you like
    badge_colour = G.C.ABSOLUTE
}



SMODS.Shader({
    key = "prismatic",
    path = "prismatic.fs",
    send = function(self, shader, card)
        shader:send("time", G.TIMERS.REAL)
    end
})

SMODS.Edition{
    key = "hex_prismatic",

    loc_txt = {
        name = "Prismatic", 
        label = "Prismatic",

        text = {
            "{C:purple}^1.25{} Mult"
        }
    },

    shader = "prismatic",
    in_shop = true,
    unlocked = true,
    discovered = true,
    weight = 0.005,

    in_pool = function(self)
        return true
    end,

    calculate = function(self, card, context)

        if card.edition 
        and card.edition.key == "e_" .. mod.prefix .. "_prismatic" then

            if context.joker_main then
                return {
                    func = function()
                        mult = to_big(mult):arrow(1, 1.25)
                    end,
                    message = "^1.25",
                    colour = G.C.PURPLE
                }
            end

            if context.individual
            and context.cardarea == G.play
            and context.other_card == card then

                return {
                    func = function()
                        mult = to_big(mult):arrow(1, 1.25)
                    end,
                    message = "^1.25",
                    colour = G.C.PURPLE
                }
            end

        end
    end
}

-- Colour used for the Orange Seal's badge/description text -- vanilla
-- Balatro only defines Gold/Red/Blue/Purple seal colours (G.C.SEAL_*
-- equivalents), so a custom one is needed here the same way MYTHIC/
-- TRANSCENDENTAL/DIVINE/RITUAL each got their own G.C entry up top.
G.C.HEX_ORANGE_SEAL = HEX("FF8800")

-- Orange Seal: retriggers the card it's on two additional times (i.e.
-- the card scores a total of 3 times -- once normally, plus these 2
-- extra reps). Mirrors vanilla's own Red Seal implementation exactly
-- (context.repetition + context.cardarea == G.play, returning a
-- `repetitions` count alongside the specific `card` being retriggered),
-- just with repetitions = 2 instead of Red Seal's 1.
SMODS.Seal{
    key = "orange",

    loc_txt = {
        name = "Orange Seal",
        label = "Orange Seal",
        text = {
            "Retriggers this card",
            "{C:attention}2{} additional times",
        }
    },

    atlas = "HexEnhancers",
    pos = { x = 2, y = 0 },

    badge_colour = G.C.HEX_ORANGE_SEAL,

    unlocked = true,
    discovered = true,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = 2,
                card = card
            }
        end
    end,
}

-- Colours used for the Green and Pink Seals' badges/description text,
-- the same way G.C.HEX_ORANGE_SEAL was defined above for Orange Seal.
G.C.HEX_GREEN_SEAL = HEX("00CC44")
G.C.HEX_PINK_SEAL = HEX("FF69B4")

-- Green Seal: retriggers the card it's on 3 additional times (i.e. the
-- card scores a total of 4 times), same implementation as Orange Seal
-- above just with a higher flat repetitions count.
SMODS.Seal{
    key = "green",

    loc_txt = {
        name = "Green Seal",
        label = "Green Seal",
        text = {
            "Retriggers this card",
            "{C:attention}3{} additional times",
        }
    },

    atlas = "HexEnhancers",
    pos = { x = 4, y = 4 },

    badge_colour = G.C.HEX_GREEN_SEAL,

    unlocked = true,
    discovered = true,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = 3,
                card = card
            }
        end
    end,
}

-- Pink Seal: on each trigger, an independent 1-in-8 roll grants 10
-- additional retriggers of the card (i.e. that particular trigger scores
-- 11 times total). Unlike Orange/Green Seal's flat, guaranteed bonus,
-- this is a probabilistic jackpot -- most triggers do nothing extra, but
-- roughly one in eight blow up into a huge score.
SMODS.Seal{
    key = "pink",

    loc_txt = {
        name = "Pink Seal",
        label = "Pink Seal",
        text = {
            "{C:green}#1# in 8{} chance to retrigger",
            "this card {C:attention}10{} additional times",
        }
    },

    atlas = "HexEnhancers",
    pos = { x = 5, y = 4 },

    badge_colour = G.C.HEX_PINK_SEAL,

    unlocked = true,
    discovered = true,

    -- Fills the #1# placeholder above with the *real*, current "X in 8"
    -- odds, taking G.GAME.probabilities.normal into account -- the same
    -- multiplier Oops! All 6s doubles (and stacks further with multiple
    -- copies of it), which is also what the seal's own calculate function
    -- below folds into its actual roll. Base odds are 1 in 8; Oops! All 6s
    -- doubling probabilities.normal to 2 means the true odds are 2 in 8,
    -- and this keeps the tooltip in sync with that instead of always
    -- showing the unmodified base value. Deliberately kept as "X in 8"
    -- (numerator scaled, denominator left at 8) rather than simplified
    -- down to a reduced fraction like "1 in 4", per request. Falls back
    -- to the base 1-in-8 reading (prob_mod = 1) outside of a run, e.g. in
    -- the collection screen, where G.GAME.probabilities may not exist yet.
    loc_vars = function(self, info_queue, card)
        local prob_mod = (G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal) or 1
        local numer = 1 * prob_mod

        local numer_display
        if numer == math.floor(numer) then
            numer_display = math.floor(numer)
        else
            numer_display = string.format("%.2f", numer)
        end

        return { vars = { numer_display } }
    end,

    -- Uses pseudoseed the same way the Negative Deck's edition-roll boost
    -- above does (a fixed seed key, not per-card), so the roll is still
    -- deterministic/seed-safe per game seed, just re-rolled fresh every
    -- time this fires. G.GAME.probabilities.normal is the same global
    -- multiplier vanilla's own "1 in X" joker effects (Space Joker,
    -- Reserved Parking, Oops! All 6s itself, etc.) read -- Oops! All 6s
    -- doubles it (and stacks further with multiple copies), so folding
    -- it into our odds here is all that's needed for Oops! All 6s to
    -- affect this seal too, without checking for that Joker directly.
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local chance = (1 / 8) * (G.GAME.probabilities.normal or 1)
            if pseudorandom(pseudoseed(mod.prefix .. "_pink_seal")) < chance then
                return {
                    repetitions = 10,
                    card = card
                }
            end
        end
    end,
}

-- Colour used for the Black Seal's badge/description text, the same way
-- G.C.HEX_ORANGE_SEAL/HEX_GREEN_SEAL/HEX_PINK_SEAL were defined above.
-- A pure black (000000) badge would be unreadable against the game's
-- dark panels, so this uses a lighter charcoal instead, the same
-- brightness compromise vanilla's own near-black UI elements (e.g.
-- G.C.JOKER_GREY) make for the same reason.
G.C.HEX_BLACK_SEAL = HEX("3A3A3A")

-- Black Seal: mirrors vanilla Blue Seal's own "card held in hand at end
-- of round" main effect. Unlike Orange/Green/Pink Seal above (which hook
-- context.repetition to add extra scoring triggers), this is a seal's
-- *main* effect, which Steamodded's own eval_card evaluates whenever
-- context.cardarea == G.hand and context.repetition is NOT set -- adding
-- an context.individual check here (as an earlier draft of this seal
-- did) is wrong and silently never fires, since that flag is set for
-- *Jokers* granting effects to individual cards, not for a card's own
-- seal/enhancement main ability. Unlike Blue Seal (which always creates
-- a Planet), this creates a random Spectral card -- SMODS.create_card
-- with set = "Spectral" and no explicit key draws randomly from the
-- game's normal Spectral pool, so custom grant-only Spectrals like this
-- mod's own Heart (in_pool = false) are correctly excluded, the same
-- way normal shop/pack generation would exclude them.
SMODS.Seal{
    key = "black",

    loc_txt = {
        name = "Black Seal",
        label = "Black Seal",
        text = {
            "",
            "creates a random {C:spectral}Spectral{} card",
            "at end of round if held in hand",
            "{C:inactive}(Must have room){}",
        }
    },

    atlas = "HexEnhancers",
    pos = { x = 3, y = 4 },

    badge_colour = G.C.HEX_BLACK_SEAL,

    unlocked = true,
    discovered = true,

    calculate = function(self, card, context)
        -- context.end_of_round fires multiple times per card in this
        -- Steamodded build (same category of quirk as the
        -- context.first_hand_drawn issue noted elsewhere in this file for
        -- Orion) -- Steamodded's own docs recommend gating on
        -- context.main_eval for a once-per-round effect, but that flag
        -- doesn't actually get set on this call in this installed build,
        -- so relying on it made the seal never fire at all. Instead we
        -- dedupe the same way Orion does further down the file: stamp the
        -- current G.GAME.round directly onto the card the moment we act,
        -- and skip if we've already fired for this exact round. This is
        -- per-card (not global), so multiple Black Seals in hand each
        -- still grant their own Spectral card once per round.
        if context.end_of_round
        and context.cardarea == G.hand
        and not context.repetition
        and not context.blueprint
        and card.hex_black_seal_last_round ~= G.GAME.round then

            card.hex_black_seal_last_round = G.GAME.round

            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        -- NOTE: deliberately NOT calling new_card:add_to_deck()
                        -- here -- that call registers a card into the
                        -- playing-card/deck-tracking systems (G.playing_cards,
                        -- deck count UI, etc.), which is only correct for
                        -- actual 52-card-deck cards (see the Manifest ritual's
                        -- playing-card creation further down the file, which
                        -- legitimately needs it). Calling it on a Spectral
                        -- consumable misregistered it there, which is what
                        -- caused the glitched/flickering blue-box texture.
                        -- SMODS.create_card already plays its own
                        -- materialize animation automatically (that's what
                        -- the skip_materialize option exists to suppress) --
                        -- calling new_card:start_materialize() again here on
                        -- top of that ran two overlapping materialize
                        -- animations on the same card at once, which is what
                        -- produced the corrupted blue-shard/double-exposure
                        -- look. Every other card creation in this file
                        -- (Life ritual, Manifest ritual, Ritualistic Deck's
                        -- grant, etc.) just creates + emplaces and leaves it
                        -- at that, so this now matches that pattern.
                        local new_card = SMODS.create_card({
                            set = "Spectral",
                            area = G.consumeables
                        })

                        G.consumeables:emplace(new_card)

                        return true
                    end
                }))

                return {
                    message = "+1 Spectral",
                    colour = G.C.HEX_BLACK_SEAL
                }
            end
        end
    end,
}

SMODS.Back{
    key = "infinite_joker_deck",

    loc_txt = {
        name = "Infinite Deck",
        text = {
            "Start off with",
            "{C:attention}infinite Joker slots{}"
        }
    },

    config = {
        joker_slot = 999995
    },
    
    unlocked = true,
    discovered = true,

    pos = { x = 0, y = 0 },

    atlas = "HexEnhancers",
}

SMODS.Back{
    key = "negative_deck",

    loc_txt = {
        name = "Negative Deck",
        text = {
            "{C:attention}Negative{} Jokers appear",
            "{C:attention}10 times{} more often"
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    pos = { x = 0, y = 2 }, -- next open frame in the atlas, right next to Infinite Deck

    atlas = "HexEnhancers",
}

-- Key of our custom Back, used below to check which deck is currently
-- selected. Declared once here so both the create_card hook and any
-- future code referencing this deck stay in sync automatically if the
-- mod prefix ever changes.
local HEX_NEGATIVE_DECK_KEY = "b_" .. mod.prefix .. "_negative_deck"

-- Vanilla's own baseline chance of a shop/generated Joker rolling the
-- Negative edition is roughly 0.3% (0.003). We want Negative Jokers to
-- show up 10x as often while this deck is selected, so the extra,
-- independent roll below checks against 10x that baseline (0.03 / 3%).
local HEX_NEGATIVE_DECK_RATE = 0.03

local function hex_negative_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_NEGATIVE_DECK_KEY
end

-- Star cards: cards of the custom "star" ConsumableType (see the
-- SMODS.ConsumableType{ key = "star", ... } registration further down
-- this file) never appear in the shop and are never part of the normal
-- Spectral/Tarot draw pools -- every Star card sets in_pool = false, the
-- same way this mod's Rituals do -- so they have to be injected by hand
-- instead. Whenever a Spectral or Arcana (Tarot) pack is generating one
-- of its card slots, `area` is G.pack_cards regardless of which of the
-- two pack types is open, which gives a single reliable hook point for
-- both. Each slot gets an independent, flat 1-in-33 chance to be
-- replaced with a random Star card instead of whatever it would have
-- naturally rolled from the Spectral/Tarot pool.
local HEX_STAR_PACK_CHANCE = 1 / 33

local function hex_get_star_centers()
    local out = {}
    for _, center in pairs(G.P_CENTERS) do
        if center.set == "star" then
            out[#out + 1] = center
        end
    end
    return out
end

local old_create_card = create_card

function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

    if (_type == "Spectral" or _type == "Tarot")
    and area == G.pack_cards
    and not forced_key
    and pseudorandom(pseudoseed(mod.prefix .. "_star_pack")) < HEX_STAR_PACK_CHANCE then

        local stars = hex_get_star_centers()
        if #stars > 0 then
            forced_key = pseudorandom_element(stars, pseudoseed(mod.prefix .. "_star_pick")).key
        end
    end

    local card = old_create_card(
        _type,
        area,
        legendary,
        _rarity,
        skip_materialize,
        soulable,
        forced_key,
        key_append
    )

    if _type == "Joker" and pseudorandom(mod.prefix .. "_prismatic_joker") < 0.005 then
    card:set_edition({
        ["hex_prismatic"] = true
    }, true)
    end

    -- Negative Deck: while selected, give Jokers an extra, independent
    -- roll for the Negative edition at ~10x the normal chance. Vanilla's
    -- own edition roll (which may have already given this card Foil/
    -- Holo/Polychrome/Negative) already ran inside old_create_card
    -- above, so we only touch cards that came out with no edition at
    -- all, to avoid overwriting/stacking editions or double-counting
    -- the chance.
    if _type == "Joker"
    and (not card.edition)
    and hex_negative_deck_selected()
    and pseudorandom(pseudoseed(mod.prefix .. "_negative_deck_boost")) < HEX_NEGATIVE_DECK_RATE then
        card:set_edition({
            ["negative"] = true
        }, true)
    end

    return card
end

SMODS.Back{
    key = "gamblers_deck",

    loc_txt = {
        name = "Gambler's Deck",
        text = {
            "Start with a {C:attention}random{}",
            "amount of {C:mult}hands{}, {C:chips}discards{},",
            "{C:money}starting money{}, and",
            "{C:attention}hand size{}",
            "(each between 1 and 10)"
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    pos = { x = 1, y = 4 }, -- next open frame in the atlas, after Infinite Deck (0,0) and Negative Deck (0,2)

    atlas = "HexEnhancers",
}

SMODS.Back{
    key = "cursed_deck",

    loc_txt = {
        name = "Cursed Deck",
        text = {
            "Start with {C:purple}50{}",
            "{C:purple}Hex points{}",
            "Gain twice the",
            "{C:purple}Hex points{} from",
            "{C:purple}hexing{} a Joker"
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    -- NOTE: this shares its atlas frame with Gambler's Deck (pos 1,4) as
    -- requested -- if that's not intentional, move one of the two decks
    -- to an unused frame before shipping, since they'll currently render
    -- with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Cursed Deck, used the same way HEX_NEGATIVE_DECK_KEY /
-- HEX_GAMBLERS_DECK_KEY are used, to check which deck is currently selected.
local HEX_CURSED_DECK_KEY = "b_" .. mod.prefix .. "_cursed_deck"

local function hex_cursed_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_CURSED_DECK_KEY
end

-- Cursed Deck: grants 50 starting Hex points. Hooked onto Game:start_run
-- separately from the main "Create Hex Points when a run starts" hooks
-- further down the file, so it doesn't need to be threaded through those.
-- We only apply this on a genuinely new run (not a save being resumed) --
-- Balatro passes a table with a `savetext` field as the first vararg when
-- continuing a saved run, so checking for that keeps this from stomping
-- your accumulated Hex points every time you reload a Cursed Deck run.
local old_start_run_cursed_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_cursed_deck(self, args, ...)

    if hex_cursed_deck_selected() and not (args and args.savetext) then
        G.GAME.hex_points = big(50)
    end

    return ret
end

SMODS.Back{
    key = "ritualistic_deck",

    loc_txt = {
        name = "Ritualistic Deck",
        text = {
            "Start with a random",
            "{C:ritual}Ritual{} card",
            "{C:mult}-4{} Joker slots",
        }
    },

    -- Same Steamodded joker_slot Back config field Infinite/Relic Deck
    -- above use, just pinned down to a single slot this time.
    config = {
        joker_slot = -4
    },

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, Prestige, and
    -- Relic Deck (pos 1,4), per how it was requested -- move it to an
    -- unused frame in HexEnhancers before shipping if that overlap isn't
    -- intentional, since all five currently render with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Ritualistic Deck, used the same way HEX_RELIC_DECK_KEY /
-- HEX_PRESTIGE_DECK_KEY are used, to check which deck is currently selected.
local HEX_RITUALISTIC_DECK_KEY = "b_" .. mod.prefix .. "_ritualistic_deck"

local function hex_ritualistic_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_RITUALISTIC_DECK_KEY
end

-- Ritualistic Deck: grants one random Ritual consumable on a genuine new
-- run. Rituals are never in the normal shop/consumable pool (they all set
-- in_pool = false, same reasoning as the Mythic/Legendary Joker grants
-- above), so we build the candidate list by hand -- the same short-key
-- list G.FUNCS.create_ritual already maintains further down the file --
-- rather than scanning G.P_CENTERS, and pick with math.random rather than
-- pseudorandom_element for the same in_pool-filtering reason.
local HEX_RITUAL_SHORT_KEYS = {
    "hyperbolic",
    "life",
    "fractal",
    "eclipse",
    "manifest",
}

local old_start_run_ritualistic_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_ritualistic_deck(self, args, ...)

    if hex_ritualistic_deck_selected() and not (args and args.savetext) then
        if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
            local chosen_short_key = HEX_RITUAL_SHORT_KEYS[math.random(#HEX_RITUAL_SHORT_KEYS)]
            local chosen_key = "c_" .. mod.prefix .. "_" .. chosen_short_key

            -- Mirrors G.FUNCS.create_ritual further down the file exactly:
            -- SMODS.create_card + manual emplace, keyed only by the full
            -- "c_..." key with no `set` field. Passing set = "ritual" here
            -- (an earlier version of this hook did) made Steamodded treat
            -- "ritual" as a broad card-type token rather than our custom
            -- ConsumableType, which could create a card whose loc_txt
            -- (name/description) didn't match the actual key/center that
            -- got applied -- omitting `set` and letting `key` alone drive
            -- creation, like create_ritual already does, avoids that.
            local card = SMODS.create_card({
                key = chosen_key,
                area = G.consumeables
            })

            G.consumeables:emplace(card)

            G.GAME.hex_rituals_summoned = G.GAME.hex_rituals_summoned or {}
            G.GAME.hex_rituals_summoned[chosen_short_key] = true
        end
    end

    return ret
end

SMODS.Back{
    key = "relic_deck",

    loc_txt = {
        name = "Relic Deck",
        text = {
            "Start with a random",
            "{C:legendary}Legendary{} Joker",
            "{C:mult}-2{} Joker slots",
        }
    },

    -- joker_slot here is the same Steamodded Back config field Infinite
    -- Deck uses above (just pinned to 3 instead of a huge number) -- it's
    -- applied to G.jokers.config.card_limit automatically on start_run,
    -- no extra hook needed for the slot count itself.
    config = {
        joker_slot = -2
    },

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, and Prestige
    -- Deck (pos 1,4), per how it was requested -- move it to an unused
    -- frame in HexEnhancers before shipping if that overlap isn't
    -- intentional, since all four currently render with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Relic Deck, used the same way HEX_CURSED_DECK_KEY /
-- HEX_PRESTIGE_DECK_KEY are used, to check which deck is currently selected.
local HEX_RELIC_DECK_KEY = "b_" .. mod.prefix .. "_relic_deck"

local function hex_relic_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_RELIC_DECK_KEY
end

-- Relic Deck: grants one random Legendary (rarity 4) Joker on a genuine
-- new run, the same pool-scan-then-math.random approach used for Prestige
-- Deck's Mythic grant above (math.random rather than pseudorandom_element,
-- since some Legendary-rarity Jokers registered by this or other mods may
-- also set in_pool = false, which pseudorandom_element would otherwise
-- filter out -- see the comment on Prestige Deck's grant for the full
-- explanation of that pitfall). The 3-slot cap itself is handled purely by
-- the joker_slot config above; this hook only needs to worry about the
-- starting Joker grant.
local old_start_run_relic_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_relic_deck(self, args, ...)

    if hex_relic_deck_selected() and not (args and args.savetext) then
        local legendaries = {}
        for _, center in pairs(G.P_CENTERS) do
            if center.set == "Joker" and center.rarity == 4 then
                legendaries[#legendaries + 1] = center
            end
        end

        if #legendaries > 0 and G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
            local chosen = legendaries[math.random(#legendaries)]

            SMODS.add_card{
                set = "Joker",
                key = chosen.key
            }
        end
    end

    return ret
end

SMODS.Back{
    key = "prestige_deck",

    loc_txt = {
        name = "Prestige Deck",
        text = {
            "Start with a random",
            "{C:mythic}Mythic{} Joker",
            "Win ante is ante 16",
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    -- NOTE: this also shares its atlas frame with Gambler's Deck and
    -- Cursed Deck (pos 1,4), per how it was requested -- move it to an
    -- unused frame in HexEnhancers before shipping if that overlap isn't
    -- intentional, since all three currently render with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Prestige Deck, used the same way HEX_CURSED_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_PRESTIGE_DECK_KEY = "b_" .. mod.prefix .. "_prestige_deck"

local function hex_prestige_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_PRESTIGE_DECK_KEY
end

-- Prestige Deck: grants one random Mythic Joker (same pool-scan approach
-- the Heart consumable above uses) and raises the ante at which Finisher
-- Blinds appear -- and therefore the ante the run is actually won at --
-- from the vanilla 8 up to 16. G.GAME.win_ante is Steamodded/vanilla's
-- own field for this (it's what the Finisher Blind check reads), so we
-- don't need any extra win-condition hooking beyond setting it.
-- Same new-run-only guard (checking args.savetext) as Cursed Deck above,
-- so reloading a save doesn't hand out a second free Mythic Joker or
-- reset win_ante if some other effect already changed it mid-run.
local old_start_run_prestige_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_prestige_deck(self, args, ...)

    if hex_prestige_deck_selected() and not (args and args.savetext) then
        G.GAME.win_ante = 16

        local mythics = {}
        for _, center in pairs(G.P_CENTERS) do
            if center.set == "Joker" and center.rarity == R_HEX_MYTHIC.key then
                mythics[#mythics + 1] = center
            end
        end

        if #mythics > 0 then
            -- NOTE: deliberately not pseudorandom_element here. Steamodded's
            -- pseudorandom_element respects each candidate's in_pool (see the
            -- SMODS.Rank/Suit docs: "while respecting in_pool"), and every
            -- Mythic Joker in this mod sets in_pool = function() return false
            -- end (that's what makes them unlock/grant-only rarities in the
            -- first place) -- so it silently filtered the pool down to
            -- nothing and returned nil, crashing here. math.random matches
            -- what the Heart consumable's use function already does above
            -- for this exact same "pick a random Mythic" case.
            local chosen = mythics[math.random(#mythics)]

            if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                SMODS.add_card{
                    set = "Joker",
                    key = chosen.key
                }
            end
        end
    end

    return ret
end

SMODS.Back{
    key = "infernal_deck",

    loc_txt = {
        name = "Infernal Deck",
        text = {
            "Start with a random",
            "{C:transcendental}Transcendental{} Joker",
            "Win ante is ante 24",
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, Ritualistic,
    -- Relic, and Prestige Deck (pos 1,4), per how it was requested -- move
    -- it to an unused frame in HexEnhancers before shipping if that
    -- overlap isn't intentional, since all these decks currently render
    -- with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Infernal Deck, used the same way HEX_PRESTIGE_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_INFERNAL_DECK_KEY = "b_" .. mod.prefix .. "_infernal_deck"

local function hex_infernal_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_INFERNAL_DECK_KEY
end

-- Infernal Deck: grants one random Transcendental Joker (same pool-scan
-- approach Prestige Deck's Mythic grant above uses) and raises win_ante
-- to 24. Same new-run-only guard (checking args.savetext) as Prestige
-- Deck above, so reloading a save doesn't hand out a second free
-- Transcendental Joker or reset win_ante if some other effect already
-- changed it mid-run.
local old_start_run_infernal_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_infernal_deck(self, args, ...)

    if hex_infernal_deck_selected() and not (args and args.savetext) then
        G.GAME.win_ante = 24

        local transcendentals = {}
        for _, center in pairs(G.P_CENTERS) do
            if center.set == "Joker" and center.rarity == R_HEX_TRANSCENDENTAL.key then
                transcendentals[#transcendentals + 1] = center
            end
        end

        if #transcendentals > 0 then
            -- Deliberately not pseudorandom_element here, for the same
            -- reason as Prestige Deck's Mythic grant above -- every
            -- Transcendental Joker in this mod sets in_pool = function()
            -- return false end, which pseudorandom_element would filter
            -- down to nothing.
            local chosen = transcendentals[math.random(#transcendentals)]

            if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                SMODS.add_card{
                    set = "Joker",
                    key = chosen.key
                }
            end
        end
    end

    return ret
end

SMODS.Back{
    key = "holy_deck",

    loc_txt = {
        name = "Holy Deck",
        text = {
            "Start with a random",
            "{C:divine}Divine{} Joker",
            "Win ante is ante 32",
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, Ritualistic,
    -- Relic, Prestige, and Infernal Deck (pos 1,4), per how it was
    -- requested -- move it to an unused frame in HexEnhancers before
    -- shipping if that overlap isn't intentional, since all these decks
    -- currently render with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Holy Deck, used the same way HEX_PRESTIGE_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_HOLY_DECK_KEY = "b_" .. mod.prefix .. "_holy_deck"

local function hex_holy_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_HOLY_DECK_KEY
end

-- Holy Deck: grants one random Divine Joker (same pool-scan approach
-- Prestige/Infernal Deck's grants above use) and raises win_ante to 32.
-- Same new-run-only guard as the decks above. Inaccessible is excluded
-- from the pool, the same way G.FUNCS.summon_divine excludes it -- it
-- must be earned normally, never handed out as a starting Joker.
local old_start_run_holy_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_holy_deck(self, args, ...)

    if hex_holy_deck_selected() and not (args and args.savetext) then
        G.GAME.win_ante = 32

        local divines = {}
        for _, center in pairs(G.P_CENTERS) do
            if center.set == "Joker"
            and center.rarity == R_HEX_DIVINE.key
            and center.key ~= ("j_" .. mod.prefix .. "_inaccessible") then -- Inaccessible can never be handed out as a starting Joker; it must be earned normally, same as summon_divine's exclusion
                divines[#divines + 1] = center
            end
        end

        if #divines > 0 then
            -- Deliberately not pseudorandom_element here, for the same
            -- reason as Prestige/Infernal Deck's grants above.
            local chosen = divines[math.random(#divines)]

            if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                SMODS.add_card{
                    set = "Joker",
                    key = chosen.key
                }
            end
        end
    end

    return ret
end

SMODS.Back{
    key = "hard_deck",

    loc_txt = {
        name = "Hard Deck",
        text = {
            "Win ante is ante 16",
            "{C:mult}-1{} Joker slot",
            "{C:mult}-1{} hand each round",
            "{C:mult}-1{} discard each round",
            "{C:attention}-1{} hand size",
            "Start with {C:money}$0{}",
        }
    },

    -- joker_slot here is the same Steamodded Back config field
    -- Ritualistic/Relic Deck use above -- it's applied to
    -- G.jokers.config.card_limit automatically on start_run, no extra
    -- hook needed for the slot count itself. Hands/discards/hand_size/
    -- dollars have no equivalent auto-applied config field (see the
    -- comment on Gambler's Deck's hook further down for why), so those
    -- are handled manually in the start_run hook below.
    config = {
        joker_slot = -1
    },

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, Ritualistic,
    -- Relic, Prestige, Infernal, and Holy Deck (pos 1,4), per how it was
    -- requested -- move it to an unused frame in HexEnhancers before
    -- shipping if that overlap isn't intentional, since all these decks
    -- currently render with the same sprite.
    pos = { x = 1, y = 2 },

    atlas = "HexEnhancers",
}

-- Key of Hard Deck, used the same way HEX_PRESTIGE_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_HARD_DECK_KEY = "b_" .. mod.prefix .. "_hard_deck"

local function hex_hard_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_HARD_DECK_KEY
end

-- Hard Deck: raises win_ante to 16 and knocks a point off of hands,
-- discards, and hand size every round, plus starts with no money.
-- Same new-run-only guard (checking args.savetext) as the decks above,
-- so reloading a save doesn't re-subtract from an already-adjusted
-- round_resets or zero out money mid-run.
--
-- Hands/discards/hand size have no auto-applied Back config field the
-- way joker_slot does, so -- same approach Gambler's Deck's hook below
-- uses -- we overwrite the per-round baseline (round_resets) directly,
-- then fix up round 1's live counters and the hand that's already been
-- dealt by the time this runs. math.max floors keep a deck selection
-- (or a future mod stacking further reductions) from ever dropping any
-- of these to something unplayable (0 hands, negative hand size, etc.).
local old_start_run_hard_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_hard_deck(self, args, ...)

    if hex_hard_deck_selected() and not (args and args.savetext) then
        G.GAME.win_ante = 16

        G.GAME.round_resets.hands = math.max(1, (G.GAME.round_resets.hands or 4) - 1)
        G.GAME.round_resets.discards = math.max(0, (G.GAME.round_resets.discards or 3) - 1)
        G.GAME.round_resets.hand_size = math.max(1, (G.GAME.round_resets.hand_size or 8) - 1)

        if G.GAME.current_round then
            G.GAME.current_round.hands_left = G.GAME.round_resets.hands
            G.GAME.current_round.discards_left = G.GAME.round_resets.discards
        end

        G.GAME.dollars = 0

        -- Hand size: the round-1 hand has already been dealt at the
        -- vanilla/deck-default size by the time this hook runs, so trim
        -- it down to match the reduced hand_size, returning the excess
        -- cards to the deck (mirrors the shrink branch of Gambler's
        -- Deck's own hand-size fixup below).
        if G.hand and G.hand.config then
            G.hand.config.card_limit = G.GAME.round_resets.hand_size

            if G.deck then
                for i = #G.hand.cards, 1, -1 do
                    if #G.hand.cards <= G.GAME.round_resets.hand_size then break end
                    local c = G.hand:remove_card(G.hand.cards[i])
                    if c then
                        G.deck:emplace(c)
                    end
                end
            end
        end
    end

    return ret
end

SMODS.Back{
    key = "broken_deck",

    loc_txt = {
        name = "Broken Deck",
        text = {
            "Start with {C:purple}100,000{}",
            "{C:purple}Hex points{}",
        }
    },

    config = {},

    unlocked = true,
    discovered = true,

    -- NOTE: shares its atlas frame with Gambler's, Cursed, Ritualistic,
    -- Relic, Prestige, Infernal, Holy, and Hard Deck (pos 1,4), per how
    -- it was requested -- move it to an unused frame in HexEnhancers
    -- before shipping if that overlap isn't intentional, since all these
    -- decks currently render with the same sprite.
    pos = { x = 1, y = 4 },

    atlas = "HexEnhancers",
}

-- Key of Broken Deck, used the same way HEX_CURSED_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_BROKEN_DECK_KEY = "b_" .. mod.prefix .. "_broken_deck"

local function hex_broken_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_BROKEN_DECK_KEY
end

-- Broken Deck: grants 100,000 starting Hex points, the exact same
-- mechanism (and the exact same new-run-only guard) as Cursed Deck's
-- 50-point grant above, hooked separately from that deck so the two
-- amounts never interfere with each other. We deliberately set rather
-- than add to G.GAME.hex_points here, matching Cursed Deck's own
-- assignment -- since this only ever fires on a genuinely new run (not a
-- resumed save), there's nothing pre-existing to add on top of.
local old_start_run_broken_deck = Game.start_run

function Game:start_run(args, ...)
    local ret = old_start_run_broken_deck(self, args, ...)

    if hex_broken_deck_selected() and not (args and args.savetext) then
        G.GAME.hex_points = big(100000)
    end

    return ret
end

-- Key of Gambler's Deck, used the same way HEX_NEGATIVE_DECK_KEY is used
-- above, to check which deck is currently selected.
local HEX_GAMBLERS_DECK_KEY = "b_" .. mod.prefix .. "_gamblers_deck"

local function hex_gamblers_deck_selected()
    return G.GAME
        and G.GAME.selected_back
        and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
        and G.GAME.selected_back.effect.center.key == HEX_GAMBLERS_DECK_KEY
end

-- Rolls a single 1-10 stat for Gambler's Deck. Each stat gets its own tag
-- so the four rolls (hands/discards/dollars/hand_size) are independent of
-- one another instead of all landing on the same number every run.
local function hex_gamblers_roll(tag)
    local n = pseudorandom(pseudoseed(mod.prefix .. "_gamblers_" .. tag), 1, 10)
    return math.max(1, math.min(10, math.floor(n)))
end

-- Gambler's Deck: rolls random starting hands, discards, money, and hand
-- size (1-10 each) once per run, and applies them on top of whatever
-- old_start_run above already set up. Hands/discards/dollars just need
-- their stored numbers overwritten, but the starting hand of cards has
-- already been dealt out of G.deck and into G.hand by the time this runs
-- (at whatever the deck's normal default hand size is), so hand size is
-- handled separately below by topping the round-1 hand up or down to match
-- the rolled size, moving any difference to/from G.deck.
local old_start_run_gamblers_deck = Game.start_run

function Game:start_run(...)
    local ret = old_start_run_gamblers_deck(self, ...)

    if hex_gamblers_deck_selected() then
        local rolled_hands = hex_gamblers_roll("hands")
        local rolled_discards = hex_gamblers_roll("discards")
        local rolled_dollars = hex_gamblers_roll("dollars")
        local rolled_hand_size = hex_gamblers_roll("hand_size")

        G.GAME.gamblers_deck_rolls = {
            hands = rolled_hands,
            discards = rolled_discards,
            dollars = rolled_dollars,
            hand_size = rolled_hand_size,
        }

        -- Hands / Discards: overwrite both the per-round baseline
        -- (round_resets, used every time a new round starts) and, if
        -- round 1's live counters already exist by this point, those too,
        -- so round 1 itself uses the rolled values instead of the usual
        -- vanilla 4 hands / 3 discards.
        G.GAME.round_resets.hands = rolled_hands
        G.GAME.round_resets.discards = rolled_discards

        if G.GAME.current_round then
            G.GAME.current_round.hands_left = rolled_hands
            G.GAME.current_round.discards_left = rolled_discards
        end

        -- Starting money: overwrite whatever old_start_run set G.GAME.dollars to.
        G.GAME.dollars = rolled_dollars

        -- Hand size: overwrite the baseline used every round, then fix up
        -- the hand that's already been dealt for round 1.
        G.GAME.round_resets.hand_size = rolled_hand_size

        if G.hand and G.hand.config then
            G.hand.config.card_limit = rolled_hand_size

            local diff = rolled_hand_size - #G.hand.cards

            if diff > 0 and G.deck and #G.deck.cards > 0 then
                local to_draw = {}
                for i = 1, math.min(diff, #G.deck.cards) do
                    to_draw[#to_draw + 1] = G.deck.cards[i]
                end
                if #to_draw > 0 then
                    G.hand:draw(to_draw)
                end
            elseif diff < 0 then
                for i = #G.hand.cards, 1, -1 do
                    if #G.hand.cards <= rolled_hand_size then break end
                    local c = G.hand:remove_card(G.hand.cards[i])
                    if c and G.deck then
                        G.deck:emplace(c)
                    end
                end
            end
        end
    end

    return ret
end

SMODS.Joker{
    key = "musa_acuminata",

    loc_txt = {
        name = "Musa Acuminata",
        text = {
            "This Joker {C:purple}^2{}",
            "Mult",
        }
    },

    atlas = "HexJokers",
    pos = { x = 4, y = 0 },

    rarity = 1,
    cost = 4,

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
    -- Only appears after Cavendish breaks
    in_pool = function(self)
        return G.GAME and G.GAME.cavendish_broken
    end,

    calculate = function(self, card, context)

        if context.joker_main then
            return {
                func = function()
                    local power = 2

                    if card.ability and card.ability.extra then
                        power = card.ability.extra.exponent or 2
                    end

                    mult = to_big(mult):arrow(1, power)
                end,

                message = "^2",
                colour = G.C.PURPLE
            }
        end
    end
}

local old_start_dissolve = Card.start_dissolve

function Card.start_dissolve(self, ...)
    
    if self.config
    and self.config.center
    and self.config.center.key == "j_cavendish" then
        G.GAME.cavendish_broken = true
    end

    return old_start_dissolve(self, ...)
end

-- Perkeo: exclude Ritual and Star consumables from the pool Perkeo can
-- copy at end of round, without restricting either from being copied by
-- any other copy source in the game (Blueprint, other copy effects,
-- etc.) -- this only touches Perkeo's own hardcoded behaviour. Vanilla
-- hardcodes Perkeo's (and Triboulet/Yorick/Chicot/Canio's) end-of-round
-- effects by name inside the shared Card:calculate_joker function, so we
-- wrap that function, intercept only the Perkeo branch ourselves, and
-- forward every other case (including every other legendary Joker)
-- straight through to the original, untouched.
--
-- Any future custom ConsumableType this mod adds that should likewise be
-- off-limits to Perkeo just needs its set key added to this table.
local HEX_PERKEO_BLOCKED_SETS = {
    ritual = true,
    star = true,
}

local hex_old_calculate_joker = Card.calculate_joker

function Card:calculate_joker(context)
    if self.ability and self.ability.name == 'Perkeo' then
        if context.end_of_round and context.main_eval then
            if G.consumeables.cards[1] then

                -- Build the eligible pool, excluding Ritual/Star-set
                -- cards. Rituals and Stars set ConsumableType = "ritual" /
                -- "star" respectively (see the SMODS.ConsumableType{...}
                -- registrations further down this file), so this is a
                -- simple set check against each consumable's own center.
                local eligible = {}
                for _, c in ipairs(G.consumeables.cards) do
                    local blocked = c.ability
                        and HEX_PERKEO_BLOCKED_SETS[c.ability.set]
                    if not blocked then
                        eligible[#eligible + 1] = c
                    end
                end

                if eligible[1] then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local card = copy_card(pseudorandom_element(eligible, pseudoseed('perkeo')), nil)
                            card:set_edition({negative = true}, true)
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            return true
                        end
                    }))
                    card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                end
            end
            return
        end
        return
    end

    return hex_old_calculate_joker(self, context)
end

SMODS.Joker{
    key = "the_seal_of_aces",

    loc_txt = {
        name = "The Seal of Aces",
        text = {
            "Played {C:attention}Aces{} are given",
            "a {C:attention}random Seal{}",
            "{C:inactive}(Red, Gold, Blue, Purple){}"
        }
    },

    atlas = "HexJokers",
    pos = { x = 6, y = 0 }, -- next open frame in the atlas, adjust if taken

    rarity = 2,   -- uncommon
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,

    calculate = function(self, card, context)
        if context.individual
        and context.cardarea == G.play
        and not context.blueprint
        and context.other_card.base.value == "Ace" then

            local seals = { "Gold", "Red", "Blue", "Purple"}
            local chosen_seal = pseudorandom_element(seals, pseudoseed("the_seal_of_aces"))

            context.other_card:set_seal(chosen_seal, true)

            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.SEAL,
            }
        end
    end,
}

SMODS.Joker{
    key = "bonus_joker",
    loc_txt = {
        name = "Bonus Joker",
        text = {
            "This Joker gains {X:mult,C:white}X0.10{} Mult",
            "every bonus card scored",
            "(Currently {X:mult,C:white}X#1#{} Mult)"
        }
    },
    config = { extra = { Xmult = big(1), Xmult_gain = big(0.1) } },
    atlas = "HexJokers",
    pos = { x = 1, y = 0 }, -- second frame in the atlas (sprite to the right)
    rarity = 3,             -- 1 common, 2 uncommon, 3 rare, 4 legendary
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,

    calculate = function(self, card, context)

    calculate = function(self, card, context)        -- Apply the current Xmult when this joker scores
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
            }
        end

        -- Grow permanently whenever a scored card has the Bonus enhancement
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.config.center.key == "m_bonus" then
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
                return {
                    message = localize("k_upgrade_ex"),
                    colour = G.C.MULT,
                }
            end
        end
    end,

    -- Fills the #1# placeholder in the description text with the current Xmult
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
}

SMODS.Joker{
    key = "trash_bin",

    loc_txt = {
        name = "Trash bin",
        text = {
            "Gains times {X:mult,C:white}X1.5{} Mult",
            "when selling a {C:rare}Rare{} Joker",
            "(Currently {X:mult,C:white}X#1#{} Mult)"
        }
    },

    atlas = "HexJokers",
    pos = { x = 8, y = 0 },

    rarity = 4,
    cost = 20,

    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,

    config = {
        extra = {
            xmult = big(1)
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult
            }
        }
    end,

    calculate = function(self, card, context)

        -- Apply the multiplier
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.xmult,
                message = "X" .. tostring(card.ability.extra.xmult) .. " Mult"
            }
        end


        -- Detect selling a rare Joker
        if context.selling_card
        and context.card.ability
        and context.card.ability.set == "Joker"
        and context.card.config.center.rarity == 3 then

            card.ability.extra.xmult =
                card.ability.extra.xmult * big(1.5)

            return {
                message = "X" .. tostring(card.ability.extra.xmult),
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker{
    key = "royal_family",

    loc_txt = {
        name = "Royal Family",
        text = {
            "Face cards count as",
            "{C:attention}Jacks, Queens, and Kings{}",
            "at the same time"
        }
    },

    atlas = "HexJokers",
    pos = {x = 7, y = 0},

    rarity = 3,
    cost = 8,

    unlocked = true,
    discovered = true,

    blueprint_compat = false,
    eternal_compat = true,

}


SMODS.Joker{
    key = "green_screen",
    loc_txt = {
        name = "Green Screen",
        text = {
            "This Joker gains {X:mult,C:white}X1{} Mult",
            "every time a",
            "{C:attention}Full House{} is played",
            "(Currently {X:mult,C:white}X#1#{} Mult)"
        }
    },
    config = { extra = { Xmult = big(1), Xmult_gain = big(1) } },
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


SMODS.Joker{
    key = "lemniscate",

    loc_txt = {
        name = "Lemniscate",
        text = {
            "Raises final Mult to the power of {C:purple}^#1#{}",
            "Gains {C:purple}+0.01{} power",
            "for every card triggered",
        }
    },

    atlas = "HexJokers",
    pos = {x = 2, y = 0},
    soul_pos = { x = 7, y = 9 },
    rarity = "hex_mythic",
    in_pool = function(self)
        return false
    end,
    cost = 50,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,

    config = {
        extra = {
            exponent = big(1),
            exponent_gain = big(0.01)
        }
    },


    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.exponent or big(1)
            }
        }
    end,

    calculate = function(self, card, context)

        -- Count every triggered card (retriggering counts)
        if context.individual and context.cardarea == G.play then

            card.ability.extra.exponent =
                (card.ability.extra.exponent or big(1))
                + (card.ability.extra.exponent_gain or big(0.01))

            return {
                message = "Upgrade",
                colour = G.C.PURPLE
            }

        end

        -- Applied when this  Joker itself scores, in its actual position
        -- among the Joker slots, rather than being forced to the very end
        -- of scoring. Jokers to its left have already modified Mult by the
        -- time this power is applied; Jokers to its right build on top of
        -- it. Uses Amulet's OmegaNum arrow(1, b) = a^b instead of Lua's `^`
        -- so it stays accurate once Mult exceeds double-precision range.
        if context.joker_main and not context.blueprint then

            local exponent = card.ability.extra.exponent or big(1)

            -- string.format can't accept OmegaNum cdata directly, so we
            -- only convert down to a plain number for the on-screen text --
            -- the actual scoring math above always uses the big `exponent`.
            local exponent_display = hex_to_plain_number(exponent)

            return {
                func = function()
                    mult = to_big(mult):arrow(1,  exponent)
                end,
                message = "^" .. string.format("%.2f", exponent_display),
                colour = G.C.PURPLE
            }

        end
    end
}

SMODS.Joker{
    key = "overflow",

    loc_txt = {
        name = "Overflow",
        text = {
            "Gain {C:mythic}+1{} Joker slot",
            "after defeating each Boss Blind"
        }
    },

    atlas = "HexJokers",
    pos = { x = 3, y = 0 },

    rarity = "hex_mythic",
    in_pool = function(self)
        return false
    end,

    cost = 40,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,

    config = {
        extra = {
            last_ante = {}
        }
    },

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.last_ante = G.GAME.round_resets.ante - 1
    end,

    calculate = function(self, card, context)
        if context.end_of_round
        and G.GAME.blind
        and G.GAME.blind.boss
        and not context.blueprint
        and G.GAME.round_resets.ante > card.ability.extra.last_ante then

            card.ability.extra.last_ante = G.GAME.round_resets.ante

            G.E_MANAGER:add_event(Event({
                func = function()
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                    return true
                end
            }))

            return {
                message = "+1 Slot",
                colour = G.C.MYTHIC
            }
        end
    end
}

-- Orion: draws the entire remaining deck into hand at the start of every
-- round. NOTE: this used to be hooked off a `context.first_hand_drawn`
-- calculate context, but that context flag doesn't actually exist/fire in
-- this Steamodded build (that's why it was silently doing nothing and you
-- kept seeing the normal 8-card hand). The real trigger logic now lives in
-- the per-frame Game:update poll further down the file, right next to the
-- other "while owned, do X" checks like Polydactyly's hand-limit override
-- and Fractal's boss-disable check -- see hex_orion_last_round below.
SMODS.Joker{
    key = "orion",

    loc_txt = {
        name = "Orion",
        text = {
            "At the start of each round,",
            "{C:attention}draw the entire deck{}",
            "into your hand",
        }
    },

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot, same as other undrawn Mythic+ jokers

    rarity = "hex_mythic",
    in_pool = function(self)
        return false -- hidden/unlock-only rarity, like the other Mythic+ jokers
    end,

    cost = 100,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}

SMODS.Joker{
    key = "polydactyly",

    loc_txt = {
        name = "Polydactyly",
        text = {
            "{C:attention}Infinte{}",
            "card selection limit",
        }
    },

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot, same as other undrawn Mythic+ jokers

    rarity = "hex_mythic",
    in_pool = function(self)
        return false
    end,

    cost = 75,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}

-- Polydactyly: G.hand.config.highlighted_limit (set in the Game:update
-- hook further down) is enough to let you *highlight* more than 5 cards,
-- since CardArea:add_to_highlighted reads that value live. But the Play
-- Hand button's enable/disable check, G.FUNCS.can_play, has its own
-- hardcoded `#G.hand.highlighted > 5` in vanilla Balatro -- completely
-- separate from highlighted_limit -- so it greys out past 5 regardless.
-- We override can_play to drop that hardcoded cap while Polydactyly is
-- owned. (can_discard has no equivalent hardcoded cap in vanilla, so it
-- doesn't need a matching override.)
local function hex_owns_polydactyly()
    return SMODS.find_card and #SMODS.find_card("j_" .. mod.prefix .. "_polydactyly") > 0
end

local old_can_play = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
    if hex_owns_polydactyly() then
        if #G.hand.highlighted <= 0 or (G.GAME.blind and G.GAME.blind.block_play) then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.BLUE
            e.config.button = "play_cards_from_highlighted"
        end
    else
        old_can_play(e)
    end
end

-- Discard: this installed game's version of can_discard apparently also
-- hardcodes an upper cap (unlike the source snapshot checked during
-- development, which only gated on discards_left/highlighted<=0) -- same
-- symptom as can_play, same fix: bypass it entirely while Polydactyly is
-- owned and just gate on the two things that should actually matter,
-- discards remaining and having something highlighted.
local old_can_discard = G.FUNCS.can_discard
G.FUNCS.can_discard = function(e)
    if hex_owns_polydactyly() then
        if (G.GAME.current_round and (G.GAME.current_round.discards_left or 0) <= 0)
        or #G.hand.highlighted <= 0 then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.RED
            e.config.button = "discard_cards_from_highlighted"
        end
    else
        old_can_discard(e)
    end
end

SMODS.Joker{
    key = "coupon",

    loc_txt = {
        name = "Coupon",
        text = {
            "Rerolls in the shop",
            "always cost {C:money}$1{}"
        }
    },

    rarity = "hex_mythic",
    in_pool = function(self) return false end, -- hidden/unlock-only rarity, like the other Mythic+ jokers

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot, same as other undrawn Mythic+ jokers

    cost = 100,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}

SMODS.Joker{
    key = "the_monolith",

    loc_txt = {
        name = "The Monolith",
        text = {
            "Gain {C:ritual}+1{} additional",
            "{C:ritual}Hex{} point whenever",
            "you {C:ritual}Hex{} a Joker",
        }
    },

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot, same as other undrawn Mythic+ jokers

    rarity = "hex_mythic",
    in_pool = function(self)
        return false -- hidden/unlock-only rarity, like Overflow/Exponent Joker
    end,

    cost = 100,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}


-- Juno: raises final Mult by tetration (^^), with the tetration height
-- equal to the number of currently owned Jokers -- Juno counts itself,
-- so 5 owned Jokers (Juno included) means the final Mult is raised to
-- ^^5. Unlike Exponent Joker, this isn't a permanent stacking counter;
-- the height is derived live from #G.jokers.cards every time it scores,
-- so it rises and falls immediately as Jokers are bought/sold/destroyed,
-- the same "fully dynamic" approach Absolute uses for its hyperoperator
-- bonus. `to_big(mult):arrow(2, height)` is Amulet's OmegaNum tetration
-- (arrow(2, n) = ^^n), applied directly to the current running Mult.
SMODS.Joker{
    key = "juno",

    loc_txt = {
        name = "Juno",
        text = {
            "{C:transcendental}^^#1#{} {C:mult}mult{}",
            "{C:transcendental}+1{} per owned Joker",
        }
    },

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot, same as other undrawn Transcendental+ jokers

    rarity = "hex_transcendental",
    in_pool = function(self)
        return false -- hidden/unlock-only rarity, like Aria/Overflow/Exponent Joker
    end,

    cost = 2500,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,

    -- Fills the #1# placeholder in the description text with the current
    -- tetration height (i.e. how many Jokers are currently owned).
    loc_vars = function(self, info_queue, card)
        local height = (G.jokers and #G.jokers.cards) or 1
        return { vars = { height } }
    end,

    calculate = function(self, card, context)
        -- Applied when Juno itself scores, in its actual position among
        -- the Joker slots (like Musa Acuminata's ^2), rather than being
        -- forced to the very end of scoring. Jokers to Juno's left have
        -- already applied their Mult changes when this tetration happens,
        -- and Jokers to Juno's right apply on top of it.
        if context.joker_main then
            local height = (G.jokers and #G.jokers.cards ) or 1

            if height > 0 then
                return {
                    func = function()
                        mult = to_big(mult):arrow(2, height)
                    end,
                    message = "^^" .. tostring(height),
                    colour = G.C.RITUAL
                }
            end
        end
    end,
}


-- Endless Abyss: grants a flat +99,995 Joker slots while owned, using the
-- same add_to_deck/remove_from_deck lifecycle Steamodded Jokers get (the
-- same pair Inaccessible's add_to_deck already uses elsewhere in this
-- file for its own one-shot flag flip). Adding the bonus in add_to_deck
-- and symmetrically subtracting it in remove_from_deck means it's applied
-- exactly once no matter how the card enters/leaves your Jokers (bought,
-- created via Life/Manifest-style summon, sold, destroyed, etc.), rather
-- than needing a per-frame poll like Polydactyly/Coupon/Fractal above.
SMODS.Joker{
    key = "endless_abyss",

    loc_txt = {
        name = "Endless Abyss",
        text = {
            "Gives {C:divine}Infinite{}",
            "{C:attention}Joker slots{}",
        }
    },

    rarity = "hex_divine",
    in_pool = function(self) return false end, -- hidden/unlock-only rarity, like the other Divine jokers

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot shared with the other undrawn Divine/Transcendental jokers

    cost = 75000,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 99995
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 99995
    end,
}

SMODS.Joker{
    key = "oracle",

    loc_txt = {
        name = "Oracle",
        text = {
            "Rituals can be",
            "{C:attention}summoned more than once{}",
        }
    },

    rarity = "hex_divine",
    in_pool = function(self) return false end, -- hidden/unlock-only rarity, like the other Divine jokers

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot shared with the other undrawn Divine/Transcendental jokers

    cost = 50000,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}

SMODS.Joker{
    key = "phanes",

    loc_txt = {
        name = "Phanes",
        text = {
            "The {C:ritual}Life{} ritual can",
            "also bring {C:transcendental}Transcendental{}",
            "Jokers to life",
        }
    },

    rarity = "hex_divine",
    in_pool = function(self) return false end, -- hidden/unlock-only rarity, like the other Divine jokers

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot shared with the other undrawn Divine/Transcendental jokers

    cost = 50000,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
}

SMODS.Joker{
    key = "inaccessible",

    loc_txt = {
        name = "Inaccessible",
        text = {
            "Permanently unlocks a button to",
            "summon {C:absolute}Absolute{} for",
            "{C:absolute}1.0e21{} Hex points",
            "{C:attention}Destroys all other Jokers{}",
            "when summoned",
        }
    },

    rarity = "hex_divine",
    in_pool = function(self) return false end, -- hidden/unlock-only rarity, like the other Divine jokers

    atlas = "HexJokers",
    pos = { x = 5, y = 0 }, -- placeholder art slot shared with the other undrawn Divine/Transcendental jokers

    cost = 100000,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,

    -- Flips the flag that permanently unlocks the "Summon Absolute" button
    -- for the rest of this run (see the Game:update hook and start_run
    -- reset near the button-creation code further down the file).
    add_to_deck = function(self, card, from_debuff)
        G.GAME.hex_inaccessible_unlocked = true
    end,
}

SMODS.Joker{
    key = "absolute",
    loc_txt = {
        name = "Absolute",
        text = {
            "Increases {C:chips}chips{}-{C:mult}mult{} hyperoperator",
            "by 1 for every hex point currently ownded + 1"
        }   
    },
    rarity = "hex_absolute",
    in_pool = function(self) return false end, 

    atlas = "HexJokers",
    pos = { x = 5, y = 0 },
    cost = 0,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,  
}





SMODS.Consumable{
    key = "heart",
    set = "Spectral",

    atlas = "HexPlanetsSpectrals",
    pos = {x = 2, y = 2},
    soul_pos = {x = 6, y = 5 },
    unlocked = true,
    discovered = true,

    soul_set = "Tarot",
    soul_rate = 0.001,

    in_pool = function(self, args)
        return false
    end,

    loc_txt = {
        name = "Heart",
        text = {
            "Creates a random",
            "{V:1,E:2}Mythic{} Joker"
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                colours = { G.C.MYTHIC }
            }
        }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)

        local mythics = {}

        -- Mythic+ rarities are always capped at one copy each, even with
        -- Showman -- Showman only affects normal-rarity Jokers, so we
        -- filter out already-owned Mythics unconditionally here (same
        -- rule Divine grants already enforce elsewhere in this file).
        for _, center in pairs(G.P_CENTERS) do
            if center.set == "Joker"
            and center.rarity == R_HEX_MYTHIC.key
            and #SMODS.find_card(center.key) == 0 then
                mythics[#mythics+1] = center
            end
        end

        if #mythics > 0 then
            local chosen = mythics[math.random(#mythics)]

            SMODS.add_card{
                set = "Joker",
                key = chosen.key
            }

            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = "Mythic!",
                colour = G.C.MYTHIC
            })
        end
    end
}


















SMODS.ConsumableType{
    key = "ritual",
    primary_colour = G.C.RITUAL,
    secondary_colour = G.C.RITUAL,
    collection_rows = { 4, 4 },
    shop_rate = 0,          -- never appears in normal shop generation
    loc_txt = {
        name = "Ritual",
        collection = "Rituals",
        undiscovered = {
            name = "Undiscovered Ritual",
            text = {
                "Use this Ritual",
                "to discover it"
            }
        }
    },
    can_stack = true,
    can_divide = true,
}

-- Stars: never appear in the shop (shop_rate = 0) and never generated by
-- the normal Spectral/Tarot draw pools (Sol below sets in_pool = false,
-- the same way every Ritual does) -- instead, each is given a flat
-- 1-in-33 chance to replace a card slot in a Spectral or Arcana pack,
-- via the create_card hook near the top of this file.
SMODS.ConsumableType{
    key = "star",
    primary_colour = G.C.STAR,
    secondary_colour = G.C.STAR,
    badge_colour = G.C.STAR,
    collection_rows = { 6, 6 },
    shop_rate = 0,          -- never appears in normal shop generation
    loc_txt = {
        name = "Star",
        collection = "Stars",
        undiscovered = {
            name = "Undiscovered Star",
            text = {
                "Use this Star",
                "to discover it"
            }
        }
    },
    can_stack = true,
    can_divide = true,
}

-- Sol: rather than just knocking down the currently active blind's chip
-- requirement (a one-off, single-blind effect), Sol permanently shrinks
-- every blind's score requirement, present and future, by a stacking
-- X0.9 each time a Sol card is used. This is stored as a persistent
-- multiplier on G.GAME (hex_sol_blind_mult, starting at 1) that vanilla's
-- own get_blind_amount(ante) -- the function that computes a blind's
-- chip target for a given ante -- gets hooked to multiply its result by,
-- so it applies uniformly to every blind's requirement from here on,
-- however many times Sol is used (0.9, then 0.81, then 0.729, ...).
local old_get_blind_amount = get_blind_amount

function get_blind_amount(ante)
    local amount = old_get_blind_amount(ante)
    local mult = (G.GAME and G.GAME.hex_sol_blind_mult) or 1

    if mult ~= 1 then
        -- Blind chip totals aren't OmegaNum-scaled the way scoring
        -- Chips/Mult are, so a plain Lua multiply + floor is safe here
        -- even with Amulet installed.
        amount = math.floor(amount * mult)
    end

    return amount
end

SMODS.Consumable{
    key = "sol",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 0, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Sol",
        text = {
            "Permanently makes the size",
            "of {C:attention}every Blind{} {C:attention}X0.9{}",
            "smaller",
            "{C:inactive}(Currently X#1#){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        local mult = (G.GAME and G.GAME.hex_sol_blind_mult) or 1
        return { vars = { string.format("%.3f", mult) } }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_sol_blind_mult = ((G.GAME and G.GAME.hex_sol_blind_mult) or 1) * 0.9

        -- Apply immediately to whatever blind is currently active too,
        -- rather than only taking effect starting next blind.
        if G.GAME.blind and G.GAME.blind.chips then
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.9)

            if G.GAME.blind.chip_text then
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            end
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "X0.9 Blind Size",
            colour = G.C.STAR
        })
    end,
}

-- Sirius: permanently grants +1 hand size. Mirrors the hand-size fixup
-- code Gambler's/Hard Deck already use elsewhere in this file -- bump
-- the per-round baseline (round_resets.hand_size, so every future round
-- also deals the extra card) and the live G.hand.config.card_limit, then
-- immediately draw one more card from the deck if one's available so the
-- extra slot doesn't just sit empty until the next round.
SMODS.Consumable{
    key = "sirius",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 1, y = 0 }, -- placeholder art slot, next open frame after Sol; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Sirius",
        text = {
            "Permanently gain",
            "{C:attention}+1{} hand size",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.round_resets.hand_size = (G.GAME.round_resets.hand_size or 8) + 1

        if G.hand and G.hand.config then
            G.hand.config.card_limit = G.hand.config.card_limit + 1

            if G.deck and #G.deck.cards > 0 then
                G.hand:draw({ G.deck.cards[1] })
            end
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+1 Hand Size",
            colour = G.C.STAR
        })
    end,
}

-- Deneb: a straightforward one-off Hex point grant, the same mechanism
-- (and the same big() wrapper for Amulet/OmegaNum compatibility) the
-- Cursed/Broken Deck starting grants and The Monolith's Hex bonus above
-- already use.
SMODS.Consumable{
    key = "deneb",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 2, y = 0 }, -- placeholder art slot, next open frame after Sirius; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Deneb",
        text = {
            "Gain {C:ritual}12{}",
            "{C:ritual}Hex points{}",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_points = (G.GAME.hex_points or big(0)) + big(12)

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+12 Hex",
            colour = G.C.HEX_ORPLE or G.C.STAR
        })
    end,
}

-- Pollux: permanently grants +1 hand every round. Same round_resets
-- pattern as Sirius above -- bump the per-round baseline so every future
-- round gets the extra hand, and also top up the current round's live
-- counter (if one exists) so the bonus is felt immediately rather than
-- waiting for the next round to start.
SMODS.Consumable{
    key = "pollux",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 3, y = 0 }, -- placeholder art slot, next open frame after Deneb; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Pollux",
        text = {
            "Permanently gain",
            "{C:attention}+1{} hand",
            "every round",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 4) + 1

        if G.GAME.current_round then
            G.GAME.current_round.hands_left = (G.GAME.current_round.hands_left or 0) + 1
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+1 Hand",
            colour = G.C.STAR
        })
    end,
}

-- Castor: permanently grants +1 discard every round. Identical pattern to
-- Pollux above, just against round_resets.discards / discards_left
-- instead of hands.
SMODS.Consumable{
    key = "castor",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 4, y = 0 }, -- placeholder art slot, next open frame after Pollux; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Castor",
        text = {
            "Permanently gain",
            "{C:attention}+1{} discard",
            "every round",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.round_resets.discards = (G.GAME.round_resets.discards or 3) + 1

        if G.GAME.current_round then
            G.GAME.current_round.discards_left = (G.GAME.current_round.discards_left or 0) + 1
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+1 Discard",
            colour = G.C.STAR
        })
    end,
}

-- Fomalhaut: sets the ante back one step (the same G.GAME.round_resets.
-- ante field Overflow above already reads as the authoritative
-- current-ante value). Unlike vanilla's Hieroglyph voucher this doesn't
-- cost a Hand, and there's no floor -- repeated uses can push the ante
-- into negative numbers with no lower bound.
SMODS.Consumable{
    key = "fomalhaut",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 5, y = 0 }, -- placeholder art slot, next open frame after Castor; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Fomalhaut",
        text = {
            "{C:attention}-1{} Ante",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.round_resets.ante = (G.GAME.round_resets.ante or 1) - 1

        -- G.GAME.round_resets.ante is the value scoring/blind-amount code
        -- reads (see get_blind_amount's caller and Overflow's own check
        -- above), but the HUD's on-screen ante counter is actually driven
        -- by a *separate* field, G.GAME.round_resets.ante_disp -- so only
        -- touching .ante changes blind difficulty correctly but leaves
        -- the visible number on screen stale. Keep them in lockstep here
        -- so the UI updates immediately.
        if G.GAME.round_resets.ante_disp then
            G.GAME.round_resets.ante_disp = G.GAME.round_resets.ante_disp - 1
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "-1 Ante",
            colour = G.C.STAR
        })
    end,
}

-- Saiph: permanently discounts shop rerolls by $1, floored so the cost
-- can never drop below $1. Same round_resets/current_round pairing as
-- Coupon's flat pin above -- adjusting round_resets.reroll_cost keeps
-- every future shop's starting price down, and adjusting current_round.
-- reroll_cost too means an already-open shop feels the discount right
-- away rather than waiting for the next one. Because both fields are
-- shifted down permanently (rather than being pinned to a fixed value
-- like Coupon does), vanilla's own per-reroll cost escalation on top of
-- that baseline is untouched -- rerolling still gets pricier as normal,
-- just $1 cheaper at every step, further stacking with each extra Saiph.
SMODS.Consumable{
    key = "saiph",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 6, y = 0 }, -- placeholder art slot, next open frame after Fomalhaut; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Saiph",
        text = {
            "Permanently makes shop",
            "{C:money}rerolls{} cost {C:money}$1{} less",
            "{C:inactive}(Minimum $1){}"
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.round_resets.reroll_cost = math.max(1, (G.GAME.round_resets.reroll_cost or 5) - 1)

        if G.GAME.current_round then
            G.GAME.current_round.reroll_cost = math.max(1, (G.GAME.current_round.reroll_cost or 5) - 1)
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "-$1 Reroll",
            colour = G.C.STAR
        })
    end,
}

-- Spica: permanently raises the interest cap by $5 -- the same field
-- (G.GAME.interest_cap, base 5) vanilla's own Seed Money/Money Tree
-- vouchers raise to $10/$20 respectively.
SMODS.Consumable{
    key = "spica",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 7, y = 0 }, -- placeholder art slot, next open frame after Saiph; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Spica",
        text = {
            "Permanently increases the",
            "{C:money}interest{} cap by {C:money}$5{}",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.interest_cap = (G.GAME.interest_cap or 5) + 5

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+$5 Cap",
            colour = G.C.STAR
        })
    end,
}

-- Vega: gives 6 levels to a random poker hand, using vanilla's own
-- level_up_hand(card, hand_key, bypass_visual, amount) function -- the
-- same one Planet cards call -- against a hand key picked at random from
-- every currently-visible entry in G.GAME.hands (so it only ever targets
-- a hand type the player has actually discovered/can see, never a
-- still-hidden secret hand).
SMODS.Consumable{
    key = "vega",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 8, y = 0 }, -- placeholder art slot, next open frame after Spica; move if a dedicated sprite exists

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Vega",
        text = {
            "Gives {C:attention}6{} levels",
            "to a {C:attention}random{}",
            "poker hand",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        local hand_keys = {}
        for k, h in pairs(G.GAME.hands) do
            if h.visible then
                hand_keys[#hand_keys + 1] = k
            end
        end

        if #hand_keys > 0 then
            local chosen = pseudorandom_element(hand_keys, pseudoseed(mod.prefix .. "_vega"))
            level_up_hand(card, chosen, nil, 6)
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+6 Levels",
            colour = G.C.STAR
        })
    end,
}

-- Canopus: permanently boosts every future Black Hole use by +1 extra
-- Planet level, stacking with each copy used. Like Sirius/Pollux/Castor
-- above, the bonus itself is just a persistent counter on G.GAME
-- (hex_canopus_bonus_levels) -- the actual application happens in the
-- Black Hole hook right below this card's definition.
SMODS.Consumable{
    key = "canopus",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 9, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Canopus",
        text = {
            "Permanently gives the",
            "{C:attention}Black Hole{} Spectral card",
            "{C:attention}+1{} extra Planet level",
            "{C:inactive}(Currently +#1#){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.hex_canopus_bonus_levels) or 0 } }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_canopus_bonus_levels = (G.GAME.hex_canopus_bonus_levels or 0) + 1

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+1 Black Hole",
            colour = G.C.STAR
        })
    end,
}

-- Toliman: permanently grants +$10 at cash-out, but only after a Boss
-- Blind. Stored the same way (persistent counter, stacks per copy used);
-- actually paid out in the G.FUNCS.cash_out hook below.
SMODS.Consumable{
    key = "toliman",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 0, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Toliman",
        text = {
            "Permanently gain {C:money}$10{}",
            "extra at the end of every",
            "{C:attention}Boss Blind{} when",
            "cashing out",
            "{C:inactive}(Currently +$#1#){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.hex_toliman_bonus) or 0 } }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_toliman_bonus = (G.GAME.hex_toliman_bonus or 0) + 10

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+$10 Boss Cash",
            colour = G.C.STAR
        })
    end,
}

-- Rigil Kentaurus: permanently grants +$3 at cash-out after every Blind
-- (Small/Big/Boss alike), stacking with Toliman's boss-only bonus above
-- rather than replacing it. Same persistent-counter pattern.
SMODS.Consumable{
    key = "rigil_kentaurus",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 1, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Rigil Kentaurus",
        text = {
            "Permanently gain {C:money}$3{}",
            "extra after every Blind",
            "when cashing out",
            "{C:inactive}(Currently +$#1#){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.hex_rigil_bonus) or 0 } }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_rigil_bonus = (G.GAME.hex_rigil_bonus or 0) + 3

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+$3 Cash",
            colour = G.C.STAR
        })
    end,
}

-- Canopus display fix: vanilla Black Hole's own animation code hardcodes
-- `level = '+1'` in its final update_hand_text call, regardless of how
-- many levels are actually being applied -- so with Canopus adding bonus
-- levels on top, the on-screen text was lying about the real amount.
-- Since that call happens deep inside Card:use_consumeable's own Black
-- Hole branch (not something we can reach after the fact), we instead
-- wrap update_hand_text globally and, while our flag is armed, rewrite
-- any '+1' level text to the real total the instant Black Hole's code
-- tries to display it.
local hex_old_update_hand_text = update_hand_text
local hex_black_hole_display_total = nil

function update_hand_text(config, vars)
    if hex_black_hole_display_total and vars and vars.level == '+1' then
        vars.level = "+" .. tostring(hex_black_hole_display_total)
    end
    return hex_old_update_hand_text(config, vars)
end

-- Canopus hook: intercepts every consumable use via the Card class method
-- itself (Card:use_consumeable), rather than patching the Black Hole
-- center's .use function directly -- G.P_CENTERS entries can be
-- rebuilt/reassigned after mod load, which was silently breaking the
-- direct-patch version. We arm hex_black_hole_display_total with the
-- real total (vanilla's base 1 + Canopus's bonus) right before calling
-- the original Black Hole logic, so its own hardcoded '+1' text gets
-- rewritten via the update_hand_text wrapper above, then apply the extra
-- levels on top exactly as before once the original call returns.
local hex_old_use_consumeable = Card.use_consumeable

function Card:use_consumeable(area, copier)
    local is_black_hole = self.ability and self.ability.name == 'Black Hole'
    local bonus = 0

    if is_black_hole then
        bonus = (G.GAME and G.GAME.hex_canopus_bonus_levels) or 0
        hex_black_hole_display_total = 1 + bonus
    end

    local ret = hex_old_use_consumeable(self, area, copier)

    hex_black_hole_display_total = nil

    if is_black_hole and bonus > 0 and G.GAME and G.GAME.hands then
        for k, v in pairs(G.GAME.hands) do
            level_up_hand(self, k, true, bonus)
        end
    end

    return ret
end


-- Lightweight stand-in for a real Card, just enough to satisfy what
-- add_round_eval_row's 'joker' row branch and its generic juice_up call
-- need (config.card.config.center.set / .key, and a :juice_up method).
-- Used below to show a Rocket/Golden-Joker-style "+$X" line for Rigil
-- Kentaurus/Toliman -- unlike an actual Joker, these are consumables
-- that have already been used and are long gone from the board by the
-- time this fires, so there's no live Card object to hand over; this
-- just points at the same center (G.P_CENTERS entry) a real card of
-- that kind would have, which is all localize{type='name_text', ...}
-- actually reads to look up the display name.
local function hex_star_bonus_card_stub(short_key)
    return {
        config = { center = G.P_CENTERS["c_" .. mod.prefix .. "_" .. short_key] },
        juice_up = function() end,
    }
end

-- Toliman / Rigil Kentaurus hook: folds the bonus into config.dollars on
-- add_round_eval_row's final 'bottom' row -- the row that both builds the
-- "Cash Out: $X" button and stores X into G.GAME.current_round.dollars.
-- Deliberately does NOT call ease_dollars itself: add_round_eval_row has
-- no money-crediting calls anywhere in it (it's purely display), and the
-- actual wallet credit happens later, inside vanilla's own G.FUNCS.
-- cash_out, which pays out G.GAME.current_round.dollars the moment the
-- button is clicked. So bumping config.dollars here is enough on its
-- own: the button's number already includes the bonus, and vanilla's
-- own click handler pays out that whole (bonus-inclusive) number exactly
-- once. Two earlier versions of this got it wrong in opposite
-- directions -- one hooked G.FUNCS.cash_out and called ease_dollars
-- itself, landing the bonus as its own separate pop disconnected from
-- the button's number; the other did that *and* bumped config.dollars
-- here, which double-paid it (once from our own ease_dollars call, once
-- again when vanilla's cash_out paid out the now-inflated
-- current_round.dollars).
--
-- Also adds its own "+$X" breakdown row for each Star card that actually
-- contributed money this round, immediately before the Cash Out row --
-- the exact same 'joker' row rendering path Rocket/Golden Joker's own
-- calculate_dollar_bonus rides on (add_round_eval_row branches on
-- string.find(config.name, 'joker') to show a card's name via its own
-- loc_txt, regardless of whether the card is an actual Joker). Toliman's
-- row only ever appears when toliman_bonus > 0, which is already gated
-- on is_boss_blind above, so it naturally only shows up after Boss
-- Blinds -- no extra check needed here.
--
-- Guarded by G.GAME.round purely as cheap insurance against this
-- somehow firing more than once for the same round -- it self-clears the
-- moment the round number moves on to the next round.
local hex_old_add_round_eval_row = add_round_eval_row

function add_round_eval_row(config)
    if config and config.name == 'bottom'
    and G.GAME and G.GAME.round
    and G.GAME.hex_cash_out_paid_round ~= G.GAME.round then

        local is_boss_blind = G.GAME.blind and G.GAME.blind.boss

        local rigil_bonus = G.GAME.hex_rigil_bonus or 0
        local toliman_bonus = is_boss_blind and (G.GAME.hex_toliman_bonus or 0) or 0
        local bonus = rigil_bonus + toliman_bonus

        if bonus > 0 then
            G.GAME.hex_cash_out_paid_round = G.GAME.round
            config.dollars = (config.dollars or 0) + bonus

            if rigil_bonus > 0 then
                hex_old_add_round_eval_row({
                    name = 'joker_hex_rigil_kentaurus',
                    dollars = rigil_bonus,
                    card = hex_star_bonus_card_stub('rigil_kentaurus'),
                    pitch = 1,
                })
            end

            if toliman_bonus > 0 then
                hex_old_add_round_eval_row({
                    name = 'joker_hex_toliman',
                    dollars = toliman_bonus,
                    card = hex_star_bonus_card_stub('toliman'),
                    pitch = 1,
                })
            end
        end
    end

    return hex_old_add_round_eval_row(config)
end





-- Proxima Centauri: creates two random Jokers, each forced Negative.
-- Negative edition Jokers don't count against the Joker slot limit in
-- vanilla Balatro (that's the whole point of the edition), so unlike the
-- Life ritual/Relic-Deck-style grants elsewhere in this file, there's no
-- need to check G.jokers.config.card_limit here -- both copies are always
-- created regardless of how full the Joker row already is. SMODS.add_card
-- with no `key` behaves like a normal shop roll (random Joker respecting
-- in_pool), the same shortcut Heart/Prestige/Relic/Infernal/Holy Deck's
-- grants above use, just without pinning a rarity -- so this can hand out
-- any ordinary-rarity Joker, same odds as the shop. Staggered by a short
-- delay between the two so their materialize animations don't perfectly
-- overlap.
SMODS.Consumable{
    key = "proxima_centauri",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 2, y = 1 }, -- next open frame in the atlas, after Rigil Kentaurus (1,1)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Proxima Centauri",
        text = {
            "Creates {C:attention}2{} random",
            "{C:attention}Negative{} Jokers",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        for i = 1, 2 do
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.2 * i,
                func = function()
                    local new_card = SMODS.add_card({ set = "Joker" })
                    if new_card then
                        new_card:set_edition({ negative = true }, true)
                    end
                    return true
                end
            }))
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+2 Negative",
            colour = G.C.STAR
        })
    end,
}


-- Barnard's Star: picks one currently-owned Joker *without* an edition
-- already and gives it a random Foil/Holographic/Polychrome edition --
-- same restriction vanilla's own Wheel of Fortune tarot card uses (it
-- only ever targets editionless Jokers, so it can never overwrite/waste
-- an edition you already earned). Eligible pool is built by filtering
-- G.jokers.cards down to cards with no card.edition set, then picked
-- from with the same pseudorandom_element pattern The Seal of Aces uses
-- above for its seal roll. can_use (and use, as a second guard in case
-- the eligible set changes between opening the menu and clicking) both
-- require at least one editionless Joker to exist.
SMODS.Consumable{
    key = "barnards_star",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 3, y = 1 }, -- next open frame in the atlas, after Proxima Centauri (2,1)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Barnard's Star",
        text = {
            "Gives a {C:attention}random{} Joker",
            "{C:attention}without an Edition{}",
            "{C:attention}Foil{}, {C:attention}Holographic{},",
            "or {C:attention}Polychrome{}",
        }
    },

    -- Shared helper so can_use and use always agree on what's eligible.
    can_use = function(self, card)
        if not (G.jokers and G.jokers.cards) then return false end

        for _, j in ipairs(G.jokers.cards) do
            if not j.edition then
                return true
            end
        end

        return false
    end,

    use = function(self, card)
        if not (G.jokers and G.jokers.cards) then return end

        local eligible = {}
        for _, j in ipairs(G.jokers.cards) do
            if not j.edition then
                eligible[#eligible + 1] = j
            end
        end

        if not eligible[1] then return end

        local chosen_joker = pseudorandom_element(
            eligible,
            pseudoseed(mod.prefix .. "_barnards_star_joker")
        )

        local editions = { "foil", "holo", "polychrome" }
        local chosen_edition = pseudorandom_element(
            editions,
            pseudoseed(mod.prefix .. "_barnards_star_edition")
        )

        chosen_joker:set_edition({ [chosen_edition] = true }, true)

        card_eval_status_text(chosen_joker, "extra", nil, nil, nil, {
            message = localize("k_upgrade_ex"),
            colour = G.C.STAR
        })
    end,
}


-- Bellatrix: grants 3 Double Tags. Uses vanilla Balatro's own tag-granting
-- API (`add_tag(Tag(key))`), the same mechanism vanilla content uses to
-- hand out tags outside of the normal Blind-skip flow -- "tag_double" is
-- vanilla's own key for the Double Tag (the tag that duplicates the next
-- tag you get). Three separate add_tag calls rather than a single call
-- with a count, since add_tag only ever inserts one tag per call.
SMODS.Consumable{
    key = "bellatrix",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 4, y = 1 }, -- next open frame in the atlas, after Barnard's Star (3,1)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Bellatrix",
        text = {
            "Gain {C:attention}3{}",
            "{C:attention}Double{} Tags",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        for i = 1, 3 do
            add_tag(Tag("tag_double"))
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+3 Double Tags",
            colour = G.C.STAR
        })
    end,
}

-- Cappella: gives one selected playing card a Black Seal. Same
-- "select exactly one card from hand, then use" pattern vanilla's own
-- Seal-granting Spectral cards (Deja Vu/Trance/Talisman/Medium) use --
-- can_use gates on exactly one highlighted card in G.hand, and use()
-- applies the seal to that card via Card:set_seal, the same call
-- The Seal of Aces Joker already uses elsewhere in this file (passing
-- the capitalized "Black" name, matching that Joker's own seal list).
SMODS.Consumable{
    key = "cappella",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 5, y = 1 }, -- next open frame in the atlas, after Bellatrix (4,1)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Cappella",
        text = {
            "Gives {C:attention}1{} selected",
            "playing card a",
            "{C:attention}Black Seal{}",
        }
    },

    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,

    use = function(self, card)
        if not (G.hand and G.hand.highlighted and G.hand.highlighted[1]) then return end

        local target = G.hand.highlighted[1]
        target:set_seal(mod.prefix .. "_black", true)   -- was just "black"

        card_eval_status_text(target, "extra", nil, nil, nil, {
            message = "Black Seal",
            colour = G.C.STAR
        })
    end,
}





















-- Rigel: creates 2 Negative Planet cards, 2 Negative Tarot cards, and 1
-- Negative Spectral card, staggered by a short delay each (same
-- staggering technique Proxima Centauri already uses above for its own
-- two Negative Jokers) so their materialize animations don't perfectly
-- overlap. Unlike Negative Jokers (which are exempt from the Joker slot
-- limit), Negative consumables still count against the normal
-- consumable slot limit, so each creation is individually gated on
-- there being room in G.consumeables at the moment it actually fires --
-- a card queued up before the area fills up would otherwise just be
-- silently lost. SMODS.create_card with only `set` (no `key`) behaves
-- like a normal draw from that type's pool -- the same shortcut Black
-- Seal's Spectral grant elsewhere in this file uses -- so every card
-- here is a genuinely random member of its type, just always Negative.
SMODS.Consumable{
    key = "rigel",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 6, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Rigel",
        text = {
            "Creates {C:attention}2{} {C:attention}Negative{}",
            "Planet cards, {C:attention}2{} {C:attention}Negative{}",
            "Tarot cards, and {C:attention}1{}",
            "{C:attention}Negative{} Spectral card",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        local to_create = { "Planet", "Planet", "Tarot", "Tarot", "Spectral" }

        for i, card_type in ipairs(to_create) do
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.2 * i,
                func = function()
                    if G.consumeables then
                        -- Deliberately no slot-limit check here -- Rigel
                        -- always creates all 5 cards regardless of how
                        -- full the consumable area already is, the same
                        -- way Negative Jokers ignore the Joker slot limit
                        -- elsewhere in this file.
                        local new_card = SMODS.create_card({
                            set = card_type,
                            area = G.consumeables
                        })

                        new_card:set_edition({ negative = true }, true)

                        G.consumeables:emplace(new_card)
                    end
                    return true
                end
            }))
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+5 Negative",
            colour = G.C.STAR
        })
    end,
}

-- Arcturus: permanently grants +1 consumable slot, the same effect the
-- vanilla Crystal Ball voucher gives -- but as a Star card rather than a
-- voucher, it isn't limited to a single purchase, so every additional
-- copy used stacks another +1 on top, uncapped. Straightforward direct
-- bump of G.consumeables.config.card_limit, the same field Crystal Ball
-- itself raises.
SMODS.Consumable{
    key = "arcturus",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 7, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Arcturus",
        text = {
            "Permanently gain",
            "{C:attention}+1{} consumable slot",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        if G.consumeables and G.consumeables.config then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+1 Slot",
            colour = G.C.STAR
        })
    end,
}

-- Procyon: disables the next Boss Blind encountered. Stores a stacking
-- charge counter (G.GAME.hex_procyon_charges) rather than a single flag,
-- so using multiple copies of this card queues up multiple future Boss
-- Blind disables rather than only ever affecting one. The actual
-- disabling happens in the Game:update hook further down the file, right
-- alongside Fractal's own boss-disable poll -- same Blind:disable() call
-- Chicot/Fractal already use, just gated on `charges > 0` instead of a
-- permanent "used" flag, and decremented by 1 every time it actually
-- fires. Checking `not G.GAME.blind.disabled` (same guard Fractal uses)
-- naturally prevents this from double-decrementing on later frames once
-- a given Boss Blind is already disabled -- the charge is only spent the
-- one frame the disable actually happens.
SMODS.Consumable{
    key = "procyon",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 8, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Procyon",
        text = {
            "The next {C:attention}Boss Blind{}",
            "is {C:attention}disabled{}",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_procyon_charges = (G.GAME.hex_procyon_charges or 0) + 1

        -- If a Boss Blind is already active/selected right now, disable
        -- it immediately rather than waiting up to a frame -- same
        -- immediate-apply treatment Fractal's own use function gives its
        -- currently-active Boss Blind.
        if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
            G.GAME.blind:disable()
            G.GAME.hex_procyon_charges = G.GAME.hex_procyon_charges - 1
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Boss Disabled!",
            colour = G.C.STAR
        })
    end,
}

-- Polaris: finds whichever poker hand type has been played the most
-- times so far this run (G.GAME.hands[key].played, vanilla's own
-- cumulative play counter -- the same field the "Most Played Hand" stat
-- reads), and permanently raises that hand's base Chips and Mult to the
-- power of 1.1. Unlike Eclipse (which tetrates -- arrow(2, ...) -- every
-- hand's Chips/Mult at once), this only ever touches the single most-
-- played hand, and uses ordinary exponentiation: arrow(1, 1.1) is
-- Amulet's OmegaNum power operator (arrow(1, n) = ^n), NOT arrow(2, ...)
-- which is tetration (^^). If no hand has been played yet this run
-- (every `played` count is 0), the first hand encountered while
-- scanning is used as a fallback so this never silently does nothing.
SMODS.Consumable{
    key = "polaris",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 9, y = 1 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Polaris",
        text = {
            "Your {C:attention}most played{}",
            "poker hand permanently",
            "gains {C:purple}^1.1{}",
            "{C:chips}Chips{} and {C:mult}Mult{}",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        local best_key, best_played = nil, -1

        for k, h in pairs(G.GAME.hands) do
            if h.played and h.played > best_played then
                best_played = h.played
                best_key = k
            end
        end

        if best_key then
            local hand = G.GAME.hands[best_key]

            if hand.chips then
                hand.chips = to_big(hand.chips):arrow(1, 1.1)
            end
            if hand.mult then
                hand.mult = to_big(hand.mult):arrow(1, 1.1)
            end
        end

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "^1.1",
            colour = G.C.STAR
        })
    end,
}

-- Betelgeuse: changes 2 selected playing cards to a chosen Rank, keeping
-- each card's own Suit, Enhancement, Seal, and Edition untouched. Reuses
-- the exact same overlay-menu "collection grid" picker Manifest's own
-- Rank step is built from (see the hex_star_pick_* system defined right
-- after the Manifest ritual further down the file) -- only the mode
-- ("rank") and the captured target cards differ.
SMODS.Consumable{
    key = "betelgeuse",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 0, y = 2 }, -- next open row in the atlas, after Polaris (9,1)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Betelgeuse",
        text = {
            "Change {C:attention}up to 2{} selected",
            "playing cards to a",
            "{C:attention}chosen Rank{}",
        }
    },

    -- At least 1 and at most 2 cards highlighted -- unlike Cappella's
    -- exact-1 gate elsewhere in this file, this is a range so the player
    -- can hit just 1 card without needing a second one highlighted too.
    can_use = function(self, card)
        return G.hand and G.hand.highlighted
            and #G.hand.highlighted >= 1
            and #G.hand.highlighted <= 2
    end,

    use = function(self, card)
        if not (G.hand and G.hand.highlighted
        and #G.hand.highlighted >= 1
        and #G.hand.highlighted <= 2) then return end

        -- Capture whichever cards are highlighted right now (1 or 2 of
        -- them) -- opening the overlay menu changes hover/focus state, so
        -- re-reading G.hand.highlighted once the menu is open (at
        -- click-time) would be unreliable.
        local targets = {}
        for _, c in ipairs(G.hand.highlighted) do
            targets[#targets + 1] = c
        end

        G.HEX_STAR_PICK_TARGETS = targets
        G.HEX_STAR_PICK_MODE = "rank"
        G.HEX_STAR_PICK_TITLE = "Betelgeuse -- Choose a Rank"
        G.FUNCS.hex_star_pick_menu()
    end,
}

-- Antares: changes 3 selected playing cards to a chosen Suit, keeping
-- each card's own Rank, Enhancement, Seal, and Edition untouched. Same
-- hex_star_pick_* picker as Betelgeuse above, just mode = "suit" and 3
-- captured targets instead of 2.
SMODS.Consumable{
    key = "antares",
    set = "star",

    atlas = "HexStarsGalaxies",
    pos = { x = 1, y = 2 }, -- next open frame in the atlas, after Betelgeuse (0,2)

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false -- never naturally drawn from a pool; only ever handed out via the Spectral/Arcana pack hook
    end,

    loc_txt = {
        name = "Antares",
        text = {
            "Change {C:attention}up to 3{} selected",
            "playing cards to a",
            "{C:attention}chosen Suit{}",
        }
    },

    -- At least 1 and at most 3 cards highlighted, same range-gate
    -- approach as Betelgeuse above.
    can_use = function(self, card)
        return G.hand and G.hand.highlighted
            and #G.hand.highlighted >= 1
            and #G.hand.highlighted <= 3
    end,

    use = function(self, card)
        if not (G.hand and G.hand.highlighted
        and #G.hand.highlighted >= 1
        and #G.hand.highlighted <= 3) then return end

        local targets = {}
        for _, c in ipairs(G.hand.highlighted) do
            targets[#targets + 1] = c
        end

        G.HEX_STAR_PICK_TARGETS = targets
        G.HEX_STAR_PICK_MODE = "suit"
        G.HEX_STAR_PICK_TITLE = "Antares -- Choose a Suit"
        G.FUNCS.hex_star_pick_menu()
    end,
}





-- Human-readable names for each hyperoperator level, used in the
-- Hyperbolic loc text and status messages.
local hex_operator_names = {
    [0] = "Chips x Mult",
    [1] = "Chips ^ Mult",
    [2] = "Chips ^^ Mult",
    [3] = "Chips ^^^ Mult",
    [4] = "Chips ^^^^ Mult",
}

local function hex_operator_name(level)
    return hex_operator_names[level]
        or ("Chips {" .. tostring(level) .. "} Mult")
end

-- Register a custom scoring calculation with Steamodded's Chip-Mult
-- Operator API (SMODS.Scoring_Calculation). This replaces the *entire*
-- chips/mult combination step for a hand, rather than nudging `mult`
-- mid-scoring like exponent_joker does. We capture the returned object so
-- we always call SMODS.set_scoring_calculation with the exact key
-- Steamodded assigned to it, instead of guessing how it gets prefixed.
-- `to_big(chips):arrow(n, mult)` is Amulet's OmegaNum hyperoperator:
--   arrow(1, b) = a * b            (ordinary multiply)
--   arrow(2, b) = a ^ b            (exponentiation)
--   arrow(3, b) = a ^^ b           (tetration)
--   arrow(4, b) = a ^^^ b          (pentation)
--   ...and so on, all fully OmegaNum-safe past 1.7e308.
-- Converts a (possibly OmegaNum/big) value into a plain Lua number,
-- best-effort. Amulet's OmegaNum cdata doesn't expose one single
-- guaranteed accessor across versions, so we try the common method names
-- before falling back to string parsing (tostring on an OmegaNum prints
-- something Lua's tonumber can still read, e.g. "1.23e+45").
local function hex_to_plain_number(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "table" or type(value) == "cdata" then
        if value.to_number then
            local ok, n = pcall(function() return value:to_number() end)
            if ok and type(n) == "number" then return n end
        end
        if value.toNumber then
            local ok, n = pcall(function() return value:toNumber() end)
            if ok and type(n) == "number" then return n end
        end
    end
    local n = tonumber(tostring(value))
    return n or 0
end

-- Absolute: while owned, the Chips/Mult operator's hyperoperator level is
-- boosted 1-for-1 by however many Hex points you currently have, stacking
-- on top of whatever level Hyperbolic has permanently bought. Unlike
-- Hyperbolic's level, this is fully dynamic -- it rises and falls in
-- real time as your Hex points change (e.g. spending them on a summon
-- drops the level right back down).
local function hex_absolute_bonus_level()
    if not (SMODS.find_card and G.GAME) then return 0 end
    if #SMODS.find_card("j_" .. mod.prefix .. "_absolute") == 0 then return 0 end

    local points = hex_to_plain_number(G.GAME.hex_points or 0)
    if points <= 0 then return 0 end

    return math.floor(points)
end

local hex_hyperbolic_calc = nil

if SMODS.Scoring_Calculation then
    hex_hyperbolic_calc = SMODS.Scoring_Calculation{
        key = "hex_hyperbolic",
        func = function(self, chips, mult, flames)
            local level = ((G.GAME and G.GAME.hex_hyperbolic_level) or 0) + hex_absolute_bonus_level()

            if level <= 0 then
                -- Not yet upgraded (shouldn't normally be reached, since we
                -- only switch to this calculation once level >= 1) — fall
                -- back to ordinary multiplication.
                return big(chips) * big(mult)
            end

            -- level 1 -> arrow(1) = ^, level 1 -> arrow(1) = ^^, etc.
            return to_big(chips):arrow(level, mult)
        end,
        -- NOTE: the base game's operator-refresh function only ever reads
        -- .text and .colour off this object, and never touches the operator
        -- DynaText's .scale — so a top-level `scale` field here is silently
        -- ignored. To actually control the size we have to take over the
        -- update ourselves via `update_ui`, which is given the operator's
        -- UI node directly.
        update_ui = function(self, container, chip_display, mult_display, operator)
            if not operator then return end

            local level = ((G.GAME and G.GAME.hex_hyperbolic_level) or 0) + hex_absolute_bonus_level()
            if level <= 0 then level = 1 end
            local txt

            if level <= 3 then
                txt = string.rep("^", level)
            else
                txt = "{" .. tostring(level) .. "}"
            end

            -- Vanilla builds this node with scale = (local scale 0.4) * 2 = 0.8.
            -- We start 0.35 smaller than that (0.45), then shrink further as
            -- the string gets longer than a "comfortable" length, so it
            -- doesn't overflow the little purple box at high levels.
            local base_scale = 1
            local comfortable_len = 1 
            local len = #txt

            local scale = base_scale
            if len > comfortable_len then
                scale = base_scale * (comfortable_len / len)
            end
            scale = math.max(scale, 0.18) -- never shrink below a readable floor

            operator.children[1].config.text = txt
            operator.children[1].config.colour = G.C.PURPLE
            operator.children[1].config.scale = scale

            operator.UIBox:recalculate()
        end,
    }
end

-- Safely switch to our custom scoring calculation, without ever crashing
-- the game if something about the registration didn't go as expected.
local function hex_activate_hyperbolic_calculation()
    if not (hex_hyperbolic_calc and SMODS.set_scoring_calculation) then
        return
    end

    local ok, err = pcall(SMODS.set_scoring_calculation, hex_hyperbolic_calc.key)
    if not ok then
        print("[hex] failed to activate hyperbolic scoring calculation: " .. tostring(err))
    end
end

SMODS.Consumable{
    key = "hyperbolic",     -- was "ritual_template1"
    set = "ritual",

    atlas = "HexRitualsQuantums",
    pos = { x = 0, y = 0 },

    unlocked = true,
    discovered = true,

    config = {
        extra = {}
    },

    in_pool = function(self)
        return false             -- never naturally generated; must be granted directly
    end,

    loc_txt = {
        name = "Hyperbolic",
        text = {
            "Permanently upgrades the operator",
            "between {C:chips}Chips{} and {C:mult}Mult{}",
            "to the next {C:attention}hyperoperator{}",
        }
    },

    loc_vars = function(self, info_queue, card)
        local level = (G.GAME and G.GAME.hex_hyperbolic_level) or 0
        return {
            vars = { hex_operator_name(level) }
        }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.GAME.hex_hyperbolic_level = (G.GAME.hex_hyperbolic_level or 0) + 1

        hex_activate_hyperbolic_calculation()

        G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
        G.GAME.hex_rituals_used["hyperbolic"] = true

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = hex_operator_name(G.GAME.hex_hyperbolic_level),
            colour = G.C.HEX_ORPLE or G.C.MULT
        })
    end,
}


-- ============================================================
-- Ritual: Life
-- Opens a menu of every registered Joker. Clicking one adds it to
-- your owned Jokers directly. Only Jokers of Mythic rarity or below
-- are selectable; Transcendental/Divine/Absolute Jokers are shown
-- but marked with an X and can't be picked.
-- ============================================================

local hex_life_base_selectable_rarities = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    ["hex_mythic"] = true,
}

-- Returns true if the player currently owns at least one copy of the given
-- Joker key. SMODS.find_card is key-based (mod-safe) and works regardless
-- of edition/eternal/etc state on the card.
local function hex_life_owns_phanes()
    return SMODS.find_card and #SMODS.find_card("j_" .. mod.prefix .. "_phanes") > 0
end

-- Oracle lets rituals be summoned more than once (i.e. bypasses the
-- "already summoned" bookkeeping in G.FUNCS.create_ritual below).
local function hex_owns_oracle()
    return SMODS.find_card and #SMODS.find_card("j_" .. mod.prefix .. "_oracle") > 0
end

-- Phanes lets the Life ritual also offer Transcendental Jokers, but never
-- Divine or Absolute ones -- those stay locked no matter what.
local function hex_life_rarity_selectable(rarity)
    if hex_life_base_selectable_rarities[rarity] then
        return true
    end
    if rarity == "hex_transcendental" and hex_life_owns_phanes() then
        return true
    end
    return false
end

-- This reuses Balatro's real Collection-screen machinery (the same
-- CardArea-of-rows + create_option_cycle pager the game's own Jokers
-- collection tab is built from) so the menu looks and pages exactly
-- like the vanilla Collection. True while our menu's overlay is open,
-- so the Card.click hook below only intercepts clicks in this context.
G.HEX_LIFE_ACTIVE = false

local HEX_LIFE_ROWS = 3
local HEX_LIFE_COLS = 5

-- Builds the list of Jokers the Life ritual can offer. G.P_CENTER_POOLS
-- only contains centers whose `in_pool` returns true (it's the pool the
-- shop's RNG draws from) — Transcendental/Divine/Absolute Jokers all set
-- in_pool = false on purpose, so they're never in there. We start from the
-- normal pool (preserving its existing order untouched) and then append
-- every other registered Joker that wasn't already included, so the
-- higher rarities still show up on the list — just later in it — instead
-- of being silently dropped.
local function hex_life_get_pool()
    local out = {}
    local seen = {}

    for _, center in ipairs(G.P_CENTER_POOLS["Joker"] or {}) do
        if not seen[center.key] then
            out[#out + 1] = center
            seen[center.key] = true
        end
    end

    local extra = {}
    for _, center in pairs(G.P_CENTERS) do
        if center.set == "Joker" and not seen[center.key] then
            extra[#extra + 1] = center
            seen[center.key] = true
        end
    end
    table.sort(extra, function(a, b) return a.key < b.key end)

    for _, center in ipairs(extra) do
        out[#out + 1] = center
    end

    return out
end

-- Locked (Transcendental+) cards are visually marked using Steamodded's
-- built-in debuff treatment (see hex_life_spawnfunc below) rather than a
-- hand-rolled overlay, so there's nothing extra to track or tear down
-- here -- the dim/red-X visual lives on the card object itself and goes
-- away automatically when the card is removed each time the page rebuilds.

local function hex_life_spawnfunc(card, center)
    if not hex_life_rarity_selectable(center.rarity) then
        card.states.hover.can = false
        card.states.drag.can = false

        -- Use Steamodded's built-in debuff visual (dim + red "X") instead
        -- of trying to fake greying with card.alpha or a custom overlay.
        -- Vanilla doesn't dim locked collection items via alpha at all,
        -- and Card:update recalculates alpha every frame from hover/drag
        -- state anyway, so a manual override never sticks. set_debuff /
        -- SMODS.debuff_card is the same treatment the base game uses for
        -- cards that can't currently be used (e.g. Boss Blind debuffs),
        -- so it's guaranteed to render correctly.
        if SMODS.debuff_card then
            SMODS.debuff_card(card, true, "hex_life_lock")
        elseif card.set_debuff then
            card:set_debuff(true)
        else
            card.debuff = true
        end
    end
end

local function hex_life_rebuild_page(current_option)
    if not G.hex_life_rows then return end

    local pool = hex_life_get_pool()

    for j = 1, #G.hex_life_rows do
        for i = #G.hex_life_rows[j].cards, 1, -1 do
            local c = G.hex_life_rows[j]:remove_card(G.hex_life_rows[j].cards[i])
            if c then c:remove() end
        end
    end

    for j = 1, #G.hex_life_rows do
        for i = 1, HEX_LIFE_COLS do
            local center = pool[i + (j - 1) * HEX_LIFE_COLS + (HEX_LIFE_COLS * #G.hex_life_rows) * (current_option - 1)]
            if center then
                local card = Card(
                    G.hex_life_rows[j].T.x + G.hex_life_rows[j].T.w / 2,
                    G.hex_life_rows[j].T.y,
                    G.CARD_W, G.CARD_H,
                    G.P_CARDS.empty,
                    center
                )
                hex_life_spawnfunc(card, center)
                G.hex_life_rows[j]:emplace(card)
            end
        end
    end
end

G.FUNCS.hex_life_page_change = function(args)
    if not args or not args.cycle_config then return end
    hex_life_rebuild_page(args.cycle_config.current_option)
end

local function hex_life_build_definition()
    local pool = hex_life_get_pool()
    local per_page = HEX_LIFE_COLS * HEX_LIFE_ROWS
    local pages = math.max(1, math.ceil(#pool / per_page))

    local deck_tables = {}
    G.hex_life_rows = {}

    for j = 1, HEX_LIFE_ROWS do
        G.hex_life_rows[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            5 * G.CARD_W, 0.95 * G.CARD_H,
            { card_limit = HEX_LIFE_COLS, type = "title", highlight_limit = 0, collection = true }
        )

        deck_tables[#deck_tables + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07, no_fill = true },
            nodes = { { n = G.UIT.O, config = { object = G.hex_life_rows[j] } } },
        }
    end

    local options = {}
    for i = 1, pages do
        options[#options + 1] = "Page " .. i .. "/" .. pages
    end

    hex_life_rebuild_page(1)

    -- Solid vanilla-style panel: a dark, mostly-opaque card with rounded
    -- corners, the same treatment the game's own Collection/options panels
    -- use, rather than a see-through overlay.
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.WHITE, -- White border
            padding = 0.045,     -- Border thickness
            r = 0.1,
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    colour = G.C.L_BLACK, -- Original panel color
                    padding = 0.2,
                    r = 0.08,
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            { n = G.UIT.T, config = { text = "Choose a Joker to bring to life", scale = 0.4, colour = G.C.WHITE } },
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = deck_tables,
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                options = options,
                                w = 4.5,
                                cycle_shoulders = true,
                                opt_callback = "hex_life_page_change",
                                current_option = 1,
                                colour = G.C.RED,
                                no_pips = true,
                                focus_args = { snap_to = true, nav = "wide" },
                            }),
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.1,
                                    r = 0.08,
                                    minw = 3,
                                    minh = 0.7,
                                    hover = true,
                                    shadow = true,
                                    colour = G.C.RED,
                                    button = "exit_overlay_menu",
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "Back", scale = 0.4, colour = G.C.WHITE } },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end

G.FUNCS.hex_life_menu = function()
    G.HEX_LIFE_ACTIVE = true
    G.FUNCS.overlay_menu({ definition = hex_life_build_definition() })
end

-- Always clear our "menu is active" flag when any overlay closes, so a
-- stray leftover flag can never affect the real Collection screen later.
local hex_life_old_exit_overlay_menu = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function(e)
    G.HEX_LIFE_ACTIVE = false
    return hex_life_old_exit_overlay_menu(e)
end

-- Intercepts clicks on collection cards while our menu is open (the same
-- technique the published "UltraHand" Balatro mod uses to make collection
-- cards clickable). Only fires while G.HEX_LIFE_ACTIVE is true, so it has
-- zero effect on the real vanilla Collection screen otherwise.
local hex_life_old_card_click = Card.click
function Card:click()
    if G.HEX_LIFE_ACTIVE and G.OVERLAY_MENU then
        if self.config and self.config.center and self.config.center.set == "Joker" then
            local center = self.config.center

            if hex_life_rarity_selectable(center.rarity)
            and G.jokers
            and #G.jokers.cards < G.jokers.config.card_limit
            and G.GAME then

                G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
                G.GAME.hex_rituals_used["life"] = true

                local chosen_key = center.key

                G.FUNCS.exit_overlay_menu()

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        local new_card = SMODS.create_card({
                            set = "Joker",
                            key = chosen_key,
                            area = G.jokers
                        })

                        G.jokers:emplace(new_card)

                        card_eval_status_text(new_card, "extra", nil, nil, nil, {
                            message = "Life!",
                            colour = G.C.HEX_ORPLE
                        })

                        return true
                    end
                }))
            end
        end

        return -- swallow the click while our menu is open either way
    end

    hex_life_old_card_click(self)
end

SMODS.Consumable{
    key = "life",
    set = "ritual",

    atlas = "HexRitualsQuantums",
    pos = { x = 1, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false             -- never naturally generated; must be granted directly
    end,

    loc_txt = {
        name = "Life",
        text = {
            "Choose a Joker of",
            "{C:mythic}Mythic{} rarity or below",
            "to add to your Jokers",
            "{C:inactive}(requires an empty Joker slot){}"
        }
    },

    -- Can only be used with an empty Joker slot.
    can_use = function(self, card)
        return G.jokers and (#G.jokers.cards < G.jokers.config.card_limit)
    end,

    use = function(self, card)
        G.FUNCS.hex_life_menu()
    end,
}

SMODS.Consumable{
    key = "eclipse",

    set = "ritual",

    atlas = "HexRitualsQuantums",
    pos = { x = 2, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false             -- never naturally generated; must be granted directly
    end,

    loc_txt = {
        name = "Eclipse",
        text = {
            "Permanently {C:attention}tetrates{}",
            "the {C:chips}Chips{} and {C:mult}Mult{}",
            "of {C:attention}every poker hand{} to {C:attention}^^2{}",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        -- Tetrates every poker hand's base Chips and Mult (the same
        -- numbers planet cards level up) to a height of 2, i.e. each
        -- value becomes value^value. This is completely separate from
        -- the Hyperbolic ritual: Hyperbolic changes the *operator* used
        -- to combine the final Chips and Mult together at the end of
        -- scoring (x -> ^ -> ^^ -> ...); Eclipse never touches that
        -- operator. It only reaches into G.GAME.hands[*].chips/.mult
        -- and tetrates those base values directly, once, permanently.
        -- So e.g. a Flush's base 35 Chips / 4 Mult (with no planet
        -- levels) becomes 35^35 Chips and 4^4 Mult, and any planet
        -- levels bought afterward still add onto those new totals as
        -- normal.
        --
        -- `to_big(n):arrow(2, 2)` is Amulet's OmegaNum tetration:
        -- arrow(2, height) is the tetration operator, so arrow(2, 2)
        -- raises a value to a power tower of itself two high (n^n).
        if G.GAME and G.GAME.hands then
            for _, hand in pairs(G.GAME.hands) do
                if hand.chips then
                    hand.chips = to_big(hand.chips):arrow(2, 2)
                end
                if hand.mult then
                    hand.mult = to_big(hand.mult):arrow(2, 2)
                end
            end
        end

        G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
        G.GAME.hex_rituals_used["eclipse"] = true

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Eclipse!",
            colour = G.C.RITUAL
        })
    end,
}

SMODS.Consumable{
    key = "fractal",

    set = "ritual",

    atlas = "HexRitualsQuantums",
    pos = { x = 4, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false             -- never naturally generated; must be granted directly
    end,

    loc_txt = {
        name = "Fractal",
        text = {
            "Permanently {C:attention}disables{}",
            "the effect of {C:attention}every{}",
            "{C:attention}Boss Blind{}, for the",
            "rest of the run",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        -- Flips a permanent, run-long flag. The actual disabling happens
        -- in the Game:update hook further down the file (right next to
        -- the other "while owned/used, do X every frame" checks like
        -- Coupon's reroll-cost pin and Absolute's scoring-calculation
        -- activation): every frame, if this flag is set and the current
        -- blind is a boss blind that hasn't been disabled yet, we call
        -- Blind:disable() on it -- the same vanilla method the legendary
        -- Joker Chicot uses to neutralize a boss blind's effect for a
        -- round, except here it's applied to *every* boss blind for the
        -- rest of the run, not just the current one.
        G.GAME.hex_fractal_used = true

        -- If a boss blind is already active/selected right now, disable
        -- it immediately rather than waiting up to a frame.
        if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
            G.GAME.blind:disable()
        end

        G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
        G.GAME.hex_rituals_used["fractal"] = true

        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Fractal!",
            colour = G.C.HEX_ORPLE or G.C.MULT
        })
    end,
}


-- ============================================================
-- Ritual: Manifest
-- Lets the player build one fully custom playing card and add it to
-- their hand, by walking through a sequence of five selection
-- screens -- Suit, then Rank, then Enhancement, then Seal, then
-- Edition -- one after another. No new menu design is used for any
-- of this: every single screen is built from the *exact* same
-- overlay-menu "collection grid" pieces as the Life ritual above
-- (same CardArea rows/cols, same panel layout, same Page cycle
-- widget). Only the list of cards shown on the grid, and what
-- happens when you click one, changes between the five steps.
-- ============================================================

-- true while any Manifest selection screen is open, mirroring
-- G.HEX_LIFE_ACTIVE above -- the Card.click hook below only
-- intercepts clicks while this is set.
G.HEX_MANIFEST_ACTIVE = false

-- Which step we're on (index into HEX_MANIFEST_STEPS) and the
-- choices accumulated so far. Reset every time Manifest is used.
G.HEX_MANIFEST_STEP_INDEX = 1
G.HEX_MANIFEST_CHOICE = {}

local HEX_MANIFEST_STEPS = { "suit", "rank", "enhancement", "seal", "edition" }

-- Lua tables can't hold a literal nil as an array element (it just
-- creates a hole), so "no Enhancement/Seal/Edition" is represented by
-- this sentinel string instead, and only converted to a real nil at
-- the point it's actually applied to a card.
local HEX_MANIFEST_NONE = "none"

local function hex_manifest_resolve(value)
    if value == HEX_MANIFEST_NONE then
        return nil
    end
    return value
end

local HEX_MANIFEST_SUIT_LETTERS = {
    Spades = "S",
    Hearts = "H",
    Clubs = "C",
    Diamonds = "D",
}

-- Base-game playing card ranks, using the same single-character keys
-- Balatro's own G.P_CARDS table is keyed with (T = Ten).
local HEX_MANIFEST_RANKS = { "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2" }

-- These three lists used to be hand-typed, which meant any enhancement,
-- seal, or edition added later (by this mod or any other mod) silently
-- never showed up in Manifest. Instead we scan the game's own registries
-- live, every time a menu is built, so Manifest always offers whatever is
-- currently loaded -- vanilla content and modded content alike.

-- Enhancements are Centers with set == "Enhanced" (m_bonus, m_mult, ...).
local function hex_manifest_get_enhancements()
    local out = { HEX_MANIFEST_NONE }
    local list = {}

    for _, center in pairs(G.P_CENTERS) do
        if center.set == "Enhanced" then
            list[#list + 1] = center.key
        end
    end

    table.sort(list)
    for _, k in ipairs(list) do out[#out + 1] = k end
    return out
end

-- Seals aren't Centers in vanilla Balatro, so there's no single
-- guaranteed registry to scan. We check every place Steamodded is known
-- to expose them (G.P_SEALS, and Centers with set == "Seal", for
-- versions/mods that register seals that way) and always guarantee the
-- four vanilla seals are present even if neither source has anything.
local function hex_manifest_get_seals()
    local out = { HEX_MANIFEST_NONE }
    local seen = {}
    local list = {}

    local function add(key)
        if key and not seen[key] then
            seen[key] = true
            list[#list + 1] = key
        end
    end

    if G.P_SEALS then
        for key, _ in pairs(G.P_SEALS) do
            add(key)
        end
    end

    for _, center in pairs(G.P_CENTERS) do
        if center.set == "Seal" then
            add(center.key)
        end
    end

    for _, key in ipairs({ "Gold", "Red", "Blue", "Purple" }) do
        add(key)
    end

    table.sort(list)
    for _, k in ipairs(list) do out[#out + 1] = k end
    return out
end

-- Editions are Centers with set == "Edition", keyed like "e_foil".
-- Card:set_edition / SMODS.create_card both want the *short* key with
-- the "e_" stripped (e.g. "foil"), so we strip it here once, for every
-- edition, instead of hardcoding four short keys by hand.
local function hex_manifest_get_editions()
    local out = { HEX_MANIFEST_NONE }
    local list = {}

    for _, center in pairs(G.P_CENTERS) do
        -- "e_base" is vanilla's internal placeholder representing "no
        -- edition" (used for shop RNG weighting) -- it isn't a real
        -- edition to apply to a card, and we already offer our own
        -- HEX_MANIFEST_NONE option for that, so skip it here or it shows
        -- up as a second blank/no-edition entry.
        if center.set == "Edition" and center.key ~= "e_base" then
            list[#list + 1] = (center.key:gsub("^e_", ""))
        end
    end

    table.sort(list)
    for _, k in ipairs(list) do out[#out + 1] = k end
    return out
end

-- Each entry is a function (not a static table) so it's re-evaluated
-- every time a step's options are needed, picking up anything newly
-- registered.
local HEX_MANIFEST_STEP_OPTIONS = {
    suit = function() return { "Spades", "Hearts", "Clubs", "Diamonds" } end,
    rank = function() return HEX_MANIFEST_RANKS end,
    enhancement = hex_manifest_get_enhancements,
    seal = hex_manifest_get_seals,
    edition = hex_manifest_get_editions,
}

local HEX_MANIFEST_STEP_TITLES = {
    suit = "Manifest -- Choose a Suit",
    rank = "Manifest -- Choose a Rank",
    enhancement = "Manifest -- Choose an Enhancement",
    seal = "Manifest -- Choose a Seal",
    edition = "Manifest -- Choose an Edition",
}

-- Builds a preview Card for one option of the current step, using
-- whatever's already been picked for every other step (so e.g. while
-- picking a Rank, every card shown already has the Suit chosen a
-- moment ago). This is the same idea as hex_life_spawnfunc's cards --
-- a real Card object, not a mocked-up sprite -- just built from base
-- playing-card parts (G.P_CARDS front + G.P_CENTERS enhancement
-- center) instead of a Joker center, with seal/edition layered on
-- with the same Card:set_seal / Card:set_edition calls the rest of
-- the mod already uses.
local function hex_manifest_preview_card(step, value)
    local suit = (step == "suit") and value or (G.HEX_MANIFEST_CHOICE.suit or "Spades")
    local rank = (step == "rank") and value or (G.HEX_MANIFEST_CHOICE.rank or "A")
    local enhancement = (step == "enhancement") and value or G.HEX_MANIFEST_CHOICE.enhancement
    local seal = (step == "seal") and value or G.HEX_MANIFEST_CHOICE.seal
    local edition = (step == "edition") and value or G.HEX_MANIFEST_CHOICE.edition

    local suit_letter = HEX_MANIFEST_SUIT_LETTERS[suit] or "S"
    local front = G.P_CARDS[suit_letter .. "_" .. rank] or G.P_CARDS.empty

    local enh_key = hex_manifest_resolve(enhancement)
    local center = (enh_key and G.P_CENTERS[enh_key]) or G.P_CENTERS.c_base

    local card = Card(0, 0, G.CARD_W, G.CARD_H, front, center)

    local seal_key = hex_manifest_resolve(seal)
    if seal_key then
        card:set_seal(seal_key, true)
    end

    local edition_key = hex_manifest_resolve(edition)
    if edition_key then
        card:set_edition({ [edition_key] = true }, true)
    end

    -- Cards on every step (including "None" options) are always
    -- clickable -- unlike Life, nothing in Manifest is ever locked, so
    -- (unlike hex_life_spawnfunc's locked-card branch) we leave
    -- hover/drag at their default enabled state here.
    card.hex_manifest_value = value

    return card
end

local function hex_manifest_rebuild_page(current_option)
    if not G.hex_manifest_rows then return end

    local step = HEX_MANIFEST_STEPS[G.HEX_MANIFEST_STEP_INDEX]
    local options = HEX_MANIFEST_STEP_OPTIONS[step]()

    for j = 1, #G.hex_manifest_rows do
        for i = #G.hex_manifest_rows[j].cards, 1, -1 do
            local c = G.hex_manifest_rows[j]:remove_card(G.hex_manifest_rows[j].cards[i])
            if c then c:remove() end
        end
    end

    for j = 1, #G.hex_manifest_rows do
        for i = 1, HEX_LIFE_COLS do
            local idx = i + (j - 1) * HEX_LIFE_COLS + (HEX_LIFE_COLS * #G.hex_manifest_rows) * (current_option - 1)
            local value = options[idx]
            if value then
                local card = hex_manifest_preview_card(step, value)
                card.T.x = G.hex_manifest_rows[j].T.x + G.hex_manifest_rows[j].T.w / 2
                card.T.y = G.hex_manifest_rows[j].T.y
                G.hex_manifest_rows[j]:emplace(card)
            end
        end
    end
end

G.FUNCS.hex_manifest_page_change = function(args)
    if not args or not args.cycle_config then return end
    hex_manifest_rebuild_page(args.cycle_config.current_option)
end

-- Identical panel/grid/pager layout to hex_life_build_definition,
-- just re-titled per step and with a Back/Cancel button instead of a
-- plain Back button (see back_button_text below).
local function hex_manifest_build_definition()
    local step = HEX_MANIFEST_STEPS[G.HEX_MANIFEST_STEP_INDEX]
    local options = HEX_MANIFEST_STEP_OPTIONS[step]()
    local per_page = HEX_LIFE_COLS * HEX_LIFE_ROWS
    local pages = math.max(1, math.ceil(#options / per_page))

    local deck_tables = {}
    G.hex_manifest_rows = {}

    for j = 1, HEX_LIFE_ROWS do
        G.hex_manifest_rows[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            5 * G.CARD_W, 0.95 * G.CARD_H,
            { card_limit = HEX_LIFE_COLS, type = "title", highlight_limit = 0, collection = true }
        )

        deck_tables[#deck_tables + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07, no_fill = true },
            nodes = { { n = G.UIT.O, config = { object = G.hex_manifest_rows[j] } } },
        }
    end

    local page_options = {}
    for i = 1, pages do
        page_options[#page_options + 1] = "Page " .. i .. "/" .. pages
    end

    hex_manifest_rebuild_page(1)

    local back_button_text = (G.HEX_MANIFEST_STEP_INDEX == 1) and "Cancel" or "Back"

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.WHITE,
            padding = 0.045,
            r = 0.1,
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    colour = G.C.L_BLACK,
                    padding = 0.2,
                    r = 0.08,
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            { n = G.UIT.T, config = { text = HEX_MANIFEST_STEP_TITLES[step], scale = 0.4, colour = G.C.WHITE } },
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = deck_tables,
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                options = page_options,
                                w = 4.5,
                                cycle_shoulders = true,
                                opt_callback = "hex_manifest_page_change",
                                current_option = 1,
                                colour = G.C.RED,
                                no_pips = true,
                                focus_args = { snap_to = true, nav = "wide" },
                            }),
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.1,
                                    r = 0.08,
                                    minw = 3,
                                    minh = 0.7,
                                    hover = true,
                                    shadow = true,
                                    colour = G.C.RED,
                                    button = "hex_manifest_back",
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = back_button_text, scale = 0.4, colour = G.C.WHITE } },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end

G.FUNCS.hex_manifest_menu = function()
    G.HEX_MANIFEST_ACTIVE = true
    G.FUNCS.overlay_menu({ definition = hex_manifest_build_definition() })
end

-- Steps backward through the wizard, or cancels out entirely from
-- step 1. Re-opening the menu (rather than mutating the existing
-- one) keeps this consistent with how advancing to the next step
-- works below, and with Life's existing open/close pattern.
G.FUNCS.hex_manifest_back = function()
    if G.HEX_MANIFEST_STEP_INDEX > 1 then
        G.HEX_MANIFEST_STEP_INDEX = G.HEX_MANIFEST_STEP_INDEX - 1
        G.FUNCS.exit_overlay_menu()

        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.05,
            func = function()
                G.FUNCS.hex_manifest_menu()
                return true
            end
        }))
    else
        G.HEX_MANIFEST_CHOICE = {}
        G.HEX_MANIFEST_STEP_INDEX = 1
        G.FUNCS.exit_overlay_menu()
    end
end

-- Always clear our "menu is active" flag when any overlay closes,
-- exactly like the equivalent Life hook above.
local hex_manifest_old_exit_overlay_menu = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function(e)
    G.HEX_MANIFEST_ACTIVE = false
    return hex_manifest_old_exit_overlay_menu(e)
end

-- Intercepts clicks on the grid cards while a Manifest screen is
-- open, the same technique (and the same underlying Card.click hook
-- chain) as the Life ritual's click interceptor above.
local hex_manifest_old_card_click = Card.click
function Card:click()
    if G.HEX_MANIFEST_ACTIVE and G.OVERLAY_MENU then
        if self.hex_manifest_value ~= nil then
            local step = HEX_MANIFEST_STEPS[G.HEX_MANIFEST_STEP_INDEX]
            G.HEX_MANIFEST_CHOICE[step] = self.hex_manifest_value

            if G.HEX_MANIFEST_STEP_INDEX < #HEX_MANIFEST_STEPS then
                -- Advance to the next selection screen.
                G.HEX_MANIFEST_STEP_INDEX = G.HEX_MANIFEST_STEP_INDEX + 1
                G.FUNCS.exit_overlay_menu()

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.05,
                    func = function()
                        G.FUNCS.hex_manifest_menu()
                        return true
                    end
                }))
            else
                -- Edition was the last step -- build the finished card
                -- and add it straight to the player's hand.
                G.FUNCS.exit_overlay_menu()

                local suit = G.HEX_MANIFEST_CHOICE.suit
                local rank = G.HEX_MANIFEST_CHOICE.rank
                local enhancement = hex_manifest_resolve(G.HEX_MANIFEST_CHOICE.enhancement)
                local seal = hex_manifest_resolve(G.HEX_MANIFEST_CHOICE.seal)
                local edition = hex_manifest_resolve(G.HEX_MANIFEST_CHOICE.edition)

                G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
                G.GAME.hex_rituals_used["manifest"] = true

                G.HEX_MANIFEST_CHOICE = {}
                G.HEX_MANIFEST_STEP_INDEX = 1

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        local new_card = SMODS.create_card({
                            set = "Base",
                            suit = suit,
                            rank = rank,
                            enhancement = enhancement,
                            seal = seal,
                            edition = edition and ("e_" .. edition) or nil,
                            area = G.deck,
                        })

                        new_card:add_to_deck()
                        G.deck:emplace(new_card)

                        -- Belt-and-braces: add_to_deck should already register the
                        -- card in G.playing_cards, but if it doesn't (e.g. due to
                        -- how the card was constructed above), the deck-view UI
                        -- reads straight from G.playing_cards, so make sure it's
                        -- actually in there and not duplicated.
                        if G.playing_cards then
                            local already_present = false
                            for _, c in ipairs(G.playing_cards) do
                                if c == new_card then
                                    already_present = true
                                    break
                                end
                            end
                            if not already_present then
                                table.insert(G.playing_cards, new_card)
                            end
                        end

                        card_eval_status_text(new_card, "extra", nil, nil, nil, {
                            message = "Manifest!",
                            colour = G.C.HEX_ORPLE
                        })

                        return true
                    end
                }))
            end
        end

        return -- swallow the click while our menu is open either way
    end

    hex_manifest_old_card_click(self)
end

SMODS.Consumable{
    key = "manifest",
    set = "ritual",

    atlas = "HexRitualsQuantums",
    pos = { x = 3, y = 0 },

    unlocked = true,
    discovered = true,

    in_pool = function(self)
        return false             -- never naturally generated; must be granted directly
    end,

    loc_txt = {
        name = "Manifest",
        text = {
            "Choose a {C:attention}Suit{}, {C:attention}Rank{},",
            "{C:attention}Enhancement{}, {C:attention}Seal{},",
            "and {C:attention}Edition{} to add a fully",
            "custom card to your hand",
        }
    },

    can_use = function(self, card)
        return true
    end,

    use = function(self, card)
        G.HEX_MANIFEST_CHOICE = {}
        G.HEX_MANIFEST_STEP_INDEX = 1
        G.FUNCS.hex_manifest_menu()
    end,
}


-- ============================================================
-- Shared picker: Betelgeuse (Rank) / Antares (Suit)
-- A single-step overlay menu, built from the exact same CardArea-grid-
-- of-rows + create_option_cycle pager pieces the Life and Manifest
-- rituals' own menus above are built from (same HEX_LIFE_ROWS/COLS grid
-- size, same panel layout). Rather than duplicating Manifest's whole
-- multi-step wizard, this is just one of Manifest's own steps (Rank or
-- Suit) pulled out on its own, reused by both Betelgeuse and Antares --
-- the only things that differ between the two cards are the picker's
-- mode ("rank" vs "suit") and which playing cards it applies the choice
-- to once something is clicked.
-- ============================================================

-- True while a Betelgeuse/Antares picker overlay is open, mirroring
-- G.HEX_LIFE_ACTIVE / G.HEX_MANIFEST_ACTIVE above -- the Card.click hook
-- below only intercepts clicks in this context.
G.HEX_STAR_PICK_ACTIVE = false
G.HEX_STAR_PICK_MODE = nil     -- "rank" or "suit"
G.HEX_STAR_PICK_TARGETS = {}   -- the specific playing cards being changed
G.HEX_STAR_PICK_TITLE = ""

local HEX_STAR_PICK_OPTIONS = {
    rank = function() return HEX_MANIFEST_RANKS end,
    suit = function() return { "Spades", "Hearts", "Clubs", "Diamonds" } end,
}

-- Maps a base card's `.value` (vanilla's own full-word rank name, e.g.
-- "Ace"/"10"/"9", the same field checked elsewhere in this file via
-- `context.other_card.base.value == "Ace"` for The Seal of Aces) to the
-- single-letter rank token G.P_CARDS is keyed with (matching
-- HEX_MANIFEST_RANKS above -- "A","K","Q","J","T","9".."2").
local HEX_RANK_VALUE_TO_LETTER = {
    ["Ace"] = "A",
    ["King"] = "K",
    ["Queen"] = "Q",
    ["Jack"] = "J",
    ["10"] = "T",
    ["9"] = "9",
    ["8"] = "8",
    ["7"] = "7",
    ["6"] = "6",
    ["5"] = "5",
    ["4"] = "4",
    ["3"] = "3",
    ["2"] = "2",
}

-- Recovers "what Suit and Rank is this card currently" straight from its
-- own `.base.suit` / `.base.value` fields (rather than scanning G.P_CARDS
-- for a table that's identical() to card.base) -- dealt-into-hand cards
-- aren't guaranteed to keep sharing the exact same table reference as the
-- G.P_CARDS entry they were built from, so an identity scan can silently
-- come up empty even though the card's suit/value fields are fine.
-- HEX_MANIFEST_SUIT_LETTERS (Spades/Hearts/Clubs/Diamonds -> S/H/C/D) is
-- reused here since card.base.suit is that same full-word format.
local function hex_get_card_letters(card)
    if not (card and card.base) then return nil, nil end

    local suit_letter = HEX_MANIFEST_SUIT_LETTERS[card.base.suit]
    local rank_letter = HEX_RANK_VALUE_TO_LETTER[card.base.value]

    return suit_letter, rank_letter
end

-- Preview card for one picker option -- a plain base (no enhancement/
-- seal/edition) showing just the Rank (on a Spade) or the Suit (as an
-- Ace), since only that single attribute is actually being chosen here.
local function hex_star_pick_preview_card(mode, value)
    local front

    if mode == "rank" then
        front = G.P_CARDS["S_" .. value]
    else
        local suit_letter = HEX_MANIFEST_SUIT_LETTERS[value] or "S"
        front = G.P_CARDS[suit_letter .. "_A"]
    end

    front = front or G.P_CARDS.empty

    local card = Card(0, 0, G.CARD_W, G.CARD_H, front, G.P_CENTERS.c_base)
    card.hex_star_pick_value = value

    return card
end

local function hex_star_pick_rebuild_page(current_option)
    if not G.hex_star_pick_rows then return end

    local options = HEX_STAR_PICK_OPTIONS[G.HEX_STAR_PICK_MODE]()

    for j = 1, #G.hex_star_pick_rows do
        for i = #G.hex_star_pick_rows[j].cards, 1, -1 do
            local c = G.hex_star_pick_rows[j]:remove_card(G.hex_star_pick_rows[j].cards[i])
            if c then c:remove() end
        end
    end

    for j = 1, #G.hex_star_pick_rows do
        for i = 1, HEX_LIFE_COLS do
            local idx = i + (j - 1) * HEX_LIFE_COLS + (HEX_LIFE_COLS * #G.hex_star_pick_rows) * (current_option - 1)
            local value = options[idx]
            if value then
                local card = hex_star_pick_preview_card(G.HEX_STAR_PICK_MODE, value)
                card.T.x = G.hex_star_pick_rows[j].T.x + G.hex_star_pick_rows[j].T.w / 2
                card.T.y = G.hex_star_pick_rows[j].T.y
                G.hex_star_pick_rows[j]:emplace(card)
            end
        end
    end
end

G.FUNCS.hex_star_pick_page_change = function(args)
    if not args or not args.cycle_config then return end
    hex_star_pick_rebuild_page(args.cycle_config.current_option)
end

-- Identical panel/grid/pager layout to hex_life_build_definition /
-- hex_manifest_build_definition above, just re-titled per card
-- (G.HEX_STAR_PICK_TITLE) and with a plain "Cancel" button, since there's
-- only ever one step here.
local function hex_star_pick_build_definition()
    local options = HEX_STAR_PICK_OPTIONS[G.HEX_STAR_PICK_MODE]()
    local per_page = HEX_LIFE_COLS * HEX_LIFE_ROWS
    local pages = math.max(1, math.ceil(#options / per_page))

    local deck_tables = {}
    G.hex_star_pick_rows = {}

    for j = 1, HEX_LIFE_ROWS do
        G.hex_star_pick_rows[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            5 * G.CARD_W, 0.95 * G.CARD_H,
            { card_limit = HEX_LIFE_COLS, type = "title", highlight_limit = 0, collection = true }
        )

        deck_tables[#deck_tables + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07, no_fill = true },
            nodes = { { n = G.UIT.O, config = { object = G.hex_star_pick_rows[j] } } },
        }
    end

    local page_options = {}
    for i = 1, pages do
        page_options[#page_options + 1] = "Page " .. i .. "/" .. pages
    end

    hex_star_pick_rebuild_page(1)

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.WHITE,
            padding = 0.045,
            r = 0.1,
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    colour = G.C.L_BLACK,
                    padding = 0.2,
                    r = 0.08,
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            { n = G.UIT.T, config = { text = G.HEX_STAR_PICK_TITLE, scale = 0.4, colour = G.C.WHITE } },
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = deck_tables,
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            create_option_cycle({
                                options = page_options,
                                w = 4.5,
                                cycle_shoulders = true,
                                opt_callback = "hex_star_pick_page_change",
                                current_option = 1,
                                colour = G.C.RED,
                                no_pips = true,
                                focus_args = { snap_to = true, nav = "wide" },
                            }),
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.1,
                                    r = 0.08,
                                    minw = 3,
                                    minh = 0.7,
                                    hover = true,
                                    shadow = true,
                                    colour = G.C.RED,
                                    button = "exit_overlay_menu",
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "Cancel", scale = 0.4, colour = G.C.WHITE } },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end

G.FUNCS.hex_star_pick_menu = function()
    G.HEX_STAR_PICK_ACTIVE = true
    G.FUNCS.overlay_menu({ definition = hex_star_pick_build_definition() })
end

-- Always clear our "menu is active" flag when any overlay closes, the
-- same layered wrapping Life's and Manifest's own exit_overlay_menu
-- hooks above already do (each wrap calls the previous one in turn, so
-- all three flags -- Life's, Manifest's, and this one -- get cleared
-- together no matter which menu was actually open).
local hex_star_pick_old_exit_overlay_menu = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function(e)
    G.HEX_STAR_PICK_ACTIVE = false
    return hex_star_pick_old_exit_overlay_menu(e)
end

-- Intercepts clicks on the grid cards while a Betelgeuse/Antares picker
-- is open, the same technique (and the same underlying Card.click hook
-- chain) as the Life and Manifest click interceptors above. On a click,
-- rewrites each captured target card's Rank (keeping its own Suit) or
-- Suit (keeping its own Rank) via Card:set_base -- Enhancement, Seal,
-- and Edition all live on separate fields (config.center / seal /
-- edition) that set_base never touches, so those stay exactly as they
-- were.
local hex_star_pick_old_card_click = Card.click
function Card:click()
    if G.HEX_STAR_PICK_ACTIVE and G.OVERLAY_MENU then
        if self.hex_star_pick_value ~= nil then
            local chosen_value = self.hex_star_pick_value
            local mode = G.HEX_STAR_PICK_MODE
            local targets = G.HEX_STAR_PICK_TARGETS or {}

            G.FUNCS.exit_overlay_menu()

            for _, target in ipairs(targets) do
                if target and target.base then
                    local suit_letter, rank_letter = hex_get_card_letters(target)

                    if suit_letter and rank_letter then
                        local new_key = (mode == "rank")
                            and (suit_letter .. "_" .. chosen_value)
                            or ((HEX_MANIFEST_SUIT_LETTERS[chosen_value] or suit_letter) .. "_" .. rank_letter)

                        local new_front = G.P_CARDS[new_key]

                        if new_front then
                            -- Card:set_base is the normal API for this (it's
                            -- what vanilla's own Death Tarot uses to turn one
                            -- selected card into another), but fall back to
                            -- setting the fields by hand + re-running whatever
                            -- sprite-refresh method exists, in case this
                            -- installed build exposes it under a different
                            -- name -- so this still has the best chance of
                            -- working either way instead of silently no-oping.
                            if target.set_base then
                                target:set_base(new_front)
                            else
                                target.base = new_front
                                if target.config then target.config.card = new_front end
                                if target.set_sprites then
                                    target:set_sprites(target.config and target.config.center, new_front)
                                end
                            end
                        else
                            print("[hex] star pick: no G.P_CARDS entry for key '" .. tostring(new_key) .. "'")
                        end
                    else
                        print("[hex] star pick: could not resolve suit/rank letters for target card (suit="
                            .. tostring(target.base and target.base.suit) .. ", value="
                            .. tostring(target.base and target.base.value) .. ")")
                    end
                end
            end
        end

        return -- swallow the click while our menu is open either way
    end

    hex_star_pick_old_card_click(self)
end








-- Create Hex Points when a run starts
local old_start_run = Game.start_run

function Game:start_run(...)
    local ret = old_start_run(self, ...)

    G.GAME.hex_points = G.GAME.hex_points or big(0)

    return ret
end


-- HEX POINT DISPLAY

G.HEX_DISPLAY = {
    value = "TEST HEX"
}

-- Update display


local old_game_update = Game.update

function Game:update(dt)

    old_game_update(self, dt)

    if G.GAME then
        local new_display = hex_format_points(G.GAME.hex_points or 0)

        if G.GAME.hex_display ~= new_display then
            G.GAME.hex_display = new_display

            if G.HEX_TEXT then
                G.HEX_TEXT:remove()

                G.HEX_TEXT = UIBox{
                    definition = {
                        n = G.UIT.ROOT,
                        config = {
                            align = "cm",
                            colour = G.C.UI.TRANSPARENT_DARK,
                            padding = 0.1
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    ref_table = G.GAME,
                                    ref_value = "hex_display",
                                    scale = 0.5,
                                    colour = G.C.WHITE,
                                    align = "cm",
                                }
                            }
                        }
                    },
                    config = {
                        align = "cm",
                        offset = {
                            x = 9,
                            y = -2
                        },
                        major = G.ROOM_ATTACH
                    }
                }
            end
        end
    end
end


-- Update the number
local old_game_update = Game.update

function Game:update(dt)

    old_game_update(self, dt)

    if G.GAME and G.HEX_DISPLAY then
        G.HEX_DISPLAY.value = hex_format_points(G.GAME.hex_points or 0)
    end
end

-- Builds the "Summon Absolute" button. Kept separate from the other three
-- (Ritual/Transcendental/Divine) buttons, which are only ever created once
-- at start_run, because Inaccessible can be bought mid-run and the button
-- needs to appear the moment that happens rather than next run.
-- `disabled` greys the button out and strips its click binding/hover/shadow,
-- for once Absolute has already been summoned this run.
local function hex_create_absolute_button(disabled)
    local hex_bg_colour = (G.C.UI.BACKGROUND_INACTIVE or HEX("4a4a4a"))
    local hex_text_colour = (G.C.UI.TEXT_INACTIVE or HEX("8a8a8a"))

    G.ABSOLUTE_BUTTON = UIBox{
        definition = {
            n = G.UIT.ROOT,
            config = {
                align = "cm",
                colour = G.C.UI.TRANSPARENT,
                padding = -1,
            },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = {
                                        align = "cm",
                                        hover = not disabled,
                                        shadow = not disabled,
                                        r = 0.08,
                                        minw = 2.5,
                                        minh = 0.8,
                                        colour = disabled and hex_bg_colour or G.C.ABSOLUTE,
                                        one_press = true,
                                        button = (not disabled) and "summon_absolute" or nil,
                                    },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "Summon", scale = 0.35, colour = disabled and hex_text_colour or G.C.WHITE, align = "cm", shadow = not disabled } },
                                            },
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "Absolute", scale = 0.35, colour = disabled and hex_text_colour or G.C.WHITE, align = "cm", shadow = not disabled } },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        config = {
            align = "cm",
            offset = { x = 9, y = 2.0 },
            major = G.ROOM_ATTACH,
            emboss = 0,
            no_fill = true,
        },
    }
end

-- Keep display updated
local old_game_update = Game.update

function Game:update(dt)

    old_game_update(self, dt)

    if G.GAME and G.HEX_DISPLAY then
        G.HEX_DISPLAY.value = hex_format_points(G.GAME.hex_points or 0)
    end

    -- Permanently (for the rest of this run) create the Summon Absolute
    -- button the moment Inaccessible is picked up, without waiting for a
    -- new run to start.
    if G.GAME and G.GAME.hex_inaccessible_unlocked then
        if not G.ABSOLUTE_BUTTON then
            hex_create_absolute_button(G.GAME.hex_absolute_summoned)
        elseif G.GAME.hex_absolute_summoned and not G.ABSOLUTE_BUTTON_LOCKED then
            G.ABSOLUTE_BUTTON_LOCKED = true
            if G.ABSOLUTE_BUTTON.remove then G.ABSOLUTE_BUTTON:remove() end
            hex_create_absolute_button(true)
        end
    end

    -- Coupon: while owned, the shop reroll cost is pinned to $1.
    --
    -- G.GAME.round_resets.reroll_cost is only the *base* cost that gets
    -- copied in when a new shop is entered (this is the field vouchers
    -- like Reroll Surplus/Glut discount). The cost that's actually
    -- displayed on the reroll button AND the one G.FUNCS.reroll_shop
    -- charges via `ease_dollars(-G.GAME.current_round.reroll_cost)` is
    -- G.GAME.current_round.reroll_cost, which then climbs by $1 (or more,
    -- with certain vouchers/tags) on every reroll within that shop visit.
    -- We pin both fields every frame so it never shows or charges
    -- anything above $1, no matter how many times the shop is rerolled.
    if G.GAME and SMODS.find_card and #SMODS.find_card("j_" .. mod.prefix .. "_coupon") > 0 then
        if G.GAME.round_resets then
            G.GAME.round_resets.reroll_cost = 1
        end
        if G.GAME.current_round then
            G.GAME.current_round.reroll_cost = 1
        end
    end

    -- Absolute: make sure our custom hyperoperator scoring calculation is
    -- active whenever Absolute is owned, even if Hyperbolic was never
    -- used (hex_hyperbolic_level == 0) -- the actual level applied is
    -- computed dynamically from current Hex points inside
    -- hex_hyperbolic_calc's func/update_ui (see hex_absolute_bonus_level).
    if G.GAME and SMODS.find_card and #SMODS.find_card("j_" .. mod.prefix .. "_absolute") > 0 then
        if hex_hyperbolic_calc
        and SMODS.set_scoring_calculation
        and G.GAME.current_scoring_calculation_key ~= hex_hyperbolic_calc.key then
            hex_activate_hyperbolic_calculation()
        end
    end

    -- Fractal: once used, every Boss Blind for the rest of the run is
    -- neutralized the moment it becomes current, via the same
    -- Blind:disable() vanilla Chicot uses on a single blind. We just
    -- check every frame instead of hooking every single boss blind's
    -- setup function individually, and skip the call once .disabled is
    -- already true so it isn't re-triggered every frame for nothing.
    if G.GAME and G.GAME.hex_fractal_used
    and G.GAME.blind
    and G.GAME.blind.boss
    and not G.GAME.blind.disabled then
        G.GAME.blind:disable()
    end

    -- Procyon: while charges remain, neutralizes every Boss Blind it
    -- encounters (one charge per Blind), the same Blind:disable() poll
    -- Fractal uses just above -- see the comment on Procyon's own
    -- definition above for why a stacking charge counter is used instead
    -- of a permanent flag. `not G.GAME.blind.disabled` (the same guard
    -- Fractal's poll relies on) keeps this from spending more than one
    -- charge on the same Boss Blind across multiple frames.
    if G.GAME and (G.GAME.hex_procyon_charges or 0) > 0
    and G.GAME.blind
    and G.GAME.blind.boss
    and not G.GAME.blind.disabled then
        G.GAME.blind:disable()
        G.GAME.hex_procyon_charges = G.GAME.hex_procyon_charges - 1
    end

    -- Polydactyly: while owned, removes the cap on how many cards can be
    -- highlighted at once to play or discard. NOTE: CardArea's *internal*
    -- field is config.highlighted_limit (with "ed") -- CardArea:init only
    -- accepts "highlight_limit" (no "ed") as a *constructor* option and
    -- immediately re-stores it as config.highlighted_limit, so once the
    -- area already exists (like G.hand here), the field we actually have
    -- to overwrite is the "ed" one. CardArea:add_to_highlighted checks
    -- #self.highlighted >= self.config.highlighted_limit on every card
    -- click, so pinning it every frame (same trick as Coupon's reroll
    -- cost) is enough. HEX_POLY_DEFAULT_HAND_LIMIT is restored the moment
    -- the Joker is no longer owned (sold/destroyed), so nothing is left
    -- permanently inflated if it leaves play.
    if G.GAME and G.hand and G.hand.config and SMODS.find_card then
        local owns_polydactyly = #SMODS.find_card("j_" .. mod.prefix .. "_polydactyly") > 0
        if owns_polydactyly then
            G.hand.config.highlighted_limit = 999995
        elseif G.hand.config.highlighted_limit == 999995 then
            G.hand.config.highlighted_limit = HEX_POLY_DEFAULT_HAND_LIMIT
        end
    end

    -- Orion: while owned, raises the hand's card_limit just enough to fit
    -- however many cards are actually in play (hand + remaining deck),
    -- capturing whatever the limit was before we touch it so it can be
    -- restored exactly once Orion is no longer owned (hand size can be
    -- affected by vouchers/decks independently of this Joker).
    --
    -- IMPORTANT: unlike Polydactyly's highlighted_limit override above,
    -- G.hand's card_limit is *also* used to size each card's slot when
    -- CardArea:align_cards lays the row out (slot width scales down as
    -- card_limit goes up). Pinning it to an arbitrary huge placeholder
    -- like 999995 (the trick used for highlighted_limit, which has no
    -- layout role) made every slot collapse to near-zero width, stacking
    -- every card on top of each other. Sizing it to the real card count
    -- instead keeps the layout math sane -- cramped with a full deck in
    -- hand, same as vanilla gets cramped with a large hand, but not a
    -- total stack.
    --
    -- Recomputed every frame so it tracks the real total as cards move
    -- between hand/deck/discard over the course of the round.
    --
    -- Once per round -- tracked via G.GAME.round, Balatro's own round
    -- counter, so this only fires again after a genuinely new round
    -- starts -- draws every remaining card in the deck into the hand.
    --
    -- NOTE: this used to be wired to a `context.first_hand_drawn`
    -- calculate context, but that context flag doesn't actually exist in
    -- this Steamodded build, so it silently never fired (hand stayed at
    -- its normal size). Polling here, the same way Fractal/Polydactyly/
    -- Absolute already do above, is the reliable way to catch "a new
    -- round just started" without a dedicated engine hook for it.
    --
    -- Also: pass a *copy* of G.deck.cards to CardArea:draw, not the live
    -- table. CardArea:draw removes each card from its source area as it
    -- moves it, so handing it the live G.deck.cards table means we'd be
    -- mutating the exact table the draw loop is iterating over -- which
    -- is what caused only about half the deck to actually get drawn.
    if G.GAME and G.hand and G.hand.config and G.deck and SMODS.find_card then
        local owns_orion = #SMODS.find_card("j_" .. mod.prefix .. "_orion") > 0

        if owns_orion then
            if not G.GAME.hex_orion_captured_hand_limit then
                G.GAME.hex_orion_captured_hand_limit = G.hand.config.card_limit
            end
            local total_cards = #G.hand.cards + #G.deck.cards
            G.hand.config.card_limit = math.max(G.GAME.hex_orion_captured_hand_limit, total_cards)
        elseif G.GAME.hex_orion_captured_hand_limit then
            G.hand.config.card_limit = G.GAME.hex_orion_captured_hand_limit
            G.GAME.hex_orion_captured_hand_limit = nil
        end

        if owns_orion
        and G.STATE == G.STATES.SELECTING_HAND
        and #G.hand.cards > 0
        and G.GAME.hex_orion_last_round ~= G.GAME.round then

            G.GAME.hex_orion_last_round = G.GAME.round

            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.1,
                func = function()
                    if G.deck and G.hand and #G.deck.cards > 0 then
                        local cards_to_draw = {}
                        for i = 1, #G.deck.cards do
                            cards_to_draw[i] = G.deck.cards[i]
                        end
                        G.hand:draw(cards_to_draw)
                    end
                    return true
                end
            }))
        end
    end
end

-- Create Hex Points when a run starts + create display

local old_start_run = Game.start_run

function Game:start_run(...)

    G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}
    G.GAME.hex_rituals_summoned = G.GAME.hex_rituals_summoned or {}
    local ret = old_start_run(self, ...)

    G.GAME.hex_points = G.GAME.hex_points or big(0)
    G.GAME.hex_display = hex_format_points(G.GAME.hex_points)
    G.GAME.hex_hyperbolic_level = G.GAME.hex_hyperbolic_level or 0
    G.GAME.hex_fractal_used = G.GAME.hex_fractal_used or false
    G.GAME.hex_sol_blind_mult = G.GAME.hex_sol_blind_mult or 1

    -- Re-apply the hyperoperator scoring calculation on resume/load, since
    -- G.GAME.current_scoring_calculation_key isn't guaranteed to survive it.
    if G.GAME.hex_hyperbolic_level > 0 then
        hex_activate_hyperbolic_calculation()
    end

    -- Re-disable the current blind on resume/load if Fractal was already
    -- used and we happen to be resuming mid-boss-blind. Normally the
    -- per-frame Game:update check (right above this function) handles
    -- this, but doing it here too means it takes effect the instant the
    -- run loads rather than waiting up to a frame.
    if G.GAME.hex_fractal_used
    and G.GAME.blind
    and G.GAME.blind.boss
    and not G.GAME.blind.disabled then
        G.GAME.blind:disable()
    end

    -- Navy blue color
    G.C.HEX_ORPLE = HEX("3b006e")

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 2,
        func = function()
            G.HEX_TEXT = UIBox{
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        align = "cm",
                        colour = G.C.UI.TRANSPARENT_DARK,
                        padding = 0.1
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                ref_table = G.GAME,
                                ref_value = "hex_display",
                                scale = 0.5,
                                colour = G.C.WHITE,
                                align = "cm",
                            }
                        }
                    }
                },
                config = {
                    align = "cm",
                    offset = {
                        x = 9,
                        y = -2
                    },
                    major = G.ROOM_ATTACH
                }
            }
            return true
        end
    }))
    return ret
end


local hex_sacrifice_values = {
    [1] = big(1),
    [2] = big(2),
    [3] = big(5),
    [4] = big(20),
    ["hex_mythic"] = big(50),
    ["hex_transcendental"] = big(250),
    ["hex_divine"] = big(5000),
}


G.FUNCS.hex_sacrifice = function(e)

    local card = e.config.ref_table

    if not card then return end

    -- Safety net: never sacrifice an eternal Joker or the Absolute Joker,
    -- even if this somehow gets triggered outside the button (e.g. some
    -- other mod's UI hook). The button itself is disabled for these too.
    if card.ability and card.ability.eternal then return end
    if card.config and card.config.center and card.config.center.key == ("j_" .. mod.prefix .. "_absolute") then return end

    local rarity = card.config.center.rarity
    local gain = hex_sacrifice_values[rarity] or big(0)

    if gain > big(0) then

        -- Cursed Deck: doubles the base Hex-point value of the Joker being
        -- hexed, before The Monolith's flat +1 bonus (below) is added on
        -- top of that doubled amount.
        if hex_cursed_deck_selected() then
            gain = gain * big(2)
        end

        -- The Monolith: +1 bonus Hex point per Hex, whatever the base value.
        if #SMODS.find_card("j_" .. mod.prefix .. "_the_monolith") > 0 then
            gain = gain + big(1)
        end

        G.GAME.hex_points = (G.GAME.hex_points or big(0)) + gain
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "+" .. tostring(gain) .. " Hex",
            colour = G.C.HEX_ORPLE
        })

        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.3,
            func = function()
                card:start_dissolve()
                return true
            end
        }))
    end
end

local old_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons

function G.UIDEF.use_and_sell_buttons(card)

    local ret = old_use_and_sell_buttons(card)

    if card
    and card.ability
    and card.config.center.set == "Joker" 
    and card.area == G.jokers then

        -- Eternal Jokers and the Absolute Joker can never be sacrificed.
        local hex_disabled =
            (card.ability.eternal)
            or (card.config.center.key == ("j_" .. mod.prefix .. "_absolute"))

        local hex_bg_colour = (G.C.UI.BACKGROUND_INACTIVE or HEX("4a4a4a"))
        local hex_text_colour = (G.C.UI.TEXT_INACTIVE or HEX("8a8a8a"))

        local sacrifice_row = {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = {
                {n=G.UIT.C, config={align = "cr"}, nodes={
                    {n=G.UIT.C, config={
                        ref_table = card,
                        align = "cr",
                        padding = 0.2,
                        r = 0.08,
                        minw = 1.25,
                        hover = not hex_disabled,
                        shadow = not hex_disabled,
                        colour = hex_disabled and hex_bg_colour or G.C.HEX_ORPLE,
                        button = (not hex_disabled) and "hex_sacrifice" or nil,
                    }, nodes={
                        {n=G.UIT.T, config={text=" HEX", colour = hex_disabled and hex_text_colour or G.C.WHITE, scale=0.5, shadow = not hex_disabled}}
                    }}
                }}
            }
        }

        table.insert(ret.nodes[1].nodes, sacrifice_row)
    end

    return ret
end

G.FUNCS.create_ritual = function()

    print("CREATE RITUAL PRESSED")


    if not G.GAME then return end


    if (G.GAME.hex_points or big(0)) < big(100) then
        print("NO HEX")
        return
    end


    if #G.consumeables.cards >= G.consumeables.config.card_limit then
        print("NO SLOT")
        return
    end

    G.GAME.hex_rituals_used = G.GAME.hex_rituals_used or {}

    -- Separate from hex_rituals_used (which is only set once a ritual's
    -- `use` function actually fires). This one is set the moment a ritual
    -- is summoned, so a ritual sitting unused in your consumable slot
    -- can't be rolled a second time.
    G.GAME.hex_rituals_summoned = G.GAME.hex_rituals_summoned or {}

    -- Master list of every ritual's short key (matches the keys set to
    -- `true` in G.GAME.hex_rituals_used by each ritual's `use` function).
    local all_ritual_keys = {
        "hyperbolic",
        "life",
        "fractal",
        "eclipse",
        "manifest",
    }

    local rituals = {}

    -- Oracle: rituals are never excluded for already having been summoned.
    local oracle_owned = hex_owns_oracle()

    for _, ritual_key in ipairs(all_ritual_keys) do
        if oracle_owned or not G.GAME.hex_rituals_summoned[ritual_key] then
            rituals[#rituals+1] = "c_" .. mod.prefix .. "_" .. ritual_key
        end
    end

    if #rituals == 0 then
        print("ALL RITUALS ALREADY SUMMONED")
        return
    end

    local chosen = pseudorandom_element(
        rituals,
        pseudoseed("ritual")
    )

    print("TRYING "..chosen)

    -- Mark it summoned immediately, before the card even materializes,
    -- so it can't be rolled again while it's sitting unused. Skipped
    -- entirely with Oracle, since that Joker allows repeats anyway.
    local chosen_key = chosen:gsub("^c_" .. mod.prefix .. "_", "")
    if not oracle_owned then
        G.GAME.hex_rituals_summoned[chosen_key] = true
    end

    G.GAME.hex_points = G.GAME.hex_points - big(100)


    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()

            local card = SMODS.create_card({
                key = chosen,
                area = G.consumeables
            })

            G.consumeables:emplace(card)

            return true
        end
    }))


end

-- Returns true if the player currently owns a "Showman" Joker, which in
-- vanilla Balatro allows duplicate copies of otherwise-unique Jokers.
local function hex_has_showman()
    return #SMODS.find_card("j_showman") > 0
end

-- Returns true if the player currently owns at least one copy of the Joker
-- with the given key (checked via SMODS.find_card, which is key-based and
-- therefore mod-safe).
local function hex_owns_joker(key)
    return #SMODS.find_card(key) > 0
end

G.FUNCS.summon_transcendental = function()

    if not G.GAME then return end

    local cost = big(1000)

    if (G.GAME.hex_points or big(0)) < cost then
        print("NOT ENOUGH HEX POINTS")
        return
    end

    if #G.jokers.cards >= G.jokers.config.card_limit then
        print("NO JOKER SLOT")
        return
    end

    local transcendental_jokers = {}

    for _, center in pairs(G.P_CENTERS) do
        if center.set == "Joker"
        and center.rarity == R_HEX_TRANSCENDENTAL.key
        and not hex_owns_joker(center.key) then -- Mythic+ rarities are always capped at one copy each, even with Showman
            transcendental_jokers[#transcendental_jokers + 1] = center.key
        end
    end

    if #transcendental_jokers == 0 then
        print("NO TRANSCENDENTAL JOKERS AVAILABLE (already owned)")
        return
    end

    local chosen = pseudorandom_element(
        transcendental_jokers,
        pseudoseed("transcendental")
    )

    G.GAME.hex_points = G.GAME.hex_points - cost

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()

            local card = SMODS.create_card({
                set = "Joker",
                key = chosen,
                area = G.jokers
            })

            G.jokers:emplace(card)

            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = "TRANSCENDENTAL!",
                colour = G.C.TRANSCENDENTAL
            })

            return true
        end
    }))
end

G.FUNCS.summon_divine = function()

    if not G.GAME then return end

    local cost = big(10000)

    if (G.GAME.hex_points or big(0)) < cost then
        print("NOT ENOUGH HEX POINTS")
        return
    end

    if #G.jokers.cards >= G.jokers.config.card_limit then
        print("NO JOKER SLOT")
        return
    end

    local divine_jokers = {}

    for _, center in pairs(G.P_CENTERS) do
        if center.set == "Joker"
        and center.rarity == R_HEX_DIVINE.key
        and center.key ~= ("j_" .. mod.prefix .. "_inaccessible") -- Inaccessible can never be summoned via this button; it must be earned normally
        and not hex_owns_joker(center.key) then -- Divine Jokers are capped at one copy each, even with Showman
            divine_jokers[#divine_jokers + 1] = center.key
        end
    end

    if #divine_jokers == 0 then
        print("NO DIVINE JOKERS AVAILABLE (already owned)")
        return
    end

    local chosen = pseudorandom_element(
        divine_jokers,
        pseudoseed("divine")
    )

    G.GAME.hex_points = G.GAME.hex_points - cost

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()

            local card = SMODS.create_card({
                set = "Joker",
                key = chosen,
                area = G.jokers
            })

            G.jokers:emplace(card)

            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = "DIVINE!",
                colour = G.C.DIVINE
            })

            return true
        end
    }))
end

G.FUNCS.summon_absolute = function()

    if not G.GAME then return end

    -- Once unlocked, this stays usable for the rest of the run even if
    -- Inaccessible itself is later sold or destroyed. The button that
    -- calls this is only created once the flag is set anyway, but this
    -- guard is kept in case something else ever calls it directly.
    if not G.GAME.hex_inaccessible_unlocked then
        print("ABSOLUTE SUMMON NOT UNLOCKED")
        return
    end

    if G.GAME.hex_absolute_summoned then
        print("ABSOLUTE ALREADY SUMMONED")
        return
    end

    local cost = big(1.0e21)

    if (G.GAME.hex_points or big(0)) < cost then
        print("NOT ENOUGH HEX POINTS")
        return
    end

    -- Absolute rarity is always capped at one copy each, even with
    -- Showman -- Showman only affects normal-rarity Jokers -- so this
    -- guard is unconditional and doesn't check hex_has_showman().
    if hex_owns_joker("j_" .. mod.prefix .. "_absolute") then
        print("ABSOLUTE ALREADY OWNED")
        return
    end

    -- Summoning Absolute wipes the player out completely rather than
    -- just deducting the flat 1.0e21-point cost -- both Hex
    -- points and dollars are reset straight to zero, whatever they
    -- were at (including any amount left over past the cost). Money is
    -- zeroed the same way Hard Deck's start_run hook sets G.GAME.dollars
    -- above; Hex points reuse `big(0)` the same way every other
    -- point-granting deck hook in this file already does.
    G.GAME.hex_points = big(0)
    G.GAME.dollars = 0

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()

            -- Destroy every other Joker currently held. start_dissolve
            -- plays the usual dissolve animation and removal, same as the
            -- HEX sacrifice button and Cavendish, and Inaccessible itself
            -- dissolves right along with the rest.
            for i = #G.jokers.cards, 1, -1 do
                local c = G.jokers.cards[i]
                if c then
                    c:start_dissolve()
                end
            end

            local card = SMODS.create_card({
                set = "Joker",
                key = "j_" .. mod.prefix .. "_absolute",
                area = G.jokers
            })

            G.jokers:emplace(card)

            G.GAME.hex_absolute_summoned = true

            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = "ABSOLUTE!",
                colour = G.C.ABSOLUTE
            })

            return true
        end
    }))
end

-- Add button under Hex counter

local old_start_run_ritual_button = Game.start_run

function Game:start_run(...)

    local ret = old_start_run_ritual_button(self, ...)

    -- Reset the Absolute button each new run -- Inaccessible has to be
    -- re-earned to unlock it again.
    G.ABSOLUTE_BUTTON = nil
    G.ABSOLUTE_BUTTON_LOCKED = nil


    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 2,
        func = function()
            
            G.RITUAL_BUTTON = UIBox{
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        align = "cm",
                        colour = G.C.UI.TRANSPARENT,
                        padding = -1,
                        emboss = 0,

                    },

                    nodes = {

                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                ref_table = G.GAME,
                            },

                            nodes = {

                                {
                                    n = G.UIT.R,
                                    config = {
                                        align = "cm"
                                    },

                                    nodes = {

                                        {
                                            n = G.UIT.C,
                                            config = {
                                                align = "cm",
                                                hover = true,
                                                shadow = true,
                                                r = 0.08,
                                                minw = 2.5,
                                                minh = 0.8,
                                                colour = G.C.HEX_ORPLE,
                                                button = "create_ritual",
                                            },

                                            nodes = {

                                                {
                                                    n = G.UIT.T,
                                                    config = {
                                                        text = "Create a ritual",
                                                        scale = 0.35,
                                                        colour = G.C.WHITE,
                                                    }
                                                }

                                            }
                                        }

                                    }
                                }

                            }
                        }

                    }
                },

                config = {
                    align = "cm",
                    offset = {
                        x = 9,
                        y = -1.0
                    },
                    major = G.ROOM_ATTACH,
                    emboss = 0,
                    no_fill = true

                }
            }

            G.TRANSCENDENTAL_BUTTON = UIBox{
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        align = "cm",
                        colour = G.C.UI.TRANSPARENT,
                        padding = -1,
                    },

                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                            },

                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = {
                                        align = "cm"
                                    },

                                    nodes = {
                                        {
                                            n = G.UIT.C,
                                            config = {
                                                align = "cm",
                                                hover = true,
                                                shadow = true,
                                                r = 0.08,
                                                minw = 2.5,
                                                minh = 0.8,
                                                colour = G.C.TRANSCENDENTAL,
                                                button = "summon_transcendental",
                                            },
                                            nodes = {
                                                {
                                                    n = G.UIT.R,
                                                    config = {
                                                        align = "cm",
                                                    },
                                                    nodes = {
                                                        {
                                                            n = G.UIT.T,
                                                            config = {
                                                                text = "Summon",
                                                                scale = 0.35,
                                                                colour = G.C.WHITE,
                                                                align = "cm",
                                                                shadow = true,
                                                            }
                                                        }
                                                    }
                                                },
                                                {
                                                    n = G.UIT.R,
                                                    config = {
                                                        align = "cm",
                                                    },
                                                    nodes = {
                                                        {
                                                            n = G.UIT.T,
                                                            config = {
                                                                text = "Transcendental",
                                                                scale = 0.35,
                                                                colour = G.C.WHITE,
                                                                align = "cm",
                                                                shadow = true,
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },

                config = {
                    align = "cm",
                    offset = {
                        x = 9,
                        y = 0
                    },
                    major = G.ROOM_ATTACH,
                    emboss = 0,
                    no_fill = true
                }
            }

            G.DIVINE_BUTTON = UIBox{
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        align = "cm",
                        colour = G.C.UI.TRANSPARENT,
                        padding = -1,
                    },

                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                            },

                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = {
                                        align = "cm"
                                    },

                                    nodes = {
                                        {
                                            n = G.UIT.C,
                                            config = {
                                                align = "cm",
                                                hover = true,
                                                shadow = true,
                                                r = 0.08,
                                                minw = 2.5,
                                                minh = 0.8,
                                                colour = G.C.DIVINE,
                                                button = "summon_divine",
                                            },
                                            nodes = {
                                                {
                                                    n = G.UIT.R,
                                                    config = {
                                                        align = "cm",
                                                    },
                                                    nodes = {
                                                        {
                                                            n = G.UIT.T,
                                                            config = {
                                                                text = "Summon",
                                                                scale = 0.35,
                                                                colour = G.C.WHITE,
                                                                align = "cm",
                                                                shadow = true,
                                                            }
                                                        }
                                                    }
                                                },
                                                {
                                                    n = G.UIT.R,
                                                    config = {
                                                        align = "cm",
                                                    },
                                                    nodes = {
                                                        {
                                                            n = G.UIT.T,
                                                            config = {
                                                                text = "Divine",
                                                                scale = 0.35,
                                                                colour = G.C.WHITE,
                                                                align = "cm",
                                                                shadow = true,
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },

                config = {
                    align = "cm",
                    offset = {
                        x = 9,
                        y = 1.0
                    },
                    major = G.ROOM_ATTACH,
                    emboss = 0,
                    no_fill = true
                }
            }

            return true
        end
    }))


    return ret
end









function Game:splash_screen()
    if G.SETTINGS.skip_splash == 'Yes' then
        G:main_menu()
        return
    end

    self:prep_stage(G.STAGES.MAIN_MENU, G.STATES.SPLASH, true)
    G.E_MANAGER:add_event(Event({
        func = (function()
            discover_card()
            return true
        end)
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            G.TIMERS.TOTAL = 0
            G.TIMERS.REAL = 0
            G.SPLASH_BACK = Sprite(-30, -13, G.ROOM.T.w+60, G.ROOM.T.h+22, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL'},
                    {name = 'vort_speed', val = 1},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'BLUE'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'WHITE'},
                    {name = 'mid_flash', val = 0},
                    {name = 'vort_offset', val = (2*90.15315131*os.time())%100000},
                }}})
            G.SPLASH_BACK:set_alignment({ major = G.ROOM_ATTACH, type = 'cm', offset = {x=0,y=0} })

            G.SPLASH_FRONT = Sprite(0,-20, G.ROOM.T.w*2, G.ROOM.T.h*4, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
            G.SPLASH_FRONT:define_draw_steps({{
                shader = 'flash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL'},
                    {name = 'mid_flash', val = 1}
                }}})
            G.SPLASH_FRONT:set_alignment({ major = G.ROOM_ATTACH, type = 'cm', offset = {x=0,y=0} })

            --spawn in splash card
            local SC = nil
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,func = (function()
                local SC_scale = 1.2
                SC = Card(G.ROOM.T.w/2 - SC_scale*G.CARD_W/2, 10. + G.ROOM.T.h/2 - SC_scale*G.CARD_H/2, SC_scale*G.CARD_W, SC_scale*G.CARD_H, G.P_CARDS.empty, G.P_CENTERS['c_hex'])
                SC.T.y = G.ROOM.T.h/2 - SC_scale*G.CARD_H/2
                SC.ambient_tilt = 1
                SC.states.drag.can = false
                SC.states.hover.can = false
                SC.no_ui = true
                G.VIBRATION = G.VIBRATION + 2
                play_sound('whoosh1', 0.7, 0.2)
                play_sound('introPad1', 0.704, 0.6)
            return true;end)}))

            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.8,func = (function()
                SC:start_dissolve({G.C.WHITE, G.C.WHITE},true, 12, true)
                play_sound('magic_crumple', 1, 0.5)
                play_sound('splash_buildup', 1, 0.7)
            return true;end)}))

            function make_splash_card(args)
                args = args or {}
                local angle = math.random()*2*3.14
                local card_size = (args.scale or 1.5)*(math.random() + 1)
                local card_pos = args.card_pos or {
                    x = (18 + card_size)*math.sin(angle),
                    y = (18 + card_size)*math.cos(angle)
                }
                local card = Card(  card_pos.x + G.ROOM.T.w/2 - G.CARD_W*card_size/2,
                                    card_pos.y + G.ROOM.T.h/2 - G.CARD_H*card_size/2,
                                    card_size*G.CARD_W, card_size*G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base)
                if math.random() > 0.8 then card.sprite_facing = 'back'; card.facing = 'back' end
                card.no_shadow = true
                card.states.hover.can = false
                card.states.drag.can = false
                card.vortex = true and not args.no_vortex
                card.T.r = angle
                return card, card_pos
            end

            G.vortex_time = G.TIMERS.REAL
            local temp_del = nil

            for i = 1, 200 do
                temp_del = temp_del or 3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    delay = temp_del,
                    func = (function()
                    local card, card_pos = make_splash_card({scale = 2 - i/300})
                    local speed = math.max(2. - i*0.005, 0.001)
                    ease_value(card.T, 'scale', -card.T.scale, nil, nil, nil, 1.*speed, 'elastic')
                    ease_value(card.T, 'x', -card_pos.x, nil, nil, nil, 0.9*speed)
                    ease_value(card.T, 'y', -card_pos.y, nil, nil, nil, 0.9*speed)
                    local temp_pitch = i*0.007 + 0.6
                    local temp_i = i
                    G.E_MANAGER:add_event(Event({
                        blockable = false,
                        func = (function()
                            if card.T.scale <= 0 then
                                if temp_i < 30 then
                                    play_sound('whoosh1', temp_pitch + math.random()*0.05, 0.25*(1 - temp_i/50))
                                end
                                if temp_i == 15 then
                                    play_sound('whoosh_long',0.9, 0.7)
                                end
                                G.VIBRATION = G.VIBRATION + 0.1
                                card:remove()
                                return true
                            end
                        end)}))
                        return true
                    end)}))
                    temp_del = temp_del + math.max(1/(i), math.max(0.2*(170-i)/500, 0.016))
            end

            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 2.,func = (function()
                G.SPLASH_BACK:remove()
                G.SPLASH_BACK = G.SPLASH_FRONT
                G.SPLASH_FRONT = nil
                G:main_menu('splash')
            return true;end)}))
        return true
    end)
    }))
end

function Game:main_menu(change_context)
    if change_context ~= 'splash' then 
        G.TIMERS.REAL = 12
        G.TIMERS.TOTAL = 12
    else
        RESET_STATES(G.STATES.MENU)
    end

    self:prep_stage(G.STAGES.MAIN_MENU, G.STATES.MENU, true)

    -- Hex UI (counter + buttons) shouldn't persist once we leave a run.
    -- These are only ever removed here on returning to the menu; the
    -- per-frame update logic in Game:update never touches G.HEX_TEXT
    -- unless it already exists, so setting it to nil just pauses it
    -- until the next start_run recreates it (still updating every
    -- second from that point on).
    if G.HEX_TEXT then
        G.HEX_TEXT:remove()
        G.HEX_TEXT = nil
    end
    if G.RITUAL_BUTTON then
        G.RITUAL_BUTTON:remove()
        G.RITUAL_BUTTON = nil
    end
    if G.TRANSCENDENTAL_BUTTON then
        G.TRANSCENDENTAL_BUTTON:remove()
        G.TRANSCENDENTAL_BUTTON = nil
    end
    if G.DIVINE_BUTTON then
        G.DIVINE_BUTTON:remove()
        G.DIVINE_BUTTON = nil
    end
    if G.ABSOLUTE_BUTTON then
        G.ABSOLUTE_BUTTON:remove()
        G.ABSOLUTE_BUTTON = nil
    end
    G.ABSOLUTE_BUTTON_LOCKED = nil

    self.GAME.selected_back = Back(G.P_CENTERS.b_red)

    if (not G.SETTINGS.tutorial_complete) and G.SETTINGS.tutorial_progress.completed_parts['big_blind'] then G.SETTINGS.tutorial_complete = true end

    G.FUNCS.change_shadows{to_key = G.SETTINGS.GRAPHICS.shadows == 'On' and 1 or 2}

    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}

    if G.SPLASH_FRONT then G.SPLASH_FRONT:remove(); G.SPLASH_FRONT = nil end
    if G.SPLASH_BACK then G.SPLASH_BACK:remove(); G.SPLASH_BACK = nil end
    G.SPLASH_BACK = Sprite(-30, -13, G.ROOM.T.w+60, G.ROOM.T.h+22, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
    G.SPLASH_BACK:set_alignment({
        major = G.ROOM_ATTACH,
        type = 'cm',
        offset = {x=0,y=0}
    })
    local splash_args = {mid_flash = change_context == 'splash' and 1.6 or 0.}
    ease_value(splash_args, 'mid_flash', -(change_context == 'splash' and 1.6 or 0), nil, nil, nil, 4)

    local blue_swirl = {
        c1 = HEX('1E3A8A'), -- deep navy blue
        c2 = HEX('38BDF8'), -- lighter sky blue
    }

    G.SPLASH_BACK:define_draw_steps({{
        shader = 'splash',
        send = {
            {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
            {name = 'vort_speed', val = 0.4},
            {name = 'colour_1', ref_table = blue_swirl, ref_value = 'c1'},
            {name = 'colour_2', ref_table = blue_swirl, ref_value = 'c2'},
            {name = 'mid_flash', ref_table = splash_args, ref_value = 'mid_flash'},
            {name = 'vort_offset', val = 0},
        }}})

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            unlock_notify()
            return true
        end)
      }))

    local SC_scale = 1.1*(G.debug_splash_size_toggle and 0.8 or 1)
    local CAI = {
        TITLE_TOP_W = G.CARD_W,
        TITLE_TOP_H = G.CARD_H,
    }
    self.title_top = CardArea(
        0, 0,
        CAI.TITLE_TOP_W,CAI.TITLE_TOP_H,
        {card_limit = 1, type = 'title'})

    G.SPLASH_LOGO = Sprite(0, 0, 
        13*SC_scale, 
        13*SC_scale*(G.ASSET_ATLAS["balatro"].py/G.ASSET_ATLAS["balatro"].px),
        G.ASSET_ATLAS["balatro"], {x=0,y=0})

    G.SPLASH_LOGO:set_alignment({
        major = G.title_top,
        type = 'cm',
        bond = 'Strong',
        offset = {x=0,y=0}
    })
    G.SPLASH_LOGO:define_draw_steps({{
            shader = 'dissolve',
        }})

    G.SPLASH_LOGO.dissolve_colours = {G.C.WHITE, G.C.WHITE}
    G.SPLASH_LOGO.dissolve = 1   

    -- 🔻 changed: base is now nil, center is c_hex instead of S_A / c_base 🔻
    local replace_card = Card(self.title_top.T.x, self.title_top.T.y, 1.2*G.CARD_W*SC_scale, 1.2*G.CARD_H*SC_scale, nil, G.P_CENTERS.c_hex)
    self.title_top:emplace(replace_card)

    replace_card.states.visible = false
    replace_card.no_ui = true
    replace_card.ambient_tilt = 0.0

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = change_context == 'game' and 1.5 or 0,
        blockable = false,
        blocking = false,
        func = (function()
            if change_context == 'splash' then 
                replace_card.states.visible = true
                replace_card:start_materialize({G.C.WHITE,G.C.WHITE}, true, 2.5)
                play_sound('whoosh1', math.random()*0.1 + 0.3,0.3)
                play_sound('crumple'..math.random(1,5), math.random()*0.2 + 0.6,0.65)
            else
                replace_card.states.visible = true
                replace_card:start_materialize({G.C.WHITE,G.C.WHITE}, nil, 1.2)
            end
            G.VIBRATION = G.VIBRATION + 1
            return true
    end)}))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = change_context == 'splash' and 1.8 or change_context == 'game' and 2 or 0.5,
        blockable = false,
        blocking = false,
        func = (function()
            play_sound('magic_crumple'..(change_context == 'splash' and 2 or 3), (change_context == 'splash' and 1 or 1.3), 0.9)
            play_sound('whoosh1', 0.4, 0.8)
            ease_value(G.SPLASH_LOGO, 'dissolve', -1, nil, nil, nil, change_context == 'splash' and 2.3 or 0.9)
            G.VIBRATION = G.VIBRATION + 1.5
            return true
    end)}))

    delay(0.1 + (change_context == 'splash' and 2 or change_context == 'game' and 1.5 or 0))

    -- 🔻 removed: the block that swapped replace_card to a random locked Joker/Voucher 🔻
    -- (this kept it from dissolving Hex away a few seconds later)

    G.E_MANAGER:add_event(Event({func = function() G.CONTROLLER.lock_input = false; return true end}))
    set_screen_positions()

    self.title_top:sort('order')
    self.title_top:set_ranks()
    self.title_top:align_cards()
    self.title_top:hard_set_cards()

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = change_context == 'splash' and 4.05 or change_context == 'game' and 3 or 1.5,
        blockable = false,
        blocking = false,
        func = (function()
                set_main_menu_UI()
                return true
            end)
        }))

    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].career_stats) do
        check_for_unlock({type = 'career_stat', statname = k})
    end
    check_for_unlock({type = 'blind_discoveries'})

    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            set_discover_tallies()
            set_profile_progress()
            G.REFRESH_ALERTS = true
        return true
        end
      }))

    UIBox{
        definition = 
        {n=G.UIT.ROOT, config={align = "cm", colour = G.C.UI.TRANSPARENT_DARK}, nodes={
            {n=G.UIT.T, config={text = G.VERSION, scale = 0.3, colour = G.C.UI.TEXT_LIGHT}}
        }},
        config = {align="tri", offset = {x=0,y=0}, major = G.ROOM_ATTACH, bond = 'Weak'}
    }
end