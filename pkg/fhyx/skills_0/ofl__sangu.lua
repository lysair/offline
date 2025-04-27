local ofl__sangu = fk.CreateSkill {
  name = "ofl__sangu"
}

Fk:loadTranslationTable{
  ['ofl__sangu'] = '三顾',
  ['#ofl__sangu-invoke'] = '三顾：你可以观看牌堆顶三张牌，令 %dest 本阶段可以将手牌当其中的牌使用',
  ['ofl__sangu_show'] = '三顾',
  ['#ofl__sangu-show'] = '三顾：你可以亮出其中的基本牌或普通锦囊牌，%dest 本阶段可以将手牌当亮出的牌使用',
  ['@$ofl__sangu-phase'] = '三顾',
  ['ofl__sangu&'] = '三顾',
  [':ofl__sangu'] = '一名角色出牌阶段开始时，若其手牌数不小于其体力上限，你可以观看牌堆顶三张牌并亮出其中任意张牌名不同的基本牌或普通锦囊牌。若如此做，此阶段每种牌名限一次，该角色可以将一张手牌当你亮出的一张牌使用。',
  ['$ofl__sangu1'] = '蒙先帝三顾祖父之恩，吾父子自当为国用命！',
  ['$ofl__sangu2'] = '祖孙三代世受君恩，当效吾祖鞠躬尽瘁。',
}

ofl__sangu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl__sangu.name) and target.phase == Player.Play and target:getHandcardNum() >= target.maxHp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = ofl__sangu.name,
      prompt = "#ofl__sangu-invoke::" .. target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(3)
    local fakemove = {
      toArea = Card.PlayerHand,
      to = player.id,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.Void} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    local availableCards = {}
    for _, id in ipairs(ids) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        table.insertIfNeed(availableCards, id)
      end
    end
    room:setPlayerMark(player, "ofl__sangu_cards", availableCards)
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__sangu_show",
      prompt = "#ofl__sangu-show::" .. target.id,
      cancelable = true
    })
    room:setPlayerMark(player, "ofl__sangu_cards", 0)
    fakemove = {
      from = player.id,
      toArea = Card.Void,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    if success then
      room:doIndicate(player.id, {target.id})
      room:moveCards({
        fromArea = Card.DrawPile,
        ids = dat.cards,
        toArea = Card.Processing,
        moveReason = fk.ReasonJustMove,
        skillName = ofl__sangu.name,
      })
      room:sendFootnote(dat.cards, {
        type = "##ShowCard",
        from = player.id,
      })
      room:delay(2000)
      room:moveCards({
        ids = dat.cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonJustMove,
        skillName = ofl__sangu.name,
      })
      if not target.dead then
        local mark = table.map(dat.cards, function(id) return Fk:getCardById(id).name end)
        room:setPlayerMark(target, "@$ofl__sangu-phase", mark)
        room:handleAddLoseSkills(target, "ofl__sangu&", nil, false, true)
        room.logic:getCurrentEvent():findParent(GameEvent.Phase, true):addCleaner(function()
          room:handleAddLoseSkills(target, '-ofl__sangu&', nil, false, true)
        end)
      end
    end
  end,
})

return ofl__sangu
