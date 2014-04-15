if ( SERVER ) then
    local entlist = {}
    local notifygroups = {"superadmin", "admin", "moderator"}

    Msg("[PLP] Initialising Prop Lag Protection\n")

    local maxPCCPerSecond = 40
    local verbose = true

    Msg("[PLP] Set to freeze past "..maxPCCPerSecond.." PPCPS\n")
    if ( verbose ) then
        Msg("[PLP] Verbose mode enabled - will display all messages.\n")
    else
        Msg("[PLP] Verbose mode disabled - will no longer display messages.")
    end

    local function notifyTest(ply)
        local plygroup = ply:GetUserGroup()
        local flag = false
        for _, v in pairs(notifygroups) do
            if v == plygroup then flag = true end
        end
        return flag
    end

    local function PMsg( content )
        if ( verbose ) then
            Msg("[PLP] "..content.."\n")
        end
    end

    local function ghostFreeze(entity, CID)
        if(entlist[CID].ghosted) then return end
        local physics = entity:GetPhysicsObject()
        entlist[CID].colour = entity:GetColor()
        entlist[CID].collision = entity:GetCollisionGroup()
        entlist[CID].motion = entity:GetPhysicsObject():IsMoveable()

        entity:SetRenderMode(RENDERMODE_TRANSALPHA)
        entity:DrawShadow(false)
        entity:SetColor(Color(255, 255, 255, 127))
        entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
        entity:GetPhysicsObject():EnableMotion(false)

        entlist[CID].ghosted = true
    end

    local function unghostFreeze(entity, CID)
        if(not entlist[CID] or not entlist[CID].ghosted) then return end
        entlist[CID].ghosted = nil

        entity:DrawShadow(true)
        entity:SetColor(entlist[CID].colour or Color(255, 255, 255, 255))
        entlist[CID].colour = nil
        entity:SetCollisionGroup(entlist[CID].collision or COLLISION_GROUP_NONE)
        entlist[CID].collision = nil
        entity:GetPhysicsObject():EnableMotion(entlist[CID].motion or true)
        entlist[CID].motion = nil
    end

    hook.Add( "PlayerSpawnedProp", "Add entity to logger", function( ply, model, entity )
        if entity:GetClass() == "prop_physics" then
            local CID = entity:GetCreationID()
            entlist[CID] = {}
            entlist[CID].owner = ply
            entlist[CID].model = model
            entlist[CID].count = 0
            entlist[CID].ccount = 0

            entity:AddCallback("PhysicsCollide", function (colData, collider)
                if (not entity:IsPlayerHolding()) then
                    entlist[CID].count = entlist[CID].count + 1
                end
            end )

            timer.Create( "Timer:"..CID, 1, 0, function()
                if (entlist[CID].count > maxPCCPerSecond) then
                    entlist[CID].ccount = entlist[CID].ccount + 1
                    PMsg("Entity "..CID.." triggered PLP, ccount is now "..entlist[CID].ccount)
                    if (entlist[CID].ccount >= 3) then
                        local owner = entlist[CID].owner
                        libnotify.notify(0, 4, true, "Your prop was ghosted because it caused too many physics updates.", owner)
                        owner = (IsValid(owner) and owner:Nick()) or "unknown"
                        PMsg("Ghosting entity PCC: "..entlist[CID].count.." pos: "..tostring(entity:GetPos()).." owned by: "..owner)
                        libnotify.notify_cond(0, 4, true, "[PLP] "..owner.." might be prop-spamming.", notifyTest)
                        ghostFreeze(entity, CID)
                    end
                else
                    entlist[CID].ccount = math.max(entlist[CID].ccount - 1, 0)
                end
                entlist[CID].count = 0
            end )

            PMsg("Added "..CID.." to PLP list")
        end
    end )

    hook.Add( "EntityRemoved", "Remove entity from logger", function( entity )
        local CID = entity:GetCreationID()
        if entlist[CID] ~= nil then
            entlist[CID] = nil
            timer.Remove( "Timer:"..CID )
            PMsg("Removed "..CID.." from PLP list")
        end
    end )

    hook.Add("PhysgunPickup", "PLP_Unghost", function(player, entity)
        unghostFreeze(entity, entity:GetCreationID())
    end)
end
