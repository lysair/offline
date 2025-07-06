local zuoxing = fk.CreateSkill {
  name = "sxfy__zuoxing",
}

Fk:loadTranslationTable{
  ["sxfy__zuoxing"] = "佐幸",
  [":sxfy__zuoxing"] = "准备阶段，你可以减1点体力上限，然后视为使用一张非伤害类普通锦囊牌。",

  ["#sxfy__zuoxing-use"] = "佐幸：请视为使用一张普通锦囊牌",
}

zuoxing:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zuoxing.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player.dead then return end
    local all_names = Fk:getAllCardNames("t")
    all_names = table.filter(all_names, function(name)
      return not Fk:cloneCard(name).is_damage_card
    end)
    room:askToUseVirtualCard(player, {
      name = all_names,
      skill_name = zuoxing.name,
      prompt = "#sxfy__zuoxing-use",
      cancelable = false,
    })
  end,
})

return zuoxing
