local luanwu = fk.CreateSkill({
  name = "ofl_mou__luanwu",
  tags = { Skill.Limited },
})

Fk:loadTranslationTable{
  ["ofl_mou__luanwu"] = "乱武",
  [":ofl_mou__luanwu"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.对距离最近的另一名其他角色使用一张【杀】；" ..
  "2.失去1点体力。",

  ["#ofl_mou__luanwu"] = "乱武：令所有其他角色选择使用【杀】或失去体力！",

  ["$ofl_mou__luanwu1"] = "你们之中谁的命更重要？嗯？自己选择吧！",
  ["$ofl_mou__luanwu2"] = "这次能活着离开的，不过我一掌之数！",
}

luanwu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_mou__luanwu",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(luanwu.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player, targets)
    for _, target in ipairs(targets) do
      if target:isAlive() then
        local other_players = table.filter(room:getOtherPlayers(target, false), function(p)
          return not p:isRemoved() and p ~= player
        end)
        local luanwu_targets = table.map(table.filter(other_players, function(p2)
          return table.every(other_players, function(p1)
            return target:distanceTo(p1) >= target:distanceTo(p2)
          end)
        end), Util.IdMapper)
        local use = room:askToUseCard(target, {
          pattern = "slash",
          skill_name = luanwu.name,
          prompt = "#luanwu-use",
          extra_data = {
            include_targets = luanwu_targets,
            bypass_times = true,
          }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          room:loseHp(target, 1, luanwu.name)
        end
      end
    end
  end,
})

return luanwu
