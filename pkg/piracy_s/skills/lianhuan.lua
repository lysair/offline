local lianhuan = fk.CreateSkill {
  name = "ofl__lianhuan",
}

Fk:loadTranslationTable{
  ["ofl__lianhuan"] = "连环",
  [":ofl__lianhuan"] = "出牌阶段限一次，你可以失去1点体力，视为使用【铁索连环】。",

  ["#ofl__lianhuan"] = "连环：失去1点体力，视为使用【铁索连环】",
}

lianhuan:addEffect("viewas", {
  anim_type = "control",
  prompt = "#ofl__lianhuan",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("iron_chain")
    c.skillName = lianhuan.name
    return c
  end,
  before_use = function (self, player, use)
    player.room:loseHp(player, 1, lianhuan.name)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(lianhuan.name, Player.HistoryPhase) == 0 and player.hp > 0
  end,
})

return lianhuan
