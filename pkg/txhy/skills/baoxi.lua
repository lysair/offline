local baoxi = fk.CreateSkill({
  name = "ofl_tx__baoxi",
})

Fk:loadTranslationTable{
  ["ofl_tx__baoxi"] = "暴袭",
  [":ofl_tx__baoxi"] = "出牌阶段限一次，你可以弃置一张【杀】或装备牌，并选择一名已受伤的其他角色，"..
  "消耗至多3点<a href='os__baonue_href'>暴虐值</a>，对其造成等量伤害。",

  ["#ofl_tx__baoxi"] = "暴袭：弃置一张【杀】或装备牌，消耗至多3点暴虐值，对一名角色造成等量伤害",
}

baoxi.os__baonue = true

baoxi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__baoxi",
  card_num = 1,
  target_num = 1,
  interaction = function (self, player)
    return UI.Spin {
      from = 1,
      to = math.min(3, player:getMark("@os__baonue")),
    }
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(baoxi.name, Player.HistoryPhase) == 0 and player:getMark("@os__baonue") > 0
  end,
  card_filter = function(self, player, to_select, selected)
    return (Fk:getCardById(to_select).trueName == "slash" or Fk:getCardById(to_select).type == Card.TypeEquip) and
      not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select:isWounded()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = self.interaction.data
    room:removePlayerMark(player, "@os__baonue", n)
    room:throwCard(effect.cards, baoxi.name, player, player)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = n,
        skillName = baoxi.name,
      }
    end
  end,
})

baoxi:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return baoxi
