local zhiyang = fk.CreateSkill {
  name = "zhiyang"
}

Fk:loadTranslationTable{
  ["zhiyang"] = "志扬",
  [":zhiyang"] = "你的红色拼点牌点数视为K。当你受到伤害后，你可以令伤害来源对你发动两次〖制霸〗。",

  ["#zhiyang-invoke"] = "志扬：是否令 %dest 对你发动两次“制霸”？",

  ["$zhiyang1"] = "天下之大，我可尽情驰骋！",
  ["$zhiyang2"] = "诸位，今日便让天下知我江东男儿勇武！",
}

zhiyang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiyang.name) and
      data.from and data.from:canPindian(player)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = zhiyang.name,
      prompt = "#zhiyang-invoke::"..data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local yes = false
    if not player:hasSkill("zhiba", true) then
      yes = true
      room:handleAddLoseSkills(player, "zhiba", nil, false, true)
    end
    local skill = Fk.skills["zhiba_active&"]
    for _ = 1, 2 do
      if data.from:canPindian(player) then
        skill:onUse(room, {
          from = data.from,
          tos = {player},
        })
      end
    end
    if yes then
      room:handleAddLoseSkills(player, "-zhiba", nil, false, true)
    end
  end,
})

zhiyang:addEffect(fk.PindianCardsDisplayed, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zhiyang.name) then
      if data.from == player then
        return data.fromCard and data.fromCard.color == Card.Red
      elseif table.contains(data.tos, player) then
        return data.results[player].toCard and data.results[player].toCard.color == Card.Red
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changePindianNumber(data, player, 13, zhiyang.name)
  end,
})

return zhiyang
