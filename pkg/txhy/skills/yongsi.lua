local yongsi = fk.CreateSkill{
  name = "ofl_tx__yongsi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__yongsi"] = "庸肆",
  [":ofl_tx__yongsi"] = "锁定技，摸牌阶段，你改为摸X张牌（X为存活角色数）；弃牌阶段开始时，你选择一项：1.摸一张牌；2.回复1点体力。",

  ["$ofl_tx__yongsi1"] = "乱世之中，必出枭雄。",
  ["$ofl_tx__yongsi2"] = "得此玉玺，是为天助！",
}

yongsi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = #player.room.alive_players
  end,
})

yongsi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name) and player.phase == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isWounded() or
      room:askToChoice(player, {
      choices = { "draw1", "recover" },
      skill_name = yongsi.name,
    }) == "draw1" then
      player:drawCards(1, yongsi.name)
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = yongsi.name,
      }
    end
  end,
})

return yongsi
