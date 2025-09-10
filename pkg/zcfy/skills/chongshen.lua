local chongshen = fk.CreateSkill {
  name = "sxfy__chongshen",
}

Fk:loadTranslationTable{
  ["sxfy__chongshen"] = "重身",
  [":sxfy__chongshen"] = "出牌阶段开始时，你可以展示所有手牌并将一种颜色的所有牌当【桃】使用。",

  ["#sxfy__chongshen-invoke"] = "重身：是否展示所有手牌，将一种颜色的牌当【桃】使用？",
  ["#sxfy__chongshen-choice"] = "重身：将一种颜色的所有手牌当【桃】使用",
}

chongshen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chongshen.name) and player.phase == Player.Play and
      not player:isKongcheng() and player:canUse(Fk:cloneCard("peach"))
  end,
  on_cost = function (self,event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chongshen.name,
      prompt = "#sxfy__chongshen-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead or player:isKongcheng() or not player:canUse(Fk:cloneCard("peach")) then return end
    local red = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    local choices = {}
    if #red > 0 then
      local card = Fk:cloneCard("peach")
      card:addSubcards(red)
      card.skillName = chongshen.name
      if player:canUse(card) then
        table.insert(choices, "red")
      end
    end
    if #black > 0 then
      local card = Fk:cloneCard("peach")
      card:addSubcards(black)
      card.skillName = chongshen.name
      if player:canUse(card) then
        table.insert(choices, "black")
      end
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = chongshen.name,
      prompt = "#sxfy__chongshen-choice",
    })
    room:useVirtualCard("peach", choice == "red" and red or black, player, player, chongshen.name)
  end,
})

return chongshen
