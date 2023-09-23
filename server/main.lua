local Props = {};
local QBCore = exports['qb-core']:GetCoreObject();

RegisterServerEvent('nk:barbeque:spawnNewObject');
AddEventHandler('nk:barbeque:spawnNewObject', function(...)
    local model, coords, heading = table.unpack { ... }
    local data = {
        model = model,
        coords = coords,
        heading = heading
    }
    TriggerClientEvent('nk:barbeque:spawnNewObject', -1, data);
    Props[#Props + 1] = data;
end);

RegisterServerEvent('nk:barbeque:deletePropCoord');
AddEventHandler('nk:barbeque:deletePropCoord', function(deleteCoord, model)
    for key, value in ipairs(Props) do
        local dist = #(value.coords - deleteCoord);
        if dist <= 1.0 then
            table.remove(Props, key);
            break;
        end
    end
    TriggerClientEvent('nk:barbeque:deleteObject', -1, deleteCoord, model);
end);

RegisterServerEvent('nk:barbeque:playerConnecting');
AddEventHandler("nk:barbeque:playerConnecting", function()
    TriggerClientEvent('nk:barbeque:setObejctData', source, Props);
end)

RegisterServerEvent('nk:barbeque:addItem');
AddEventHandler("nk:barbeque:addItem", function(item, count)
    local src = source;
    addItemInventory(src, item, count);
end)

lib.callback.register('nk:barbeque:removeItemCheck', function(source, items)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source);
        for i, key in ipairs(items) do
            key.value = key.value or 1;
            local haveItem = Player.Functions.GetItemByName(key.item);
            if haveItem then
                if haveItem.amount < key.value then
                    return false;
                end
            else
                return false;
            end
        end
    end
    for i, key in ipairs(items) do
        removeItem(source, key.item, key.value);
    end
    return true;
end)

Citizen.CreateThread(function()
    if QBCore then
        local items = {
            ["bbq_prop"] = {
                name = "bbq_prop",
                label = "BBQ",
                weight = 15,
                type = 'item',
                image = "barbecue.png",
                unique = false,
                useable = true,
                shouldClose = true,
                combinable = nil,
                description = "Barbekü mangalı"
            },
        };
        for _i, item in ipairs(Config.Foods) do
            items[item.item] = {
                name = item.item,
                label = item.name,
                weight = item.weight or 5,
                type = 'item',
                image = item.itemImg,
                unique = false,
                useable = true,
                shouldClose = true,
                combinable = nil,
                description = item.description or 'Leziz bir yemek'
            };
            for key, val in pairs(item.metarials) do
                items[val.item] = {
                    name = val.item,
                    label = val.label,
                    weight = val.weight or 5,
                    type = 'item',
                    image = val.itemImg,
                    unique = false,
                    useable = true,
                    shouldClose = true,
                    combinable = nil,
                    description = val.description or 'Yemeklik malzemeler'
                };
            end
        end
        QBCore.Functions.AddItems(items);
    end
end)


function removeItem(source, item, count)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source);
        Player.Functions.RemoveItem(item, count);
    end
end

function addItemInventory(src, item, count)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src);
        Player.Functions.AddItem(item, count);
    end
end
