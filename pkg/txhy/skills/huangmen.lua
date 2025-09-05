local huangmen = fk.CreateSkill {
  name = "ofl_tx__huangmen",
}

Fk:loadTranslationTable{
  ["ofl_tx__huangmen"] = "黄门",
  [":ofl_tx__huangmen"] = "准备阶段或结束阶段，若你没有手牌，你选择一项：1.摸两张牌；2.获得一名敌方角色的一张牌。",

  ["#ofl_tx__huangmen-choose"] = "黄门：获得一名敌方角色一张牌，或点“取消”摸两张牌",
}

huangmen:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huangmen.name) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      player:isKongcheng()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:isEnemy(player) and not p:isNude()
    end)
    if #targets == 0 then
      player:drawCards(2, huangmen.name)
    else
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = huangmen.name,
        prompt = "#ofl_tx__huangmen-choose",
        cancelable = true,
      })
      if #to > 0 then
        to = to[1]
        local card = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = huangmen.name,
        })
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, huangmen.name, nil, false, player)
      else
        player:drawCards(2, huangmen.name)
      end
    end
  end,
})

return huangmen
