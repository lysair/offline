local liaoluan = fk.CreateSkill {
  name = "liaoluan"
}

Fk:loadTranslationTable{
  ['liaoluan&'] = '缭乱',
  ['#liaoluan'] = '缭乱：你可以翻面，对攻击范围内一名非起义军角色造成1点伤害（每局游戏限一次！）',
  ['liaoluan'] = '缭乱',
  [':liaoluan&'] = '每局游戏限一次，出牌阶段，你可以翻面，对攻击范围内一名非起义军角色造成1点伤害。',
}

liaoluan:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player, card, extra_data)
    return IsInsurrectionary(player) and
      player:usedSkillTimes(liaoluan.name, Player.HistoryGame) + player:usedSkillTimes("liaoluan", Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return not IsInsurrectionary(target) and player:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:turnOver()
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skill_name = liaoluan.name,
      }
    end
  end,
})

return liaoluan
