local liaoluan = fk.CreateSkill {
  name = "liaoluan",
}

Fk:loadTranslationTable{
  ["liaoluan"] = "缭乱",
  [":liaoluan"] = "每名起义军限一次，出牌阶段，其可以翻面，对攻击范围内一名非起义军角色造成1点伤害。",

  ["#liaoluan"] = "缭乱：你可以翻面，对攻击范围内一名非起义军角色造成1点伤害（每局游戏限一次！）",
}

local U = require "packages/offline/pkg/piracy_e/insurrectionary_util"

liaoluan:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player)
    return U.isInsurrectionary(player) and player:usedSkillTimes(liaoluan.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return not U.isInsurrectionary(to_select) and player:inMyAttackRange(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
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

liaoluan:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    if U.isInsurrectionary(p) and not p:hasSkill(liaoluan.name, true) then
      room:handleAddLoseSkills(p, "liaoluan&", nil, false, true)
    end
  end
end)

liaoluan:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not table.find(room:getOtherPlayers(player, false), function(p)
    return p:hasSkill(liaoluan.name, true)
  end) then
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if U.isInsurrectionary(p) and not p:hasSkill(liaoluan.name, true) then
        room:handleAddLoseSkills(p, "-liaoluan&", nil, false, true)
      end
    end
  elseif U.isInsurrectionary(player) and not is_death then
    room:handleAddLoseSkills(player, "liaoluan&", nil, false, true)
  end
end)

liaoluan:addEffect(U.JoinInsurrectionary, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(liaoluan.name, true) and
      not (target:hasSkill(liaoluan.name, true) or target:hasSkill("liaoluan&", true))
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(target, "liaoluan&", nil, false, true)
  end,
})

liaoluan:addEffect(U.QuitInsurrectionary, {
  can_refresh = function(self, event, target, player, data)
    return target:hasSkill("liaoluan&", true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(target, "-liaoluan&", nil, false, true)
  end,
})

return liaoluan
