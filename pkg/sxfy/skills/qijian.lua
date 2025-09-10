
local qijian = fk.CreateSkill {
  name = "sxfy__qijian",
}

Fk:loadTranslationTable{
  ["sxfy__qijian"] = "七笺",
  [":sxfy__qijian"] = "准备阶段，你令两名手牌数之和为7的角色依次选择一项：1.弃置对方一张牌；2.对方摸一张牌。",

  ["#sxfy__qijian-choose"] = "七笺：令两名手牌数之和为7的角色选择弃置对方一张牌或对方摸一张牌",
  ["sxfy__qijian_discard"] = "弃置%dest一张牌",
  ["sxfy__qijian_draw"] = "%dest摸一张牌",
}

qijian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qijian.name) and player.phase == Player.Start and
      table.find(player.room.alive_players, function (p)
        return table.find(player.room.alive_players, function (q)
          return p:getHandcardNum() + q:getHandcardNum() == 7
        end) ~= nil
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "sxfy__qijian_active",
      prompt = "#sxfy__qijian-choose",
      cancelable = true
    })
    if success and dat then
      room:sortByAction(dat.targets)
      event:setCostData(self, { tos = dat.targets })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    if not targets[2]:isNude() and
      room:askToChoice(targets[1], {
        choices = {"sxfy__qijian_discard::"..targets[2].id, "sxfy__qijian_draw::"..targets[2].id},
        skill_name = qijian.name,
      }):startsWith("sxfy__qijian_discard") then
      local card = room:askToChooseCard(targets[1], {
        target = targets[2],
        flag = "he",
        skill_name = qijian.name,
      })
      room:throwCard(card, qijian.name, targets[2], targets[1])
    else
      targets[2]:drawCards(1, qijian.name)
    end
    if targets[1].dead or targets[2].dead then return end
    if not targets[1]:isNude() and
      room:askToChoice(targets[2], {
        choices = {"sxfy__qijian_discard::"..targets[1].id, "sxfy__qijian_draw::"..targets[1].id},
        skill_name = qijian.name,
      }):startsWith("sxfy__qijian_discard") then
      local card = room:askToChooseCard(targets[2], {
        target = targets[1],
        flag = "he",
        skill_name = qijian.name,
      })
      room:throwCard(card, qijian.name, targets[1], targets[2])
    else
      targets[1]:drawCards(1, qijian.name)
    end
  end,
})

return qijian
