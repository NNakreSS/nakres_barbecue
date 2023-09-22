function loadModel(model)
    local timer = 0;
    RequestModel(model);
    while not HasModelLoaded(model) do
        if timer >= 500 then return print("model not loaded : " .. model) end
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
            end,
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
        local dist    = #(propVec - currentCoord)
        if dist <= 1.0 then
            local entity = GetClosestObjectOfType(currentCoord, 1.5, model, 0, 0, 0)
            DeleteEntity(entity)
            print("deleted")
            table.remove(Props, i)
            break;
        end
    end
end

function onDutyWaitCustomerNpc()
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        while Barbeque.dutyStatus and not Barbeque.activeCustomer do
            local coords = GetEntityCoords(ped)
            local retval, outPed = GetClosestPed(coords.x, coords.y, coords.z, 10.0, 1, 0, 1, 1, 26)
            if retval and math.random() > 0.1 then
                Barbeque.activeCustomer = outPed;
                TaskGoToEntity(outPed, ped, -1, 1.5, 1.0, 1073741824, 0)
                while true do
                    dist = #(coords - GetEntityCoords(outPed))
                    if dist <= 2.0 then
                        TaskStandStill(outPed, 10 * 1000)
                        TaskLookAtEntity(outPed, ped, -1)
                        break;
                    end
                    Citizen.Wait(500)
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

function removeItemCheckCount(items)
    return lib.callback.await('nk:barbeque:removeItemCheck', false, items)
end

function addItem(item, count)
    TriggerServerEvent("nk:barbeque:addItem", item, count)
end

RegisterCommand('bbqc', function()
    BarbequeTable.create(Config.BBQprop);
end)
