local daoshu = fk.CreateSkill {
  name = "sgsh__daoshu",
}

Fk:loadTranslationTable{
  ["sgsh__daoshu"] = "盗书",
  [":sgsh__daoshu"] = "出牌阶段限一次，你可以选择一名其他角色并声明一种花色，其展示所有手牌并选择一项：1.交给你所有你此花色的手牌；"..
  "2.你对其造成1点伤害。",

  ["#sgsh__daoshu"] = "盗书：声明一种花色，令一名角色选择交给你所有此花色手牌或你对其造成伤害",
  ["#sgsh__daoshu-give"] = "盗书：交给%src所有%arg手牌，或点“取消”其对你造成1点伤害",

  ["$sgsh__daoshu1"] = "赤壁之战，我军之患，不足为惧。",
  ["$sgsh__daoshu2"] = "取此机密，简直易如反掌。",
}

daoshu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sgsh__daoshu",
  card_num = 0,
  target_num = 1,
  interaction = UI.ComboBox{ "log_spade", "log_club", "log_heart", "log_diamond" },
  can_use = function(self, player)
    return player:usedSkillTimes(daoshu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local choice = self.interaction.data
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = choice,
      toast = true,
    }
    if target:isKongcheng() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = daoshu.name,
      }
    else
      target:showCards(target:getCardIds("h"))
      if target.dead then return end
      local cards = table.filter(target:getCardIds("h"), function(id)
        return Fk:getCardById(id):getSuitString(true) == choice
      end)
      if #cards == 0 or player.dead or
        not room:askToSkillInvoke(target, {
          skill_name = daoshu.name,
          prompt = "#sgsh__daoshu-give:"..player.id.."::"..choice,
        }) then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = daoshu.name,
        }
      else
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, daoshu.name, nil, true, target)
      end
    end
  end,
})

return daoshu
