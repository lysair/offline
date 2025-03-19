local luoshen = fk.CreateSkill {
  name = "es__luoshen"
}

Fk:loadTranslationTable{
  ['es__luoshen'] = '洛神',
  [':es__luoshen'] = '准备阶段，你可以判定，并获得生效后的判定牌，然后若你本次以此法获得的牌颜色均相同，你可以重复此流程。',
}

luoshen:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(luoshen.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local color = ""
    local pattern = ".|.|."
    while true do
      if color == "red" then
        pattern = ".|.|heart,diamond"
      elseif color == "black" then
        pattern = ".|.|spade,club"
      end
      local judge = {
        who = player,
        reason = luoshen.name,
        pattern = pattern,
      }
      room:judge(judge)
      if color == "" then
        color = judge.card:getColorString()
      end
      if judge.card:getColorString() ~= color or player.dead or not room:askToSkillInvoke(player, { skill_name = luoshen.name }) then
        break
      end
    end
  end,
})

luoshen:addEffect(fk.FinishJudge, {
  name = "#es__luoshen_obtain",
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.reason == luoshen.name
      and data.card:matchPattern(data.pattern)
      and player.room:getCardArea(data.card:getEffectiveId()) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, nil, player.id, luoshen.name)
  end,
})

return luoshen
