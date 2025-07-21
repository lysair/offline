local huji = fk.CreateSkill {
  name = "huji",
}

Fk:loadTranslationTable{
  ["huji"] = "互忌",
  [":huji"] = "每轮开始时，你可以选择一名不在你攻击范围内且你不在其攻击范围内的其他角色，其需赠予你一张手牌；本轮每个回合结束时，"..
  "你与其攻击范围内包含对方的角色需弃置两张手牌，对对方造成1点伤害。",

  ["#huji-choose"] = "互忌：选择一名角色，其需赠予你一张手牌，本轮每个回合结束时执行效果",
  ["#huji-give"] = "互忌：你需将一张手牌赠予 %src",
  ["@[chara]huji-round"] = "互忌",
  ["#huji-discard"] = "互忌：你需弃置两张手牌，对 %dest 造成1点伤害",
}

local U = require "packages/utility/utility"

huji:addEffect(fk.RoundStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huji.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not player:inMyAttackRange(p) and not p:inMyAttackRange(player)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not player:inMyAttackRange(p) and not p:inMyAttackRange(player)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = huji.name,
      prompt = "#huji-choose",
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
    room:setPlayerMark(player, "@[chara]huji-round", to.id)
    if not to:isKongcheng() then
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = huji.name,
        prompt = "#huji-give:"..player.id,
        cancelable = false,
      })
      U.presentCard(to, player, card[1], huji.name)
    end
  end,
})

huji:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if player:getMark("@[chara]huji-round") ~= 0 then
      local to = player.room:getPlayerById(player:getMark("@[chara]huji-round"))
      if not to.dead then
        if player:inMyAttackRange(to) and
          #table.filter(player:getCardIds("h"), function (id)
            return not player:prohibitDiscard(id)
          end) > 1 then
          return true
        end
        if to:inMyAttackRange(player) and
          #table.filter(to:getCardIds("h"), function (id)
            return not to:prohibitDiscard(id)
          end) > 1 then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("@[chara]huji-round"))
    local targets = {player, to}
    room:sortByAction(targets)
    local p1, p2 = targets[1], targets[2]
    for _ = 1, 2 do
      if p1:inMyAttackRange(p2) and
        #table.filter(p1:getCardIds("h"), function (id)
          return not p1:prohibitDiscard(id)
        end) > 1 then
        room:askToDiscard(p1, {
          min_num = 2,
          max_num = 2,
          include_equip = false,
          skill_name = huji.name,
          cancelable = false,
          prompt = "#huji-discard::"..p2.id,
        })
        if not p2.dead then
          room:doIndicate(p1, {p2})
          room:damage{
            from = p1,
            to = p2,
            damage = 1,
            skillName = huji.name,
          }
        end
      end
      if p1.dead or p2.dead then return end
      p1, p2 = p2, p1
    end
  end,
})

huji:addEffect(fk.Death, {
  can_refresh = function (self, event, target, player, data)
    return player:getMark("@[chara]huji-round") == target.id
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[chara]huji-round", 0)
  end,
})

return huji
