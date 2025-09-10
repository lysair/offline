local liaoluan = fk.CreateSkill {
  name = "liaoluan&",
}

Fk:loadTranslationTable{
  ["liaoluan&"] = "缭乱",
  [":liaoluan&"] = "每局游戏限一次，出牌阶段，你可以翻面，对攻击范围内一名非起义军角色造成1点伤害。",
}

local U = require "packages/offline/ofl_util"

liaoluan:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player)
    return U.isInsurrectionary(player) and player:usedSkillTimes("liaoluan", Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return not U.isInsurrectionary(to_select) and player:inMyAttackRange(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:addSkillUseHistory("liaoluan", 1)
    player:turnOver()
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = liaoluan.name,
      }
    end
  end,
})

return liaoluan
