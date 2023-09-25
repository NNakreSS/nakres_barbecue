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
                    DeleteEntity(object);
                    local obj = CreateObjectNoOffset(model, coord, false, false, false);
                    SetModelAsNoLongerNeeded(model);
                    SetEntityHeading(obj, heading);
                    PlaceObjectOnGroundProperly(obj);
                    TriggerServerEvent('nk:barbeque:spawnNewObject', model, coord, heading);
                    Animation.stop();
                    break;
                elseif IsControlPressed(0, 73) then
                    DeleteEntity(object);
                    Animation.stop();
                    break;
                end
                Wait(30);
            end;
        end);
    end,

    remove = function(obj)
        local currentCoord = GetEntityCoords(obj);
        local model = GetEntityModel(obj);
        TriggerServerEvent("nk:barbeque:deletePropCoord", currentCoord, model);
        addItem(Config.BBQitemName, 1);
        Barbeque.currentBbqTable = nil;
        Barbeque.dutyStatus = false;
        cancelCustomerNpc(Barbeque.waitCustomer);
        lib.notify({
            title = Lang.you_have_collected,
            type = 'info'
        });
    end
}

Animation = {
    currentProp = nil,
    start = function(dict, anim, options)
        local playerPed = options and options.ped or PlayerPedId();
        if options?.scenario then
            TaskStartScenarioInPlace(
                playerPed,
                dict --[[ string ]],
                options?.unkDelay --[[ integer ]],
                anim --[[ boolean ]]
            );
            return;
        end;
        reqAnimDict(dict);
        if options?.Prop and not Animation.currentProp then Animation.createProp(playerPed, options) end;
        TaskPlayAnim(playerPed, dict, anim, 2.0, 2.0, -1, options?.Move or 0,
            options?.Playback or 0, false,
            false,
            false);
        RemoveAnimDict(dict);
        if options?.duration then Citizen.Wait(2000); end;
    end,

    stop = function(prop)
        local playerPed = PlayerPedId();
        ClearPedTasks(playerPed);
        if Animation.currentProp then
            DeleteEntity(Animation.currentProp);
            Animation.currentProp = nil;
        end
    end,

    createProp = function(ped, options)
        local propName = options.Prop;
        local propBone = options.PropBone;
        PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(options.PropPlacement);
        local x, y, z = table.unpack(GetEntityCoords(ped));

        loadModel(propName)
        Animation.currentProp = CreateObject(propName, x, y, z + 0.2, true, true, true);
        AttachEntityToEntity(Animation.currentProp, ped, GetPedBoneIndex(ped, propBone),
            PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6,
            true, true, false, true, 1, true);
        SetModelAsNoLongerNeeded(propName);
    end
}

