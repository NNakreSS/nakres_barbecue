<iframe width="974" height="548" src="https://www.youtube.com/embed/_akblmM_ySo" title="NakreS Barbecue" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>


# [TR]

Bu script, FiveM platformunda kullanılmak üzere geliştirilmiş bir BBQ satış sistemini içerir. Bu sistem, oyuncuların barbekü objeleri oluşturmasına, işlerini yönetmelerine ve çevredeki NPC'lerden sipariş alarak yiyecek satmalarına olanak tanır.

### Türkçe Kurulum Kılavuzu

**Bağımlılıklar:**  [nakres_skill_minigame](https://github.com/NNakreSS/nakres_skill_minigame) / [ox_lib](https://github.com/overextended/ox_lib)  / OX veya Qb Target / Esx veya Qb Framework

**Kurulum Adımları:**
1. Ana betik klasörünü sunucunuzun resources dizinine yerleştirin.
2. Betiğin `shared` klasörü içindeki `Config.lua` dosyasını sunucu ayarlarınıza göre güncelleyin.
3. `shared` klasörü altındaki `foods.lua` dosyasına yeni yiyecekleri ekleyin. Aşağıdaki örneği kullanabilirsiniz:

```lua
{
    label = "Biftek",
    item = "biftek",
    price = 250,
    prop = "prop_cs_steak",
    itemImg = "",
    weight = 5,
    description = "Lezzetli bir biftek yediniz",
    icon = Config.tartget == "qb" and "fa-solid fa-drumstick-bite" or "drumstick-bite",
    materials = {
        {
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
        img = "img/biftek.webp",
    }
},
```
> [!NOTE]
> Görselleri uygun şekilde sağladığınızdan ve envanter sisteminizde `foods.lua` içindeki `itemImg` alanını doğru bir şekilde belirttiğinizden emin olun. Tüm itemler otomatik olarak oluşturulacaktır.


> [!IMPORTANT]
> ox-inventory kullanan QB paketleri için itemlerin otomatik olarak oluşturulabilmesi için betiği startladıktan sonra envanteri 2 kere restartlayın. 

## Özellikler

- **Barbekü Objeleri:** Script, oyuncuların barbekü objelerini oluşturmak için `bbq` itemini kullanmalarını sağlar. Bu objeler üzerinden işlemler gerçekleştirilir (başlatma, pişirme, toplama, vb.).

- **Sipariş Sistemi:** Yoldan geçen NPC'lerin tanınırlıklarına göre dikkatlerini çeker ve gelip sizden yiyecek siparişi verebilirler.

- **Tanınırlık Sistemi:** Başarılı satışlar tanınırlığınızı artırırken, sipariş iptalleri ve müşterilere saldırma tanınırlık kaybetmenize neden olabilir. Tanınırlık 0'a yaklaştığında kimse sizden yiyecek almaz.

## Kullanım

1. Oyuna girdikten sonra, barbekü objesini oluşturmak için envanterinizde bulunan `bbq` itemini kullanın.

2. Oluşturduğunuz barbekü objesinin etrafındaki interaktif menüyü kullanmak için sunucuda bulunan `qb-target` veya `ox-target` gibi bir targeting sistemi kullanabilirsiniz.

3. Menü üzerinden işlemleri gerçekleştirin (başlatma, pişirme, toplama, vb.).

4. NPC'lerden gelen siparişleri dikkatlice yönetin ve başarılı satışlar yaparak tanınırlığınızı artırın.

## Notlar

- Scripti kullanırken olası hatalar veya sorunlar için [GitHub](https://github.com/NNakreSS/nakres_barbeque) sayfasını kontrol edin.

- Daha fazla özelleştirme yapmak istiyorsanız, scriptin kaynak kodunu inceleyebilir ve ihtiyacınıza göre düzenleyebilirsiniz.

Bu README dosyası, BBQ satış scripti kullanımı hakkında temel bilgileri içermektedir. Daha fazla bilgi ve detaylar için scriptin kaynak kodunu inceleyebilirsiniz.

# [EN]

This script contains an advanced BBQ sales system developed for use on the FiveM platform. This system allows players to create barbecue objects, manage their business, and sell food by taking orders from nearby NPCs.

## English Installation Guide

**Dependencies:**  [nakres_skill_minigame](https://github.com/NNakreSS/nakres_skill_minigame) / [ox_lib](https://github.com/overextended/ox_lib)  / OX or Qb Target / Esx or Qb Framework

**Installation Steps:**
1. Place the main script folder in the resources directory of your server.
2. Inside the `shared` folder of the script, update the `Config.lua` file according to your server settings.
3. Add new food items in the `foods.lua` file located under the `shared` folder. You can use the following example:

    ```lua
    {
        label = "Steak",
        item = "steak",
        price = 250,
        prop = "prop_cs_steak",
        itemImg = "",
        weight = 5,
        description = "You ate a delicious Steak",
        icon = Config.tartget == "qb" and "fa-solid fa-drumstick-bite" or "drumstick-bite",
        materials = {
            {
                label = "Meat",
                item = "raw_meat",
                value = 1,
                description = "Raw meat waiting to be cooked",
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
    ```
> [!NOTE]
> Ensure you provide appropriate visuals for the items, and specify the image name in your inventory system using the `itemImg` field in `foods.lua`.
  All items will be automatically generated.

> [!IMPORTANT]
> For QB packages using ox-inventory, after starting the script, restart the inventory twice to automatically generate items.


## Features

- **Barbecue Objects:** The script allows players to use the `bbq` item to create barbecue objects. Various actions can be performed on these objects (start, cook, collect, etc.).

- **Order System:** Attracts the attention of passing NPCs based on their recognition level, and they may come to place food orders.

- **Recognition System:** Successful sales increase your recognition, while order cancellations and attacking customers may cause you to lose recognition. When your recognition approaches 0, nobody will buy food from you.

## Usage

1. After entering the game, use the `bbq` item in your inventory to create the barbecue object.

2. To access the interactive menu around the created barbecue object, you can use a targeting system such as `qb-target` or `ox-target` available on the server.

3. Perform actions through the menu (start, cook, collect, etc.).

4. Manage orders from NPCs carefully, making successful sales to increase your recognition.

## Notes

- Check the [GitHub](https://github.com/NNakreSS/nakres_barbeque) page for possible errors or issues while using the script.

- If you want to customize the script further, you can examine the source code and make modifications according to your needs.

This README file provides basic information about using the BBQ sales script. For more details and information, you can explore the source code of the script.
