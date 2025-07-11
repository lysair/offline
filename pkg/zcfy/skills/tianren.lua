local tianren = fk.CreateSkill {
  name = "sxfy__tianren",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__tianren"] = "天任",
  [":sxfy__tianren"] = "锁定技，当一张基本牌或普通锦囊牌不因使用而置入弃牌堆后，将之置于你的武将牌上。若“天任”数不小于你的体力上限，"..
  "你移去等量“天任”，加1点体力上限并摸两张牌。",

  ["#sxfy__tianren-ask"] = "天任：请移去%arg张“天任”",
}

tianren:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  derived_piles = tianren.name,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(tianren.name) then
      for _, move in ipairs(data) do
        if move.skillName ~= tianren.name and move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
          for _, info in ipairs(move.moveInfo) do
            local card = Fk:getCardById(info.cardId)
            if (card.type == Card.TypeBasic or card:isCommonTrick()) and
              table.contains(player.room.discard_pile, info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card.type == Card.TypeBasic or card:isCommonTrick() and
            table.contains(room.discard_pile, info.cardId) then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    player:addToPile(tianren.name, ids, true, tianren.name, player)
    while #player:getPile(tianren.name) >= player.maxHp do
      local cards = player:getPile(tianren.name)
      if #cards > player.maxHp then
        cards = room:askToCards(player, {
          min_num = player.maxHp,
          max_num = player.maxHp,
          include_equip = false,
          skill_name = tianren.name,
          pattern = ".|.|.|sxfy__tianren",
          prompt = "#sxfy__tianren-ask:::"..player.maxHp,
          cancelable = false,
          expand_pile = tianren.name,
        })
      end
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, tianren.name, nil, true, player)
      room:changeMaxHp(player, 1)
      if player.dead then return false end
      player:drawCards(2, tianren.name)
      if player.dead then return false end
    end
  end,
})

return tianren
