local xiongye = fk.CreateSkill {
  name = "ofl__xiongye$"
}

Fk:loadTranslationTable{
  ['#ofl__xiongye'] = '交给任意名群势力角色各一张手牌，然后对这些角色各造成1点伤害（先选择一张牌和一名目标）',
  ['@DistributionTo'] = '',
  ['#ofl__xiongye-choose'] = '凶业：是否继续选择目标？',
}

xiongye:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiongye",
  can_use = function(self, player)
    return player:usedSkillTimes(xiongye.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id and Fk:currentRoom():getPlayerById(to_select).kingdom == "qun"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local list = {}
    list[target.id] = effect.cards
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function (p)
      return p ~= target and p.kingdom == "qun"
    end), Util.IdMapper)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return id ~= effect.cards[1]
    end)
    room:setCardMark(Fk:getCardById(effect.cards[1]), "@DistributionTo", Fk:translate(target.general))
    while #targets > 0 and #cards > 0 do
      local to, id = room:askToChooseCardsAndPlayers(player, {
        min_card_num = 1,
        max_card_num = 1,
        targets = table.map(targets, Util.IdMapper),
        pattern = tostring(Exppattern{ id = cards }),
        prompt = "#ofl__xiongye-choose",
        skill_name = xiongye.name,
        cancelable = true
      })
      if #to > 0 then
        table.removeOne(targets, to[1])
        table.removeOne(cards, id)
        list[to[1]] = {id}
        room:setCardMark(Fk:getCardById(id), "@DistributionTo", Fk:translate(room:getPlayerById(to[1]).general))
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
    room:sortPlayersByAction(targets)
    room:doYiji(list, player.id, xiongye.name)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
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
