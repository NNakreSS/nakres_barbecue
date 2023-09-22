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
                Barbeque.cook.startCooking(f.prop, f.metarials, f.item, f.skillBarImg)
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
end

RegisterCommand('bbqc', function()
    BarbequeTable.create("prop_bbq_1");
end)
