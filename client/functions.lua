MiniGame = exports['nakres_skill_minigame']:GetMiniGame();

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
            -- args = {
            --     ["food"] = f.item,
            --     ["items"] = f.metarials
            -- },
            onSelect = function()
                Barbeque.cook.startCooking(f.prop, f.metarials, f.item)
            end,
        }
        foodOptions[#foodOptions + 1] = food;
    end
    return foodOptions
end

RegisterCommand('bbqc', function()
    BarbequeTable.create("prop_bbq_1");
end)
