local Props, customers = {}, {};
local QBCore = exports?['qb-core']:GetCoreObject();
local ox_inventory = exports?.ox_inventory
local ESX = nil;
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Lang = (require 'shared.lang')[Config.LANGUAGE]


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

RegisterServerEvent('nk:barbeque:giveMoney');
AddEventHandler("nk:barbeque:giveMoney", function(price)
    local src = source;
    giveMoney(src, price);
end)

RegisterServerEvent('nk:barbeque:deleteCustomer');
AddEventHandler("nk:barbeque:deleteCustomer", function(id)
    table.remove(customers, id);
end)

lib.callback.register('nk:barbeque:removeItemCheck', function(source, items)
    local Player = Config.inventory == "qb" and QBCore.Functions.GetPlayer(source) or
        Config.inventory == "esx" and ESX.GetPlayerFromId(source);
    for i, key in ipairs(items) do
        key.value = key.value or 1;
        local amount = Config.inventory == "qb" and Player.Functions.GetItemByName(key.item)?.amount or
            Config.inventory == "ox" and exports.ox_inventory:Search(source, 'count', key.item) or
            Config.inventory == "esx" and Player.getInventoryItem(key.item)?.count;
        if amount then
            if amount < key.value then
                return false;
            end
        else
            return false;
        end
    end
    for i, key in ipairs(items) do
        removeItem(source, key.item, key.value);
    end
    return true;
end)

lib.callback.register('nk:barbeque:checkCustomer', function(source, ped)
    for key, cPed in pairs(customers) do
        if cPed == ped then
            return false;
        end
    end
    customers[#customers + 1] = ped;
    return #customers;
end)

Citizen.CreateThread(function() -- only qb framework
    if Config.inventory == "qb" or (Config.inventory == "ox" and Config.framework == "qb") then
        local items = {
            [Config.BBQitemName] = {
                name = Config.BBQitemName,
                label = "BBQ",
                weight = 2000,
                type = 'item',
                image = "",
                unique = false,
                useable = true,
                shouldClose = true,
                combinable = nil,
                description = Lang.barbecue_grill
            }
        };
        for _i, item in ipairs(Config.Foods) do
            items[item.item] = {
                name = item.item,
                label = item.label,
                weight = item.weight or 200,
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
                    weight = val.weight or 200,
                    type = 'item',
                    image = val.itemImg,
                    unique = false,
                    useable = true,
                    shouldClose = true,
                    combinable = nil,
                    description = val.description or Lang.cooking_supplies
                };
            end
        end
        QBCore.Functions.AddItems(items);
    end
end)

function removeItem(source, item, count)
    if Config.inventory == "qb" then
        local Player = QBCore.Functions.GetPlayer(source);
        Player.Functions.RemoveItem(item, count);
    elseif Config.inventory == "ox" then
        ox_inventory:RemoveItem(source, item, count)
    elseif Config.inventory == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(item, count)
    end
end

function addItemInventory(source, item, count)
    if Config.inventory == "qb" then
        local Player = QBCore.Functions.GetPlayer(source);
        Player.Functions.AddItem(item, count);
    elseif Config.inventory == "ox" then
        ox_inventory:AddItem(source, item, count)
    elseif Config.inventory == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(item, count)
    end
end

function giveMoney(source, price)
    if Config.framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(source);
        Player.Functions.AddMoney("cash", price, Lang.barbecue_payment);
    elseif Config.framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addAccountMoney("money", price)
        -- xPlayer.addInventoryItem("cash", price)
    end
end
