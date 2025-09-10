local yaoli = fk.CreateSkill {
  name = "ofl__yaoli",
}

Fk:loadTranslationTable{
  ["ofl__yaoli"] = "媱丽",
  [":ofl__yaoli"] = "当其他角色于其出牌阶段使用【酒】后，你可以令其本回合使用的下一张【杀】不可被响应且可以额外指定一个目标。",

  ["#ofl__yaoli-invoke"] = "媱丽：你可以令 %dest 本回合下一张【杀】不可响应且可以额外指定一个目标",
  ["@@ofl__yaoli-turn"] = "媱丽",
  ["#ofl__yaoli-choose"] = "媱丽：你可以为此%arg额外指定至多%arg2个目标",
}

yaoli:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(yaoli.name) and
      data.card.trueName == "analeptic" and target.phase == Player.Play and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yaoli.name,
      prompt = "#ofl__yaoli-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(target, "@@ofl__yaoli-turn", 1)
  end,
})

yaoli:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@@ofl__yaoli-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("@@ofl__yaoli-turn")
    room:setPlayerMark(player, "@@ofl__yaoli-turn", 0)
    data.disresponsiveList = table.simpleClone(room.players)
    if #data:getExtraTargets() > 0 then
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = n,
        targets = data:getExtraTargets(),
        skill_name = yaoli.name,
        prompt = "#ofl__yaoli-choose:::"..data.card:toLogString()..":"..n,
        cancelable = true,
      })
      if #tos > 0 then
        room:sortByAction(tos)
        for _, p in ipairs(tos) do
          data:addTarget(p)
        end
      end
    end
  end,
})

return yaoli
