
local shuangren = fk.CreateSkill {
  name = "sxfy__shuangren",
}

Fk:loadTranslationTable{
  ["sxfy__shuangren"] = "双刃",
  [":sxfy__shuangren"] = "出牌阶段开始时，你可以与一名其他角色拼点，若你赢，你可以视为对其距离1的至多两名角色各使用一张【杀】"..
  "（无距离限制，计入次数）；若你没赢，你本回合不能使用【杀】。",

  ["#sxfy__shuangren-choose"] = "双刃：你可以拼点，若赢，视为对目标距离1的至多两名角色使用【杀】！",
  ["#sxfy__shuangren-use"] = "双刃：视为对 %dest 距离1的至多两名角色使用【杀】！",
}

shuangren:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangren.name) and player.phase == Player.Play and
      not player:isKongcheng() and
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
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shuangren.name,
      prompt = "#sxfy__shuangren-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local pindian = player:pindian({to}, shuangren.name)
    if pindian.results[to].winner == player then
      if player.dead then return end
      local card = Fk:cloneCard("slash")
      card.skillName = shuangren.name
      if player:prohibitUse(card) then return end
      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
          return p:distanceTo(to) == 1 and not player:isProhibited(p, card)
        end)
      if #targets == 0 then return end
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 2,
        targets = targets,
        skill_name = shuangren.name,
        prompt = "#sxfy__shuangren-use::"..to.id,
        cancelable = true,
      })
      if #tos > 0 then
        room:sortByAction(tos)
        for _, p in ipairs(tos) do
          if player.dead then return end
          if not p.dead then
            room:useVirtualCard("slash", nil, player, p, shuangren.name, false)
          end
        end
      end
    else
      room:setPlayerMark(player, "sxfy__shuangren_fail-turn", 1)
    end
  end,
})

shuangren:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and player:getMark("sxfy__shuangren_fail-turn") > 0 and card.trueName == "slash"
  end,
})

return shuangren
