local qianjun = fk.CreateSkill {
  name = "ofl__qianjun"
}

Fk:loadTranslationTable{
  ['ofl__qianjun'] = '迁军',
  ['#ofl__qianjun'] = '迁军：将所有装备交给一名角色并与其交换座次，你回复1点体力并获得〖乱击〗！',
  ['@ofl__tunquan'] = '屯犬',
  [':ofl__qianjun'] = '限定技，出牌阶段，你可以交给一名其他角色装备区里的所有牌并与其交换座次，然后你回复1点体力并获得〖乱击〗。',
}

qianjun:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__qianjun",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(qianjun.name, Player.HistoryGame) == 0 and
      #player:getCardIds("e") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "@ofl__tunquan", 0)
    room:moveCardTo(player:getCardIds("e"), Card.PlayerHand, target, fk.ReasonGive, qianjun.name, nil, true, player.id)
    room:swapSeat(player, target)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = qianjun.name,
      }
      if player.dead then return end
    end
    room:handleAddLoseSkills(player, "luanji", nil, true, false)
  end,
})

return qianjun
