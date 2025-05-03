local zhaoxin = fk.CreateSkill {
  name = "sxfy__zhaoxin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhaoxin"] = "昭心",
  [":sxfy__zhaoxin"] = "锁定技，准备阶段，你展示所有手牌，若红色牌和黑色牌数量相同，你对一名角色造成1点伤害。",

  ["#sxfy__zhaoxin-choose"] = "昭心：对一名角色造成1点伤害",
}

zhaoxin:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhaoxin.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(player:getCardIds("h"))
    local red = table.filter(cards, function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(cards, function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    player:showCards(cards)
    if player.dead then return end
    if #red == #black then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = zhaoxin.name,
        prompt = "#sxfy__zhaoxin-choose",
        cancelable = false,
      })[1]
      player.room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = zhaoxin.name,
      }
    end
  end,
})

return zhaoxin
