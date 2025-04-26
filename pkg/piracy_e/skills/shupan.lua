local shupan = fk.CreateSkill {
  name = "ofl__shupan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__shupan"] = "述叛",
  [":ofl__shupan"] = "限定技，出牌阶段，你可以选择两名其他角色：展示第一名角色的所有手牌，你与第二名角色各摸三张牌，然后其对第一名角色"..
  "依次使用手牌中所有伤害牌；这两名角色互相使用牌无次数限制直到游戏结束。",

  ["#ofl__shupan"] = "述叛：选择两名角色，展示第一名角色的手牌，你与第二名角色各摸三张牌，然后后者对前者使用伤害牌！",
  ["@@ofl__shupan"] = "述叛",
}

shupan:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__shupan",
  card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(shupan.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 1 or to_select == player then return end
    if #selected == 0 then
      return not to_select:isKongcheng()
    elseif #selected == 1 then
      return true
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    return #selected == 2 and not selected[1]:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target1 = effect.tos[1]
    local target2 = effect.tos[2]
    target1:showCards(target1:getCardIds("h"))
    if not player.dead then
      player:drawCards(3, shupan.name)
    end
    if not target2.dead then
      target2:drawCards(3, shupan.name)
    end
    if target1.dead or target2.dead then return end
    room:addTableMarkIfNeed(target1, "@@ofl__shupan", target2.id)
    room:addTableMarkIfNeed(target2, "@@ofl__shupan", target1.id)
    local cards = table.filter(target2:getCardIds("h"), function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    while not target1.dead and not target2.dead do
      cards = table.filter(cards, function (id)
        local card = Fk:getCardById(id)
        return table.contains(target2:getCardIds("h"), id) and card.is_damage_card and
          table.contains(card:getAvailableTargets(target2, {bypass_distances = true, bypass_times = true}), target1)
      end)
      if #cards > 0 then
        local card = Fk:getCardById(cards[1])
        table.remove(cards, 1)
        room:useCard{
          from = target2,
          tos = {target1},
          card = card,
        }
      else
        break
      end
    end
  end,
})

shupan:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(player:getTableMark("@@ofl__shupan"), to.id)
  end,
})

shupan:addEffect(fk.Death, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__shupan") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:removeTableMark(p, "@@ofl__shupan", player.id)
    end
  end,
})

return shupan
