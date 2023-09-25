Props = {};
MiniGame = exports['nakres_skill_minigame']:GetMiniGame();
Lang = (require 'shared.lang')[Config.LANGUAGE]

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
    Barbeque.order.take(entity);
end)

RegisterNetEvent('nk:barbeque:giveOrder');
AddEventHandler('nk:barbeque:giveOrder', function(entity)
    Barbeque.order.give(entity);
end)

CreateThread(function()
    if Config.target == "qb" then
        exports['qb-target']:AddTargetModel(Config.BBQprop, {
            options = { {
                label = Lang.bbq_menu,
                targeticon = 'fa-solid fa-fire-burner',
                action = function(entity)
                    TriggerEvent('nk:barbeque:openBbqMenu', entity)
                end
            } },
            distance = 1.5
        })
    elseif Config.target == "ox" then
        exports.ox_target:addModel(Config.BBQprop, {
            label = Lang.bbq_menu,
            icon = 'fa-solid fa-fire-burner',
            distance = 1.5,
            onSelect = function(data)
                TriggerEvent('nk:barbeque:openBbqMenu', data.entity)
            end
        })
    end
end)
