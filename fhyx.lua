local extension = Package("fhyx")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["fhyx"] = "线下-飞鸿映雪",
}

Fk:loadTranslationTable{
  ["ofl__bianfuren"] = "卞夫人",
  ["ofl__fuding"] = "抚定",
  [":ofl__fuding"] = "每轮限一次，当一名其他角色进入濒死状态时，你可以交给其至多五张牌，若如此做，当其脱离濒死状态时，你摸等量牌并回复1点体力。",
  ["ofl__yuejian"] = "约俭",
  [":ofl__yuejian"] = "你的手牌上限+X（X为你的体力上限）。当你需使用一张基本牌时，若你本轮未使用过基本牌，你可以视为使用之。",
}

Fk:loadTranslationTable{
  ["ofl__chenzhen"] = "陈震",
  ["ofl__shameng"] = "歃盟",
  [":ofl__shameng"] = "出牌阶段限一次，你可以展示至多两张手牌，然后令一名其他角色展示至多两张手牌，若如此做，你可以弃置这些牌，你摸等同于其中"..
  "花色数的牌，令该角色摸等同于其中类别数的牌。",
}

Fk:loadTranslationTable{
  ["ofl__sunshao"] = "孙邵",
  ["ofl__dingyi"] = "定仪",
  [":ofl__dingyi"] = "每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。有“定仪”牌的角色根据花色"..
  "获得对应效果：<br>♠，手牌上限+4；<br><font color='red'>♥</font>，每回合首次脱离濒死状态时，回复2点体力；♣，使用牌无距离限制；"..
  "<font color='red'>♦</font>，摸牌阶段多摸两张牌。",
  ["ofl__zuici"] = "罪辞",
  [":ofl__zuici"] = "当你受到伤害后，你可以获得一名角色的“定仪”牌，然后你从额外牌堆选择一张智囊牌令其获得。",
}

Fk:loadTranslationTable{
  ["ofl__luotong"] = "骆统",
  ["ofl__minshi"] = "定仪",
  [":ofl__minshi"] = "出牌阶段限一次，你可以选择所有手牌数少于体力值的角色并观看额外牌堆中至多三张基本牌，然后你可以依次将其中任意张牌"..
  "交给任意角色。然后你选择的角色中每有一名未获得牌的角色，你失去1点体力。",
  ["ofl__xianming"] = "显名",
  [":ofl__xianming"] = "每回合限一次，当额外牌堆中失去最后一张基本牌时，你可以摸两张牌并回复1点体力。",
}
--[[local goddianwei = General(extension, "ofl__goddianwei", "god", 4)
local juanjia = fk.CreateTriggerSkill{
  name = "juanjia",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GamePrepared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0 then
      room:abortPlayerArea(player, {Player.ArmorSlot})
    end
    table.insert(player.equipSlots, 2, Player.WeaponSlot)
  end,
}
goddianwei:addSkill(juanjia)]]--
Fk:loadTranslationTable{
  ["ofl__goddianwei"] = "神典韦",
  ["juanjia"] = "捐甲",
  [":juanjia"] = "锁定技，游戏开始时，废除你的防具栏，然后你获得一个额外的武器栏。",
  ["cuijue"] = "摧决",
  [":cuijue"] = "出牌阶段对每名角色限一次，你可以弃置一张牌，对攻击范围内距离最远的一名其他角色造成1点伤害。",
}

return extension
