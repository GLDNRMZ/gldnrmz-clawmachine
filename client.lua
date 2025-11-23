local machineInfo = nil
local createdMachines = {}

local function loadModel(model)
    if not IsModelValid(model) then
        print("[ERROR] Invalid model hash: " .. tostring(model))
        return false
    end
    
    if not HasModelLoaded(model) then
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 5000 do
            Wait(10)
            timeout = timeout + 10
        end
        
        if not HasModelLoaded(model) then
            print("[ERROR] Failed to load model: " .. tostring(model))
            return false
        end
    end
    
    return true
end

local function createClawMachines()
    local model = `ch_prop_arcade_claw_01a`
    
    -- Load model with error handling
    if not loadModel(model) then
        print("[ERROR] Failed to load claw machine model")
        return false
    end
    
    -- Remove any existing targets for this model with error handling
    pcall(function()
        exports.ox_target:removeModel(model)
    end)

    -- Clean up existing machines
    for i = 1, #createdMachines do
        if DoesEntityExist(createdMachines[i]) then
            DeleteEntity(createdMachines[i])
        end
    end
    createdMachines = {}

    -- Validate config
    if not Config or not Config.machines then
        print("[ERROR] No claw machines configured")
        return false
    end

    -- Create new machines
     local successCount = 0
     for k, location in pairs(Config.machines) do
         if not location then
             print("[ERROR] Invalid machine location at key: " .. tostring(k))
             goto continue
         end
         
         local coords = location
        
        -- Check and delete any existing objects at this location
        if DoesObjectOfTypeExistAtCoords(coords.x, coords.y, coords.z, 1.0, model, 0) then
            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, model)
            if DoesEntityExist(object) then
                SetEntityAsMissionEntity(object, true, true)
                DeleteEntity(object)
                Wait(100)
            end
        end

        -- Create new object
        local claw = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, false, false)
        
        if DoesEntityExist(claw) then
            SetEntityHeading(claw, coords.w - 180)
            FreezeEntityPosition(claw, true)
            SetEntityAsMissionEntity(claw, true, true)
            createdMachines[#createdMachines + 1] = claw
            successCount = successCount + 1
        else
            print("[ERROR] Failed to create claw machine at location: " .. tostring(k))
        end
        
        ::continue::
    end
    
    print("[INFO] Created " .. successCount .. "/" .. #Config.machines .. " claw machines")

    -- Add target for the model with error handling
    local targetSuccess = pcall(function()
        exports.ox_target:addModel(model, {
            {
                name = 'claw_machine_use',
                icon = 'fas fa-coins',
                label = (Config.Text and Config.Text['use_claw'] or 'Use Claw Machine $') .. (Config.price or 10),
                onSelect = function(data)
                    local entity = data.entity
                    if not entity or IsPedAPlayer(entity) then 
                        lib.notify({
                            title = 'Error',
                            description = 'Invalid claw machine entity',
                            type = 'error'
                        })
                        return 
                    end
                    
                    if not DoesEntityExist(entity) then
                        lib.notify({
                            title = 'Error',
                            description = 'Claw machine not found',
                            type = 'error'
                        })
                        return
                    end
                    
                    local playerPed = PlayerPedId()
                    local pCoords = GetEntityCoords(playerPed)
                    
                    -- Face the machine
                    TaskTurnPedToFaceEntity(playerPed, entity, 2000)
                    Wait(1000)

                    -- Find the closest machine
                    local closestMachine = nil
                    local closestDistance = math.huge
                    
                    if Config and Config.machines then
                         for k, location in pairs(Config.machines) do
                             if location then
                                 local distance = #(pCoords - location.xyz)
                                 if distance < closestDistance and distance <= 5.0 then
                                     closestDistance = distance
                                     closestMachine = { location = location }
                                 end
                             end
                         end
                     end
                    
                    if not closestMachine then
                        lib.notify({
                            title = 'Claw Machine',
                            description = 'You are too far from the machine!',
                            type = 'error'
                        })
                        return
                    end
                    
                    -- Start progress bar
                    if lib.progressBar({
                        duration = Config.progressTime,
                        label = (Config.Text and Config.Text['grab_toy']) or 'Grabbing toy...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            mouse = false,
                            combat = true,
                        },
                        anim = {
                            dict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft",
                            clip = "insert_coins",
                            flag = 16,
                        },
                    }) then
                        -- Progress completed successfully
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('qb-clawmachine:winPrize', closestMachine)
                    else
                        -- Progress was cancelled
                        ClearPedTasks(playerPed)
                    end
                        end,
                     distance = 1.0
                 }
             })
    end)
    
    if not targetSuccess then
        print("[ERROR] Failed to add ox_target interaction for claw machines")
        return false
    end
    
    return true
end

-- Initialize claw machines when resource starts
CreateThread(function()
    -- Add a small delay to ensure all dependencies are loaded
    Wait(1000)
    
    local success = createClawMachines()
    if not success then
        print("[ERROR] Failed to initialize claw machines")
    end
end)

local function playClawMachineAnimation(animType)
    if not animType then
        print("[ERROR] No animation type provided")
        return
    end
    
    local playerPed = PlayerPedId()
    if not DoesEntityExist(playerPed) then
        print("[ERROR] Player ped does not exist")
        return
    end
    
    local animDict, animName
    
    if animType == "win" then
        animDict = "anim@mp_player_intcelebrationfemale@slow_clap"
        animName = "slow_clap"
    else
        animDict = "gestures@m@standing@casual"
        animName = "gesture_damn"
    end
    
    -- Request animation dictionary with timeout
    local success = lib.requestAnimDict(animDict, 5000)
    if not success then
        print("[ERROR] Failed to load animation dictionary: " .. animDict)
        -- Fallback to simple emote
        if animType == "win" then
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CHEERING", 0, true)
        else
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
        end
        CreateThread(function()
            Wait(3000)
            if DoesEntityExist(playerPed) then
                ClearPedTasks(playerPed)
            end
        end)
        return
    end
    
    -- Play animation with error checking
    local animSuccess = pcall(function()
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 3000, 0, 0, false, false, false)
    end)
    
    if not animSuccess then
        print("[ERROR] Failed to play animation: " .. animName)
        -- Fallback to scenario
        if animType == "win" then
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CHEERING", 0, true)
        else
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
        end
    end
    
    -- Clean up after animation
    CreateThread(function()
        Wait(3000)
        if DoesEntityExist(playerPed) then
            ClearPedTasks(playerPed)
        end
        if HasAnimDictLoaded(animDict) then
            RemoveAnimDict(animDict)
        end
    end)
end

-- Animation event handler with validation
RegisterNetEvent('qb-clawmachine:client:animation', function(animType)
    if not animType or (animType ~= "win" and animType ~= "lose") then
        print("[ERROR] Invalid animation type received: " .. tostring(animType))
        return
    end
    
    playClawMachineAnimation(animType)
end)

-- Cleanup function for all created machines
local function cleanupClawMachines()
    local model = `ch_prop_arcade_claw_01a`
    
    -- Remove ox_target interactions
    pcall(function()
        exports.ox_target:removeModel(model)
    end)
    
    -- Delete all created machines
    for i = 1, #createdMachines do
        if DoesEntityExist(createdMachines[i]) then
            SetEntityAsMissionEntity(createdMachines[i], true, true)
            DeleteEntity(createdMachines[i])
        end
    end
    
    -- Clear the machines table
    createdMachines = {}
    
    -- Unload the model
    if HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
    end
    
    print("[INFO] Cleaned up all claw machines")
end

-- Resource stop cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        cleanupClawMachines()
    end
end)

-- Resource start cleanup (in case of restart)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Small delay to ensure clean startup
        Wait(500)
        cleanupClawMachines()
    end
end)