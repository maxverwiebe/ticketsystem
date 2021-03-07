function TicketSystem:GetTicketStatus(statusID)
    if not TicketSystem.Config.Labels then return false end

    local name = TicketSystem.Config.Labels[statusID].name
    local color = TicketSystem.Config.Labels[statusID].color

    return name, color
end