local wufei = fk.CreateSkill {
  name = "sxfy__wufei",
}

Fk:loadTranslationTable{
  ["sxfy__wufei"] = "诬诽",
  [":sxfy__wufei"] = "准备阶段，你可以令一名女性角色展示所有手牌，然后其弃置其中一种颜色的牌并摸一张牌。",

  ["#sxfy__wufei-choose"] = "诬诽：令一名女性角色弃置一种颜色的手牌并摸一张牌",
}

wufei:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wufei.name) and player.phase == Player.Start and
      table.find(player.room.alive_players, function (p)
        return p:isFemale() and not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:isFemale() and not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = wufei.name,
      prompt = "#sxfy__wufei-choose",
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
    to:showCards(to:getCardIds("h"))
    if to.dead or to:isKongcheng() then return end
    local colors = {}
    local red = table.filter(to:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Red and not to:prohibitDiscard(id)
    end)
    local black = table.filter(to:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Black and not to:prohibitDiscard(id)
    end)
    if #red > 0 then
      table.insert(colors, "red")
    end
    if #black > 0 then
      table.insert(colors, "black")
    end
    if #colors == 0 then return end
    local color = room:askToChoice(to, {
      choices = colors,
      skill_name = wufei.name,
      all_choices = {"red", "black"},
    })
    local cards = color == "red" and red or black
    room:throwCard(cards, wufei.name, to, to)
    if not to.dead then
      to:drawCards(1, wufei.name)
    end
  end,
})

return wufei
