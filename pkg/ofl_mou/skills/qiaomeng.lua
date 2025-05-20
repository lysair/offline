local qiaomeng = fk.CreateSkill({
  name = "ofl_mou__qiaomeng",
})

Fk:loadTranslationTable{
  ["ofl_mou__qiaomeng"] = "趫猛",
  [":ofl_mou__qiaomeng"] = "当你使用【杀】造成伤害后，你可以选择一项：1.摸一张牌，然后弃置其区域内的一张牌；" ..
  "2.亮出牌堆顶四张牌，将其中所有【杀】或【闪】置为“扈”。",

  ["ofl_mou__qiaomeng_discard"] = "摸一张牌，弃置%dest区域内一张牌",
  ["ofl_mou__qiaomeng_gain"] = "亮出牌堆顶四张牌，将其中所有【杀】或【闪】置为“扈”",
}

qiaomeng:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiaomeng.name) and
      data.card and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {
        "ofl_mou__qiaomeng_discard::" .. data.to.id,
        "ofl_mou__qiaomeng_gain",
        "Cancel",
      },
      skill_name = qiaomeng.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice:startsWith("ofl_mou__qiaomeng_discard") then
      player:drawCards(1, qiaomeng.name)
      if player.dead then return end
      if data.to:isAlive() and not data.to:isAllNude() then
        if data.to == player then
          local ids = table.filter(player:getCardIds("hej"), function (id)
            return not player:prohibitDiscard(id)
          end)
          if #ids > 0 then
            ids = room:askToCards(player, {
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = qiaomeng.name,
              pattern = tostring(Exppattern{ id = ids }),
              cancelable = false,
              expand_pile = player:getCardIds("j"),
            })
            room:throwCard(ids, qiaomeng.name, player, player)
          end
        else
          local id = room:askToChooseCard(player, {
            target = data.to,
            flag = "hej",
            skill_name = qiaomeng.name,
          })
          room:throwCard(id, qiaomeng.name, data.to, player)
        end
      end
    else
      local cards = room:getNCards(4)
      room:turnOverCardsFromDrawPile(player, cards, qiaomeng.name)
      if #player:getPile("ofl_mou__yicong_hu&") < 4 then
        local slash = table.filter(cards, function (id)
          return Fk:getCardById(id).trueName == "slash"
        end)
        local jink = table.filter(cards, function (id)
          return Fk:getCardById(id).trueName == "jink"
        end)
        if #slash + #jink > 0 then
          local choices = {}
          if #slash > 0 then
            table.insert(choices, "slash")
          end
          if #jink > 0 then
            table.insert(choices, "jink")
          end
          local choice = room:askToChoice(player, {
            choices = choices,
            skill_name = qiaomeng.name,
          })
          local ids = choice == "slash" and slash or jink
          player:addToPile("ofl_mou__yicong_hu&", table.random(ids, 4 - #player:getPile("ofl_mou__yicong_hu&")), true, qiaomeng.name)
        end
      end
      room:cleanProcessingArea(cards)
    end
  end,
})

return qiaomeng
