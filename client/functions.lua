local minigame = exports['nakres_skill_minigame']:GetMiniGame();

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
