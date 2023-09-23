Config = {}

Config.target = "qb"              -- or "ox"

Config.BBQprop = { "prop_bbq_5" } -- if false onlySpawnBBQ

Config.recognitionUpValue = 5

Config.recognitionDownValue = 2

Config.Foods = { {
    name = "Steak",
    item = "steak_food",
    price = 250,
    prop = "prop_cs_steak",
    itemImg = "",
    weight = 5,
    -- description = "",
    -- icon = ""
    metarials = { {
        label = "Et",
        item = "raw_meat",
        value = 1,
        description = "Pişmeyi bekleyen et"
    }, {
        label = "Yağ",
        item = "food_oil",
        value = 1,
        description = "Yemek yapmada kullanılacak yağ"
    } },
    skillBarData = {
        -- difficultyFactor = 0.98,
        lineSpeedUp = 1,
        time = 15,
        valueUpSpeed = 0.5,
        valueDownSpeed = 0.3,
        areaMoveSpeed = 0.5
        -- img = "img/burger.webp",
    }
}, {
    name = "Hotdog",
    item = "hotdog_food",
    price = 250,
    prop = "prop_cs_hotdog_01",
    itemImg = "",
    weight = 5,
    -- description = "",
    -- icon = ""
    metarials = { {
        label = "Et",
        item = "raw_meat",
        value = 1,
        description = "Yemek yapmada kullanılacak yağ"
    }, {
        label = "Yağ",
        item = "food_oil",
        value = 1,
        description = "Yemek yapmada kullanılacak yağ"
    } },
    skillBarData = {
        -- difficultyFactor = 0.98,
        lineSpeedUp = 1,
        time = 15,
        valueUpSpeed = 0.5,
        valueDownSpeed = 0.3,
        areaMoveSpeed = 0.5
        -- img = "img/burger.webp",
    }
}, {
    name = "Burger",
    item = "burger_food",
    price = 250,
    prop = "prop_cs_burger_01",
    itemImg = "",
    weight = 5,
    -- description = "",
    -- icon = ""
    metarials = { {
        label = "Et",
        item = "raw_meat",
        value = 1,
        description = "Yemek yapmada kullanılacak yağ"
    }, {
        label = "Yağ",
        item = "food_oil",
        value = 1,
        description = "Yemek yapmada kullanılacak yağ"
    } },
    skillBarData = {
        -- difficultyFactor = 0.98,
        lineSpeedUp = 1,
        time = 15,
        valueUpSpeed = 0.5,
        valueDownSpeed = 0.3,
        areaMoveSpeed = 0.5,
        img = "img/burger.webp"
    }
} }
