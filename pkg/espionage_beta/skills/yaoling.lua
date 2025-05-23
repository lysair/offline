local yaoling = fk.CreateSkill {
  name = "yaoling",
}

Fk:loadTranslationTable{
  ["yaoling"] = "耀令",
  [":yaoling"] = "出牌阶段结束时，你可以减1点体力上限，令一名其他角色选择一项：1.对你指定的另一名角色使用一张【杀】；2.你弃置其一张牌。",

  ["#yaoling-choose"] = "耀令：减1点体力上限选择一名角色，其需对你指定的角色使用【杀】或你弃置其一张牌",
  ["#yaoling-dest"] = "耀令：选择令 %dest 使用【杀】的目标",
  ["#yaoling-use"] = "耀令：对 %dest 使用【杀】，否则 %src 弃置你一张牌",
}

yaoling:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaoling.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#yaoling-choose",
      skill_name = yaoling.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    local to = event:getCostData(self).tos[1]
    if player.dead or to.dead then return end
    local dest = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(to, false),
      min_num = 1,
      max_num = 1,
      prompt = "#yaoling-dest::" .. to.id,
      skill_name = yaoling.name,
      cancelable = false,
      no_indicate = true,
    })[1]
    room:doIndicate(to, {dest})
    local use = room:askToUseCard(to, {
      skill_name = yaoling.name,
      pattern = "slash",
      prompt = "#yaoling-use:" .. player.id .. ":" .. dest,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        must_targets = {dest.id},
      }
    })
    if use then
      use.extraUse = true
      room:useCard(use)
    elseif not to:isNude() then
      local card = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = yaoling.name
      })
      room:throwCard(card, yaoling.name, to, player)
    end
  end,
})

return yaoling
