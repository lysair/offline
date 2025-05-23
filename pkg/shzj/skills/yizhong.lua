
local yizhong = fk.CreateSkill {
  name = "shzj_xiangfan__yizhong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_xiangfan__yizhong"] = "毅重",
  [":shzj_xiangfan__yizhong"] = "锁定技，若你的装备区里没有防具牌，黑色【杀】对你无效；若你的装备区里没有武器牌，你出牌阶段使用【杀】次数上限+1。",
}

yizhong:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yizhong.name) and data.card.trueName == "slash" and data.to == player and
      data.card.color == Card.Black and #player:getEquipments(Card.SubtypeArmor) == 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:broadcastPlaySound("./packages/standard_cards/audio/card/nioh_shield")
    player.room:setEmotion(player, "./packages/standard_cards/image/anim/nioh_shield")
    data.nullified = true
  end,
})

yizhong:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(yizhong.name) and #player:getEquipments(Card.SubtypeWeapon) == 0 and
      skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end
})

return yizhong
