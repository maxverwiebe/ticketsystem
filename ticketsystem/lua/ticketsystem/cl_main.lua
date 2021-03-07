if not CLIENT then return end

local theme = TicketSystem.Config.Theme

TicketSystem.SelectMenu = {}
TicketSystem.CreateMenu = {}

-- These are the options that are called when you right-click on a ticket
local dropdownOptions = {
    {
        shouldShow = function(ticket)
            return not TicketSystem:IsClaimed(ticket)
        end,
        name = TicketSystem:GetText("OPTIONS_CLAIM"),
        icon = "icon16/accept.png",
        func = function(ticketKey)
            net.Start("TicketSystem.ClaimTicket")
            net.WriteInt(ticketKey, 32)
            net.SendToServer()
            TicketSystem.SelectMenu:RefreshOverview()
        end
    },
    {
        shouldShow = function(ticket)
            return TicketSystem:ClaimedBy(LocalPlayer(), ticket)
        end,
        name = TicketSystem:GetText("OPTIONS_CLOSE"),
        icon = "icon16/cross.png",
        func = function(ticketKey)
            net.Start("TicketSystem.CloseTicket")
            net.WriteInt(ticketKey, 32)
            net.SendToServer()
            TicketSystem.SelectMenu:RefreshOverview()
        end
    },
    {
        shouldShow = function(ticket)
            return TicketSystem:ClaimedBy(LocalPlayer(), ticket)
        end,
        name = TicketSystem:GetText("OPTIONS_REOPEN"),
        icon = "icon16/arrow_refresh.png",
        func = function(ticketKey)
            net.Start("TicketSystem.ReopenTicket")
            net.WriteInt(ticketKey, 32)
            net.SendToServer()
            TicketSystem.SelectMenu:RefreshOverview()
        end
    },
}

