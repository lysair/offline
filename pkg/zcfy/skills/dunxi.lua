local dunxi = fk.CreateSkill {
  name = "sxfy__dunxi",
}

Fk:loadTranslationTable{
  ["sxfy__dunxi"] = "钝袭",
  [":sxfy__dunxi"] = "每回合限一次，当一名其他角色使用【杀】时，你可以与其同时弃置一张手牌，若其弃置的牌名字数："..
  "大于你，你失去1点体力；小于你，此牌无效。",

  ["#sxfy__dunxi-invoke"] = "钝袭：你可以与 %dest 同时弃一张手牌，根据牌名字数执行效果",
}

dunxi:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(dunxi.name) and
      data.card.trueName == "slash" and not target:isKongcheng() and not player:isKongcheng() and
      player:usedSkillTimes(dunxi.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = dunxi.name,
      prompt = "#sxfy__dunxi-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askToJointCards(player, {
      players = {player, target},
      min_num = 1,
      max_num = 1,
      include_equip = false,
      cancelable = false,
      pattern = ".|.|.|hand",
      skill_name = dunxi.name,
      prompt = "#AskForDiscard:::1:1",
      will_throw = true,
    })
    local moves = {}
    local dat = {}
    for _, p in ipairs({player, target}) do
      local throw = result[p][1]
      if throw then
        dat[p] = Fk:translate(Fk:getCardById(throw).trueName, "zh_CN"):len()
        table.insert(moves, {
          ids = {throw},
          from = p,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          proposer = p,
          skillName = dunxi.name,
        })
      end
    end
    if #moves == 0 then return end
    room:moveCards(table.unpack(moves))
    if dat[player] and dat[target] then
      if dat[player] < dat[target] then
        if not target.dead then
          room:loseHp(target, 1, dunxi.name)
        end
      elseif dat[player] > dat[target] then
        data:removeAllTargets()
      end
    end
  end,
})

return dunxi
