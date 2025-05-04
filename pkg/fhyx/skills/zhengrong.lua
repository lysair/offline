local zhengrong = fk.CreateSkill {
  name = "fhyx__zhengrong",
  tags = { Skill.Switch, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fhyx__zhengrong"] = "征荣",
  [":fhyx__zhengrong"] = "转换技，锁定技，游戏开始时，你将牌堆顶一张牌置于武将牌上，称为“荣”。当你于出牌阶段对其他角色使用牌结算后，"..
  "阳：你选择任意张手牌替换等量的“荣”；阴：你将一名其他角色的一张牌置为“荣”。",

  ["$fhyx__glory"] = "荣",
  ["#fhyx__zhengrong-exchange"] = "征荣：选择任意张手牌替换等量的“荣”",
  ["#fhyx__zhengrong-choose"] = "征荣：将一名其他角色的一张牌置为“荣”",
}

zhengrong:addEffect(fk.GameStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(zhengrong.name)
  end,
  on_use = function (self, event, target, player, data)
    player:addToPile("$fhyx__glory", player.room:getNCards(1), false, zhengrong.name, player)
  end,
})

zhengrong:addEffect(fk.CardUseFinished, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zhengrong.name) and player.phase == Player.Play and
      table.find(data.tos, function (p)
        return p ~= player
      end) then
      if player:getSwitchSkillState(zhengrong.name, false) == fk.SwitchYang then
        return not player:isKongcheng() and #player:getPile("$fhyx__glory") > 0
      else
        return table.find(player.room:getOtherPlayers(player, false), function (p)
          return not p:isNude()
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(zhengrong.name, true) == fk.SwitchYang then
      local cards = room:askToArrangeCards(player, {
        skill_name = zhengrong.name,
        card_map = {player:getPile("$fhyx__glory"), player:getCardIds("h")},
        prompt = "#fhyx__zhengrong-exchange",
        free_arrange = true,
      })
      room:swapCardsWithPile(player, cards[1], cards[2], zhengrong.name, "$fhyx__glory")
    else
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return not p:isNude()
      end)
      local to = room:askToChoosePlayers(player, {
        skill_name = zhengrong.name,
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#fhyx__zhengrong-choose",
        cancelable = false,
      })[1]
      local card = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = zhengrong.name
      })
      player:addToPile("$fhyx__glory", card, false, zhengrong.name, player)
    end
  end,
})

return zhengrong
