TicketSystem = {}

print("[TicketSystem] Loading TicketSystem...")

local dir = "ticketsystem/"

if SERVER then
    AddCSLuaFile(dir.."sh_config.lua")
    AddCSLuaFile(dir.."cl_fonts.lua")
    AddCSLuaFile(dir.."cl_main.lua")
    AddCSLuaFile(dir.."cl_functions.lua")
    AddCSLuaFile(dir.."sh_main.lua")
    AddCSLuaFile(dir.."ui_elements/cl_navbutton.lua")
    AddCSLuaFile(dir.."ui_elements/cl_textentry.lua")
    AddCSLuaFile(dir.."ui_elements/cl_circularavatar.lua")
    AddCSLuaFile(dir.."ui_elements/cl_closebutton.lua")



    include(dir.."sh_config.lua")
    include(dir.."sh_main.lua")
    include(dir.."sv_main.lua")
else
    include(dir.."sh_config.lua")
    include(dir.."cl_fonts.lua")
    include(dir.."sh_main.lua")
    include(dir.."cl_main.lua")
    include(dir.."cl_functions.lua")
    include(dir.."ui_elements/cl_navbutton.lua")
    include(dir.."ui_elements/cl_textentry.lua")
    include(dir.."ui_elements/cl_circularavatar.lua")
    include(dir.."ui_elements/cl_closebutton.lua")
end

print("[TicketSystem] Successfully loaded")