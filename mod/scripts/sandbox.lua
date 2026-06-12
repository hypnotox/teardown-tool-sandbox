-- Sandbox (server): the version-2 game-mode logic. Discovers every CUSTOM
-- (mod-registered) tool present in the session and grants it to every player.
-- No client/world state beyond per-player tool enable + ammo (both serveronly).
-- See ../docs/specs/2026-06-12-tool-sandbox-gamemode-design.md.
Sandbox = {
    -- Re-assert/top-up cadence (seconds). Throttled to keep SetToolAmmo churn low.
    maintainInterval = 1.0,
    infiniteAmmo = true,
    _timer = 0,
}

-- Idempotent setup. Seeds the infinite-ammo setting on first run, then reads it.
function Sandbox:setup()
    if not HasKey('savegame.mod.sandbox.initialized') then
        SetBool('savegame.mod.sandbox.infinite_ammo', true)
        SetBool('savegame.mod.sandbox.initialized', true)
    end
    self.infiniteAmmo = GetBool('savegame.mod.sandbox.infinite_ammo')
end

-- All custom (mod-registered) tool ids currently present. Vanilla tools lack the
-- `.custom` flag and are excluded (players get those from the base game anyway).
function Sandbox:customTools()
    local ids = {}
    for _, id in ipairs(ListKeys('game.tool')) do
        if GetBool('game.tool.' .. id .. '.custom') then
            ids[#ids + 1] = id
        end
    end
    return ids
end

-- Per-tool pickup ammo (falls back to a large number if the tool set none).
local function toolAmmo(id)
    local n = GetToolAmmoPickupAmount(id)
    if n <= 0 then
        n = 999
    end
    return n
end

-- Enable + fill every custom tool for one player.
function Sandbox:grant(player)
    for _, id in ipairs(self:customTools()) do
        SetToolEnabled(id, true, player)
        SetToolAmmo(id, toolAmmo(id), player)
    end
end

-- Grant to players who joined since the last tick.
function Sandbox:onJoin()
    for _, p in ipairs(GetAddedPlayers()) do
        self:grant(p)
    end
end

-- Throttled upkeep: re-assert grants (idempotent SetToolEnabled restores tools
-- cleared on respawn -- no dependence on a respawn event), and top up ammo when
-- infinite-ammo is on.
function Sandbox:maintain(dt)
    self._timer = self._timer + dt
    if self._timer < self.maintainInterval then
        return
    end
    self._timer = 0

    local ids = self:customTools()
    for _, p in ipairs(GetAllPlayers()) do
        for _, id in ipairs(ids) do
            SetToolEnabled(id, true, p)
            if self.infiniteAmmo then
                SetToolAmmo(id, toolAmmo(id), p)
            end
        end
    end
end
