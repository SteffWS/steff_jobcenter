local resourceName = GetCurrentResourceName()
if resourceName ~= "steff_jobcenter" then
    print(('^1[steff_jobcenter] Resource must be named "steff_jobcenter". Currently: "%s"^0'):format(resourceName))
    return
end

local QBCore = exports["qb-core"]:GetCoreObject()
local ox_lib = exports["ox_lib"]
local cfg = Config
local lastJobChange = 0
local lang = cfg.Language or "en"
local L = Locales[lang] or Locales["en"]

if not cfg.Menu then
    error("[JobCenter] Missing Config.Menu. Please set it to either 'qb' or 'ox'")
elseif cfg.Menu ~= "qb" and cfg.Menu ~= "ox" then
    error(("[JobCenter] Invalid Config.Menu: '%s'. Must be 'qb' or 'ox'"):format(cfg.Menu))
end

if not cfg.Interact then
    error("[JobCenter] Missing Config.Interact. Please set it to either 'qb-target' or 'ox_target'")
elseif cfg.Interact ~= "qb-target" and cfg.Interact ~= "ox_target" then
    error(("[JobCenter] Invalid Config.Interact: '%s'. Must be 'qb-target' or 'ox_target'"):format(cfg.Interact))
end

if not cfg.Notify then
    error("[JobCenter] Missing Config.Notify. Please set it to either 'qb' or 'ox'")
elseif cfg.Notify ~= "qb" and cfg.Notify ~= "ox" then
    error(("[JobCenter] Invalid Config.Notify: '%s'. Must be 'qb' or 'ox'"):format(cfg.Notify))
end

local function t(key, ...)
    local str = L[key] or Locales["en"][key] or key
    return ... and string.format(str, ...)
end

