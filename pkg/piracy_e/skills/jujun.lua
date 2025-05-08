local jujun = fk.CreateSkill {
  name = "jujun",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["jujun"] = "聚军",
  [":jujun"] = "限定技，出牌阶段，你可以将手牌和体力补至体力上限，若如此做，你不能回复体力直到你杀死一名角色。",

  ["#jujun"] = "聚军：将手牌和体力补至体力上限，不能回复体力直到杀死角色",
}

jujun:addEffect("active", {
  anim_type = "control",
  prompt = "#jujun",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(jujun.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    if player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum(), jujun.name)
      if player.dead then return end
    end
    if player.hp < player.maxHp then
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = jujun.name,
      }
      if player.dead then return end
    end
    room:setPlayerMark(player, jujun.name, 1)
  end,
})

jujun:addEffect(fk.PreHpRecover, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(jujun.name) > 0
  end,
  on_use = function(self, event, target, player, data)
    data.prevented = true
  end,
})

jujun:addEffect(fk.Deathed, {
  can_refresh = function(self, event, target, player, data)
    return data.killer == player
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, jujun.name, 0)
  end,
})

return jujun
