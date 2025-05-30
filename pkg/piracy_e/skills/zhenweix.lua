
local zhenweix = fk.CreateSkill{
  name = "ofl__zhenweix",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__zhenweix"] = "震威",
  [":ofl__zhenweix"] = "锁定技，摸牌阶段，你多摸X张牌（X为你废除的装备栏数）。",
}

zhenweix:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(zhenweix.name) and
      table.find(player.sealedSlots, function(slot)
        return slot ~= Player.JudgeSlot
      end)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n +
      #table.filter(player.sealedSlots, function(slot)
        return slot ~= Player.JudgeSlot
      end)
  end,
})

return zhenweix
