SMODS.current_mod = SMODS.current_mod or {}

SMODS.current_mod.init = function()
    print("Hex initialized")
end

SMODS.current_mod.keybind = function()
    if love.keyboard.isDown("h") then
        print("Hex key pressed!")
    end
end

local hex_triggered = false

local old_update = Game.update
function Game:update(dt)
    old_update(self, dt)

    if love.keyboard.isDown("h") and not hex_triggered then
        hex_triggered = true
        print("Hex triggered")
    end

    if not love.keyboard.isDown("h") then
        hex_triggered = false
    end
end
