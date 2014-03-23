if ( SERVER ) then
    Msg("[PLP] Initialising Prop Lag Protection\n")

    local maxPCCPerSecond = 40
    local verbose = true

    Msg("[PLP] Set to freeze past "..maxPCCPerSecond.." PPCPS\n")
    if ( verbose ) then
        Msg("[PLP] Verbose mode enabled - will display all messages.\n")
    else
        Msg("[PLP] Verbose mode disabled - will no longer display messages.")
    end

    function PMsg( content )
        if ( verbose ) then
            Msg("[PLP] "..content.."\n")
        end
    end

    local entlist = {}

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
                        owner = (IsValid(owner) and owner:Nick()) or "unknown"
                        PMsg("Freezing entity PCC: "..entlist[CID].count.." pos: "..tostring(entity:GetPos()).." owned by: "..owner)
                        for _, v in pairs(player.GetHumans()) do
                            if v:IsAdmin() and IsValid(v) then
                                DarkRP.notify(v, 0, 4, "[PLP] "..owner.." might be prop-spamming.")
                            end
                        end

                        entity:GetPhysicsObject():EnableMotion(false)
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
        if entity:GetClass() == "prop_physics" then
            local CID = entity:GetCreationID()
            entlist[CID] = nil
            timer.Remove( "Timer:"..CID )
            PMsg("Removed "..CID.." from PLP list")
        end
    end )
end
