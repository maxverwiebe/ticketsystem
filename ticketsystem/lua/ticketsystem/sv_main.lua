util.AddNetworkString("TicketSystem.AddTicket")
util.AddNetworkString("TicketSystem.ReviseTicket") -- TODO
util.AddNetworkString("TicketSystem.RequestTickets")
util.AddNetworkString("TicketSystem.TicketsSent")
util.AddNetworkString("TicketSystem.ClaimTicket")
util.AddNetworkString("TicketSystem.CloseTicket")
util.AddNetworkString("TicketSystem.ReopenTicket")
util.AddNetworkString("TicketSystem.ChatMessage")
util.AddNetworkString("TicketSystem.OpenTicketCreation")
util.AddNetworkString("TicketSystem.OpenTicketAdmin")

TicketSystem.Tickets = {}

net.Receive("TicketSystem.AddTicket", function(_, ply)
    local title = net.ReadString()
    local text = net.ReadString()

    TicketSystem:AddTicket(ply, title, text)
end)

net.Receive("TicketSystem.RequestTickets", function(_, ply)
    if not TicketSystem:PlayerHasPermission(ply, "TicketSystem.CanOpenAdminMenu") then return end
    net.Start("TicketSystem.TicketsSent")
    net.WriteTable(TicketSystem.Tickets)
    net.Send(ply)
end)

net.Receive("TicketSystem.ClaimTicket", function(_, ply)
    local key = net.ReadInt(32)
    TicketSystem:ClaimTicket(ply, key)
end)

net.Receive("TicketSystem.CloseTicket", function(_, ply)
    local key = net.ReadInt(32)
    TicketSystem:CloseTicket(ply, key)
end)

net.Receive("TicketSystem.ReopenTicket", function(_, ply)
    local key = net.ReadInt(32)
    TicketSystem:ReopenTicket(ply, key)
end)

-- Adds a ticket to the global table
--
-- @Param Player ply
-- @Param String title
-- @Param String text
-- @Return Boolean success
function TicketSystem:AddTicket(ply, title, text)

    if not TicketSystem:PlayerHasPermission(ply, "TicketSystem.CanCreateTicket") then return false end

    if TicketSystem:CheckTicketLimitReached(ply) then ply:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_TICKETLIMITREACHED", TicketSystem.Config.TicketLimit)) return false end

    local ticket = table.Copy(TicketSystem.TicketObject)
    ticket.title = title
    ticket.text = text
    ticket.sender_id = ply:SteamID64()
    ticket.status = 1
    ticket.time = CurTime()

    table.insert(TicketSystem.Tickets, ticket)

    ply:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_TICKETCREATED"), TicketSystem.Config.Labels[1].color, TicketSystem.Config.Labels[1].name)

    for k, v in pairs(TicketSystem:GetAllStaffmembers()) do
        v:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_NEWTICKET"))
    end

    hook.Run("TicketSystem.TicketCreated", ply, title, text)
    return true
end

-- Marks a ticket as claimed by the given player
--
-- @Param Player ply
-- @Param Number key
-- @Return Boolean success
function TicketSystem:ClaimTicket(ply, key)
    if not TicketSystem:PlayerHasPermission(ply, "TicketSystem.ManageTickets") then return false end
    if TicketSystem:IsClaimed(TicketSystem.Tickets[key]) then return false end

    TicketSystem.Tickets[key].status = 2
    TicketSystem.Tickets[key].admin_id = ply:SteamID64()

    local sender = player.GetBySteamID64(TicketSystem.Tickets[key].sender_id)
    sender:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_STATUSCHANGED"), TicketSystem.Config.Labels[2].color, TicketSystem.Config.Labels[2].name)

    hook.Run("TicketSystem.TicketClaimed", ply)
    return true
end

