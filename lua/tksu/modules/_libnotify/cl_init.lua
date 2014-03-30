Msg("[LN] Loading libnotify\n")
net.Receive("libnotify", function(length, client)
    local table = net.ReadTable()
    GAMEMODE:AddNotify(table.message or "Error.", table.mtype or 4, table.time or 4)
    if table.sound then
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    print(table.message or "error")
end)
Msg("[LN] Loaded clientside hooks\n")
Msg("[LN] Loaded libnotify successfuly\n")
