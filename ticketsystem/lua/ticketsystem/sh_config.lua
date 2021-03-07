TicketSystem.Config = {}

-- Here you can change the basic color theme
TicketSystem.Config.Theme = {
    bg = Color(27,27,27),
    navButton = Color(34,34,34),
    primary = Color(89,249,255),
}

-- Here you can change the usergroups, which are displayed in the "online staffmember" tab
TicketSystem.Config.Usergroups = {
    ["founder"] = {
        name = "Founder",
        color = Color(255,62,175),
    },
    ["owner"] = {
        name = "Owner",
        color = Color(255,62,213),
    },
    ["communitymanager"] = {
        name = "Manager",
        color = Color(255,62,213),
    },
    ["manager"] = {
        name = "Manager",
        color = Color(255,62,213),
    },
    ["superadmin"] = {
        name = "Superadmin",
        color = Color(255,62,62),
    },
    ["admin"] = {
        name = "Admin",
        color = Color(255,123,0),
    },
    ["moderator"] = {
        name = "Moderator",
        color = Color(255,91,62),
    },
    ["testmoderator"] = {
        name = "Test-Moderator",
        color = Color(255,91,62),
    },
    ["trialmoderator"] = {
        name = "Trial-Moderator",
        color = Color(255,91,62),
    },
    ["staff"] = {
        name = "Staff",
        color = Color(255,91,62),
    },
    ["operator"] = {
        name = "Operator",
        color = Color(62,123,255),
    },
    ["supporter"] = {
        name = "Supporter",
        color = Color(0,138,30),
    },
    ["trialsupporter"] = {
        name = "Trial-Supporter",
        color = Color(0,138,30),
    },
    ["user"] = {
        name = "Gast",
        color = Color(151,151,151),
    },
}

-- This is the fallback/default usergroup
TicketSystem.Config.DefaultUsergroup = "user"

-- This is the max ticket count, a player can have
TicketSystem.Config.TicketLimit = 3

-- This is the cooldown for the "there are X open tickets" message
TicketSystem.Config.ReminderCooldown = 300

-- Here you can add or change the commands
TicketSystem.Config.Commands = {
    Creation = {"/support", "/ticket"},
    Admin = {"/tickets", "/ticketoverview"},
}

-- Here you can change the text and color of the ticket lables/status
TicketSystem.Config.Labels = {}
TicketSystem.Config.Labels[1] = {
    name = "OPEN",
    color = Color(6,187,0),
}
TicketSystem.Config.Labels[2] = {
    name = "CLAIMED",
    color = Color(255,145,0),
}
TicketSystem.Config.Labels[3] = {
    name = "CLOSED",
    color = Color(255,41,41),
}

-- Localization part:
--
-- Here you can customize all the texts of the addon. 
-- What is written below has priority. So if you want to use the preset "German", then delete the whole english part and remove the comments from the german table.
-- Of course you can also just change the texts.

-- GERMAN

--[[]
TicketSystem.Config.Language = {
    ["CREATE_TITLEPLACEHOLDER"] = "Bitte gebe deinem Anliegen einen Titel...",
    ["CREATE_TEXTPLACEHOLDER"] = "Bitte beschreibe dein Anliegen...",
    ["CREATE_SUBMIT"] = "Absenden",
    ["CREATE_FRAMETITLE"] = "Erstellen",

    ["OPTIONS_CLAIM"] = "Ticket claimen",
    ["OPTIONS_CLOSE"] = "Ticket schließen",
    ["OPTIONS_REOPEN"] = "Ticket wieder öffnen",

    ["OVERVIEW_NOTICKETS"] = "Es gibt aktuell keine Tickets :)",
    ["OVERVIEW_TICKET_TIMESTAMP"] = "vor %s Minuten",

    ["FRAME_OVERVIEW"] = "Übersicht",
    ["FRAME_STAFF"] = "Online Teammitglieder",

    ["MSG_NEWTICKET"] = "Es wurde ein neues Ticket erstellt.",
    ["MSG_STATUSCHANGED"] = "Der Status deines Tickets wurde geändert: ",
    ["MSG_TICKETCREATED"] = "Das Ticket wurde erfolgreich erstellt. Nun dauert es einen Moment, bis sich ein Teammitglied deinem Ticket annimmt. Der Status ist nun auf: ",
    ["MSG_REMINDERTEXT"] = "Es sind aktuell noch %s Ticket(s) offen!",
    ["MSG_NOPERMS"] = "Du hast nicht genügend Berechtigungen: %s",
    ["MSG_TICKETLIMITREACHED"] = "Du hast das Limit an %s Tickets erreicht."
}]]--

-- ENGLISH
TicketSystem.Config.Language = {
    ["CREATE_TITLEPLACEHOLDER"] = "Please give your ticket a title...",
    ["CREATE_TEXTPLACEHOLDER"] = "Please describe your concern...",
    ["CREATE_SUBMIT"] = "Submit",
    ["CREATE_FRAMETITLE"] = "Create",

    ["OPTIONS_CLAIM"] = "Claim ticket",
    ["OPTIONS_CLOSE"] = "Close ticket",
    ["OPTIONS_REOPEN"] = "Reopen ticket",

    ["OVERVIEW_NOTICKETS"] = "There are currently no tickets :)",
    ["OVERVIEW_TICKET_TIMESTAMP"] = "%s minutes ago",

    ["FRAME_OVERVIEW"] = "Overview",
    ["FRAME_STAFF"] = "Online staffmembers",

    ["MSG_NEWTICKET"] = "A new ticket has been created.",
    ["MSG_STATUSCHANGED"] = "The status of your ticket has been changed: ",
    ["MSG_TICKETCREATED"] = "The ticket has been successfully created. Now it takes a moment until a staff member takes care of your ticket. The status is now: ",
    ["MSG_REMINDERTEXT"] = "There are currently %s ticket(s) open!",
    ["MSG_NOPERMS"] = "You do not have enough permissions: %s",
    ["MSG_TICKETLIMITREACHED"] = "You have reached the limit of tickets (%s)."
}