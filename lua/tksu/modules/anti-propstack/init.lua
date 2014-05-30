if (SERVER) then
    Msg("[APS] Initialising Anti Prop Stack.\n")
    hook.Add("PlayerSpawnedProp", "Anti-PropStack", function(ply, model, ent)
        pos = ent:GetPos()
        for _, v in pairs(ents.FindInSphere(pos, 1)) do
            if v:GetPos() == pos and v:GetModel() == model and v != ent then
                ent:Remove()
                if IsValid(ply) then libnotify.notify(0, 4, true, "Your prop was removed because its position coincided with the position of a previous prop.", ply) end
                Msg(ply:GetName() or "unknown" .. " tried to spawn prop at " .. tostring(pos) .. " but already found ent at " .. tostring(v:GetPos()) .. ".\n")
                break
            end
        end
    end)
    Msg("[APS] Anti Prop Stack initialised.\n")
end
