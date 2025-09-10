local dangxian = fk.CreateSkill {
  name = "shzj_juedai__dangxian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_juedai__dangxian"] = "当先",
  [":shzj_juedai__dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段并从弃牌堆获得一张【杀】。你于非额定出牌阶段使用牌无距离限制。",

  ["#shzj_juedai__dangxian-prey"] = "当先：获得一张【杀】",

  ["$shzj_juedai__dangxian1"] = "看老夫如何立下头功！",
  ["$shzj_juedai__dangxian2"] = "让老夫先来！",
}

dangxian:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dangxian.name)
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, dangxian.name)
  end,
})

dangxian:addEffect(fk.EventPhaseStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dangxian.name) and player.phase == Player.Play and
      data.reason ~= "game_rule"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "shzj_juedai__dangxian-phase", 1)
    if data.reason == dangxian.name then
      local cards = table.filter(room.discard_pile, function (id)
        return Fk:getCardById(id).trueName == "slash"
      end)
      if #cards > 0 then
        local card = room:askToChooseCard(player, {
          target = player,
          flag = { card_data = {{ "pile_discard", cards }} },
          skill_name = dangxian.name,
          prompt = "#shzj_juedai__dangxian-prey",
        })
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, dangxian.name, nil, true, player)
      end
    end
  end,
})

dangxian:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(dangxian.name) and player:getMark("shzj_juedai__dangxian-phase") > 0 and card
  end,
})

return dangxian
