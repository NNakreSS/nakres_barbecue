BarbequeTable = {

    create = function(model, propmodel)
        AnimationOptions = {
            Prop = propmodel,
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
        addItem("BBQprop", 1)
        Barbeque.currentBbqTable = nil;
        Barbeque.dutyStatus = false;
        Barbeque.waitCustomer = nil;
        lib.notify({
            title = 'Toparlandın !',
            description = 'Mangalı toparladın',
            type = 'info'
        })
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
    -- waitCustomer = nil,
    -- activeCustomer = nil,
    -- activeOrder = nil
    cook = {

        startCooking = function(prop, items, food, skillBarData)
            if removeItemCheckCount(items) then
                local coords = GetOffsetFromEntityInWorldCoords(Barbeque.currentBbqTable, 0.0, -0.7, 0.0);
                SetEntityCoords(PlayerPedId(), coords);
                SetEntityHeading(PlayerPedId(), GetEntityHeading(Barbeque.currentBbqTable));
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
                Barbeque.currentFoodProp = CreateObject(prop,
                    GetOffsetFromEntityInWorldCoords(Barbeque.currentBbqTable, 0.0, 0.0, 0.94),
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
                lib.notify({
                    title = 'Yetersiz !',
                    description = 'Bunun için gerekli mazemelere sahip değilsin',
                    type = 'error'
                })
            end
        end,

        endCooking = function(type, food)
            DeleteEntity(Barbeque.currentFoodProp)
            Barbeque.currentFoodProp = nil;
            FreezeEntityPosition(PlayerPedId(), false);
            Animation.stop();
            if type == "success" then
                lib.notify({
                    title = 'Leziz !',
                    description = 'Hazır onu yemek için müşteriler sabırsız...',
                    type = 'success'
                })
                addItem(food, 1)
            else
                lib.notify({
                    title = 'Beceremedin !',
                    description = 'Ateşte çok bekleterek tüm mazemeleri yaktın.',
                    type = 'error'
                })
            end
        end,

        menu = function(entity)
            Barbeque.currentBbqTable = entity;
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
                            BarbequeTable.remove(Barbeque.currentBbqTable)
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
                lib.notify({
                    title = 'BBQ İşine başladın',
                    description = 'Yoldan geçen müşterileri bekle , daha fazla müşteri çekmek için başarılı satışlar yap',
                    type = 'info'
                })
            else
                lib.notify({
                    title = 'BBQ İşinden ayrıldın',
                    description = 'Dilediğin zaman tekrar başlamak için mangalı kaldırmayı unutma',
                    type = 'info'
                })
            end
            Barbeque.dutyStatus = not Barbeque.dutyStatus;
        end
    },

    order = {
        take = function(entity)
            local foods = {}
            for index, value in ipairs(Config.Foods) do
                foods[index] = value
            end
            local randomOrderCount = math.random(1, 3)
            local orders           = {}
            local text             = '';
            for i = 1, randomOrderCount, 1 do
                print(#Config.Foods)
                local random     = math.floor(math.random(1, #foods))
                local randomFood = foods[random]
                orders[i]        = {
                    name = randomFood.name,
                    item = randomFood.item
                }
                text             = text .. "  \n " .. string.format('- %s', randomFood.name)
                table.remove(foods, random)
            end
            Barbeque.activeCustomer = Barbeque.waitCustomer;
            local confirm = lib.alertDialog({
                header = 'Sipariş',
                content = text,
                centered = true,
                cancel = true
            })
            if confirm == "confirm" then
                lib.showTextUI("### Beklenen siparişler\t\n" .. text, {
                    position = "left-center",
                    icon = "clipboard"
                })
                Barbeque.activeOrder = orders;
                TaskStandStill(Barbeque.activeCustomer, -1);
                lib.notify({
                    title = 'Siparişleri aldın hazırlamya başla',
                    type = 'info'
                })
                removePedTarget(Barbeque.activeCustomer);
            else
                removePedTarget(Barbeque.activeCustomer);
                TaskStandStill(Barbeque.activeCustomer, 1);
                Barbeque.activeCustomer = nil;
                Barbeque.waitCustomer = nil;
                Barbeque.activeOrder = nil;
            end
        end
    }
}
