local mangji = fk.CreateSkill {
  name = "mangji",
}

Fk:loadTranslationTable{
  ['mangji'] = '莽击',
  ['#mangji-discard'] = '莽击：你需弃置一张手牌并视为使用一张【杀】',
  [':mangji'] = '锁定技，当你装备区的牌数变化或当你体力值变化后，若你体力值不小于1，你弃置一张手牌并视为使用一张【杀】。',
}

mangji:addEffect({fk.HpChanged, fk.AfterCardsMove}, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mangji.name) and player.hp > 0 then
      if event == fk.HpChanged then
        return target == player
      else
        local equipnum = #player:getCardIds("e")
        for _, move in ipairs(target.data) do
          for _, info in ipairs(move.moveInfo) do
            if move.from == player.id and info.fromArea == Card.PlayerEquip then
              equipnum = equipnum + 1
            elseif move.to == player.id and move.toArea == Card.PlayerEquip then
              equipnum = equipnum - 1
            end
          end
        end
        return #player:getCardIds("e") ~= equipnum
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isKongcheng() then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = mangji.name,
        cancelable = false,
        prompt = "#mangji-discard",
      })
    end
    if not player.dead then
      U.askForUseVirtualCard(room, player, "slash", nil, mangji.name, nil, false, true, false, true)
    end
  end,
})

return mangji
