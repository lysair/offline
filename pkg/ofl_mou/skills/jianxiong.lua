local jianxiong = fk.CreateSkill({
  name = "ofl_mou__jianxiong",
})

Fk:loadTranslationTable{
  ["ofl_mou__jianxiong"] = "奸雄",
  [":ofl_mou__jianxiong"] = "游戏开始时，你可以获得至多两枚“治世”标记。当你受到伤害后，你可以获得对你造成伤害的牌并摸2-X张牌，"..
  "然后你可以移除1枚“治世”（X为“治世”的数量）。",

  ["$ofl_mou__jianxiong1"] = "恨其才不为我所用，宁杀之亦胜入他人之手！",
  ["$ofl_mou__jianxiong2"] = "兵行错役之制，可绝负我之人！",
}

jianxiong:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jianxiong.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = room:askToNumber(player, {
      skill_name = jianxiong.name,
      prompt = "#mou__jianxiong-gamestart",
      min = 1,
      max = 2,
      cancelable = true,
    })
    if n then
      event:setCostData(self, {choice = n})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player,  "@mou__jianxiong", event:getCostData(self).choice)
  end,
})

jianxiong:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianxiong.name) and
      ((data.card and player.room:getCardArea(data.card) == Card.Processing) or player:getMark("@mou__jianxiong") == 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card and room:getCardArea(data.card) == Card.Processing then
      room:moveCardTo(data.card, Player.Hand, player, fk.ReasonPrey, jianxiong.name)
      if player.dead then return end
    end
    local num = 2 - player:getMark("@mou__jianxiong")
    if num > 0 then
      player:drawCards(num, jianxiong.name)
    end
    if player:getMark("@mou__jianxiong") > 0 and
      room:askToSkillInvoke(player, {
        skill_name = jianxiong.name,
        prompt = "#mou__jianxiong-dismark",
      }) then
      room:removePlayerMark(player, "@mou__jianxiong", 1)
    end
  end,
})

return jianxiong
