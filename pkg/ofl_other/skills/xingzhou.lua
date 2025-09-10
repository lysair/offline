local xingzhou = fk.CreateSkill {
  name = "xingzhou",
}

Fk:loadTranslationTable{
  ["xingzhou"] = "兴周",
  [":xingzhou"] = "每回合限一次，当手牌数最少的角色受到伤害后，你可以弃置两张手牌，视为对伤害来源使用一张【杀】，然后若其死亡，〖列神〗"..
  "视为未发动过。",

  ["#xingzhou-invoke"] = "兴周：是否弃置两张手牌，视为对 %dest 使用【杀】？",
}

xingzhou:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xingzhou.name) and
      data.from and not data.from.dead and data.from ~= player and
      player:getHandcardNum() > 1 and player:usedSkillTimes(xingzhou.name, Player.HistoryTurn) == 0 and
      table.every(player.room.alive_players, function (p)
        return p:getHandcardNum() >= target:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = xingzhou.name,
      cancelable = true,
      prompt = "#xingzhou-invoke::" .. data.from.id,
      skip = true,
    })
    if #cards == 2 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, xingzhou.name, player, player)
    if not data.from.dead then
      room:useVirtualCard("slash", nil, player, data.from, xingzhou.name, true)
    end
    if data.from.dead then
      player:setSkillUseHistory("lieshen", 0, Player.HistoryGame)
    end
  end,
})

return xingzhou