Barbeque = {
    --#region Properties
    -- dutyStatus = false,
    -- currentFoodProp = nil,
    -- currentBbqTable = nil,
    -- waitCustomer = nil,
    -- activeCustomer = nil,
    -- activeOrder = nil
    --#endregion
    recognition = 20,
    cook        = {

        startCooking = function(prop, items, food, skillBarData)
            if removeItemCheckCount(items) then
                local coords = GetOffsetFromEntityInWorldCoords(Barbeque.currentBbqTable, 0.0, -0.7, 0.0);
                SetEntityCoords(PlayerPedId(), coords);
                SetEntityHeading(PlayerPedId(), GetEntityHeading(Barbeque.currentBbqTable));
                FreezeEntityPosition(PlayerPedId(), true);
                Animation.start("PROP_HUMAN_BBQ", true,
                    {
                        scenario = true,
                        unkDelay = -1
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
                    title = Lang.insufficient,
                    description = Lang.lack_supplies,
                    type = 'error'
                })
            end
        end,

        endCooking = function(type, food)
            DeleteEntity(Barbeque.currentFoodProp)
            Barbeque.currentFoodProp = nil;
            FreezeEntityPosition(PlayerPedId(), false);
            Animation.stop("prop_fish_slice_01");
            if type == "success" then
                lib.notify({
                    title = Lang.delicious,
                    description = Lang.impatient_customers,
                    type = 'success'
                })
                addItem(food, 1)
            else
                lib.notify({
                    title = Lang.not_successful,
                    description = Lang.burned_supplies,
                    type = 'error'
                })
            end
        end,

        menu = function(entity)
            Barbeque.currentBbqTable = entity;
            local schemaColor = getColorShema();
            lib.registerContext({
                id = 'food_menu',
                title = Lang.meals,
                options = getFoods(),
                menu = "cookMenu",
            })
            lib.registerContext({
                id = 'cookMenu',
                title = Lang.barbecue_menu,
                options = {
                    {
                        title = Lang.visibility,
                        description = Lang.customer_attention,
                        icon = 'ranking-star',
                        iconColor = schemaColor,
                        progress = Barbeque.recognition,
                        colorScheme = schemaColor,
                        metadata = {
                            { label = Lang.visibility, value = "%" .. Barbeque.recognition },
                        },
                    },
                    {
                        title = Lang.shift,
                        description = Lang.start_end_shift,
                        icon = 'circle',
                        iconColor = Barbeque.dutyStatus and 'green' or 'red',
                        onSelect = function()
                            Barbeque.duty.toggle()
                        end,
                        metadata = {
                            { label = Lang.status, value = Barbeque.dutyStatus and Lang.active or Lang.idle },
                        },
                    },
                    {
                        title = Lang.remove_barbecue,
                        icon = 'box',
                        onSelect = function()
                            BarbequeTable.remove(Barbeque.currentBbqTable)
                        end,
                    },
                    {
                        title = Lang.cook_something,
                        menu = 'food_menu',
                        icon = 'bars'
                    },
                }
            })
            lib.showContext('cookMenu')
        end
    },

    duty        = {
        toggle = function()
            if not Barbeque.dutyStatus then
                onDutyWaitCustomerNpc(Barbeque.currentBbqTable);
                lib.notify({
                    title = Lang.start_bbq_job,
                    description = Lang.wait_for_customers,
                    type = 'info'
                })
            else
                if Barbeque.waitCustomer then cancelCustomerNpc(Barbeque.waitCustomer) end
                lib.notify({
                    title = Lang.end_bbq_job,
                    description = Lang.remember_pickup_bbq,
                    type = 'info'
                })
            end
            Barbeque.dutyStatus = not Barbeque.dutyStatus;
        end
    },

    order       = {
        take = function(entity)
            local plPed = PlayerPedId();
            Barbeque.activeCustomer = Barbeque.waitCustomer;
            SetEntityHeading(Barbeque.waitCustomer, GetEntityHeading(plPed) - 180);
            lookEntityToPlayer();
            Animation.start("special_ped@jane@monologue_5@monologue_5c", "brotheradrianhasshown_2",
                { ped = Barbeque.activeCustomer });
            local AnimationOptions = {
                Prop = "prop_notepad_01",
                PropBone = 18905,
                PropPlacement = { 0.1, 0.02, 0.05, 10.0, 0.0, 0.0 },
                Move = 0,
                Playback = 0
            };
            Animation.start("missheistdockssetup1clipboard@base", "base", AnimationOptions);
            local foods = {};
            for index, value in ipairs(Config.Foods) do
                foods[index] = value;
            end;
            local randomOrderCount = math.random(1, 3);
            local orders           = {};
            local text             = '';
            for i = 1, randomOrderCount, 1 do
                local random     = math.floor(math.random(1, #foods));
                local randomFood = foods[random];
                orders[i]        = {
                    label = randomFood.label,
                    item = randomFood.item,
                    price = randomFood.price,
                };
                text             = text .. string.format('\n- %s', randomFood.label);
                table.remove(foods, random);
            end
            FreezeEntityPosition(Barbeque.activeCustomer, true);
            local confirm = lib.alertDialog({
                header = Lang.order,
                content = text,
                centered = true,
                cancel = true
            });
            if Barbeque.activeCustomer then
                if confirm == "confirm" then
                    lib.showTextUI("### " .. Lang.expected_orders .. text, {
                        position = "left-center",
                        icon = "clipboard"
                    });
                    Barbeque.activeOrder = orders;
                    TaskStandStill(Barbeque.activeCustomer, -1);
                    lib.notify({
                        title = Lang.prepare_orders,
                        type = 'info'
                    });
                    removePedTarget(Barbeque.activeCustomer);
                    addTargetCustomerNpc(Barbeque.activeCustomer, "giveOrder");
                else
                    Barbeque.recognition -= (Config.recognitionDownValue) / 2;
                    cancelCustomerNpc(Barbeque.activeCustomer);
                end
            end
            Animation.stop();
        end,

        give = function(entity)
            local items = Barbeque.activeOrder;
            local isHaveOrder = lib.callback.await('nk:barbeque:removeItemCheck', false, items);
            if isHaveOrder then
                lib.notify({
                    title = Lang.delivered_orders,
                    type = 'success'
                })
                Animation.start("mp_common", "givetake1_a")
                Animation.start("mp_common", "givetake1_a", { ped = Barbeque.activeCustomer, duration = true })
                local totalPrice = 0
                for _i, order in ipairs(Barbeque.activeOrder) do
                    totalPrice += order.price;
                end
                TriggerServerEvent("nk:barbeque:giveMoney", totalPrice);
                cancelCustomerNpc(Barbeque.activeCustomer);
                Barbeque.recognition += Config.recognitionUpValue;
            else
                lib.notify({
                    title = Lang.lack_requirements,
                    type = 'error'
                })
            end
        end
    }
}
