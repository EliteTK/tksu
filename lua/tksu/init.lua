Msg("\n ==== Initialising TK Server Utilities ==== \n")
AddCSLuaFile("tksu/cl_init.lua")
AddCSLuaFile("autorun/start.lua")
local filenames  = {"init.lua", "shared.lua", "cl_init.lua"}

local _, modules = file.Find( "tksu/modules/*", "LUA" )

for _, folder in pairs(modules) do
    Msg("[TKSU] Loading "..folder.."\n")
    for _, filename in pairs(filenames) do
        local path = "tksu/modules/"..folder.."/"..filename
        if file.Exists( path, "LUA" ) then
            if filename == filenames[1] then
                Msg( "[TKSU] Including file: "..folder.."/init.lua\n" )
                include( path, "LUA" )
            elseif filename == filenames[2] then
                Msg( "[TKSU] Including and adding CS file: "..folder.."/shared.lua\n" )
                include( path, "LUA" )
                AddCSLuaFile( path, "LUA" )
            elseif filename == filenames[3] then
                Msg( "[TKSU] Adding CS file: "..folder.."/cl_init.lua\n" )
                AddCSLuaFile( path, "LUA" )
            end
        end
    end
end

Msg(" ==== TKSU initialisation successful ==== \n\n")
