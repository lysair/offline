local dangjing = fk.CreateSkill {
  name = "ofl__dangjing"
}

Fk:loadTranslationTable{
  ["ofl__dangjing"] = "荡京",
  [":ofl__dangjing"] = "当你发动〖众附〗后，若你装备区内的牌为全场最多，你可以令一名角色进行一次判定，若为你〖众附〗声明的花色，"..
  "你对其造成1点雷电伤害且可以重复此流程。",

  ["#ofl__dangjing-choose"] = "荡京：令一名角色进行判定，若为“众附”花色，对其造成1点雷电伤害且可以再次发动！",
}

local U = require "packages/utility/utility"

dangjing:addEffect(fk.AfterSkillEffect, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dangjing.name) and
      data.skill:getSkeleton().name == "ofl__zhongfu" and
      table.every(player.room.alive_players, function(p)
        return #player:getCardIds("e") >= #p:getCardIds("e")
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__dangjing-choose",
      skill_name = dangjing.name,
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
    local mark = player:getMark("@ofl__zhongfu-round")
    local pattern
    if mark == 0 then
      pattern = "false"
    else
      pattern = ".|.|" .. U.ConvertSuit(mark, "sym", "str")
    end
    local judge = {
      who = to,
      reason = dangjing.name,
      pattern = pattern,
    }
    room:judge(judge)
    if judge:matchPattern() then
      if not to.dead then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = dangjing.name,
        }
      end
      if not player.dead then
        self:doCost(event, target, player, data)
      end
    end
  end,
})

return dangjing
