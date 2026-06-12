#version 2
--[[
#include "scripts/sandbox.lua"
#include "scripts/hud.lua"
]]

-- `#version 2` MUST be the literal first line (the docs say each script "must start
-- with" it, and the MP game-mode menu validator appears to read the raw first line
-- -- a `#version 2` buried inside the block comment is not detected, so the game
-- mode never appears). Lua/LuaJIT skip a leading line starting with `#` (shebang
-- handling), so this stays valid for luajit / lua-language-server. The #include
-- directives remain in the block comment; Teardown's preprocessor still reads them.

local serverSetupDone = false

function server.init()
    Sandbox:setup()
    serverSetupDone = true
end

function server.tick(dt)
    if not serverSetupDone then
        Sandbox:setup()
        serverSetupDone = true
    end
    Sandbox:onJoin()
end

function server.update(dt)
    Sandbox:maintain(dt)
end

function client.draw()
    Hud:draw()
end
