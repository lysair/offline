local fencheng = fk.CreateSkill {
  name = "ofl_tx__fencheng",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl_tx__fencheng"] = "焚城",
  [":ofl_tx__fencheng"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.弃置至少X+1张牌（X为该角色的上家以此法弃置牌的数量）；"..
  "2.受到你造成的2点火焰伤害。当你杀死一名角色后，此技能视为未发动过。",

  ["$ofl_tx__fencheng1"] = "我得不到的，你们也别想得到！",
  ["$ofl_tx__fencheng2"] = "让这一切都灰飞烟灭吧！哼哼哼哼……",
}

fencheng:addEffect("active", {
  anim_type = "offensive",
  prompt = "#fencheng",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(fencheng.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player, targets)
    local n = 0
    for _, target in ipairs(targets) do
      if not target.dead then
        local cards = room:askToDiscard(target, {
          min_num = n + 1,
          max_num = 999,
          include_equip = true,
          skill_name = fencheng.name,
          cancelable = true,
          prompt = "#fencheng-discard:::"..(n + 1),
        })
        if #cards == 0 then
          room:damage{
            from = player,
            to = target,
            damage = 2,
            damageType = fk.FireDamage,
            skillName = fencheng.name,
          }
          n = 0
        else
          n = #cards
        end
      end
    end
  end,
})

fencheng:addEffect(fk.Deathed, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(fencheng.name) and data.killer == player and
      player:usedSkillTimes(fencheng.name, Player.HistoryGame) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:setSkillUseHistory(fencheng.name, 0, Player.HistoryGame)
  end,
})

return fencheng
