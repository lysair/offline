local xiaoguo = fk.CreateSkill{
  name = "ofl__xiaoguo",
}

Fk:loadTranslationTable{
  ["ofl__xiaoguo"] = "骁果",
  [":ofl__xiaoguo"] = "出牌阶段，你可以弃置一张基本牌，对一名其他角色造成1点伤害，若其因此进入濒死状态，此技能本回合失效。",

  ["#ofl__xiaoguo"] = "骁果：弃置一张基本牌，对一名其他角色造成1点伤害！",
}

xiaoguo:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__xiaoguo",
  card_num = 1,
  target_num = 1,
  can_use = Util.TrueFunc,
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic and
      not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, xiaoguo.name, player, player)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = xiaoguo.name,
      }
    end
  end,
})

xiaoguo:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    return data.damage and data.damage.skillName == xiaoguo.name and
      data.damage.from == player and not player.dead
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:invalidateSkill(player, xiaoguo.name, "-turn")
  end,
})

return xiaoguo
