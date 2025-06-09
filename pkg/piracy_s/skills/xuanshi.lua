local xuanshi = fk.CreateSkill {
  name = "ofl__xuanshi",
}

Fk:loadTranslationTable{
  ["ofl__xuanshi"] = "旋势",
  [":ofl__xuanshi"] = "出牌阶段限两次，若你的手牌中黑色牌和红色牌数量相同，你可以展示手牌，然后获得一名其他角色的一张牌。",

  ["#ofl__xuanshi"] = "旋势：你可以展示手牌，获得一名其他角色的一张牌",
  ["#ofl__xuanshi-choose"] = "旋势：选择一名角色，获得其一张牌",
  ["#ofl__xuanshi-prey"] = "旋势：获得 %dest 一张牌",
}

xuanshi:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__xuanshi",
  card_num = 0,
  target_num = 0,
  times = function(self, player)
    return player.phase == Player.Play and 2 - player:usedSkillTimes(xuanshi.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(xuanshi.name, Player.HistoryPhase) < 2 and
      not player:isKongcheng() and
      #table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).color == Card.Red
      end) == #table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).color == Card.Black
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isNude()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__xuanshi-choose",
      skill_name = xuanshi.name,
      cancelable = false,
    })
    to = to[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = xuanshi.name,
      prompt = "#ofl__xuanshi-prey::"..to.id,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, xuanshi.name, nil, false, player)
  end,
})

return xuanshi
