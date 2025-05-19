
local lianji = fk.CreateSkill{
  name = "ofl2__lianji",
}

Fk:loadTranslationTable{
  ["ofl2__lianji"] = "连计",
  [":ofl2__lianji"] = "出牌阶段限一次，你可以令一名其他角色摸一张牌，然后令其视为使用一张你选择的伤害牌。",

  ["#ofl2__lianji"] = "连计：令一名其他角色摸一张牌，然后令其视为使用你选择的伤害牌",
  ["#ofl2__lianji-choice"] = "连计：选择令 %dest 视为使用的伤害牌",
  ["#ofl2__lianji-use"] = "连计：请视为使用【%arg】",
}

local U = require "packages/utility/utility"

lianji:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl2__lianji",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:drawCards(1, lianji.name)
    if player.dead or target.dead then return end
    local cards = room:getBanner(lianji.name)
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = lianji.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ofl2__lianji-choice::"..target.id,
      cancelable = false,
      expand_pile = cards,
    })[1]
    local name = Fk:getCardById(card).name
    room:askToUseVirtualCard(target, {
      name = name,
      skill_name = lianji.name,
      prompt = "#ofl2__lianji-use:::"..name,
      cancelable = false,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
  end,
})

lianji:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(lianji.name) then
    local ids = {}
    for _, id in ipairs(U.getUniversalCards(room, "bt")) do
      if Fk:getCardById(id).is_damage_card then
        table.insert(ids, id)
      end
    end
    room:setBanner(lianji.name, ids)
  end
end)

return lianji