local function doNotify(key, ...)
    local args = {...}
    local nType = nil
    if type(args[#args]) == "string" then
        nType = table.remove(args)
    end
    local msg = t(key, table.unpack(args))
    if cfg.Notify == "ox" then
        ox_lib:notify({description = msg, type = nType or "success"})
    else
        QBCore.Functions.Notify(msg, nType or "success")
    end
end

RegisterNetEvent(
    "jobcenter:clientNotify",
    function(key, ...)
        doNotify(key, ...)
    end
)

Citizen.CreateThread(
    function()
        local pedHash = GetHashKey(cfg.Ped.model)
        local interactSystem = cfg.Interact
        local interactDistance = cfg.InteractDistance

        RequestModel(pedHash)
        while not HasModelLoaded(pedHash) do
            Wait(1)
        end
        local ped = CreatePed(4, pedHash, cfg.Ped.spawn, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if cfg.Ped.animation then
            RequestAnimDict(cfg.Ped.animation.dict)
            while not HasAnimDictLoaded(cfg.Ped.animation.dict) do
                Wait(1)
            end
            TaskPlayAnim(ped, cfg.Ped.animation.dict, cfg.Ped.animation.name, 8.0, 0.0, -1, 1, 0, false, false, false)
        end
        cfg.Ped.npc = ped

        if cfg.Ped.blip.enabled then
            local b = cfg.Ped.blip
            local blip = AddBlipForCoord(cfg.Ped.spawn.x, cfg.Ped.spawn.y, cfg.Ped.spawn.z)
            SetBlipSprite(blip, b.sprite)
            SetBlipColour(blip, b.color)
            SetBlipScale(blip, b.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(b.text)
            EndTextCommandSetBlipName(blip)
        end

        if interactSystem == "ox_target" then
            exports.ox_target:addModel(
                pedHash,
                {
                    {
                        event = "jobcenter:clientOpenMenu",
                        icon = "fa-solid fa-briefcase",
                        label = "Job Center",
                        distance = interactDistance
                    }
                }
            )
        elseif interactSystem == "qb-target" then
            exports["qb-target"]:AddTargetModel(
                {pedHash},
                {
                    options = {
                        {
                            type = "client",
                            event = "jobcenter:clientOpenMenu",
                            icon = "fa-solid fa-briefcase",
                            label = "Job Center"
                        }
                    },
                    distance = interactDistance
                }
            )
        else
            print("^1[jobcenter]^7 Invalid Config.Interact: " .. tostring(interactSystem))
        end
    end
)

local function openMainMenu()
    QBCore.Functions.TriggerCallback(
        "jobcenter:getPlayerJob",
        function(currentJobName)
            if cfg.Menu == "qb" then
                local menu = {
                    {header = "Job Center", txt = "", isMenuHeader = true, disabled = true, hidden = false},
                    {
                        header = "Currently Employed As",
                        txt = currentJobName or "Unemployed",
                        isMenuHeader = false,
                        disabled = true,
                        hidden = false
                    }
                }
                for idx, job in ipairs(cfg.Jobs) do
                    menu[#menu + 1] = {
                        header = job.label,
                        icon = job.icon,
                        txt = job.text,
                        isMenuHeader = false,
                        disabled = false,
                        hidden = false,
                        params = {event = "jobcenter:clientOpenDetail", args = {index = idx}, isServer = false}
                    }
                end
                exports["qb-menu"]:openMenu(menu, true, false)
            else
                local opts = {
                    {
                        title = "Currently Employed As",
                        description = currentJobName or "Unemployed",
                        icon = "fa-solid fa-id-badge",
                        disabled = true
                    }
                }
                for idx, job in ipairs(cfg.Jobs) do
                    opts[#opts + 1] = {
                        icon = job.icon,
                        title = job.label,
                        description = job.text,
                        arrow = true,
                        onSelect = function()
                            openDetailMenu(idx)
                        end
                    }
                end
                ox_lib:registerContext({id = "job_center_main", title = "Job Center", options = opts})
                ox_lib:showContext("job_center_main")
            end
        end
    )
end
RegisterNetEvent("jobcenter:clientOpenMenu", openMainMenu)
RegisterNetEvent(
    "jobcenter:clientOpenDetail",
    function(data)
        openDetailMenu(data.index)
    end
)
RegisterNetEvent(
    "jobcenter:clientNotify",
    function(msg, nType)
        doNotify(msg, nType)
    end
)

function openDetailMenu(idx)
    local job = cfg.Jobs[idx]
    if not job then
        return
    end

    if cfg.Menu == "qb" then
        local menu = {
            {header = job.label, txt = "", isMenuHeader = true, disabled = true, hidden = false},
            {header = "Tutorial", txt = job.tutorial, isMenuHeader = false, disabled = true, hidden = false}
        }
        if job.locations then
            for _, loc in ipairs(job.locations) do
                menu[#menu + 1] = {
                    header = loc.label,
                    icon = "fa-solid fa-map-pin",
                    txt = loc.txt,
                    isMenuHeader = false,
                    disabled = false,
                    hidden = false,
                    params = {
                        event = "jobcenter:setWaypoint",
                        args = {pos = loc.pos, label = loc.label},
                        isServer = false
                    }
                }
            end
        end
        menu[#menu + 1] = {
            header = "Accept Job",
            icon = "fa-solid fa-check",
            txt = "Take on the " .. job.label .. " role",
            isMenuHeader = false,
            disabled = false,
            hidden = false,
            params = {event = "jobcenter:acceptJob", args = {index = idx}, isServer = false}
        }
        menu[#menu + 1] = {
            header = "Go Back",
            icon = "fa-solid fa-arrow-left",
            txt = "",
            isMenuHeader = false,
            disabled = false,
            hidden = false,
            params = {event = "jobcenter:clientOpenMenu", args = {}, isServer = false}
        }
        exports["qb-menu"]:openMenu(menu, true, false)
    else
        local opts = {
            {title = "Tutorial", description = job.tutorial}
        }
        if job.locations then
            for _, loc in ipairs(job.locations) do
                opts[#opts + 1] = {
                    icon = "fa-solid fa-map-pin",
                    title = loc.label,
                    description = loc.txt,
                    onSelect = function()
                        SetNewWaypoint(loc.pos.x, loc.pos.y)
                        doNotify("gps_set", loc.label, "success")
                    end
                }
            end
        end
        opts[#opts + 1] = {
            icon = "fa-solid fa-check",
            title = "Accept Job",
            description = "Take on the " .. job.label .. " role",
            onSelect = function()
                local now = GetGameTimer()
                local cd = (cfg.CooldownSeconds or 60) * 1000
                if now < lastJobChange + cd then
                    local wait = math.ceil((lastJobChange + cd - now) / 1000)
                    doNotify("job_change_wait", wait, "error")
                    return
                end
                lastJobChange = now
                TriggerServerEvent("jobcenter:serverSetJob", job.jobName)
            end
        }
        ox_lib:registerContext({
        id     = "job_center_detail_" .. idx,
        title  = job.label,
        -- point back to the main menu so ox_lib draws the back-arrow
        menu   = "job_center_main",
        onBack = openMainMenu,
        options = opts
        })
        ox_lib:showContext("job_center_detail_" .. idx)
    end
end

RegisterNetEvent(
    "jobcenter:setWaypoint",
    function(data)
        SetNewWaypoint(data.pos.x, data.pos.y)
        doNotify("GPS set: " .. data.label, "success")
    end
)

RegisterNetEvent(
    "jobcenter:acceptJob",
    function(data)
        local idx = data.index
        local job = cfg.Jobs[idx]
        if not job then
            return
        end
        local now = GetGameTimer()
        local cd = (cfg.CooldownSeconds or 60) * 1000
        if now < lastJobChange + cd then
            local wait = math.ceil((lastJobChange + cd - now) / 1000)
            doNotify("job_change_wait", wait, "error")
            return
        end
        lastJobChange = now
        TriggerServerEvent("jobcenter:serverSetJob", job.jobName)
    end
)
