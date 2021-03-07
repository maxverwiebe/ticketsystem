local NavButton = {}

function NavButton:Init()
    self.Color = TicketSystem.Config.Theme.navButton
    self.HoverColor = Color(self.Color.r + 16, self.Color.g + 16, self.Color.b + 16, 255)
    self.DisabledColor = Color(180, 180, 180)

    self.RoundRadius = 0
    self.round1 = false
    self.round2 = false
    self.round3 = false
    self.round4 = false

    self:SetFont("TicketSystem.Button")
end

function NavButton:Paint(width, height)
    local color = self.DisabledColor

    if not self:GetDisabled() then
        if self:IsHovered() then
            color = self.HoverColor
        else
            color = self.Color
        end
    end

    draw.RoundedBoxEx(self.RoundRadius, 0, 0, width, height, color, self.round1, self.round2, self.round3, self.round4)
end

function NavButton:DoClickInternal()
    surface.PlaySound("UI/buttonclick.wav")
end

function NavButton:SetDisabledButton(color)
    self.DisabledColor = color
end

function NavButton:SetRound(radius)
    self.RoundRadius = radius

    if self.RoundRadius > 0 then
        self:SetRoundCorners(true, true, true, true)
    else
        self:SetRoundCorners(false, false, false, false)
    end
end

function NavButton:SetRoundCorners(round1, round2, round3, round4)
    self.round1 = round1
    self.round2 = round2
    self.round3 = round3
    self.round4 = round4
end

vgui.Register("TicketSystem.NavButton", NavButton, "DButton")