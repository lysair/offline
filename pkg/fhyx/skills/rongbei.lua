local rongbei = fk.CreateSkill {
  name = "ofl_shiji__rongbei",
  tags = { Skill.Limited },
}

  Fk:loadTranslationTable{
  ["ofl_shiji__rongbei"] = "戎备",
  [":ofl_shiji__rongbei"] = "限定技，出牌阶段，你可以选择一名装备区有空置装备栏的角色，其为每个空置的装备栏从额外牌堆随机使用一张对应类别的装备。",

  ["#ofl_shiji__rongbei"] = "戎备：令一名角色从额外牌堆每个空置的装备栏随机使用一张装备",

  ["$ofl_shiji__rongbei1"] = "吾等无休之时，速置军资，以充戎备。",
  ["$ofl_shiji__rongbei2"] = "军饷兵械多多益善，无恤时日之久。",
}

local U = require "packages/offline/ofl_util"

rongbei:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl_shiji__rongbei",
  target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(rongbei.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select:hasEmptyEquipSlot()
  end,
  on_use = function(self, room, effect)
    local target = effect.tos[1]
    for _, slot in ipairs(target:getAvailableEquipSlots()) do
      if target.dead then return end
      local type = Util.convertSubtypeAndEquipSlot(slot)
      if target:hasEmptyEquipSlot(type) then
        local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
        local card = Fk:getCardById(id)
          return card.sub_type == type and not target:isProhibited(target, card)
        end)
        if #cards > 0 then
          local card = Fk:getCardById(table.random(cards))
          room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
          room:useCard{
            from = target,
            tos = {target},
            card = card,
          }
        end
      end
    end
  end,
})

rongbei:addAcquireEffect(function (self, player, is_start)
  U.PrepareExtraPile(player.room)
end)

return rongbei
