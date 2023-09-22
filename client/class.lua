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

    remove = function(obj)
        local currentCoord = GetEntityCoords(obj)
        local model = GetEntityModel(obj)
        TriggerServerEvent("nk:barbeque:deletePropCoord", currentCoord, model)
        addItem(Config.BBQprop, 1)
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
    -- currentFoodProp = nil,
    -- currentBbqTable = nil,
    -- activeCustomer = nil,

    selectCurrentTable = function(entity)
        currentBbqTable = entity;
    end,

    cook = {

        startCooking = function(prop, items, food, skillBarData)
            if removeItemCheckCount(items) then
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
                currentFoodProp = CreateObject(prop, GetOffsetFromEntityInWorldCoords(currentBbqTable, 0.0, 0.0, 0.94),
                    true,
                    true,
                    true)
                MiniGame.Start(skillBarData,
                    function()
                        Barbeque.cook.endCooking("success", food)
                    end,
                    function()
                        Barbeque.cook.endCooking("fail")
                    end
                )
            else
                print("Gerekli malzemelerin yok")
            end
        end,

        endCooking = function(type, food)
            DeleteEntity(currentFoodProp)
            currentFoodProp = nil;
            FreezeEntityPosition(PlayerPedId(), false);
            Animation.stop();
            if type == "success" then
                print("Pişirdin");
                addItem(food, 1)
            else
                print("beceremedin");
            end
        end,

        menu = function(entity)
            Barbeque.selectCurrentTable(entity);
            lib.registerContext({
                id = 'food_menu',
                title = 'Yemekler',
                options = getFoods(),
                menu = "cookMenu",
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
                        title = 'Mangalı Kaldır',
                        icon = 'box',
                        onSelect = function()
                            BarbequeTable.remove(currentBbqTable)
                        end,
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
            if not Barbeque.dutyStatus then
                onDutyWaitCustomerNpc();
                print("başladın");
            else
                print("işten ayrıldın");
            end
            Barbeque.dutyStatus = not Barbeque.dutyStatus;
        end
    }
}
