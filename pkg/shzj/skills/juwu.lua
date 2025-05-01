
local juwu = fk.CreateSkill {
  name = "juwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["juwu"] = "拒武",
  [":juwu"] = "锁定技，若一名角色攻击范围内包含至少三名角色，该角色对你使用的普通【杀】无效。",
}

juwu:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juwu.name) and data.card.name == "slash" and data.to == player and
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

return juwu
