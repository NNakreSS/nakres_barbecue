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

RegisterNetEvent('nk:barbeque:openBbqMenu');
AddEventHandler('nk:barbeque:openBbqMenu', function(entity)
    Barbeque.cook.menu(entity);
end)

CreateThread(function()
    if Config.target == "qb" then
        exports['qb-target']:AddTargetModel({ "prop_bbq_1" },
            {
                options = {
                    {
                        label = 'Bbq Menu',
                        targeticon = 'fa-solid fa-fire-burner',
                        action = function(entity)
                            TriggerEvent('nk:barbeque:openBbqMenu', entity)
                        end
                    }
                },
                distance = 1.5,
            })
    end
end)
