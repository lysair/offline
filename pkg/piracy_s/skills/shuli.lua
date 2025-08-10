local shuli = fk.CreateSkill {
  name = "ofl__shuli",
}

Fk:loadTranslationTable{
  ["ofl__shuli"] = "姝丽",
  [":ofl__shuli"] = "每回合限两次，当其他角色使用【杀】造成伤害后，你可以与其各摸一张牌。",

  ["#ofl__shuli-invoke"] = "姝丽：你可以与 %dest 各摸一张牌",
}

shuli:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and target and player:hasSkill(shuli.name) and
      data.card and data.card.trueName == "slash" and not target.dead and
      player:usedSkillTimes(shuli.name, Player.HistoryTurn) < 2
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = shuli.name,
      prompt = "#ofl__shuli-invoke",
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, shuli.name)
    if not target.dead then
      target:drawCards(1, shuli.name)
    end
  end,
})

return shuli
