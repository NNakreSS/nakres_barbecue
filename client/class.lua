BarbequeTable = {
    create = function(model, propmodel)
        AnimationOptions = {
            Prop = propmodel or "prop_tool_box_06",
            PropBone = 28422,
            PropPlacement = {
                0.0, -0.18, -0.16, 0.0, 0.0, 0.0
            },
            Move = 51,
            Playback = 0
        };

        local player = PlayerPedId();
        local coord = GetOffsetFromEntityInWorldCoords(player, 0, 1.0, -1.0);
        local heading = GetEntityHeading(player);
        loadModel(model);
        local object = CreateObjectNoOffset(model, coord, false, false, false);

        SetEntityAlpha(object, 150);
        SetEntityCompletelyDisableCollision(object, false);
        SetEntityDrawOutline(object, true);
        SetEntityDrawOutlineColor(0, 250, 0);

        Animation.start("anim@heists@box_carry@", "idle", AnimationOptions);

        CreateThread(function()
            while true do
                coord = GetOffsetFromEntityInWorldCoords(player, 0, 1.0, -1.0);
                heading = GetEntityHeading(player);

                SetEntityCoords(object, coord);
                SetEntityHeading(object, heading);
                PlaceObjectOnGroundProperly(object);

                if IsControlPressed(0, 38) then
                    DeleteEntity(object)
                    local obj = CreateObjectNoOffset(model, coord, false, false, false)
                    SetModelAsNoLongerNeeded(model)
                    SetEntityHeading(obj, heading)
                    PlaceObjectOnGroundProperly(obj)
                    TriggerServerEvent('nk:barbeque:spawnNewObject', model, coord, heading)
                    Animation.stop();
                    break;
                end
                Wait(10)
            end;
        end);
    end,
    remove = function()
        --TODO: propları tekrar kaldırma modu eklenecek.
        Barbeque.selectCurrentTable(nil);
    end
}

Animation = {
    currentProp = nil,
    start = function(dict, anim, options)
        local playerPed = PlayerPedId();

        RequestAnimDict(dict);
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end

        if options and options.Prop and not currentProp then Animation.createProp(playerPed, options) end

        TaskPlayAnim(playerPed, dict, anim, 2.0, 2.0, -1, options.Move, options.Playback, false, false, false);
        RemoveAnimDict(dict);
    end,
    stop = function()
        local playerPed = PlayerPedId();
        ClearPedTasks(playerPed);
        if currentProp then
            DeleteEntity(currentProp);
            currentProp = nil;
        end
    end,
    createProp = function(ped, options)
        local propName = options.Prop;
        local propBone = options.PropBone;
        PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(options.PropPlacement);
        local x, y, z = table.unpack(GetEntityCoords(ped));

        loadModel(propName)
        currentProp = CreateObject(propName, x, y, z + 0.2, true, true, true);
        AttachEntityToEntity(currentProp, ped, GetPedBoneIndex(ped, propBone),
            PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6,
            true, true, false, true, 1, true);
        SetModelAsNoLongerNeeded(propName);
    end
}

Barbeque = {
    -- dutyStatus = false,
    -- smokeParticle = nil,
    -- currentFoodProp = nil,
    -- currentBbqTable = nil,
    selectCurrentTable = function(entity)
        currentBbqTable = entity;
    end,
    --#region
    -- fireStatu = false,
    -- Fire = {
    --     start = function(currentBbqTable)
    --         if not Barbeque.fireStatu then
    --             local propName = "prop_beach_fire";
    --             local objecoords = GetOffsetFromEntityInWorldCoords(currentBbqTable, 0.0, 0.0, 0.35);
    --             loadModel(propName)
    --             local fireobj = CreateObject(propName, objecoords.x, objecoords.y,
    --                 objecoords.z, true, true, true)
    --             -- SetEntityDrawOutline(fireobj, true);
    --             -- SetEntityDrawOutlineColor(0, 250, 0);
    --         end
    --     end,
    --     stop = function()
    --     end,
    -- },
    --#endregion
    cook = {
        startCooking = function(prop, items, food, skillBarImg)
            local coords = GetOffsetFromEntityInWorldCoords(currentBbqTable, 0.0, -0.7, 0.0);
            SetEntityCoords(PlayerPedId(), coords);
            SetEntityHeading(PlayerPedId(), GetEntityHeading(currentBbqTable));
            FreezeEntityPosition(PlayerPedId(), true);
            Animation.start("amb@prop_human_bbq@male@idle_a", "idle_b",
                {
                    Prop = "prop_fish_slice_01",
                    PropBone = 57005,
                    PropPlacement = {
                        0.08, 0.0, -0.02, 0.0, -25.0, 130.0
                    },
                    Move = 1,
                    Playback = 1
                });
            loadModel(prop)
            currentFoodProp = CreateObject(prop, GetOffsetFromEntityInWorldCoords(currentBbqTable, 0.0, 0.0, 0.94), true,
                true,
                true)
            MiniGame.Start({
                    difficultyFactor = 0.99,
                    time = 30,
                    halfSuccessMin = 70,
                    valueUpSpeed = 1,
                    img = skillBarImg or "img/fire.webp",
                },
                function()
                    Barbeque.cook.endCooking("success", items, food)
                end,
                function()
                    Barbeque.cook.endCooking("fail")
                end,
                function()
                    Barbeque.cook.endCooking("halfSuccess", items, food)
                end
            )
        end,
        endCooking = function(type, items, food)
            DeleteEntity(currentFoodProp)
            currentFoodProp = nil;
            FreezeEntityPosition(PlayerPedId(), false);
            Animation.stop();
            if type == "success" then
                print("Pişirdin");
            elseif type == "halfSuccess" then
                print("Yarı pişmiş");
            else
                print("beceremedin");
            end
        end,
        menu = function(entity)
            Barbeque.selectCurrentTable(entity);
            lib.registerContext({
                id = 'food_menu',
                title = 'Yemekler',
                options = getFoods()
            })
            lib.registerContext({
                id = 'cookMenu',
                title = 'Barbeque Menu',
                options = {
                    {
                        title = 'Mesai',
                        description = 'İşe başla / ayrıl',
                        icon = 'circle',
                        iconColor = Barbeque.dutyStatus and 'green' or 'red',
                        onSelect = function()
                            Barbeque.duty.toggle()
                        end,
                        metadata = {
                            { label = 'Durum', value = Barbeque.dutyStatus and "Aktif" or "Boşta" },
                        },
                    },
                    {
                        title = 'Birşeyler Pişir',
                        menu = 'food_menu',
                        icon = 'bars'
                    },
                }
            })
            lib.showContext('cookMenu')
        end
    },
    duty = {
        toggle = function()
            --TODO: Müşteri beklemeye başla
            if not Barbeque.dutyStatus then
                --#region
                -- local coords = GetOffsetFromEntityInWorldCoords(currentBbqTable, 0.0, 0.0, 1.0);
                -- RequestNamedPtfxAsset("core")
                -- while not HasNamedPtfxAssetLoaded("core") do
                --     Citizen.Wait(1)
                -- end
                -- UseParticleFxAssetNextCall("core")
                -- smokeParticle = StartParticleFxLoopedAtCoord("ent_amb_smoke_foundry", coords.x, coords.y, coords.z,
                --     0.0, 0.0, 0.0, 0.1, false, false, false, 0);
                --#endregion
                -- print(smokeParticle);
            else
                -- StopParticleFxLooped(smokeParticle, false);
                print("işten ayrıldın");
            end
            Barbeque.dutyStatus = not Barbeque.dutyStatus;
        end
    }
}
