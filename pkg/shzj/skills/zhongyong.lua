local zhongyong = fk.CreateSkill {
  name = "shzj_guansuo__zhongyong"
}

Fk:loadTranslationTable{
  ["shzj_guansuo__zhongyong"] = "忠勇",
  [":shzj_guansuo__zhongyong"] = "每回合限X+1次，与你势力相同的角色成为另一名角色使用牌的目标时，若此牌为：基本牌，你可以令其摸一张牌；"..
  "锦囊牌，你可以失去1点体力，代替其成为此牌的目标（X为你已损失体力值）。",

  ["#shzj_guansuo__zhongyong-basic"] = "忠勇：你可以令 %dest 摸一张牌",
  ["#shzj_guansuo__zhongyong-trick"] = "忠勇：你可以失去1点体力，代替 %dest 成为%arg的目标",

  ["$shzj_guansuo__zhongyong1"] = "",
  ["$shzj_guansuo__zhongyong2"] = "",
}

zhongyong:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  times = function(self, player)
    return player:getLostHp() + 1 - player:usedSkillTimes(zhongyong.name, Player.HistoryTurn)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zhongyong.name) and target.kingdom == player.kingdom and data.from ~= target and
      player:usedSkillTimes(zhongyong.name, Player.HistoryTurn) < player:getLostHp() + 1 then
      if data.card.type == Card.TypeBasic then
        return not target.dead
      elseif data.card.type == Card.TypeTrick then
        return target ~= player and player.hp > 0 and not table.contains(data.use.tos, player) and
          data.from:canUseTo(data.card, player, {bypass_distances = true, bypass_times = true})
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#shzj_guansuo__zhongyong-basic::"..target.id
    if data.card.type == Card.TypeTrick then
      prompt = "#shzj_guansuo__zhongyong-trick::"..target.id..":"..data.card:toLogString()
    end
    if room:askToSkillInvoke(player, {
      skill_name = zhongyong.name,
      prompt = prompt,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.type == Card.TypeBasic then
      target:drawCards(1, zhongyong.name)
    elseif data.card.type == Card.TypeTrick then
      data:cancelTarget(target)
      room:loseHp(player, 1, zhongyong.name)
      if not player.dead and not data.from:isProhibited(player, data.card) then
        data:addTarget(player)
      end
    end
  end,
})

return zhongyong
