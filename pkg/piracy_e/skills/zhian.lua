local zhian = fk.CreateSkill {
  name = "ofl__zhian",
}

Fk:loadTranslationTable{
  ["ofl__zhian"] = "治暗",
  [":ofl__zhian"] = "每回合限X次，当一名角色使用的非基本牌结算结束后，你可以选择一项：<br>"..
  "1.弃置一张手牌，获得场上或弃牌堆中的此牌；<br>"..
  "2.回复1点体力，此技能本轮失效；<br>"..
  "3.对其造成X点伤害，你获得〖飞影〗并删去此项（X为你已损失体力值，至少为1）。",

  ["ofl__zhian1"] = "弃一张手牌，从场上或弃牌堆获得%arg",
  ["ofl__zhian2"] = "回复1点体力，“治暗”本轮失效",
  ["ofl__zhian3"] = "对%dest造成%arg点伤害，获得“飞影”并删去此项",
}

zhian:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  times = function(self, player)
    return math.max(1, player:getLostHp()) - player:usedSkillTimes(zhian.name, Player.HistoryRound)
  end,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(zhian.name) and data.card.type ~= Card.TypeBasic and
      player:usedSkillTimes(zhian.name, Player.HistoryTurn) < math.max(1, player:getLostHp())
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    if table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "ofl__zhian1:::"..data.card:toLogString())
    end
    if player:isWounded() then
      table.insert(choices, "ofl__zhian2")
    end
    if not target.dead and player:getMark(zhian.name) == 0 then
      table.insert(choices, "ofl__zhian3::"..target.id..":"..math.max(1, player:getLostHp()))
    end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = zhian.name,
      all_choices = {
        "ofl__zhian1:::"..data.card:toLogString(),
        "ofl__zhian2",
        "ofl__zhian3::"..target.id..":"..math.max(1, player:getLostHp()),
        "Cancel",
      },
    })
    if choice ~= "Cancel" then
      if choice:startsWith("ofl__zhian1") then
        local card = room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = zhian.name,
          cancelable = true,
          skip = true,
        })
        if #card > 0 then
          event:setCostData(self, {cards = card, choice = choice})
          return true
        end
      else
        event:setCostData(self, {tos = choice:startsWith("ofl__zhian3") and {target} or {}, choice = choice})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice:startsWith("ofl__zhian1") then
      room:throwCard(event:getCostData(self).cards, zhian.name, player, player)
      if player.dead then return end
      if table.contains({Card.Processing, Card.DiscardPile, Card.PlayerEquip, Card.PlayerJudge}, room:getCardArea(data.card)) then
        room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, zhian.name, nil, true, player)
      end
    elseif choice == "ofl__zhian2" then
      room:invalidateSkill(player, zhian.name, "-round")
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = zhian.name,
      }
    elseif choice:startsWith("ofl__zhian3") then
      room:damage{
        from = player,
        to = target,
        damage = math.max(1, player:getLostHp()),
        skillName = zhian.name,
      }
      if not player.dead then
        room:setPlayerMark(player, zhian.name, 1)
        room:handleAddLoseSkills(player, "feiying")
      end
    end
  end,
})

zhian:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, zhian.name, 0)
end)

return zhian
