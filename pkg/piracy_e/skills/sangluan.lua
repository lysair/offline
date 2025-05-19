local sangluan = fk.CreateSkill {
  name = "sangluan",
}

Fk:loadTranslationTable{
  ["sangluan"] = "丧乱",
  [":sangluan"] = "当你使用伤害牌后，你可以令一名其他角色对你指定的另一名角色使用一张【杀】，否则其失去1点体力且你回复1点体力。",

  ["#sangluan-choose"] = "丧乱：选择一名其他角色，其需对你指定的角色使用【杀】，否则其失去1点体力且你回复1点体力",
  ["#sangluan-victim"] = "丧乱：选择令 %dest 使用【杀】的目标",
  ["#sangluan-use"] = "丧乱：对 %dest 使用【杀】，否则你失去1点体力且 %src 回复1点体力",
}

sangluan:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(sangluan.name) and data.card.is_damage_card and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = sangluan.name,
      prompt = "#sangluan-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMarkIfNeed(player, "longmu", to.id)
    local victim = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(to, false),
      skill_name = sangluan.name,
      prompt = "#sangluan-victim::"..to.id,
      cancelable = false,
      no_indicate = true,
    })[1]
    room:doIndicate(to, {victim.id})
    local use = room:askToUseCard(to, {
      skill_name = sangluan.name,
      pattern = "slash",
      prompt = "#sangluan-use:"..player.id..":"..victim.id,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        exclusive_targets = {victim.id},
      }
    })
    if use then
      use.extraUse = true
      room:useCard(use)
    else
      room:loseHp(to, 1, sangluan.name)
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = sangluan.name,
        }
      end
    end
  end,
})

return sangluan
