local kunjun = fk.CreateSkill {
  name = "ofl__kunjun"
}

Fk:loadTranslationTable{
  ['ofl__kunjun'] = '困军',
  [':ofl__kunjun'] = '锁定技，你的初始手牌数+4，手牌数小于你的角色不能响应你使用的牌，你不能响应手牌数大于你的角色使用的牌。',
}

kunjun:addEffect(fk.DrawInitialCards, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    if player:hasSkill(skill.name) then
      return target == player
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(kunjun.name)
    room:notifySkillInvoked(player, kunjun.name, "drawcard")
    data.num = data.num + 4
  end,
})

kunjun:addEffect(fk.CardUsing, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skill.name) then
      if (data.card.trueName == "slash" or data.card:isCommonTrick()) then
        if target == player then
          return table.find(player.room.alive_players, function (p)
            return player:getHandcardNum() > p:getHandcardNum()
          end) ~= nil
        else
          return target:getHandcardNum() > player:getHandcardNum()
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(kunjun.name)
    data.disresponsiveList = data.disresponsiveList or {}
    if target == player then
      room:notifySkillInvoked(player, kunjun.name, "offensive")
      for _, p in ipairs(room.alive_players) do
        if player:getHandcardNum() > p:getHandcardNum() then
          table.insertIfNeed(data.disresponsiveList, p.id)
        end
      end
    else
      room:notifySkillInvoked(player, kunjun.name, "negative")
      table.insertIfNeed(data.disresponsiveList, player.id)
    end
  end,
})

return kunjun
