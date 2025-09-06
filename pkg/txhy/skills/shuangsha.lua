local shuangsha = fk.CreateSkill {
  name = "ofl_tx__shuangsha",
}

Fk:loadTranslationTable{
  ["ofl_tx__shuangsha"] = "双煞",
  [":ofl_tx__shuangsha"] = "准备阶段，你可以对一名角色造成1点伤害。出牌阶段限一次，你可以视为使用一张【决斗】。",

  ["#ofl_tx__shuangsha"] = "双煞：你可以视为使用一张【决斗】",
  ["#ofl_tx__shuangsha-choose"] = "双煞：你可以对一名角色造成1点伤害",

  ["$ofl_tx__shuangsha1"] = "吾乃河北上将颜良文丑是也！",
  ["$ofl_tx__shuangsha2"] = "快来与我等决一死战！",
}

shuangsha:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl_tx__shuangsha",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("duel")
    c.skillName = shuangsha.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
})

shuangsha:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangsha.name) and player.phase == Player.Start
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = shuangsha.name,
      prompt = "#ofl_tx__shuangsha-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = event:getCostData(self).tos[1],
      damage = 1,
      skillName = shuangsha.name,
    }
  end,
})

shuangsha:addAI(nil, "vs_skill")

return shuangsha
