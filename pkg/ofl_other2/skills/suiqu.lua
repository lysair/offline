local suiqu = fk.CreateSkill {
  name = "ofl__suiqu"
}

Fk:loadTranslationTable{
  ['ofl__suiqu'] = '随去',
  ['ofl__tianpan1'] = '加1点体力上限',
  [':ofl__suiqu'] = '锁定技，所有角色的弃牌阶段，你弃置所有手牌，若至少弃置一张牌，你加1点体力上限或回复1点体力。',
}

suiqu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(skill.name) and target.phase == Player.Discard and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local yes = table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end)
    player:throwAllCards("h")
    if player.dead then return end
    if yes then
      local choices = {"ofl__tianpan1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = suiqu.name
      })
      if choice == "ofl__tianpan1" then
        room:changeMaxHp(player, 1)
      else
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = suiqu.name,
        }
      end
    end
  end,
})

return suiqu
