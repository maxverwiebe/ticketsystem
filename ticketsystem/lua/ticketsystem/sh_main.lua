TicketSystem.TicketObject = {
    title = "",
    text = "",
    sender_id = "",
    admin_id = "",
    status = "",
    time = "",
}

-- Checks whether the ticket is claimed (in status 2)
--
-- @Param Table ticketTable
-- @Return Boolean isClaimed
function TicketSystem:IsClaimed(ticket)
    if ticket.status == 2 then return true end
    return false
end

-- Checks whether the ticket is claimed by the given player
--
-- @Param Player ply
-- @Param Table ticket
-- @Return Boolean isClaimedByPlayer
function TicketSystem:ClaimedBy(ply, ticket)
    if ticket.admin_id == ply:SteamID64() then return true end
    return false
end

-- Checks whether the given player has the CAMI permission
--
-- @Param Player ply
-- @Param String permission
-- @Param Boolean preventMessage
-- @Return Boolean isClaimedByPlayer
function TicketSystem:PlayerHasPermission(ply, permission, preventMessage)
    --[[local usergroup = ply:GetUserGroup()

    if not TicketSystem.Config.Usergroups[usergroup] then usergroup = TicketSystem.Config.DefaultUsergroup end -- Fallback if the rank isn't configured

    if table.HasValue(TicketSystem.Config.Usergroups[usergroup].perms, "*") then return true end
    if table.HasValue(TicketSystem.Config.Usergroups[usergroup].perms, permission) then return true end]]--

    if CAMI.PlayerHasAccess(ply, permission) then
        return true 
    else
        if preventMessage then return false end

        if SERVER then
            ply:TicketMessage(Color(255,0,0), TicketSystem:GetText("MSG_NOPERMS", permission))
        else
            chat.AddText(Color(255,77,77), "TicketSystem", Color(90,90,90)," » ", Color(255,0,0), TicketSystem:GetText("MSG_NOPERMS", permission))
        end
        return false
    end
end

-- Returns the aligned usergroup info
--
-- @Param Player ply
-- @Return String usergroupName
-- @Return Color usergroupColor
function TicketSystem:GetUsergroupInfo(ply)
    local usergroup = ply:GetUserGroup()

    if not TicketSystem.Config.Usergroups[usergroup] then usergroup = TicketSystem.Config.DefaultUsergroup end -- Fallback if the rank isn't configured

    return TicketSystem.Config.Usergroups[usergroup].name, TicketSystem.Config.Usergroups[usergroup].color
end

-- Returns all players with the permission "TicketSystem.CanOpenAdminMenu"
--
-- @Return Table staffmembers
function TicketSystem:GetAllStaffmembers()
    local list = {}

    for k, v in pairs(player.GetAll()) do
        if TicketSystem:PlayerHasPermission(v, "TicketSystem.CanOpenAdminMenu", true) then
            table.insert(list, v)
        end
    end

    return list
end

if SERVER then
    local ply = FindMetaTable("Player")

    function ply:TicketMessage(...)
        net.Start("TicketSystem.ChatMessage")
            net.WriteTable({...})
        net.Send(self)
    end
else
    net.Receive("TicketSystem.ChatMessage", function(len)
        chat.AddText(Color(255,77,77), "TicketSystem", Color(90,90,90)," » ", unpack(net.ReadTable()))
    end)
end

-- Localization support
--
-- @Param String identifier
-- @Param Any var1... var5
-- @Return String formattedText
function TicketSystem:GetText(identifier, var1, var2, var3, var4, var5)
    if not TicketSystem.Config.Language[identifier] then return "ERROR" end

    return string.format(TicketSystem.Config.Language[identifier], var1, var2, var3, var4, var5)
end

CAMI.RegisterPrivilege({
    Name = "TicketSystem.CanOpenAdminMenu",
    MinAccess = "operator",
    Description = "Can the player open the overview menu?",
})

CAMI.RegisterPrivilege({
    Name = "TicketSystem.ManageTickets",
    MinAccess = "operator",
    Description = "Can the player manage tickets? (Claim, close, reopen etc.)",
})

CAMI.RegisterPrivilege({
    Name = "TicketSystem.CanCreateTicket",
    MinAccess = "user",
    Description = "Can the player create a ticket?",
})