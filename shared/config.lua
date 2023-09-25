Config = {}

Config.LANGUAGE = 'EN'            --EN/TR

Config.target = "ox"              --"qb"  or  "ox"

Config.inventory = "qb"           --"qb" / "ox" / "esx"

Config.framework = "qb"           --"qb" or "esx"

Config.BBQprop = { "prop_bbq_5" } -- if false onlySpawnBBQ

Config.BBQitemName = "bbq_prop"

Config.recognitionUpValue = 5

Config.recognitionDownValue = 2

Config.Foods = {
    {
        label = "Steak",
        item = "steak",
        price = 250,
        prop = "prop_cs_steak",
        itemImg = "",
        weight = 5,
        description = "You ate a delicious Steak",
        icon = Config.tartget == "qb" and "fa-solid fa-drumstick-bite" or "drumstick-bite",
        metarials = { {
            label = "Et",
            item = "raw_meat",
            value = 1,
            description = "Pişmeyi bekleyen et",
            itemImg = ""
        }
        },
        skillBarData = {
            difficultyFactor = 0.98,
            lineSpeedUp = 1,
            time = 15,
            valueUpSpeed = 0.5,
            valueDownSpeed = 0.3,
            areaMoveSpeed = 0.5,
            img = "img/steak.webp",
        }
    },
    {
        label = "Hotdog",
        item = "hotdog",
        price = 250,
        prop = "prop_cs_hotdog_01",
        itemImg = "",
        weight = 5,
        description = "You ate a delicious Hotdog",
        icon = Config.tartget == "qb" and "fa-solid fa-hotdog" or "hotdog",
        metarials = {
            {
                label = "Et",
                item = "raw_sausage",
                value = 1,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = "",
            },
            {
                label = "Yağ",
                item = "food_oil",
                value = 1,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = ""
            },
            {
                label = "Sosisli ekmeği",
                item = "hotdog_bun",
                value = 2,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = ""
            },
        },
        skillBarData = {
            difficultyFactor = 0.98,
            lineSpeedUp = 1,
            time = 15,
            valueUpSpeed = 0.5,
            valueDownSpeed = 0.3,
            areaMoveSpeed = 0.5,
            img = "img/hotdog.webp",
        }
    },
    {
        label = "Burger",
        item = "burger",
        price = 250,
        prop = "prop_cs_burger_01",
        itemImg = "",
        weight = 5,
        description = "You ate a delicious Burger",
        icon = Config.tartget == "qb" and "fa-solid fa-burger" or "burger",
        metarials = {
            {
                label = "Et",
                item = "raw_meat",
                value = 1,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = "",

            },
            {
                label = "Yağ",
                item = "food_oil",
                value = 1,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = ""

            },
            {
                label = "Burger Ekmeği",
                item = "burger_bun",
                value = 2,
                description = "Yemek yapmada kullanılacak yağ",
                itemImg = ""

            },
        },
        skillBarData = {
            difficultyFactor = 0.98,
            lineSpeedUp = 1,
            time = 15,
            valueUpSpeed = 0.5,
            valueDownSpeed = 0.3,
            areaMoveSpeed = 0.5,
            img = "img/burger.webp"
        }
    } }
