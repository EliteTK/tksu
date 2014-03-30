Msg("[LN] Loading libnotify\n")

if not libnotify then libnotify = {} end

util.AddNetworkString("libnotify")


function libnotify.notify(mtype, time, sound, message, ply)
    if not IsValid(ply) then return end
    local table = {}
    table.message = message
    table.mtype = mtype
    table.time = time
    table.sound = sound
    net.Start("libnotify")
        net.WriteTable(table)
    net.Send(ply)
end

function libnotify.notify_all(mtype, time, sound, message)
    local table = {}
    table.message = message
    table.mtype = time
    table.time = time
    table.sound = sound
    net.Start("libnotify")
        net.WriteTable(table)
    net.Broadcast()
end

function libnotify.notify_cond(mtype, time, sound, message, test)
    for _, user in pairs(player.GetHumans()) do
        if test(user) then
            libnotify.notify(mtype, time, sound, message, user)
        end
    end
end

Msg("[LN] Loaded serverside functionality\n")
Msg("[LN] Loaded libnotify successfuly\n")
