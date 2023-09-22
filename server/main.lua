local Props = {}

RegisterServerEvent('nk:barbeque:spawnNewObject');
AddEventHandler('nk:barbeque:spawnNewObject', function(...)
    local model, coords, heading = table.unpack { ... }
    local data = {
        model = model,
        coords = coords,
        heading = heading
    }
    TriggerClientEvent('nk:barbeque:spawnNewObject', -1, data);
    Props[#Props + 1] = data
end);

RegisterServerEvent('nk:barbeque:playerConnecting');
AddEventHandler("nk:barbeque:playerConnecting", function()
    TriggerClientEvent('nk:barbeque:setObejctData', source, Props);
end)
