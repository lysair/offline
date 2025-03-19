local qianjing = fk.CreateSkill {
  name = "qianjing"
}

Fk:loadTranslationTable{
  ['qianjing'] = '潜荆',
  ['#qianjing'] = '潜荆：选择你的一张【刑鞭】当【杀】使用（或先指定【杀】的目标，再选择一名角色场上的一张【刑鞭】）',
  ['#qianjing_use-choose'] = '潜荆：选择一名角色，将其场上的【刑鞭】当【杀】使用',
  ['#qianjing_use-card'] = '潜荆：选择 %dest 场上一张【刑鞭】当【杀】使用',
  ['#qianjing_trigger'] = '潜荆',
  ['qianjing_active'] = '潜荆',
  ['#qianjing-put'] = '潜荆：你可以将手牌中一张【刑鞭】置入一名角色任意装备栏，若为你则摸一张牌',
  [':qianjing'] = '当你造成或受到伤害后，你可以将手牌中一张<a href=>【刑鞭】</a>置于一名角色的任意一个装备栏，若为你则摸一张牌。你可以将场上或手牌中的一张【刑鞭】当不计入次数的【杀】使用。',
}

qianjing:addEffect('viewas', {
  pattern = "slash",
  anim_type = "offensive",
  prompt = "#qianjing",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).name == "caning_whip"
  end,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("slash")
    if #cards == 1 then
      card:addSubcards(cards)
    end
    card.skillName = qianjing.name
    return card
  end,
  before_use = function(self, player, use)
    if #use.card.subcards == 0 then
      local room = player.room
      local targets = table.map(table.filter(room.alive_players, function(p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end) end), Util.IdMapper)
      if #targets == 0 then return "" end
      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#qianjing_use-choose",
        skill_name = qianjing.name,
        cancelable = false,
      })
      if #to == 0 then return "" end
      to = room:getPlayerById(to[1])
      local cards = table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
      if #cards == 1 then
        use.card:addSubcard(cards[1])
      else
        local card = room:askToChooseCardsAndPlayers(player, {
          min_card_num = 1,
          max_card_num = 1,
          targets = cards,
          min_target_num = 0,
          max_target_num = 0,
          pattern = "caning_whip",
          prompt = "#qianjing_use-card::"..to.id,
          skill_name = qianjing.name,
        })
        use.card:addSubcard(card[2][1])
      end
    end
    use.extraUse = true
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

qianjing:addEffect(fk.Damage + fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(qianjing) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askToUseActiveSkill(player, {
      skill_name = "qianjing_active",
      prompt = "#qianjing-put",
      cancelable = true,
      extra_data = nil,
      no_indicate = false,
    })
    if success and dat then
      event:setCostData(self, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    local mapper = {
      ["WeaponSlot"] = "weapon",
      ["ArmorSlot"] = "armor",
      ["OffensiveRideSlot"] = "offensive_horse",
      ["DefensiveRideSlot"] = "defensive_horse",
      ["TreasureSlot"] = "treasure",
    }
    room:setCardMark(card, "@caning_whip", Fk:translate(mapper[event:getCostData(self).interaction]))
    Fk.printed_cards[event:getCostData(self).cards[1]].sub_type = Util.convertSubtypeAndEquipSlot(event:getCostData(self).interaction)
    local to = room:getPlayerById(event:getCostData(self).targets[1])
    room:moveCardIntoEquip(to, event:getCostData(self).cards, "qianjing", false, player)
    if to == player and not player.dead then
      player:drawCards(1, qianjing.name)
    end
  end,
})

return qianjing
