
local bizun = fk.CreateSkill {
  name = "bizun",
}

Fk:loadTranslationTable{
  ["bizun"] = "避尊",
  [":bizun"] = "每回合限一次，你可以将一张装备牌当【杀】或【闪】使用，然后手牌唯一最多的角色可以移动场上一张牌。",

  ["#bizun"] = "避尊：你可以将一张装备牌当【杀】或【闪】使用",
  ["#bizun-move"] = "避尊：你可以移动场上一张牌",
}

bizun:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = "#bizun",
  interaction = function(self, player)
    local all_names = {"slash", "jink"}
    local names = player:getViewAsCardNames(bizun.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = bizun.name
    return card
  end,
  after_use = function (self, player, use)
    local room = player.room
    local to = table.filter(room.alive_players, function (p)
      return table.every(room.alive_players, function (q)
        return p:getHandcardNum() >= q:getHandcardNum()
      end)
    end)
    if #to ~= 1 then return end
    to = to[1]
    if #room:canMoveCardInBoard() > 0 then
      local targets = room:askToChooseToMoveCardInBoard(player, {
        skill_name = bizun.name,
        prompt = "#bizun-move",
        cancelable = true,
      })
      if #targets > 0 then
        room:askToMoveCardInBoard(to, {
          skill_name = bizun.name,
          target_one = targets[1],
          target_two = targets[2],
        })
      end
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(bizun.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(bizun.name, Player.HistoryTurn) == 0
  end,
})

return bizun
