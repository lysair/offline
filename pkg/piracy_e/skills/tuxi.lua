local tuxi = fk.CreateSkill {
  name = "ofl__tuxi",
}

Fk:loadTranslationTable{
  ["ofl__tuxi"] = "突袭",
  [":ofl__tuxi"] = "当你造成伤害后，你可以摸一张牌，然后获得受伤角色和其上下家各一张牌。",

  ["#ofl__tuxi-prey"] = "突袭：获得 %dest 一张牌",
}

tuxi:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tuxi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, tuxi.name)
    if player.dead then return end
    local targets = {data.to, data.to:getLastAlive(), data.to:getNextAlive()}
    for _, p in ipairs(targets) do
      if not p.dead then
        if p == player then
          if #player:getCardIds("e") > 0 then
            local card = room:askToChooseCard(player, {
              target = p,
              flag = "e",
              skill_name = tuxi.name,
              prompt = "#ofl__tuxi-prey::"..p.id,
            })
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, tuxi.name, nil, false, player)
          end
        elseif not p:isNude() then
          local card = room:askToChooseCard(player, {
            target = p,
            flag = "he",
            skill_name = tuxi.name,
            prompt = "#ofl__tuxi-prey::"..p.id,
          })
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, tuxi.name, nil, false, player)
        end
      end
    end
  end,
})

return tuxi
