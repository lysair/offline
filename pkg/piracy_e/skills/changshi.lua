local changshi = fk.CreateSkill {
  name = "changshi",
}

Fk:loadTranslationTable{
  ["changshi"] = "常侍",
  [":changshi"] = "游戏开始时，你获得一张<a href='changshi_href'>“常侍”标记</a>，当你失去“常侍”标记时，你减1点体力上限。",

  ["changshi_href"] = "拥有“常侍”标记的角色拥有以下技能：<br>1号位的弃牌阶段开始时，你可以摸一张牌，令其手牌上限+1。当你受到致命伤害时，"..
  "你可以弃置“常侍”标记，将此伤害转移给另一名有“常侍”标记的角色。",
  ["@@changshi"] = "常侍",

  ["#changshi-invoke"] = "常侍：是否摸一张牌，令 %dest 手牌上限+1？",
  ["#changshi-choose"] = "常侍：是否弃置“常侍”标记，将你受到的致命伤害转移给另一名常侍？",
}

changshi:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(changshi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@changshi", 1)
  end,
})

changshi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@changshi") > 0 and target.seat == 1 and target.phase == Player.Discard
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = changshi.name,
      prompt = "#changshi-invoke::" .. target.id
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(target, MarkEnum.AddMaxCards, 1)
    player:drawCards(1, changshi.name)
  end,
})

changshi:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@changshi") > 0 and
      data.damage >= player.hp + player.shield and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:getMark("@@changshi") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getMark("@@changshi") > 0
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#changshi-choose",
      skill_name = changshi.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:setPlayerMark(player, "@@changshi", 0)
    if player:hasSkill(changshi.name) then
      room:changeMaxHp(player, -1)
    end
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
      data:preventDamage()
    end
  end,
})

return changshi
