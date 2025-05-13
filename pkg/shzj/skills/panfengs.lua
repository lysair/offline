local panfengs = fk.CreateSkill({
  name = "panfengs",
})

Fk:loadTranslationTable{
  ["panfengs"] = "叛封",
  [":panfengs"] = "当你使用【杀】后或失去最后一张手牌后，你可以变更势力并将手牌补至体力上限，然后对一名势力与你相同的角色造成1点伤害。",

  ["#panfengs-invoke"] = "叛封：你可以变更势力并将手牌补至体力上限，然后对一名同势力角色造成伤害",
  ["#panfengs-choose"] = "叛封：对一名相同势力角色造成1点伤害",
}

local spec = {
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = Fk:getKingdomMap("god")
    table.insert(all_choices, "Cancel")
    local choices = table.simpleClone(all_choices)
    table.removeOne(choices, player.kingdom)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = panfengs.name,
      prompt = "#panfengs-invoke",
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeKingdom(player, event:getCostData(self).choice, true)
    if player.dead then return end
    if player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum(), panfengs.name)
      if player.dead then return end
    end
    local targets = table.filter(room.alive_players, function (p)
      return p.kingdom == player.kingdom
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = panfengs.name,
      prompt = "#panfengs-choose",
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = panfengs.name,
    }
  end,
}

panfengs:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(panfengs.name) and data.card.trueName == "slash"
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})
panfengs:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(panfengs.name) and player:isKongcheng()) then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return panfengs
