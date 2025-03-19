local xianjing = fk.CreateSkill {
  name = "ofl__xianjing"
}

Fk:loadTranslationTable{
  ['ofl__xianjing'] = '娴静',
  [':ofl__xianjing'] = '准备阶段，你可令〖隅泣〗中的一个数字+1（单项不能超过3）。若你满体力值，则再令〖隅泣〗中的一个数字+1。',
  ['$ofl__xianjing1'] = '得父母之爱，享公主之礼遇。',
  ['$ofl__xianjing2'] = '哼，可不要小瞧女孩子啊。',
}

xianjing:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(xianjing.name) and player.phase == Player.Start then
      for i = 1, 4 do
        if player:getMark("yuqi" .. tostring(i)) < 5 then
          return true
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player)
    AddYuqi(player, xianjing.name, 1)
    if not player:isWounded() then
      AddYuqi(player, xianjing.name, 1)
    end
  end,
})

return xianjing
