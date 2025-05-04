local yinge = fk.CreateSkill {
  name = "ofl_shiji__yinge",
}

Fk:loadTranslationTable{
  ["ofl_shiji__yinge"] = "引戈",
  [":ofl_shiji__yinge"] = "出牌阶段限一次，你可以令一名其他角色将一张手牌置入<a href='RenPile_href'>“仁”区</a>，然后其可以使用一张“仁”区牌，"..
  "若此牌为伤害类牌，额外指定你为目标。",

  ["#ofl_shiji__yinge"] = "引戈：令一名角色将一张手牌置入仁区，然后其可以使用一张仁区牌，若为伤害牌则额外指定你为目标",
  ["#ofl_shiji__yinge-ask"] = "引戈：请将一张手牌置入仁区，然后你可以使用一张仁区牌",
  ["#ofl_shiji__yinge-use"] = "引戈：你可以使用一张仁区牌，若为伤害牌，额外指定 %src 为目标",
}

local U = require "packages/utility/utility"

yinge:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_shiji__yinge",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yinge.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yinge.name,
      cancelable = false,
      prompt = "#ofl_shiji__yinge-ask",
    })
    U.AddToRenPile(target, card, yinge.name)
    local cards = U.GetRenPile(room)
    if target.dead or #cards == 0 then return end
    local use = room:askToUseRealCard(target, {
      pattern = cards,
      skill_name = yinge.name,
      prompt = "#ofl_shiji__yinge-use:"..player.id,
      extra_data = {
        bypass_times = true,
        expand_pile = cards,
        extraUse = true,
      },
      cancelable = true,
      skip = true,
    })
    if use then
      if use.card.is_damage_card and not use.card.multiple_targets and
        target:canUseTo(use.card, player, {bypass_distances = true, bypass_times = true}) then
        table.insertIfNeed(use.tos, player)
        room:sortByAction(use.tos)
      end
      room:useCard(use)
    end
  end,
})

return yinge
