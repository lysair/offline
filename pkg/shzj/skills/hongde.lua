local hongde = fk.CreateSkill {
  name = "shzj_yiling__hongde",
}

Fk:loadTranslationTable{
  ["shzj_yiling__hongde"] = "弘德",
  [":shzj_yiling__hongde"] = "当你一次获得或失去至少两张牌后，你可以令一名角色摸一张牌或弃一张牌。",

  ["#shzj_yiling__hongde-choose"] = "弘德：你可以令一名角色摸一张牌或弃一张牌",
}

hongde:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(hongde.name) then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and
          ((move.from == player and move.to ~= player) or (move.to == player and move.toArea == Card.PlayerHand)) then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "shzj_yiling__hongde_active",
      prompt = "#shzj_yiling__hongde-choose",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {tos = dat.targets, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if event:getCostData(self).choice == "draw1" then
      to:drawCards(1, hongde.name)
    else
      room:askToDiscard(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = hongde.name,
        cancelable = false,
      })
    end
  end,
})

return hongde
