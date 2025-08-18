local qianjing = fk.CreateSkill {
  name = "qianjing",
}

Fk:loadTranslationTable{
  ["qianjing"] = "潜荆",
  [":qianjing"] = "当你造成或受到伤害后，你可以将手牌中一张<a href=':caning_whip'>【刑鞭】</a>置于一名角色的任意一个装备栏，若为你则摸一张牌。"..
  "你可以将场上或手牌中的一张【刑鞭】当不计入次数的【杀】使用。",

  ["#qianjing-put"] = "潜荆：你可以将手牌中一张【刑鞭】置入一名角色任意装备栏，若为你则摸一张牌",
  ["#qianjing"] = "潜荆：将一张【刑鞭】当【杀】使用（或先指定【杀】的目标，再选择一名角色场上的一张【刑鞭】）",
  ["#qianjing_use-choose"] = "潜荆：选择一名角色，将其场上的【刑鞭】当【杀】使用",
  ["#qianjing_use-card"] = "潜荆：选择 %dest 场上一张【刑鞭】当【杀】使用",
}

qianjing:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
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
      local targets = table.filter(room.alive_players, function(p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end) ~= nil
      end)
      if #targets == 0 then return qianjing.name end
      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#qianjing_use-choose",
        skill_name = qianjing.name,
        cancelable = false,
      })[1]
      local cards = table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
      if #cards == 1 then
        use.card:addSubcard(cards[1])
      else
        local card = room:askToChooseCard(player, {
          target = to,
          flag = { card_data = {{ to.general, cards }} },
          skill_name = qianjing.name,
          prompt = "#qianjing_use-card::"..to.id,
        })
        use.card:addSubcard(card)
      end
    end
    use.extraUse = true
  end,
  enabled_at_response = function (self, player, response)
    if response then return end
    if table.find(table.connect(player:getHandlyIds()), function (id)
      return Fk:getCardById(id).name == "caning_whip"
    end) then
      return true
    end
    return table.find(Fk:currentRoom().alive_players, function(p)
      return table.find(p:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end) ~= nil
    end)
  end,
})

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(qianjing.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "qianjing_active",
      prompt = "#qianjing-put",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {tos = dat.targets, cards = dat.cards, interaction = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    local type = event:getCostData(self).interaction
    local mapper = {
      ["WeaponSlot"] = "weapon",
      ["ArmorSlot"] = "armor",
      ["OffensiveRideSlot"] = "offensive_horse",
      ["DefensiveRideSlot"] = "defensive_horse",
      ["TreasureSlot"] = "treasure",
    }
    room:setCardMark(card, "@caning_whip", Fk:translate(mapper[type]))
    if Fk.printed_cards[card.id] then
      Fk.printed_cards[card.id].sub_type = Util.convertSubtypeAndEquipSlot(type)
    else
      Fk.cards[card.id].sub_type = Util.convertSubtypeAndEquipSlot(type)
    end
    local to = event:getCostData(self).tos[1]
    room:moveCardIntoEquip(to, card.id, qianjing.name, false, player)
    if to == player and not player.dead then
      player:drawCards(1, qianjing.name)
    end
  end,
}

qianjing:addEffect(fk.Damage, spec)
qianjing:addEffect(fk.Damaged, spec)

qianjing:addAI(nil, "vs_skill")

return qianjing
