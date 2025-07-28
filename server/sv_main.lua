CreateThread(
    function()
        local resourceName = GetCurrentResourceName()
        if resourceName ~= "steff_jobcenter" then
            print(
                ('^1[steff_jobcenter]^7 Resource must be named "steff_jobcenter". Currently: "%s"'):format(resourceName)
            )
            StopResource(resourceName)
        end
    end
)

CreateThread(function()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local checkURL = 'https://raw.githubusercontent.com/SteffWS/steff_jobcenter/refs/heads/main/version.txt' -- Replace this

    PerformHttpRequest(checkURL, function(statusCode, response, headers)
        if not response or response == '' then
            print('^1[steff_jobcenter] Version check failed: No response.^0')
            return
        end

        local latestVersion = response:match("^%s*(.-)%s*$") -- trim
        if latestVersion == currentVersion then
            print('^2[steff_jobcenter] You are running the latest version (' .. currentVersion .. ').^0')
        else
            print('^3[steff_jobcenter] A new version is available!^0')
            print('^3[steff_jobcenter] Current: ' .. currentVersion .. ', Latest: ' .. latestVersion .. '^0')
            print('^3[steff_jobcenter] Download it at: https://github.com/SteffWS/steff_jobcenter^0')
        end
    end, 'GET')
end)

local QBCore = exports["qb-core"]:GetCoreObject()

local webhookURL = Config.WebhookURL or ""

local validJobs, jobLabels = {}, {}
if type(Config.Jobs) == "table" then
    for _, job in ipairs(Config.Jobs) do
        if job.jobName and job.label then
            validJobs[job.jobName] = true
            jobLabels[job.jobName] = job.label
        end
    end
else
    error("^1[JobCenter]^7 Config.Jobs must be a table!")
end

local lastRequest = {}

local function sendDiscordLog(oldJob, newJob, userName, charName, playerId)
    if webhookURL == "" then
        return
    end

    local embed = {
        username = "JobCenter Logger",
        embeds = {
            {
                title = "Player Job Change",
                color = 7506394,
                fields = {
                    {name = "Username", value = userName, inline = false},
                    {name = "Character Name", value = charName, inline = false},
                    {name = "Server ID", value = tostring(playerId), inline = false},
                    {name = "Old Job", value = oldJob, inline = true},
                    {name = "New Job", value = newJob, inline = true}
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }

    PerformHttpRequest(
        webhookURL,
        function(err, text)
            if err ~= 204 then
                print(("[JobCenter] Webhook error %d: %s"):format(err, text))
            end
        end,
        "POST",
        json.encode(embed),
        {["Content-Type"] = "application/json"}
    )
end

QBCore.Functions.CreateCallback(
    "jobcenter:getPlayerJob",
    function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        local label = Player and Player.PlayerData.job and Player.PlayerData.job.label or "Unemployed"
        cb(label)
    end
)

RegisterNetEvent(
    "jobcenter:serverSetJob",
    function(jobName)
        local src = source

        if type(jobName) ~= "string" or not validJobs[jobName] then
            return TriggerClientEvent("jobcenter:clientNotify", src, "invalid_job", jobName, "error")
        end

        local now = os.time()
        local cooldown = tonumber(Config.CooldownSeconds) or 60
        if lastRequest[src] and (now - lastRequest[src]) < cooldown then
            local wait = cooldown - (now - lastRequest[src])
            return TriggerClientEvent("jobcenter:clientNotify", src, "job_change_wait", wait, "error")
        end
        lastRequest[src] = now

        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then
            return print(("[JobCenter]^1 Could not get QBCore player for source %d"):format(src))
        end

        local userName = GetPlayerName(src)
        local ci = Player.PlayerData.charinfo or {}
        local charName = ("%s %s"):format(ci.firstname or "Unknown", ci.lastname or "Player")

        local oldJobKey = Player.PlayerData.job and Player.PlayerData.job.name
        local oldJobLabel = oldJobKey and jobLabels[oldJobKey] or "Unemployed"
        local newJobLabel = jobLabels[jobName] or jobName

        Player.Functions.SetJob(jobName, 0)

        TriggerClientEvent("jobcenter:clientNotify", src, "job_change_success", newJobLabel, "success")

        sendDiscordLog(oldJobLabel, newJobLabel, userName, charName, src)
    end
)
