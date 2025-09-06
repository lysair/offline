local yingji = fk.CreateSkill {
  name = "ofl_tx__yingji",
}

Fk:loadTranslationTable{
  ["ofl_tx__yingji"] = "迎击",
  [":ofl_tx__yingji"] = "出牌阶段限一次，你可以对一名其他角色造成1点伤害。"..
  "<a href='os__override'>凌越·体力</a>：改为造成2点伤害，然后你失去1点体力，获得1点护甲。",

  ["#ofl_tx__yingji"] = "迎击：对一名角色造成1点伤害，若凌越则改为2点伤害且你失去1点体力获得1点护甲",
  ["override"] = "凌越",
}

yingji:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__yingji",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yingji.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    if to_select.hp < player.hp then
      return "override"
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if player.hp > target.hp then
      room:damage{
        from = player,
        to = target,
        damage = 2,
        skillName = yingji.name,
      }
      if player.dead then return end
      room:loseHp(player, 1, yingji.name)
      if player.dead then return end
      room:changeShield(player, 1)
    else
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = yingji.name,
      }
    end
  end,
})

return yingji
