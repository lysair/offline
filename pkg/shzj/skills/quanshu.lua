local quanshu = fk.CreateSkill {
  name = "quanshu",
}

Fk:loadTranslationTable{
  ["quanshu"] = "权术",
  [":quanshu"] = "当你议事结束后或当你受到伤害后，你可以摸X张牌并<a href='premeditate_href'>“蓄谋”</a>；你的手牌上限+X（X为你场上的牌数）。",

  ["#quanshu-ask"] = "权术：请蓄谋一张手牌",
}

local U = require "packages/utility/utility"

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#player:getCardIds("ej"), quanshu.name)
    if not player.dead and not table.contains(player.sealedSlots, Player.JudgeSlot) and not player:isKongcheng() then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = quanshu.name,
        cancelable = false,
        prompt = "#quanshu-ask",
      })
      U.premeditate(player, card, quanshu.name)
    end
  end,
}

quanshu:addEffect(U.DiscussionFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return (target == player or table.contains(data.tos, player)) and player:hasSkill(quanshu.name) and
      #player:getCardIds("ej") > 0
  end,
  on_use = spec.on_use,
})

quanshu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(quanshu.name) and
      #player:getCardIds("ej") > 0
  end,
  on_use = spec.on_use,
})

quanshu:addEffect("maxcards", {
  correct_func = function (self, player)
    if player:hasSkill(quanshu.name) then
      return #player:getCardIds("ej")
    end
  end,
})

return quanshu
