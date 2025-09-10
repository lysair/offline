local songshu = fk.CreateSkill {
  name = "ofl_shiji__songshu",
}

Fk:loadTranslationTable{
  ["ofl_shiji__songshu"] = "颂蜀",
  [":ofl_shiji__songshu"] = "一名角色出牌阶段开始时，你可以将一张牌置入<a href='RenPile_href'>“仁”区</a>，然后若“仁”区牌数不小于其手牌数，"..
  "你令其本回合只能使用或打出“仁”区牌。",

  ["#ofl_shiji__songshu-invoke"] = "颂蜀：将一张牌置入仁区，若仁区牌数不小于 %dest 手牌数，其本回合只能使用打出仁区牌",
  ["@@ofl_shiji__songshu-turn"] = "颂蜀",

  ["$ofl_shiji__songshu1"] = "以陛下之聪恣，可比古贤。",
  ["$ofl_shiji__songshu2"] = "庭若灿星，统于有道之君。",
}

local U = require "packages/utility/utility"

songshu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(songshu.name) and target.phase == Player.Play and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = songshu.name,
      include_equip = true,
      prompt = "#ofl_shiji__songshu-invoke::" .. target.id,
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    U.AddToRenPile(player, event:getCostData(self).cards, songshu.name)
    if target.dead then return end
    if #U.GetRenPile(room) >= target:getHandcardNum() then
      room:setPlayerMark(target, "@@ofl_shiji__songshu-turn", 1)
    end
  end,
})

songshu:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl_shiji__songshu-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards == 0 or table.find(subcards, function(id)
        return not table.contains(U.GetRenPile(Fk:currentRoom()) or {}, id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@ofl_shiji__songshu-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards == 0 or table.find(subcards, function(id)
        return not table.contains(U.GetRenPile(Fk:currentRoom()) or {}, id)
      end)
    end
  end,
})

songshu:addEffect("filter", {
  handly_cards = function (self, player)
    if player:getMark("@@ofl_shiji__songshu-turn") > 0 then
      return U.GetRenPile(Fk:currentRoom())
    end
  end,
})

return songshu
