local Props = {};

Citizen.CreateThread(function()
    TriggerServerEvent('nk:barbeque:playerConnecting');
    while true do
        pcord = GetEntityCoords(PlayerPedId())
        for _i, v in ipairs(Props) do
            local coord = v.coords
            dst = #(pcord - coord)
            local areaInProp = GetClosestObjectOfType(coord, 1.5, GetHashKey(v.model), 0, 0, 0)
            if dst < 150 then
                if not DoesEntityExist(areaInProp) then
                    loadModel(v.model);
                    areaInProp = CreateObjectNoOffset(v.model, v.coords);
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
end)

RegisterNetEvent('nk:barbeque:spawnNewObject');
AddEventHandler('nk:barbeque:spawnNewObject', function(data)
    Props[#Props + 1] = data;
end)

RegisterNetEvent('nk:barbeque:setObejctData');
AddEventHandler('nk:barbeque:setObejctData', function(data)
    Props = data;
end)

RegisterNetEvent('nk:barbeque:setObejctData');
AddEventHandler('nk:barbeque:setObejctData', function(data)
    Props = data;
end)

RegisterNetEvent('nk:barbeque:targetSelect');
AddEventHandler('nk:barbeque:targetSelect', function(type, entity)
    if type == "duty" then
        Barbeque.duty.start(entity);
    elseif type == "cook" then
        Barbeque.cook(entity);
    end
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel({ "prop_bbq_1" },
        {
            options = {
                {
                    num = 1,
                    type = "client",
                    event = "nk:barbeque:targetSelect",
                    icon = 'fa-solid fa-fire',
                    label = 'İşe başla',
                    targeticon = 'fa-solid fa-fire-burner',
                    action = function(entity)
                        TriggerEvent('nk:barbeque:targetSelect', "duty", entity)
                    end
                },
                {
                    num = 2,
                    type = "client",
                    event = "nk:barbeque:targetSelect",
                    icon = 'fa-solid fa-utensils',
                    label = 'Pişir',
                    targeticon = 'fa-solid fa-fire-burner',
                    action = function(entity)
                        TriggerEvent('nk:barbeque:targetSelect', "cook", entity)
                    end
                }
            },
            distance = 1.5,
        })
end)

RegisterCommand('bbqc', function()
    BarbequeTable.create("prop_bbq_1");
end)
