Config = {}

Config.target = "qb" -- or "ox"

Config.Foods = {
    {
        name = "Steak",
        item = "steak_food",
        prop = "prop_cs_steak",
        metarials = {
            { label = "Et", item = "steak", value = 1 },
            { label = "Yağ", item = "oil", value = 1 }
        },
        -- skillBarImg = "", -- in nakres_skill_minigame ui/img
        -- description = "",
        -- icon = ""
    },
    {
        name = "Hotdog",
        item = "hotdog_food",
        prop = "prop_cs_hotdog_01",
        metarials = {
            { label = "Et", item = "steak", value = 1 },
            { label = "Yağ", item = "oil", value = 1 }
        },
        -- skillBarImg = "", -- in nakres_skill_minigame ui/img
        -- description = "",
        -- icon = ""
    },
    {
        name = "Burger",
        item = "burger_food",
        prop = "prop_cs_burger_01",
        metarials = {
            { label = "Et", item = "steak", value = 1 },
            { label = "Yağ", item = "oil", value = 1 }
        },
        skillBarImg = "img/burger.webp", -- in nakres_skill_minigame ui/img
        -- description = "",
        -- icon = ""
    },
}
