local zhaoeh = fk.CreateSkill {
  name = "zhaoeh",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["zhaoeh"] = "昭恶",
  [":zhaoeh"] = "限定技，你失去过牌的回合结束时，你可以展示当前回合角色所有手牌，然后令至多X名角色对其使用至多X张【杀】（X为其展示的伤害牌数）。",

  ["#zhaoeh-invoke"] = "昭恶：你可以令 %dest 展示手牌，根据其中伤害牌数令角色对其使用【杀】！",
  ["#zhaoeh-choose"] = "昭恶：令至多%arg名角色对 %dest 使用共计%arg张【杀】！",
  ["#zhaoeh-slash"] = "昭恶：你可以对 %dest 使用【杀】",
}

zhaoeh:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhaoeh.name) and player:usedSkillTimes(zhaoeh.name, Player.HistoryGame) == 0 and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.to ~= player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0 and
      not target:isKongcheng() and
      #player.room:getOtherPlayers(target, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = zhaoeh.name,
      prompt = "#zhaoeh-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(target:getCardIds("h"))
    local n = #table.filter(cards, function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    target:showCards(cards)
    if target.dead or n == 0 or #room:getOtherPlayers(target, false) == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = n,
      targets = room:getOtherPlayers(target, false),
      skill_name = zhaoeh.name,
      prompt = "#zhaoeh-choose::"..target.id..":"..n,
      cancelable = false,
    })
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      while not p.dead and n > 0 and not target.dead do
        local use = room:askToUseCard(p, {
          skill_name = zhaoeh.name,
          pattern = "slash",
          prompt = "#zhaoeh-slash::" .. target.id,
          cancelable = true,
          extra_data = {
            exclusive_targets = {target.id},
            bypass_distances = true,
            bypass_times = true,
          }
        })
        if use then
          n = n - 1
          use.extraUse = true
          room:useCard(use)
        else
          break
        end
      end
      if n <= 0 or target.dead then return end
    end
  end,
})

return zhaoeh
