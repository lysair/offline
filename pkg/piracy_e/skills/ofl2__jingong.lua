local jingong = fk.CreateSkill{
  name = "ofl2__jingong",
}

Fk:loadTranslationTable{
  ["ofl2__jingong"] = "矜功",
  [":ofl2__jingong"] = "出牌阶段限一次，你可以将一张【杀】或装备牌当任意锦囊牌使用，本回合结束阶段，若你本回合未造成过伤害，你失去1点体力。",

  ["#ofl2__jingong"] = "矜功：你可以将一张【杀】或装备牌当任意锦囊牌使用",
}

local U = require "packages/utility/utility"

jingong:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl2__jingong",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("td")
    table.insertTable(all_names, { "honey_trap", "daggar_in_smile" })
    local names = player:getViewAsCardNames(jingong.name, all_names)
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and (card.trueName == "slash" or card.type == Card.TypeEquip)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = jingong.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(jingong.name, Player.HistoryPhase) == 0
  end,
})

jingong:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish and not player.dead and
      player:usedSkillTimes(jingong.name, Player.HistoryTurn) > 0 and
      #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == player
      end, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, jingong.name)
  end,
})

return jingong
