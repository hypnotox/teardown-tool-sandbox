-- Hud (client): a small overlay listing the tools the sandbox grants. Uses only
-- read-only game.tool queries, so it computes the list independently in the
-- client environment (where Sandbox's server-side grant state does not exist).
Hud = {}

function Hud:draw()
    local ids = Sandbox:customTools()

    UiPush()
    UiTranslate(40, 40)
    UiFont('regular.ttf', 24)
    UiColor(1, 0.85, 0.3)

    if #ids == 0 then
        UiText('Tool Sandbox: no custom tools loaded -- enable your tool mods in the host setup.')
    else
        local names = {}
        for _, id in ipairs(ids) do
            local name = GetString('game.tool.' .. id .. '.name')
            if name == '' then
                name = id
            end
            names[#names + 1] = name
        end
        UiText('Tool Sandbox -- granted: ' .. table.concat(names, ', '))
    end

    UiPop()
end
