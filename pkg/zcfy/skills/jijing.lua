local jijing = fk.CreateSkill {
  name = "sxfy__jijing",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__jijing"] = "吉境",
  [":sxfy__jijing"] = "锁定技，当你受到伤害后，你进行判定，然后你弃置至少一张牌，若点数之和大于判定结果，你回复1点体力",

  ["#sxfy__jijing-discard"] = "吉境：弃置至少一张牌，若点数之和大于%arg则回复1点体力",
}

jijing:addEffect(fk.Damaged, {
  anim_type = "defensive",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = jijing.name,
    }
    room:judge(judge)
    if player.dead or player:isNude() or judge.card == nil then return end
    local n = judge.card.number
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = jijing.name,
      prompt = "#sxfy__jijing-discard:::" .. n,
      cancelable = false,
      skip = true,
    })
    if #cards > 0 then
      for _, id in ipairs(cards) do
        n = n - Fk:getCardById(id).number
      end
      room:throwCard(cards, jijing.name, player, player)
      if not player.dead and n < 0 then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = jijing.name,
        }
      end
    end
  end,
})

return jijing
