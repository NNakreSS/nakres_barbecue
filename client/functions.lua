function loadModel(model)
    local timer = 0;
    RequestModel(model);
    while not HasModelLoaded(model) do
        if timer >= 500 then
            return print("model not loaded : " .. model)
        end
        RequestModel(model);
        timer = timer + 1;
        Citizen.Wait(10)
    end
end

function getFoods()
    local foodOptions = {};
    for i, f in pairs(Foods) do
        local food = {
            title = f.label,
            description = f.description or Lang.delicious_meals,
            icon = f.icon or 'check',
            arrow = false,
            metadata = f.metarials,
            onSelect = function()
                Barbeque.cook.startCooking(f.prop, f.metarials, f.item, f.skillBarData)
            end
        }
        foodOptions[#foodOptions + 1] = food;
    end
    return foodOptions
end

function startBbqPropCheck()
    while true do
        pcord = GetEntityCoords(PlayerPedId())
        for _i, v in ipairs(Props) do
            local coord = vector3(v.coords.x, v.coords.y, v.coords.z)
            dst = #(pcord - coord)
            local areaInProp = GetClosestObjectOfType(coord, 1.5, GetHashKey(v.model), 0, 0, 0)
            if dst < 150 then
                if not DoesEntityExist(areaInProp) then
                    loadModel(v.model);
                    areaInProp = CreateObjectNoOffset(v.model, coord);
                    SetEntityHeading(areaInProp, v.heading);
                    PlaceObjectOnGroundProperly(areaInProp);
                    SetModelAsNoLongerNeeded(v.model);
                end
            else
                if DoesEntityExist(areaInProp) then
                    DeleteEntity(areaInProp);
                end
            end
        end
        Citizen.Wait(5000)
    end
end

function deleteBbqTable(currentCoord, model)
    for i, prop in ipairs(Props) do
        local propVec = vector3(prop.coords.x, prop.coords.y, prop.coords.z)
        local dist = #(propVec - currentCoord)
        if dist <= 1.0 then
            local entity = GetClosestObjectOfType(currentCoord, 1.5, model, 0, 0, 0)
            DeleteEntity(entity)
            table.remove(Props, i)
            break
        end
    end
end

local lastCustomer;
function onDutyWaitCustomerNpc(entity)
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(entity)
        if Barbeque.recognition <= 5 then
            return lib.notify({
                title = Lang.customers_unhappy,
                type = 'error'
            })
        end
        while true do
            local sleep = 3000
            local dist = #(coords - GetEntityCoords(ped))
            if dist >= 30 then return Barbeque.duty.toggle(); end
            if Barbeque.dutyStatus and not Barbeque.waitCustomer then
                sleep = 1000
                local retval, outPed = GetClosestPed(coords.x, coords.y, coords.z, (Barbeque.recognition / 2.0), 1, 0, 1,
                    1,
                    26)

                if lastCustomer ~= outPed and retval then
                    Barbeque.checkCustomer = lib.callback.await('nk:barbeque:checkCustomer', false, PedToNet(outPed));
                    if Barbeque.checkCustomer then
                        Barbeque.waitCustomer = outPed;
                        TaskGoToEntity(outPed, entity, -1, 1.5, 1.0, 1073741824, 0)
                        while true do
                            dist = #(coords - GetEntityCoords(outPed))
                            if dist <= 2.5 then
                                lookEntityToPlayer()
                                addTargetCustomerNpc(outPed, "takeOrder")
                                lib.notify({
                                    title = Lang.customer_arrived,
                                    type = 'info'
                                })
                                startWaitCustomerTimer(outPed);
                                break;
                            end
                            Citizen.Wait(500)
                        end
                    end
                end
            elseif Barbeque.activeCustomer then
                if HasEntityBeenDamagedByAnyPed(Barbeque.activeCustomer) then
                    cancelCustomerNpc(Barbeque.activeCustomer)
                    lib.notify({
                        title = Lang.missed_customer,
                        type = 'error'
                    })
                    Barbeque.recognition -= Config.recognitionDownValue * 2;
                end
            end
            Citizen.Wait(sleep)
        end
    end)
end

function startWaitCustomerTimer(customer)
    CreateThread(function()
        Wait(180000)
        if Barbeque.dutyStatus and Barbeque.activeCustomer == customer then
            lib.notify({
                title = Lang.missed,
                description = Lang.customer_left_due_to_wait,
                type = 'error'
            })
            Barbeque.recognition -= Config.recognitionDownValue
            cancelCustomerNpc(Barbeque.activeCustomer)
        end
    end)