-- Marks a ticket as closed by the given player
--
-- @Param Player ply
-- @Param Number key
-- @Return Boolean success
function TicketSystem:CloseTicket(ply, key)
    if not TicketSystem:PlayerHasPermission(ply, "TicketSystem.ManageTickets") then return false end
    if not TicketSystem:ClaimedBy(ply, TicketSystem.Tickets[key]) then return false end

    local sender = player.GetBySteamID64(TicketSystem.Tickets[key].sender_id)
    sender:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_STATUSCHANGED"), TicketSystem.Config.Labels[3].color, TicketSystem.Config.Labels[3].name)

    TicketSystem.Tickets[key] = nil

    hook.Run("TicketSystem.TicketClosed", ply)
    return true
end

-- Reopens a ticket by the given player
--
-- @Param Player ply
-- @Param Number key
-- @Return Boolean success
function TicketSystem:ReopenTicket(ply, key)
    if not TicketSystem:PlayerHasPermission(ply, "TicketSystem.ManageTickets") then return false end
    if not TicketSystem:IsClaimed(TicketSystem.Tickets[key]) then return false end

    TicketSystem.Tickets[key].status = 1
    TicketSystem.Tickets[key].admin_id = "ply:SteamID64()"

    local sender = player.GetBySteamID64(TicketSystem.Tickets[key].sender_id)
    sender:TicketMessage(Color(255,255,255), TicketSystem:GetText("MSG_STATUSCHANGED"), TicketSystem.Config.Labels[1].color, TicketSystem.Config.Labels[1].name)

    hook.Run("TicketSystem.TicketReopened", ply)
    return true
end

-- Onetime function to start the reminder timer
--
function TicketSystem:StartReminder()
    local timerString = "TicketSystem.Reminder"
    if timer.Exists(timerString) then timer.Remove(timerString) end

    timer.Create(timerString, TicketSystem.Config.ReminderCooldown, 0, function()

        local ticketCount = #TicketSystem.Tickets

        if ticketCount <= 0 then return end

        for _, ply in pairs(TicketSystem:GetAllStaffmembers()) do
            ply:TicketMessage(Color(255,193,193), TicketSystem:GetText("MSG_REMINDERTEXT", ticketCount))
        end
    end)
end

-- Checks whether the player has reached the ticket limit
--
-- @Param Player ply
-- @Return Boolean limitReached
function TicketSystem:CheckTicketLimitReached(ply)
    local ticketCount = 0
    local plySteamID64 = ply:SteamID64()

    for key, ticket in pairs(TicketSystem.Tickets) do
        if ticket.sender_id == plySteamID64 then
            ticketCount = ticketCount + 1
        end
    end

    if ticketCount >= TicketSystem.Config.TicketLimit then
        return true
    end

    return false
end

-- HOOK: if the player has a ticket and leaves the server, it will be deleted
-- HOOK: When the admin has claimed a ticket and leaves the server, the ticket is reopened
hook.Add("PlayerDisconnected", "TicketSystem.OnDisconnect", function(ply)
    local plySteamID64 = ply:SteamID64()

    for key, ticket in pairs(TicketSystem.Tickets) do
        if ticket.sender_id == plySteamID64 then
            TicketSystem.Tickets[key] = nil
        end
        if ticket.admin_id == plySteamID64 then
            if not TicketSystem.Tickets[key] then continue end
            TicketSystem.Tickets[key].status = 1
            TicketSystem.Tickets[key].admin_id = ""
        end
    end
end)

-- HOOK: Starts the timer on initilizing
hook.Add("Initialize", "TicketSystem.StartReminderTimer", function()
    TicketSystem:StartReminder()
end)

-- HOOK: Commands
hook.Add("PlayerSay", "CoinFlip", function( ply, text )
	if table.HasValue(TicketSystem.Config.Commands.Creation, string.lower(text)) then
		net.Start("TicketSystem.OpenTicketCreation")
        net.Send(ply)
		return ""
	end
    if table.HasValue(TicketSystem.Config.Commands.Admin, string.lower(text)) then
		net.Start("TicketSystem.OpenTicketAdmin")
        net.Send(ply)
		return ""
	end
end)