Props = {};
MiniGame = exports['nakres_skill_minigame']:GetMiniGame();

Citizen.CreateThread(function()
    TriggerServerEvent('nk:barbeque:playerConnecting');
    startBbqPropCheck();
end)

RegisterNetEvent('nk:barbeque:spawnNewObject');
AddEventHandler('nk:barbeque:spawnNewObject', function(data)
    Props[#Props + 1] = data;
end)

RegisterNetEvent('nk:barbeque:deleteObject');
AddEventHandler('nk:barbeque:deleteObject', function(coord, model)
    deleteBbqTable(coord, model);
end)

RegisterNetEvent('nk:barbeque:setObejctData');
AddEventHandler('nk:barbeque:setObejctData', function(data)
    Props = data;
end)

RegisterNetEvent('nk:barbeque:openBbqMenu');
AddEventHandler('nk:barbeque:openBbqMenu', function(entity)
    Barbeque.cook.menu(entity);
end)

RegisterNetEvent('nk:barbeque:takeOrder');
AddEventHandler('nk:barbeque:takeOrder', function(entity)
    Barbeque.activeOrder = true; --TODO: bu değişken sipariş bilgilerini tutacak ;)
    Barbeque.order.take(entity);
end)

CreateThread(function()
    if Config.target == "qb" then
        exports['qb-target']:AddTargetModel({ Config.BBQprop },
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
