local xiandao = fk.CreateSkill{
  name = "xiandao"
}

Fk:loadTranslationTable{
  ['xiandao'] = '献刀',
  ['#xiandao-trigger'] = '献刀：你即将赠予 %dest %arg，是否对其发动“献刀”？',
  ['@xiandao-turn'] = '献刀',
  [':xiandao'] = '每回合限一次，你赠予其他角色牌后，你可以令其本回合不能使用此花色的牌，然后若此牌为：锦囊牌，你摸两张牌；装备牌，你获得其另一张牌；武器牌，你对其造成1点伤害。',
}

xiandao:addEffect(fk.AfterCardsMove, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skill.name) and player:usedSkillTimes(xiandao.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.to and not player.room:getPlayerById(move.to).dead and move.proposer == player.id and move.skillName == "present" then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local dat = {}
    for _, move in ipairs(data) do
      if move.to and not room:getPlayerById(move.to).dead and move.proposer == player.id and move.skillName == "present" then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(dat, {move.to, info.cardId})
        end
      end
    end
    for _, d in ipairs(dat) do
      if not player:hasSkill(skill.name) or player:usedSkillTimes(xiandao.name, Player.HistoryTurn) > 0 then break end
      local to = room:getPlayerById(d[1])
      skill:doCost(event, to, player, d[2], xiandao)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiandao.name,
      prompt = "#xiandao-trigger::"..target.id..":"..Fk:getCardById(data):toLogString()
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local card = Fk:getCardById(data)
    room:addTableMarkIfNeed(target, "@xiandao-turn", card:getSuitString(true))
    if not player.dead then
      if card.type == Card.TypeTrick then
        player:drawCards(2, xiandao.name)
      elseif card.type == Card.TypeEquip then
        if not target.dead and not target:isNude() then
          local card_data = {}
          if target:getHandcardNum() > 0 then
            local dat = {}
            for i = 1, target:getHandcardNum(), 1 do
              if target:getCardIds("h")[i] ~= card.id then
                table.insert(dat, -1)
              end
            end
            if #dat > 0 then
              table.insert(card_data, {"$Hand", dat})
            end
          end
          if #target:getCardIds("e") > 0 then
            local dat = target:getCardIds("e")
            table.removeOne(dat, card.id)
            if #dat > 0 then
              table.insert(card_data, {"$Equip", dat})
            end
          end
          if #card_data > 0 then
            local c = room:askToChooseCard(player, {
              target = target,
              flag = {card_data = card_data},
              skill_name = xiandao.name
            })
            if c == -1 then
              c = table.random(target:getCardIds("h"))
            end
            room:moveCardTo(Fk:getCardById(c), Card.PlayerHand, player, fk.ReasonPrey, xiandao.name, nil, false, player.id)
          end
          if card.sub_type == Card.SubtypeWeapon and not player.dead and not target.dead then
            room:damage{
              from = player,
              to = target,
              damage = 1,
              skillName = xiandao.name,
            }
          end
        end
      end
    end
  end,
})

xiandao:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return player:getMark("@xiandao-turn") ~= 0 and table.contains(player:getMark("@xiandao-turn"), card:getSuitString(true))
  end,
})

return xiandao
