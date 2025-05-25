local huoce = fk.CreateSkill{
  name = "ofl__huoce",
}

Fk:loadTranslationTable{
  ["ofl__huoce"] = "火策",
  [":ofl__huoce"] = "出牌阶段限一次，你可以与一名其他角色同时弃置一张手牌，若颜色相同，你对一名角色造成1点火焰伤害。",

  ["#ofl__huoce"] = "火策：与一名角色同时弃置一张手牌，若颜色相同则对一名角色造成火焰伤害。",
  ["#ofl__huoce-discard"] = "火策：弃置一张手牌，若双方弃牌颜色相同则造成火焰伤害",
  ["#ofl__huoce-choose"] = "火策：对一名角色造成1点火焰伤害",
}

huoce:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__huoce",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(huoce.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local result = room:askToJointCards(player, {
      players = {player, target},
      min_num = 1,
      max_num = 1,
      cancelable = false,
      skill_name = huoce.name,
      prompt = "#ofl__huoce-discard",
      will_throw = true,
    })
    local moves = {}
    local yes = nil
    for _, p in ipairs({player, target}) do
      local throw = result[p][1]
      if throw then
        if yes == nil then
          yes = Fk:getCardById(throw).color
        else
          yes = yes == Fk:getCardById(throw).color and yes ~= Card.NoColor
        end
        table.insert(moves, {
          ids = {throw},
          from = p,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          proposer = p,
          skillName = huoce.name,
        })
      end
    end
    room:moveCards(table.unpack(moves))
    if #moves == 2 and yes and not player.dead then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = huoce.name,
        prompt = "#ofl__huoce-choose",
        cancelable = false,
      })[1]
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = huoce.name,
      }
    end
  end,
})

return huoce