end

function cancelCustomerNpc(npc)
    lastCustomer = npc;
    if Barbeque.activeOrder then
        lib.hideTextUI()
    end
    removePedTarget(npc);
    FreezeEntityPosition(npc, false)
    TaskWanderStandard(npc, 10.0, 10)
    Barbeque.activeCustomer = nil;
    Barbeque.waitCustomer = nil;
    Barbeque.activeOrder = nil;
    TriggerServerEvent("nk:barbeque:deleteCustomer", Barbeque.checkCustomer)
    Barbeque.checkCustomer = nil;
end

function addTargetCustomerNpc(npc, _type)
    if Config.target == "qb" then
        if _type == 'takeOrder' then
            Barbeque.activeTarget = Lang.take_order
            exports['qb-target']:AddTargetEntity(npc, {
                options = { {
                    label = Lang.take_order,
                    targeticon = 'fa-solid fa-comments',
                    action = function()
                        TriggerEvent('nk:barbeque:takeOrder', npc)
                    end
                } },
                distance = 2
            })
        elseif _type == 'giveOrder' then
            Barbeque.activeTarget = Lang.deliver_order;
            exports['qb-target']:AddTargetEntity(npc, {
                options = { {
                    label = Lang.deliver_order,
                    targeticon = 'fa-solid fa-box',
                    action = function()
                        TriggerEvent('nk:barbeque:giveOrder', npc)
                    end
                } },
                distance = 2
            })
        end
    elseif Config.target == "ox" then
        if _type == 'takeOrder' then
            Barbeque.activeTarget = "takeOrder"
            exports.ox_target:addLocalEntity(npc, {
                label = Lang.take_order,
                name = "takeOrder",
                icon = 'fa-solid fa-comments',
                distance = 2,
                onSelect = function()
                    TriggerEvent('nk:barbeque:takeOrder', npc)
                end
            })
        elseif _type == 'giveOrder' then
            Barbeque.activeTarget = "giveOrder";
            exports.ox_target:addLocalEntity(npc, {
                label = Lang.deliver_order,
                name = "giveOrder",
                icon = 'fa-solid fa-box',
                distance = 2,
                onSelect = function()
                    TriggerEvent('nk:barbeque:giveOrder', npc)
                end
            })
        end
    end
end

function removePedTarget(npc)
    if npc then
        if Config.target == "qb" then
            exports['qb-target']:RemoveTargetEntity(npc, Barbeque.activeTarget);
        elseif Config.target == "ox" then
            exports.ox_target:removeLocalEntity(npc, Barbeque.activeTarget)
        end
        Barbeque.activeTarget = nil;
    end
end

function removeItemCheckCount(items)
    return lib.callback.await('nk:barbeque:removeItemCheck', false, items)
end

function addItem(item, count)
    TriggerServerEvent("nk:barbeque:addItem", item, count)
end

function lookEntityToPlayer()
    local plPed = PlayerPedId();
    SetBlockingOfNonTemporaryEvents(Barbeque.waitCustomer, true)
    TaskSetBlockingOfNonTemporaryEvents(Barbeque.waitCustomer, true)
    SetEveryoneIgnorePlayer(PlayerId(), true)
    TaskTurnPedToFaceEntity(Barbeque.waitCustomer, plPed, -1)
    TaskLookAtEntity(Barbeque.waitCustomer, plPed, -1, 2048, 3)
end

function getColorShema()
    local colorScheme;
    if Barbeque.recognition >= 90 then
        colorScheme = "#087F5B"
    elseif Barbeque.recognition >= 80 then
        colorScheme = "#099268"
    elseif Barbeque.recognition >= 70 then
        colorScheme = "#0CA678"
    elseif Barbeque.recognition >= 60 then
        colorScheme = "#12B886"
    elseif Barbeque.recognition >= 50 then
        colorScheme = "#20C997"
    elseif Barbeque.recognition >= 40 then
        colorScheme = "#38D9A9"
    elseif Barbeque.recognition >= 30 then
        colorScheme = "#63E6BE"
    elseif Barbeque.recognition >= 20 then
        colorScheme = "#96F2D7"
    elseif Barbeque.recognition >= 10 then
        colorScheme = "#C3FAE8"
    else
        colorScheme = "#E6FCF5"
    end
    return colorScheme;
end

function reqAnimDict(dict)
    RequestAnimDict(dict);
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10);
    end;
end