-- Opens the main ticket overview for staff members
--
function TicketSystem.SelectMenu:OpenMenu()

    if not TicketSystem:PlayerHasPermission(LocalPlayer(), "TicketSystem.CanOpenAdminMenu") then return end

    if self.MainFrame then self.MainFrame:Remove() end

    local width = ScrW() * .6
    local height = ScrH() * .6
    local windowTitle = "TicketSystem"

    local activeButton

    self.MainFrame = vgui.Create("DFrame")
    self.MainFrame:SetTitle("")
    self.MainFrame:SetSize(width, height)
    self.MainFrame:MakePopup()
    self.MainFrame:Center()
    self.MainFrame:SetDraggable(false)
    self.MainFrame:ShowCloseButton(false)
    self.MainFrame.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.bg)

        surface.SetDrawColor(theme.bg)
        surface.DrawRect(0, 0, w, h * .075)

        surface.SetDrawColor(Color(theme.bg.r + 8, theme.bg.g + 8, theme.bg.b + 8))
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, 0, w, h * .075)

        draw.DrawText(windowTitle, "TicketSystem.Title", w * .01, h * .007, theme.primary, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(theme.primary)
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, h * .075, w, h * .005)
    end

    self.NavBar = vgui.Create("DScrollPanel", self.MainFrame)
    self.NavBar:SetPos(0, height * 0.08)
    self.NavBar:SetSize(width * 0.2, height * 0.9)
    self.NavBar.Paint = function(me,w,h)
        surface.SetDrawColor(Color(theme.bg.r + 8, theme.bg.g + 8, theme.bg.b + 8, 50))
        surface.DrawRect(0, 0, w, h)
    end

    self.MasterPanel = vgui.Create("DPanel", self.MainFrame)
    self.MasterPanel:SetPos(width * 0.22, height * 0.1)
    self.MasterPanel:SetSize(width * 0.78, height * 0.9)
    self.MasterPanel.Paint = function(me,w,h)
    end

    local navButtons = {}
    navButtons[1] = {
        name = TicketSystem:GetText("FRAME_OVERVIEW"),
        color = Color(242,44,3),
        func = function(master)
            self.bgPanel = vgui.Create("DScrollPanel", master)
            self.bgPanel:SetSize(width * .76, height * .86)
            self.bgPanel:SetPos(width * .001, height * .01)
            function self.bgPanel:Paint(w, h) end

            local sbar = self.bgPanel:GetVBar()
            function sbar:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(0, 0, 0, 100))
            end
            function sbar.btnUp:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnDown:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnGrip:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end

            sbar.LerpTarget = 0

            function sbar:AddScroll(dlta)
                local OldScroll = self.LerpTarget or self:GetScroll()
                dlta = dlta * 75
                self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())

                return OldScroll ~= self:GetScroll()
            end

            sbar.Think = function(s)
                local frac = FrameTime() * 5
                if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
                    frac = FrameTime() * 2
                end
                local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
                s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))
                if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
                    s.LerpTarget = 0
                elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
                    s.LerpTarget = s.CanvasSize
                end
            end


            function TicketSystem.SelectMenu:RefreshOverview()
                if IsValid(self.bgPanel) then self.bgPanel:Clear() end

                net.Start("TicketSystem.RequestTickets")
                net.SendToServer()

                net.Receive("TicketSystem.TicketsSent", function()

                    local ticketList = net.ReadTable()

                    if #ticketList == 0 then
                        local DLabel = vgui.Create("DLabel", self.bgPanel)
                        DLabel:SetPos(ScrW() * .12, ScrH() * .18)
                        DLabel:SetSize(ScrW() * .2, ScrH() * .1)
                        DLabel:SetFont("TicketSystem.NoTicketsInfo")
                        DLabel:SetText(TicketSystem:GetText("OVERVIEW_NOTICKETS"))
                        DLabel:SetColor(Color(theme.bg.r + 12, theme.bg.g + 12, theme.bg.b + 12))
                        DLabel:SetContentAlignment(5)
                    end

                    for key, ticket in SortedPairsByMemberValue(ticketList, "status") do

                        local sender = player.GetBySteamID64(ticket.sender_id)
                        local admin
    
                        if not IsValid(sender) then continue end
                        if not sender:IsPlayer() then continue end
    
                        if ticket.status == 2 then
                            admin = player.GetBySteamID64(ticket.admin_id)
                            if not IsValid(admin) then continue end
                            if not admin:IsPlayer() then continue end
                        end
    
                        local statusName, statusColor = TicketSystem:GetTicketStatus(ticket.status)
    
                        local senderNick = sender:GetName()
                        local adminNick
                        if ticket.status == 2 then
                            adminNick = admin:GetName()
                        end
    
                        local ticketPanel = vgui.Create("DButton", self.bgPanel)
                        ticketPanel:Dock(TOP)
                        ticketPanel:SetText("")
                        ticketPanel:DockMargin(0, 0, 0, ScrH() * .01)
                        ticketPanel:SetSize(ScrW() * .3, ScrH() * .07)
                        ticketPanel.state = "collapsed"

                        local wStatic = width * .76
                        local hStatic = ScrH() * .07

                        function ticketPanel:Paint(w, h)
                            
                            local bgCol
    
                            if self:IsHovered() then
                                bgCol = Color(theme.bg.r + 12, theme.bg.g + 12, theme.bg.b + 12)
                            else
                                bgCol = Color(theme.bg.r + 5, theme.bg.g + 5, theme.bg.b + 5)
                            end
    
                            draw.RoundedBox(10, 0, 0, w, h, bgCol)
                            local titleWidth = draw.SimpleText(ticket.title, "TicketSystem.TicketTitle", w * .01, hStatic * .06, Color(255,255,255), TEXT_ALIGN_LEFT)
                            draw.DrawText(senderNick, "TicketSystem.TicketText1", w * .05, hStatic * .55, Color(146,146,146), TEXT_ALIGN_LEFT)
    
                            local time = (ticket.time - CurTime()) / 60
    
                            draw.DrawText(TicketSystem:GetText("OVERVIEW_TICKET_TIMESTAMP", math.Round(-time, 0)), "TicketSystem.TicketText1", w * .97, hStatic * .55, Color(146,146,146), TEXT_ALIGN_RIGHT)
    
                            draw.RoundedBox(5, w * .02 + titleWidth, hStatic * .06, w * .1, hStatic * .3, statusColor)
                            draw.DrawText(statusName, "TicketSystem.LabelText", w * .069 + titleWidth, hStatic * .096, Color(255,255,255), TEXT_ALIGN_CENTER)
    
                            if ticket.status == 2 then
                                draw.DrawText(adminNick, "TicketSystem.TicketText1", w * .483, hStatic * .55, Color(146,146,146), TEXT_ALIGN_LEFT)
                            end

                            draw.RoundedBox(5, 0, hStatic * 1.01, w, hStatic * .03, Color(104,104,104, 10))
                        end

                        self.Text = vgui.Create("DLabel", ticketPanel)
                        self.Text:SetPos( ScrW() * .005, ScrH() * .08 )
                        self.Text:SetText(ticket.text)
                        self.Text:SetSize(ScrW() * .4, 40)
                        self.Text:SetFont("TicketSystem.TextEntry")
                        self.Text:SetWrap(true)
                        self.Text:SetAutoStretchVertical( true )
                        
                        local senderAvatar = vgui.Create("TicketSystem.Avatar", ticketPanel)
                        senderAvatar:SetPlayer(sender, 64)
                        senderAvatar:SetPos(ScrW() * .003, ScrH() * .035)
                        senderAvatar:SetSize(ScrH() * .03, ScrH() * .03)
    
                        if ticket.status == 2 then
                            local adminAvatar = vgui.Create("TicketSystem.Avatar", ticketPanel)
                            adminAvatar:SetPlayer(sender, 64)
                            adminAvatar:SetPos(ScrW() * .2, ScrH() * .035)
                            adminAvatar:SetSize(ScrH() * .03, ScrH() * .03)
                        end

                        function ticketPanel:DoClick()
                            if self.state == "collapsed" then
                                self:SizeTo(width * .76, ScrH() * .3, 0.7)
                                self.state = "extended"
                            else
                                self:SizeTo(width * .76, ScrH() * .07, 0.7)
                                self.state = "collapsed"
                            end
                        end

                        function ticketPanel:DoRightClick()
                            local contextMenu = DermaMenu(line)
                            function contextMenu:Paint(width, height) end
        
                            for k, option in pairs(dropdownOptions) do
                                if option.shouldShow(ticket) then
                                    local optionPanel = contextMenu:AddOption(option.name, function()
                                        option.func(key)
                                    end)
        
                                    optionPanel:SetColor(color_white)
                                    optionPanel:SetFont("TicketSystem.Button")
        
                                    function optionPanel:Paint(width, height)
                                        if self:IsHovered() then
                                            draw.RoundedBox(6, 0, 0, width, height, TicketSystem.Config.Theme.primary)
                                        elseif k % 2 == 0 then
                                            draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
                                        else
                                            draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
                                        end
                                    end
        
                                    local icon = vgui.Create("DImage", optionPanel)
                                    icon:SetPos(optionPanel:GetWide() * 0.075, optionPanel:GetTall() * 0.15)
                                    icon:SetSize(ScrH() / 67.5, ScrH() / 67.5)
                                    icon:SetImage(option.icon)
                                end
                            end
        
                            contextMenu:Open()
                        end
                    end
                end)

            end
            TicketSystem.SelectMenu:RefreshOverview()
        end,
    }
    navButtons[2] = {
        name = TicketSystem:GetText("FRAME_STAFF"),
        color = Color(126,39,22),
        func = function(master)

            self.bgPanel = vgui.Create("DScrollPanel", master)
            self.bgPanel:SetSize(width * .76, height * .86)
            self.bgPanel:SetPos(width * .001, height * .01)
            function self.bgPanel:Paint(w, h) end
            local sbar = self.bgPanel:GetVBar()
            function sbar:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(0, 0, 0, 100))
            end
            function sbar.btnUp:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnDown:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnGrip:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end

            sbar.LerpTarget = 0

            function sbar:AddScroll(dlta)
                local OldScroll = self.LerpTarget or self:GetScroll()
                dlta = dlta * 75
                self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())

                return OldScroll ~= self:GetScroll()
            end

            sbar.Think = function(s)
                local frac = FrameTime() * 5
                if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
                    frac = FrameTime() * 2
                end
                local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
                s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))
                if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
                    s.LerpTarget = 0
                elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
                    s.LerpTarget = s.CanvasSize
                end
            end

            for k, v in SortedPairs(TicketSystem.Config.Usergroups, true) do
                for _, ply in pairs(player.GetAll()) do

                    if k == ply:GetUserGroup() then

                        local usrGrpName, usrGrpColor = TicketSystem:GetUsergroupInfo(ply)
                        local plyNick = ply:GetName()

                        local plyPanel = vgui.Create("DButton", self.bgPanel)
                        plyPanel:Dock(TOP)
                        plyPanel:SetText("")
                        plyPanel:DockMargin(0, 0, 0, ScrH() * .01)
                        plyPanel:SetSize(ScrW() * .3, ScrH() * .05)
                        function plyPanel:Paint(w, h)     
                            local bgCol

                            if self:IsHovered() then
                                bgCol = Color(theme.bg.r + 12, theme.bg.g + 12, theme.bg.b + 12)
                            else
                                bgCol = Color(theme.bg.r + 5, theme.bg.g + 5, theme.bg.b + 5)
                            end

                            draw.RoundedBox(10, 0, 0, w, h, bgCol)
                            local titleWidth = draw.SimpleText(plyNick, "TicketSystem.TicketText1", w * .07, h * .28, Color(114,114,114), TEXT_ALIGN_LEFT)

                            draw.RoundedBox(5, w * .09 + titleWidth, h * .3, w * .15, h * .4, usrGrpColor)
                            draw.DrawText(usrGrpName, "TicketSystem.LabelText", w * .165 + titleWidth, h * .3, Color(255,255,255), TEXT_ALIGN_CENTER)
                        end

                        local senderAvatar = vgui.Create("TicketSystem.Avatar", plyPanel)
                        senderAvatar:SetPlayer(ply, 64)
                        senderAvatar:SetPos(ScrW() * .003, ScrH() * .006)
                        senderAvatar:SetSize(ScrH() * .04, ScrH() * .04)
                    end
                end
            end

            

        end,
    }

    for k, v in pairs(navButtons) do
        local navButton = vgui.Create("TicketSystem.NavButton", self.NavBar)
        navButton:Dock(TOP)
        navButton:DockMargin(0, 0, 0, ScrH() * .005)
        navButton:SetText(v.name)
        navButton:SetTall(height * .05)
        navButton:SetRound(10)
        navButton.DoClick = function()
            windowTitle = "TicketSystem".." - ".. v.name
            self.MasterPanel:Clear()
            self.MasterPanel.Paint = function() end
            v.func(self.MasterPanel)
            activeButton = navButton
        end
    end

    self.Close = vgui.Create("TicketSystem.CloseButton", self.MainFrame)
    self.Close:SetSize( height * .05, height * .05 )
    self.Close:SetPos( width * .967, height * .01 )
    self.Close.DoClick = function() self.MainFrame:Remove() end

    navButtons[1].func(self.MasterPanel)
