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
    for i, f in pairs(Config.Foods) do
        local food = {
            title = f.name,
            description = f.description or 'Leziz yemah',
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
            print("deleted")
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
        while true do
            local sleep = 3000
            if Barbeque.dutyStatus and not Barbeque.waitCustomer then
                print("bekleniyor ...")
                sleep = 1000
                local retval, outPed = GetClosestPed(coords.x, coords.y, coords.z, 10.0, 1, 0, 1, 1, 26)
                if lastCustomer ~= outPed and retval and math.random() > 0.1 then
                    Barbeque.waitCustomer = outPed;
                    TaskGoToEntity(outPed, entity, -1, 1.5, 1.0, 1073741824, 0)
                    while true do
                        dist = #(coords - GetEntityCoords(outPed))
                        if dist <= 2.5 then
                            SetBlockingOfNonTemporaryEvents(Barbeque.waitCustomer, true)
                            TaskSetBlockingOfNonTemporaryEvents(Barbeque.waitCustomer, true)
                            SetEveryoneIgnorePlayer(PlayerId(), true)
                            -- print(GetRelationshipBetweenPeds(outPed, ped));
                            addTargetCustomerNpc(outPed, "takeOrder")
                            TaskStandStill(outPed, -1);
                            TaskLookAtEntity(outPed, entity, -1);
                            lastCustomer = outPed;
                            lib.notify({
                                title = 'Müşteri geldi !',
                                type = 'info'
                            })
                            CreateThread(function()
                                Wait(15000)
                                if Barbeque.dutyStatus and not Barbeque.activeCustomer and lastCustomer == Barbeque.waitCustomer then
                                    lib.notify({
                                        title = 'Kaçırdın 1!',
                                        description = "Çok beklettiğin için müşteri uzaklaştı",
                                        type = 'error'
                                    })
                                    cancelCustomerNpc(Barbeque.waitCustomer)
                                else
                                    Wait(60000)
                                    if Barbeque.dutyStatus and Barbeque.activeCustomer and lastCustomer == Barbeque.activeCustomer then
                                        lib.notify({
                                            title = 'Kaçırdın 2!',
                                            description = "Çok beklettiğin için müşteri uzaklaştı",
                                            type = 'error'
                                        })
                                        cancelCustomerNpc(Barbeque.activeCustomer)
                                    end
                                end
                            end)
                            break
                        end
                        Citizen.Wait(500)
                    end
                end
            elseif Barbeque.activeCustomer then
                if HasEntityBeenDamagedByAnyPed(Barbeque.activeCustomer) then
                    cancelCustomerNpc(Barbeque.activeCustomer)
                    lib.notify({
                        title = 'Müşteriyi kaçırdın !',
                        type = 'error'
                    })
                end
            end
            Citizen.Wait(sleep)
        end
    end)
end

function cancelCustomerNpc(npc)
    if Barbeque.activeOrder then
        lib.hideTextUI()
    end
    removePedTarget(npc);
    FreezeEntityPosition(npc, false)
    TaskWanderStandard(npc, 10.0, 10)
    Barbeque.activeCustomer = nil;
    Barbeque.waitCustomer = nil;
    Barbeque.activeOrder = nil;
end

function addTargetCustomerNpc(npc, _type)
    if Config.target == "qb" then
        if _type == 'takeOrder' then
            Barbeque.activeTarget = "Sipariş Al"
            exports['qb-target']:AddTargetEntity(npc, {
                options = { {
                    label = 'Sipariş Al',
                    targeticon = 'fa-solid fa-comments',
                    action = function(entity)
                        TriggerEvent('nk:barbeque:takeOrder', npc)
                    end
                } },
                distance = 2
            })
        elseif _type == 'giveOrder' then
            Barbeque.activeTarget = "Sipariş Teslim";
            exports['qb-target']:AddTargetEntity(npc, {
                options = { {
                    label = 'Sipariş Teslim',
                    targeticon = 'fa-solid fa-box',
                    action = function(entity)
                        TriggerEvent('nk:barbeque:giveOrder', npc)
                    end
                } },
                distance = 2
            })
        end
    end
end

function removePedTarget(npc)
    local label = Barbeque.activeTarget;
    if npc then
        if Config.target == "qb" then
            exports['qb-target']:RemoveTargetEntity(npc, label or 'Sipariş Al');
            Barbeque.activeTarget = nil;
        end
    end
end

function removeItemCheckCount(items)
    return lib.callback.await('nk:barbeque:removeItemCheck', false, items)
end

function addItem(item, count)
    TriggerServerEvent("nk:barbeque:addItem", item, count)
end

RegisterCommand('bbqc', function()
    BarbequeTable.create(Config.BBQprop, "prop_tool_box_06");
end)
