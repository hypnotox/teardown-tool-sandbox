--[[
#version 2

#include "scripts/sandbox.lua"
#include "scripts/hud.lua"
]]

-- #version 2 sits inside this leading block comment alongside the #include
-- directives: Teardown's preprocessor reads them; standard Lua tooling sees a
-- comment, so the file stays valid for luajit / lua-language-server.

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