end

-- Opens the ticket creation frame
--
function TicketSystem.CreateMenu:OpenMenu()

    if not TicketSystem:PlayerHasPermission(LocalPlayer(), "TicketSystem.CanCreateTicket") then return end

    if self.MainFrame then self.MainFrame:Remove() end

    local width = ScrW() * .3
    local height = ScrH() * .4
    local windowTitle = "TicketSystem"

    self.MainFrame = vgui.Create("DFrame")
    self.MainFrame:SetTitle("")
    self.MainFrame:SetSize(width, height)
    self.MainFrame:MakePopup()
    self.MainFrame:Center()
    self.MainFrame:SetDraggable(false)
    self.MainFrame:ShowCloseButton(false)
    self.MainFrame.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.bg)

        surface.SetDrawColor(theme.bg)
        surface.DrawRect(0, 0, w, h * .075)

        surface.SetDrawColor(Color(theme.bg.r + 8, theme.bg.g + 8, theme.bg.b + 8))
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, 0, w, h * .095)

        draw.DrawText(windowTitle.. " - ".. TicketSystem:GetText("CREATE_FRAMETITLE"), "TicketSystem.Title", w * .01, h * .001, theme.primary, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(theme.primary)
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, h * .095, w, h * .005)
    end

    self.TitleEntry = vgui.Create("TicketSystem.TextEntry", self.MainFrame)
    self.TitleEntry:SetSize(width * .8, height * .08)
    self.TitleEntry:SetPos(width * .1, height * .25)
    self.TitleEntry:SetEnterAllowed(false)
    self.TitleEntry:SetMultiline(false)
    self.TitleEntry:SetPlaceholder(TicketSystem:GetText("CREATE_TITLEPLACEHOLDER"))

    self.TextEntry = vgui.Create("TicketSystem.TextEntry", self.MainFrame)
    self.TextEntry:SetSize(width * .8, height * .3)
    self.TextEntry:SetPos(width * .1, height * .35)
    self.TextEntry:SetEnterAllowed(false)
    self.TextEntry:SetMultiline(true)
    self.TextEntry:SetPlaceholder(TicketSystem:GetText("CREATE_TEXTPLACEHOLDER"))
    
    self.Submit = vgui.Create("TicketSystem.NavButton", self.MainFrame)
    self.Submit:SetSize( width * .6, height * .08 )
    self.Submit:SetPos( width * .2, height * .7 )
    self.Submit:SetText(TicketSystem:GetText("CREATE_SUBMIT"))
    self.Submit:SetTextColor(theme.primary)
    self.Submit:SetRound(20)
    self.Submit.DoClick = function()

        if self.TitleEntry:GetText() == "" then return end
        if self.TextEntry:GetText() == "" then return end

        net.Start("TicketSystem.AddTicket")
        net.WriteString(self.TitleEntry:GetText())
        net.WriteString(self.TextEntry:GetText())
        net.SendToServer()

        self.MainFrame:Remove()
    end

    self.Close = vgui.Create("TicketSystem.CloseButton", self.MainFrame)
    self.Close:SetSize( height * .07, height * .07 )
    self.Close:SetPos( width * .935, height * .01 )
    self.Close.DoClick = function() self.MainFrame:Remove() end
end

--Concommands

concommand.Add("TicketSystemAdmin", function()
    TicketSystem.SelectMenu:OpenMenu()
end)

concommand.Add("TicketSystemCreate", function()
    TicketSystem.CreateMenu:OpenMenu()
end)

--Networking Commands

net.Receive("TicketSystem.OpenTicketCreation", function()
    TicketSystem.CreateMenu:OpenMenu()
end)

net.Receive("TicketSystem.OpenTicketAdmin", function()
    TicketSystem.SelectMenu:OpenMenu()
end)