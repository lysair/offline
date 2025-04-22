local changshi = fk.CreateSkill {
  name = "changshi"
}

Fk:loadTranslationTable{
  ['changshi'] = '常侍',
  ['@@changshi'] = '常侍',
  ['#changshi_trigger'] = '常侍',
  ['#changshi-invoke'] = '常侍：是否摸一张牌，令 %dest 手牌上限+1？',
  ['#changshi-choose'] = '常侍：是否弃置“常侍”标记，将你受到的致命伤害转移给另一名常侍？',
  [':changshi'] = '游戏开始时，你获得一张<a href=>“常侍”标记</a>，当你失去“常侍”标记时，你减1点体力上限。',
}

changshi:addEffect({fk.GameStart, "fk.ChangshiInvoke"}, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(changshi.name) then
      if event == fk.GameStart then
        return true
      elseif event == "fk.ChangshiInvoke" then
        return target == player
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:setPlayerMark(player, "@@changshi", 1)
    elseif event == "fk.ChangshiInvoke" then
      room:changeMaxHp(player, -1)
    end
  end,
})

changshi:addEffect({fk.EventPhaseStart, fk.DamageInflicted}, {
  name = "#changshi_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@@changshi") > 0 then
      if event == fk.EventPhaseStart then
        return target.seat == 1 and target.phase == Player.Discard
      elseif event == fk.DamageInflicted then
        return target == player and data.damage >= player.hp + player.shield and
          table.find(player.room:getOtherPlayers(player, false), function (p)
            return p:getMark("@@changshi") > 0
          end) ~= nil
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      if room:askToSkillInvoke(player, {
        skill_name = changshi.name,
        prompt = "#changshi-invoke::" .. target.id
      }) then
        event:setCostData(changshi, {tos = {target.id}})
        return true
      end
    elseif event == fk.DamageInflicted then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p:getMark("@@changshi") > 0
      end)
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        prompt = "#changshi-choose",
        skill_name = changshi.name,
        cancelable = true,
        targets = table.map(targets, Util.IdMapper),
      })
      if #to > 0 then
        event:setCostData(changshi, {tos = to})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("changshi")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, changshi.name, "drawcard")
      room:addPlayerMark(target, MarkEnum.AddMaxCards, 1)
      player:drawCards(1, changshi.name)
    elseif event == fk.DamageInflicted then
      local cost_data = event:getCostData(changshi)
      room:notifySkillInvoked(player, changshi.name, "defensive")
      local to = room:getPlayerById(cost_data.tos[1])
      room:setPlayerMark(player, "@@changshi", 0)
      room.logic:trigger("fk.ChangshiInvoke", player, {})
      if not to.dead then
        room:damage{
          from = data.from,
          to = to,
          damage = data.damage,
          damageType = data.damageType,
          skillName = data.skillName,
          chain = data.chain,
          card = data.card,
        }
      end
      return true
    end
  end,
})

return changshi
