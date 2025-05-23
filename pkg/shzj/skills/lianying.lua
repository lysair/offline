local lianying = fk.CreateSkill({
  name = "shzj_guansuo__lianying",
})

Fk:loadTranslationTable{
  ["shzj_guansuo__lianying"] = "连营",
  [":shzj_guansuo__lianying"] = "当你不因〖谦逊〗或〖连营〗失去最后一张手牌后，你可以摸两张牌，然后选择一项：1.弃置一张手牌；"..
  "2.弃置两张牌，选择一种牌名，令此牌名的牌对你无效，直到你的回合开始。",

  ["shzj_guansuo__lianying1"] = "弃置一张手牌",
  ["shzj_guansuo__lianying2"] = "弃置两张牌，令一种牌名对你无效直到回合开始",
  ["#shzj_guansuo__lianying-choice"] = "连营：选择一种牌名，此牌对你无效直到你回合开始",
  ["@$shzj_guansuo__lianying"] = "连营",

  ["$shzj_guansuo__lianying1"] = "火烧蜀营八百里，扬我东吴万世名。",
  ["$shzj_guansuo__lianying2"] = "蜀营连绵不断，待我一场大火，尽摧敌军心胆。",
}

local U = require "packages/utility/utility"

lianying:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(lianying.name) and player:isKongcheng()) then return end
    for _, move in ipairs(data) do
      if move.from == player and move.skillName ~= "shzj_guansuo__qianxun" and move.skillName ~= lianying.name then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, lianying.name)
    if player.dead then return end
    local choices = {}
    if table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "shzj_guansuo__lianying1")
    end
    if #table.filter(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end) > 1 then
      table.insert(choices, "shzj_guansuo__lianying2")
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = lianying.name,
    })
    if choice == "shzj_guansuo__lianying1" then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = lianying.name,
        cancelable = false,
      })
    else
      room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = lianying.name,
        cancelable = false,
      })
      if player.dead then return end
      local name = U.askForChooseCardNames(room, player, Fk:getAllCardNames("btde", true), 1, 1, lianying.name,
        "#shzj_guansuo__lianying-choice")
      room:addTableMarkIfNeed(player, "@$shzj_guansuo__lianying", name[1])
    end
  end,
})

lianying:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and table.contains(player:getTableMark("@$shzj_guansuo__lianying"), data.card.trueName)
  end,
  on_use = function (self, event, target, player, data)
    data.nullified = true
  end,
})

lianying:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@$shzj_guansuo__lianying", 0)
  end,
})

return lianying
