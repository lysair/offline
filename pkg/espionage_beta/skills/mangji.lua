local mangji = fk.CreateSkill {
  name = "mangji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mangji"] = "莽击",
  [":mangji"] = "锁定技，当你装备区的牌数变化或当你体力值变化后，若你体力值不小于1，你弃置一张手牌并视为使用一张【杀】。",

  ["#mangji-slash"] = "莽击：请视为使用【杀】",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = mangji.name,
      cancelable = false,
    })
    if not player.dead then
      room:askToUseVirtualCard(player, {
        name = "slash",
        skill_name = mangji.name,
        prompt = "#mangji-slash",
        cancelable = false,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
    end
  end,
}

mangji:addEffect(fk.HpChanged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mangji.name) and player.hp > 0
  end,
  on_use = spec.on_use,
})

mangji:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mangji.name) and player.hp > 0 then
      local equipnum = #player:getCardIds("e")
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if move.from == player and info.fromArea == Card.PlayerEquip then
            equipnum = equipnum + 1
          elseif move.to == player and move.toArea == Card.PlayerEquip then
            equipnum = equipnum - 1
          end
        end
      end
      return #player:getCardIds("e") ~= equipnum
    end
  end,
  on_use = spec.on_use,
})

return mangji
