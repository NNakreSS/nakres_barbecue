BarbequeTable = {
    create = function(model, propmodel)
        AnimationOptions = {
            Prop = propmodel or "prop_tool_box_06",
            PropBone = 28422,
            PropPlacement = {
                0.0, -0.18, -0.16, 0.0, 0.0, 0.0
            },
            Move = 51,
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

        TaskPlayAnim(playerPed, dict, anim, 2.0, 2.0, -1, options.Move, 0, false, false, false);
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
    dutyStatus = false,
    smokeParticle = nil,
    -- fireStatu = false,
    -- Fire = {
    --     start = function(entity)
    --         if not Barbeque.fireStatu then
    --             local propName = "prop_beach_fire";
    --             local objecoords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 0.35);
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
    cook = function(entity)
        --TODO: Yemek pişime minigame olayları
        local coords = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.7, 0.0);
        SetEntityCoords(PlayerPedId(), coords)
        SetEntityHeading(PlayerPedId(), GetEntityHeading(entity))
        FreezeEntityPosition(PlayerPedId(), true)
        Animation.start("amb@prop_human_bbq@male@idle_b", "idle_d",
            {
                Prop = "prop_fish_slice_01",
                PropBone = 57005,
                PropPlacement = {
                    0.08, 0.0, -0.02, 0.0, -25.0, 130.0
                },
                Move = 0,
            })
        print("Pişirme menüsünü aç")
    end,
    duty = {
        start = function(entity)
            --TODO: Müşteri beklemeye başla
            if not dutyStatus then
                local coords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 0.35);
                RequestNamedPtfxAsset("core")
                while not HasNamedPtfxAssetLoaded("core") do
                    Citizen.Wait(1)
                end
                UseParticleFxAssetNextCall("core")
                smokeParticle = StartParticleFxLoopedAtCoord("ent_amb_beach_campfire", coords.x, coords.y, coords.z,
                    0.0, 0.0, 0.0, 1.0, false, false, false, 0);
                dutyStatus = true;
                print(smokeParticle)
            end
        end,
        stop = function()
            --TODO: Müşteri beklemeyi durdur
            if dutyStatus then
                dutyStatus = false;
                StopParticleFxLooped(smokeParticle, false)
                print("işten ayrıldın")
            end
        end
    }
}
