Msg("\n ==== Initialising TK Server Utilities Clientside ==== \n")
local filenames  = {"shared.lua", "cl_init.lua"}

local _, modules = file.Find( "tksu/modules/*", "LUA" )

for _, folder in pairs(modules) do
    Msg("[TKSU] Loading "..folder.."\n")
    for _, filename in pairs(filenames) do
        local path = "tksu/modules/"..folder.."/"..filename
        if file.Exists( path, "LUA" ) then
            Msg( "[TKSU] Including file: "..folder.."/cl_init.lua\n" )
            AddCSLuaFile( path, "LUA" )
        end
    end
end

Msg(" ==== TKSU clientside initialisation successful. ==== \n\n")
