local wansu = fk.CreateSkill {
  name = "wansu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["wansu"] = "完夙",
  [":wansu"] = "锁定技，有装备栏被废除的角色不能响应虚拟牌；虚拟牌造成的伤害均改为失去体力。",
}

wansu:addEffect(fk.CardUsing, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wansu.name) and data.card:isVirtual() and #data.card.subcards == 0 and
      table.find(player.room.alive_players, function (p)
        return #p.sealedSlots > 0 and table.find(p.sealedSlots, function (slot)
          return slot ~= Player.JudgeSlot
        end) ~= nil
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(room.alive_players) do
      if #p.sealedSlots > 0 and table.find(p.sealedSlots, function (slot)
        return slot ~= Player.JudgeSlot
      end) then
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
  end,
})

wansu:addEffect(fk.PreDamage, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wansu.name) and
      data.card and data.card:isVirtual() and #data.card.subcards == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, wansu.name)
    data:preventDamage()
  end,
})

return wansu
