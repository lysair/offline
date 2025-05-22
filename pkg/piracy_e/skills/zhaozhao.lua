local zhaozhao = fk.CreateSkill {
  name = "zhaozhao",
}

Fk:loadTranslationTable{
  ["zhaozhao"] = "诏昭",
  [":zhaozhao"] = "当你造成或受到1点伤害后，你可以摸一张牌，然后令伤害来源或受伤角色选择一项：1.从弃牌堆或场上获得一张装备牌并使用之，"..
  "此牌置于一个额外装备栏；2.翻面并摸一张牌；3.减1点体力上限。",

  ["#zhaozhao-choose"] = "诏昭：令你或对方选择一项",
  ["zhaozhao_equip"] = "从弃牌堆或场上获得一张装备并使用之（置于额外装备栏）",
  ["zhaozhao_turnover"] = "翻面并摸一张牌",
  ["#zhaozhao-ask"] = "诏昭：获得一张装备牌，然后使用之",
}

local spec = {
  anim_type = "offensive",
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, zhaozhao.name)
    if player.dead then return end
    local targets = {}
    if not data.to.dead then
      table.insert(targets, data.to)
    end
    if data.from and not data.from.dead then
      table.insert(targets, data.from)
    end
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zhaozhao.name,
      prompt = "#zhaozhao-choose",
      cancelable = false,
    })[1]
    local card_data = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if #p:getCardIds("e") > 0 then
        table.insert(card_data, {p.general, p:getCardIds("e")})
      end
    end
    local cards = table.filter(room.discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
    if #cards > 0 then
      table.insert(card_data, {"pile_discard", cards})
    end
    local all_choices = {
      "zhaozhao_equip",
      "zhaozhao_turnover",
      "loseMaxHp",
    }
    local choices = table.simpleClone(all_choices)
    if #card_data == 0 then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(to, {
      choices = choices,
      skill_name = zhaozhao.name,
      all_choices = all_choices,
    })
    if choice == "zhaozhao_equip" then
      local card = room:askToChooseCard(to, {
        target = to,
        flag = { card_data = card_data },
        skill_name = zhaozhao.name,
        prompt = "#zhaozhao-ask",
      })
      room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonPrey, zhaozhao.name, nil, true, to)
      if to.dead or not table.contains(to:getCardIds("h"), card) or Fk:getCardById(card).type ~= Card.TypeEquip then return end
      card = Fk:getCardById(card)
      local slot = Util.convertSubtypeAndEquipSlot(card.sub_type)
      table.insert(to.equipSlots, 1, slot)
      local yes = to:canUseTo(card, to)
      table.remove(to.equipSlots, 1)
      if yes then
        room:addPlayerEquipSlots(to, slot)
        room:setCardMark(card, zhaozhao.name, 1)
        room:useCard{
          from = to,
          tos = {to},
          card = card,
        }
      end
    elseif choice == "zhaozhao_turnover" then
      to:turnOver()
      if not to.dead then
        to:drawCards(1, zhaozhao.name)
      end
    elseif choice == "loseMaxHp" then
      room:changeMaxHp(to, -1)
    end
  end,
}

zhaozhao:addEffect(fk.Damage, spec)
zhaozhao:addEffect(fk.Damaged, spec)

zhaozhao:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId):getMark(zhaozhao.name) > 0 then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            local card = Fk:getCardById(info.cardId)
            if card:getMark(zhaozhao.name) > 0 then
              room:setCardMark(card, zhaozhao.name, 0)
              local slot = Util.convertSubtypeAndEquipSlot(card.sub_type)
              room:removePlayerEquipSlots(player, slot)
            end
          end
        end
      end
    end
  end,
})

return zhaozhao
