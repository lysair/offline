local ofl_shiji__rongbei = fk.CreateSkill {
  name = "ofl_shiji__rongbei"
}

  Fk:loadTranslationTable{
  ['ofl_shiji__rongbe'] = '戎备',
  ['#ofl_shiji__rongbei'] = '戎备：令一名角色从额外牌堆每个空置的装备栏随机使用一张装备',
  [@$fhyx_extra_pile'] = '额外牌堆',
  [':ofl_shiji__rongbei'] = '限定技，出牌阶段，你可以选择一名装备区有空置装备栏的角色，其为每个空置的装备栏从额外牌堆随机使用一张对应类别的装备。',
  ['$ofl_shiji__rongbei1'] = '吾等无休之时，速置军资，以充戎备。',
  ['$ofl_shiji__rongbei2'] = '军饷兵械多多益善，无恤时日之久。',
}

-- Active Skill Effect
ofl_shiji__rongbei:addEffect('active', {
  anim_type = "support",
  target_num = 1,
  card_num = 0,
  frequency = Skill.Limited,
  prompt = "#ofl_shiji__rongbei",
  can_use = function(self, player)
  return player:usedSkillTimes(ofl_shiji__rongbei.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
  local target = Fk:currentRoom():getPlayerById(to_select)
  return #selected == 0 and #target:getCardIds("e") < #target:getAvailableEquipSlots()
  end,
  on_use = function(self, room, effect)
  local target = room:getPlayerById(effect.tos[1])
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
  room:useCard({
  from = effect.tos[1],
  tos = {{effect.tos[1]}},
  card = card,
  })
  end
  end
  end
  end,

  on_acquire = function (self, player, is_start)
  PrepareExtraPile(player.room)
  end,
  })

  -- Trigger Skill Effect
  ofl_shiji__rongbei:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
  if player.seat == 1 then
  for _, move in ipairs(data) do
  for _, info in ipairs(move.moveInfo) do
  if player.room:getBanner("fhyx_extra_pile") and
  table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
  return true
  end
  end
  end
  end
  end,
  on_refresh = function(self, event, target, player, data)
  SetFhyxExtraPileBanner(player.room)
  end,
  })

  return ofl_shiji__rongbei
