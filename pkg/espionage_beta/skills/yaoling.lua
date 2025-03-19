local yaoling = fk.CreateSkill {
  name = "yaoling"
}

Fk:loadTranslationTable{
  ['yaoling'] = '耀令',
  ['#yaoling-choose'] = '耀令：减1点体力上限选择一名角色，其需对你指定的角色使用【杀】或你弃置其一张牌',
  ['#yaoling-dest'] = '耀令：选择令 %dest 使用【杀】的目标',
  ['#yaoling-use'] = '耀令：对 %dest 使用【杀】，否则 %src 弃置你一张牌',
  [':yaoling'] = '出牌阶段结束时，你可以减1点体力上限，令一名其他角色选择一项：1.对你指定的另一名角色使用一张【杀】；2.你弃置其一张牌。',
}

yaoling:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(yaoling.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#yaoling-choose",
      skill_name = yaoling.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:changeMaxHp(player, -1)
    local to = room:getPlayerById(event:getCostData(self))
    if player.dead or to.dead then return end
    local dest = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(to), function(p) return p.id end),
      min_num = 1,
      max_num = 1,
      prompt = "#yaoling-dest::" .. to.id,
      skill_name = yaoling.name,
      cancelable = false
    })
    if #dest > 0 then
      dest = dest[1]
    else
      dest = player.id
    end
    local use = room:askToUseCard(to, {
      pattern = "slash",
      prompt = "#yaoling-use:" .. player.id .. ":" .. dest,
      cancelable = true,
      extra_data = {must_targets = {dest}}
    })
    if use then
      room:useCard(use)
    else
      if not to:isNude() then
        room:doIndicate(player.id, {to.id})
        local card = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = yaoling.name
        })
        room:throwCard({card}, yaoling.name, to, player)
      end
    end
  end,
})

return yaoling
