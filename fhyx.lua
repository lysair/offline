local extension = Package("fhyx")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["fhyx"] = "线下-飞鸿映雪",
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
