Config = {}

Config.Ped = {
    model = "ig_barry", -- Ped model name (https://wiki.rage.mp/wiki/Peds)
    spawn = vector4(-545.13, -204.22, 37.22, 214.52), -- Ped spawn location: x, y, z, heading
    animation = {
        dict = "mini@strip_club@idles@bouncer@base", -- Animation dictionary
        name = "base" -- Animation name to play on ped
    },
    blip = {
        enabled = true, -- Show a blip on the map
        sprite = 498, -- Blip icon (https://wiki.rage.mp/wiki/Blips)
        color = 4, -- Blip color ID (https://wiki.rage.mp/wiki/Blip::color)
        scale = 0.7, -- Blip size/scale
        text = "Job Center" -- Blip label text
    }
}

Config.Language = "en" -- Language key (matches files in the "locales" folder)
Config.Interact = "ox_target" -- Target system: 'ox_target' or 'qb-target'
Config.InteractDistance = 2.5 -- Max distance players have to have to interact with the ped

Config.Menu = "ox" -- Menu system: 'qb' for qb-menu, 'ox' for ox_lib context menu
Config.Notify = "ox" -- Notification system: 'qb' (QBCore.Notify) or 'ox' (ox_lib notify)

Config.CooldownSeconds = 30 -- Time in seconds players must wait between job changes

Config.WebhookURL = "" -- If you leave this empty, Discord logging is disabled

Config.Jobs = {
    {
        jobName = "miner",
        icon = "fa-regular fa-gem",
        label = "Mining Job",
        text = "Mine gems and sell them to the jewelry",
        tutorial = "Go to the mining area (marked with gold bars on the map)...",
        locations = {
            {pos = vector3(2953.22, 2787.83, 41.51), label = "Mining area", txt = "This is where you can start mining"},
            {pos = vector3(-622.64, -229.87, 38.06), label = "Vangelico Jewelry", txt = "Here, you can sell your gems"}
        }
    },
    {
        jobName = "fisher",
        icon = "fa-solid fa-fish",
        label = "Fishing Job",
        text = "Go fishing!",
        tutorial = "Buy a fishing rod and bait from YouTool Store...",
        locations = {
            {pos = vector3(342.79, -1299.78, 32.51), label = "YouTool", txt = "Buy rod & bait here"},
            {pos = vector3(-1843.37, -1256.10, 8.62), label = "Fishing Area", txt = "Catch fish here"},
            {pos = vector3(959.58, -1673.74, 30.06), label = "Fish Factory", txt = "Sell fish here"}
        }
    },
    {
        jobName = "delivery",
        icon = "fa-solid fa-truck-fast",
        label = "Delivery Job",
        text = "Deliver products by truck",
        tutorial = "Deposit $1000 at Walker Logistics Garage to rent a truck..."
    },
    {
        jobName = "pizzeria",
        icon = "fa-solid fa-pizza-slice",
        label = "Pizzeria Job",
        text = "Deliver pizza on a scooter!",
        tutorial = "Pay $500 to get the scooter, deliver pizzas, return scooter to get paid."
    },
    {
        jobName = "lumberjack",
        icon = "fa-solid fa-tree",
        label = "Lumberjack Job",
        text = "Cut down trees and sell them to the factory",
        tutorial = "Chop trees at the brown-chest markers, then sell at the wood factory.",
        locations = {
            {pos = vector3(-637.96, 5451.83, 52.68), label = "Cutting Area", txt = "Chop trees here"},
            {pos = vector3(1192.38, -1267.52, 35.17), label = "Factory", txt = "Sell wood here"}
        }
    },
    {
        jobName = "garbage",
        icon = "fa-solid fa-recycle",
        label = "Garbage Truck Job",
        text = "Get paid for cleaning the city.",
        tutorial = "Deposit $500 to rent the truck, collect trash stops, then return."
    },
    {
        jobName = "lawnmower",
        icon = "fa-solid fa-fan",
        label = "Lawn Mower Job",
        text = "Get paid for cutting grass.",
        tutorial = "Grab the mower from the NW house, cut lawns, return for pay."
    },
    {
        jobName = "hotdog",
        icon = "fa-solid fa-hotdog",
        label = "Hot Dog Job",
        text = "Sell hotdogs and eat some too.",
        tutorial = "Rent the stand for $1000 at Chihuahua Hotdogs, then sell on streets."
    },
    {
        jobName = "farmer",
        icon = "fa-solid fa-wheat-awn",
        label = "Farmer Job",
        text = "Plant, cultivate and harvest.",
        tutorial = "Buy watering cans & seeds, farm in the area, then sell at Alamo market.",
        locations = {
            {pos = vector3(342.79, -1299.78, 32.51), label = "YouTool", txt = "Buy watering cans"},
            {pos = vector3(-51.40, 6360.12, 31.45), label = "Seeds Shop", txt = "Buy seeds here"},
            {pos = vector3(242.06, 6463.59, 31.22), label = "Farming Area", txt = "Plant & water here"},
            {pos = vector3(1792.63, 4593.64, 37.68), label = "Fruit Market", txt = "Sell crops here"}
        }
    },
    {
        jobName = "taxi",
        icon = "fa-solid fa-taxi",
        label = "Taxi Driver",
        text = "Drive around Los Santos picking up locals.",
        tutorial = "Sign contract at the cab company, press F6 to accept fares."
    }
}
