local shuangren = fk.CreateSkill {
  name = "ofl_tx__shuangren",
}

Fk:loadTranslationTable{
  ["ofl_tx__shuangren"] = "双刃",
  [":ofl_tx__shuangren"] = "出牌阶段开始时或结束时，你可以与一名角色拼点：若你赢，你可以视为对与其距离不大于1的至多两名角色依次使用一张"..
  "无距离限制的【杀】；若你没赢，你获得双方拼点牌。",

  ["#ofl_tx__shuangren-choose"] = "双刃：与一名角色拼点，若赢则对两名角色使用【杀】，没赢获得双方拼点牌",
  ["#ofl_tx__shuangren-slash"] = "双刃：你可以视为对至 %dest 距离不大于1的至多两名角色依次使用一张【杀】",

  ["$ofl_tx__shuangren1"] = "仲国大将纪灵在此！",
  ["$ofl_tx__shuangren2"] = "吃我一记三尖两刃刀！",
}

local spec =  {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangren.name) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return player:canPindian(p)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = shuangren.name,
      prompt = "#ofl_tx__shuangren-choose",
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local pindian = player:pindian({ to }, shuangren.name)
    if player.dead then return end
    if pindian.results[to].winner == player then
      local slash = Fk:cloneCard("slash")
      if player:prohibitUse(slash) then return false end
      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return p:compareDistance(to, 1, "<=") and
          player:canUseTo(Fk:cloneCard("slash"), p, { bypass_distances = true, bypass_times = true })
      end)
      if #targets == 0 then return end
      local victims = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 2,
        skill_name = shuangren.name,
        prompt = "#ofl_tx__shuangren-slash::" .. to.id,
      })
      if #victims > 0 then
        room:sortByAction(victims)
        for _, p in ipairs(victims) do
          if player.dead then return end
          if not p.dead then
            room:useVirtualCard("slash", nil, player, p, shuangren.name, true)
          end
        end
      end
    else
      local cards = {}
      if pindian.fromCard then
        cards = Card:getIdList(pindian.fromCard)
      end
      if pindian.results[to].toCard then
        table.insertTableIfNeed(cards, Card:getIdList(pindian.results[to].toCard))
      end
      cards = table.filter(cards, function (id)
        return table.contains(room.discard_pile, id)
      end)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, shuangren.name, nil, true, player)
      end
    end
  end,
}

shuangren:addEffect(fk.EventPhaseStart, spec)
shuangren:addEffect(fk.EventPhaseEnd, spec)

return shuangren
