local daihan = fk.CreateSkill {
  name = "ofl_tx__daihan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__daihan"] = "代汉",
  [":ofl_tx__daihan"] = "锁定技，当你受到伤害后，你展示所有手牌，伤害来源选择一项：1.交给你一张你手牌中拥有的牌名的牌；"..
  "2.令你回复X点体力并结束当前回合（X为其体力上限）。",

  ["#ofl_tx__daihan-ask"] = "代汉：交给 %src 一张其拥有的牌，否则其回复%arg点体力并结束当前回合",
}

daihan:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(daihan.name) and
      not player:isKongcheng() and data.from and not data.from.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local names = table.map(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName
    end)
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    if data.from ~= player then
      local card = room:askToCards(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = daihan.name,
        pattern = table.concat(names, ","),
        prompt = "#ofl_tx__daihan-ask:"..player.id.."::"..data.from.maxHp,
        cancelable = true,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, daihan.name, nil, true, data.from)
        return
      end
    end
    room:recover{
      who = player,
      num = data.from.maxHp,
      recoverBy = player,
      skillName = daihan.name,
    }
    room:endTurn()
  end,
})

return daihan
