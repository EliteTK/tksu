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

    local entPCC = {}

    hook.Add( "OnEntityCreated", "Add entity to logger", function( entity )
        if entity:GetClass() == "prop_physics" then
            local CID = entity:GetCreationID()
            entPCC[CID] = 0

            entity:AddCallback("PhysicsCollide", function (colData, collider)
                if (not entity:IsPlayerHolding()) then
                    entPCC[CID] = entPCC[CID] + 1
                end
            end )

            timer.Create( "Timer:"..CID, 1, 0, function() 
                if (entPCC[CID] > maxPCCPerSecond) then
                    PMsg("Freezing entity "..entity:GetModel().." PCC: "..entPCC[CID].." pos: "..tostring(entity:GetPos()))
                    entity:GetPhysicsObject():EnableMotion(false)
                end
                entPCC[CID] = 0
            end )

            PMsg("Added "..CID.." to PLP list")
        end
    end )

    hook.Add( "EntityRemoved", "Remove entity from logger", function( entity )
        if entity:GetClass() == "prop_physics" then
            local CID = entity:GetCreationID()
            entPCC[CID] = nil
            timer.Remove( "Timer:"..CID )
            PMsg("Removed "..CID.." from PLP list")
        end
    end )
end
