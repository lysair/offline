
local shouxiang = fk.CreateSkill {
  name = "shzj_guansuo__shouxiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_guansuo__shouxiang"] = "守襄",
  [":shzj_guansuo__shouxiang"] = "锁定技，攻击范围内包含至少三名角色的角色使用的普通【杀】对你无效。",
}

shouxiang:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shouxiang.name) and data.card.name == "slash" and data.to == player and
      not data.from.dead and #table.filter(player.room.alive_players, function(p)
        return data.from:inMyAttackRange(p)
      end) > 2
  end,
  on_use = function (self, event, target, player, data)
    player.room:broadcastPlaySound("./packages/standard_cards/audio/card/nioh_shield")
    player.room:setEmotion(player, "./packages/standard_cards/image/anim/nioh_shield")
    data.nullified = true
  end,
})

return shouxiang
