Msg("[APK] Initialising Anti Propkill\n")
local verbose = true
Msg("[APK] Verbose mode enabled - will display all messages.\n")

local blockedDamage = {
    "gmod_button",
    "wire_textscreen",
    "prop_physics",
}

local conditionalDamage = {
    "worldspawn",
}

local blockConditional = true

local function PMsg( content )
    if ( verbose ) then
        Msg("[APK] "..content.."\n")
    end
end

local function damageIsBlocked( damage, attacker )
    for _, v in pairs(blockedDamage) do
        if attacker:GetClass() == v then
            return true
        end
    end
    return false
end

local function damageIsConditional( damage, attacker )
    for _, v in pairs(conditionalDamage) do
        if attacker:GetClass() == v then
            return true
        end
    end
    return false
end

local function markTime()
    blockConditinal = true
    timer.Create( "Unblock Conditional", 1, 1, function()
        blockConditional = false
    end )
end

hook.Add( "PlayerShouldTakeDamage", "propdamage remover", function( ply, attacker )
        if ( not attacker:IsPlayer() and ply:IsValid() ) then
            local damage = attacker:GetClass()
            local blocked = damageIsBlocked( damage, attacker )
            local conditional = damageIsConditional( damage, attacker )

            if ( blocked ) then -- Stop blocked damage and mark the time.
                markTime()
                PMsg("Stopped blocked damage")
                return false
            end

            if ( conditional and blockConditional) then
                markTime()
                PMsg("Stopped conditional damage")
                return false
            end
            PMsg("Letting conditional damage from "..damage.." pass")
        end
    end
)
