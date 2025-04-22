local xiongye = fk.CreateSkill {
  name = "ofl__xiongye",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["ofl__xiongye"] = "凶业",
  [":ofl__xiongye"] = "主公技，出牌阶段限一次，你可以交给任意名其他群势力角色各一张手牌，然后对这些角色各造成1点伤害。",

  ["#ofl__xiongye"] = "凶业：交给任意名群势力角色各一张手牌，然后对这些角色各造成1点伤害",
  ["@DistributionTo"] = "",
}

xiongye:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__xiongye",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xiongye.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and to_select.kingdom == "qun"
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local list = {}
    list[target.id] = effect.cards
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p ~= target and p.kingdom == "qun"
    end)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return id ~= effect.cards[1]
    end)
    room:setCardMark(Fk:getCardById(effect.cards[1]), "@DistributionTo", Fk:translate(target.general))
    while #targets > 0 and #cards > 0 do
      local to, id = room:askToChooseCardsAndPlayers(player, {
        min_num = 1,
        max_num = 1,
        min_card_num = 1,
        max_card_num = 1,
        targets = targets,
        pattern = tostring(Exppattern{ id = cards }),
        prompt = "#ofl__xiongye-choose",
        skill_name = xiongye.name,
        cancelable = true,
      })
      if #to > 0 then
        to = to[1]
        id = id[1]
        table.removeOne(targets, to)
        table.removeOne(cards, id)
        list[to.id] = {id}
        room:setCardMark(Fk:getCardById(id), "@DistributionTo", Fk:translate(to.general))
      else
        break
      end
    end
    for _, id in ipairs(player:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "@DistributionTo", 0)
    end
    targets = {}
    for id, _ in pairs(list) do
      if list[id] then
        table.insert(targets, id)
      end
    end
    room:sortByAction(targets)
    room:doYiji(list, player, xiongye.name)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = xiongye.name,
        }
      end
    end
  end,
})

return xiongye
