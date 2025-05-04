local ejian = fk.CreateSkill {
  name = "ofl_shiji__ejian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_shiji__ejian"] = "恶荐",
  [":ofl_shiji__ejian"] = "锁定技，当其他角色获得你的牌后，其展示所有手牌，若其有除此牌以外与此牌类别相同的牌，其选择一项：1.弃置这些牌；"..
  "2.受到你造成的1点伤害，你重置〖博名〗记录的角色。",

  ["#ofl_shiji__ejian-discard"] = "恶荐：弃置除获得的牌外和获得的牌类别相同的牌，或点“取消”%src 对你造成1点伤害",

  ["$ofl_shiji__ejian1"] = "贤者当举而上之，不肖者当抑而废之。",
  ["$ofl_shiji__ejian2"] = "董公虽能臣天下之人，不能擅天下之士也。",
}

ejian:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ejian.name) then
      for _, move in ipairs(data) do
        if move.from == player and move.to and move.to ~= player and move.toArea == Card.PlayerHand and
          not move.to.dead and not move.to:isKongcheng() then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    for _, move in ipairs(data) do
      if move.from == player and move.to and move.to ~= player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(tos, move.to)
            break
          end
        end
      end
    end
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not player:hasSkill(ejian.name) then break end
      if not to.dead and not to:isKongcheng() then
        event:setCostData(self, {tos = {to}})
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    to:showCards(to:getCardIds("h"))
    if to.dead or to:isNude() then return end
    room:delay(1000)
    local yes, cards = false, {}
    for _, move in ipairs(data) do
      if move.from == player and move.to == to and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            for _, id in ipairs(to:getCardIds("he")) do
              if id ~= info.cardId and Fk:getCardById(id).type == Fk:getCardById(info.cardId).type then
                yes = true
                if not to:prohibitDiscard(id) then
                  table.insertIfNeed(cards, id)
                end
              end
            end
          end
        end
      end
    end
    if not yes then return end
    if #cards == 0 or not room:askToSkillInvoke(to, {
      skill_name = ejian.name,
      prompt = "#ofl_shiji__ejian-discard:"..player.id,
    }) then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = ejian.name,
      }
      room:setPlayerMark(player, "ofl_shiji__boming", 0)
    else
      room:throwCard(cards, ejian.name, to, to)
    end
  end,
})

return ejian
