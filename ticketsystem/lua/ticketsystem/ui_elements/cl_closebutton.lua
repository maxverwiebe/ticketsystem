local CloseButton = {}

function CloseButton:Init()
    self.Color = TicketSystem.Config.Theme.navButton
    self.HoverColor = Color(self.Color.r + 16, self.Color.g + 16, self.Color.b + 16, 255)
    self.DisabledColor = Color(180, 180, 180)

    self:SetFont("TicketSystem.Button")
    self:SetText("")
end

function CloseButton:Paint(w, h)
    local color = self.DisabledColor

    if not self:GetDisabled() then
        if self:IsHovered() then
            color = self.HoverColor
        else
            color = self.Color
        end
    end

    draw.RoundedBoxEx(5, 0, 0, w, h, color, true, true, true, true)

    draw.DrawText("X", "TicketSystem.TicketTitle", w / 2, h * .09, Color(255,23,23), TEXT_ALIGN_CENTER)
end

function CloseButton:DoClickInternal()
    surface.PlaySound("UI/buttonclick.wav")
end

vgui.Register("TicketSystem.CloseButton", CloseButton, "DButton")