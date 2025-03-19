local sgsh__daoshu = fk.CreateSkill {
  name = "sgsh__daoshu"
}

Fk:loadTranslationTable{
  ['sgsh__daoshu'] = '盗书',
  ['#sgsh__daoshu'] = '盗书：声明一种花色，令一名角色选择交给你所有此花色手牌或你对其造成伤害',
  ['#sgsh__daoshu-chose'] = '盗书选择了：',
  ['#sgsh__daoshu-give'] = '盗书：交给%src所有%arg手牌，或点“取消”其对你造成1点伤害',
  [':sgsh__daoshu'] = '出牌阶段限一次，你可以选择一名其他角色并声明一种花色，其展示所有手牌并选择一项：1.交给你所有你此花色的手牌；2.你对其造成1点伤害。',
  ['$sgsh__daoshu1'] = '赤壁之战，我军之患，不足为惧。',
  ['$sgsh__daoshu2'] = '取此机密，简直易如反掌。',
}

sgsh__daoshu:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#sgsh__daoshu",
  can_use = function(self, player)
    return player:usedSkillTimes(sgsh__daoshu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choice = room:askToChoice(player, {
      choices = suits,
      skill_name = sgsh__daoshu.name
    })
    room:doBroadcastNotify("ShowToast", Fk:translate(player.general)..Fk:translate("#sgsh__daoshu-chose")..Fk:translate(choice))
    if target:isKongcheng() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = sgsh__daoshu.name,
      }
    else
      target:showCards(target:getCardIds("h"))
      if target.dead then return end
      local cards = table.filter(target:getCardIds("h"), function(id) return Fk:getCardById(id):getSuitString(true) == choice end)
      if #cards == 0 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = sgsh__daoshu.name,
        }
      elseif player.dead or not room:askToSkillInvoke(target, {
          skill_name = sgsh__daoshu.name,
          prompt = "#sgsh__daoshu-give:"..player.id.."::"..choice
        }) then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = sgsh__daoshu.name,
        }
      else
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, sgsh__daoshu.name, nil, true, target.id)
      end
    end
  end,
})

return sgsh__daoshu
