
local baobian = fk.CreateSkill {
  name = "sxfy__baobian",
}

Fk:loadTranslationTable{
  ["sxfy__baobian"] = "豹变",
  [":sxfy__baobian"] = "出牌阶段开始时，你可以失去1点体力并指定一名其他角色，其需弃置一张手牌，若此牌为基本牌，你视为对其使用一张【杀】"..
  "（无距离次数限制）。",

  ["#sxfy__baobian-choose"] = "豹变：失去1点体力，令一名角色弃置一张手牌，若为基本牌，视为对其使用【杀】",
  ["#sxfy__baobian-discard"] = "豹变：请弃置一张手牌，若为基本牌，视为 %src 对你使用【杀】！",
}

baobian:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(baobian.name) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = baobian.name,
      prompt = "#sxfy__baobian-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, baobian.name)
    local to = event:getCostData(self).tos[1]
    if to.dead or to:isKongcheng() then return end
    local card = room:askToDiscard(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = baobian.name,
      cancelable = false,
      prompt = "#sxfy__baobian-discard:"..player.id,
    })
    if #card > 0 and Fk:getCardById(card[1]).type == Card.TypeBasic and not to.dead then
      room:useVirtualCard("slash", nil, player, to, baobian.name, true)
    end
  end,
})

return baobian
