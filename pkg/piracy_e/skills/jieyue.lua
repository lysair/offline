local jieyue = fk.CreateSkill({
  name = "ofl__jieyue",
})

Fk:loadTranslationTable{
  ["ofl__jieyue"] = "节钺",
  [":ofl__jieyue"] = "每轮各限一次，结束阶段，你可以令一名角色摸一张牌，其选择一项：1.令你摸三张牌；2.失去1点体力，令你执行一个额外回合。",

  ["#ofl__jieyue-choose"] = "节钺：令一名角色摸一张牌，其选择令你摸三张牌，或其失去体力你执行额外回合",
  ["ofl__jieyue1"] = "%src摸三张牌",
  ["ofl__jieyue2"] = "失去1点体力，%src执行一个额外回合",
}

jieyue:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieyue.name) and player.phase == Player.Finish and
      #player:getTableMark("ofl__jieyue-round") < 2
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__jieyue-choose",
      skill_name = jieyue.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    to:drawCards(1, jieyue.name)
    if to.dead or player.dead then return end
    local choices = {}
    if not table.contains(player:getTableMark("ofl__jieyue-round"), "ofl__jieyue1") then
      table.insert(choices, "ofl__jieyue1:"..player.id)
    end
    if not table.contains(player:getTableMark("ofl__jieyue-round"), "ofl__jieyue2") then
      table.insert(choices, "ofl__jieyue2:"..player.id)
    end
    local choice = room:askToChoice(to, {
      choices = choices,
      skill_name = jieyue.name,
    })
    if choice:startsWith("ofl__jieyue1") then
      room:addTableMark(player, "ofl__jieyue-round", "ofl__jieyue1")
      player:drawCards(3, jieyue.name)
    else
      room:addTableMark(player, "ofl__jieyue-round", "ofl__jieyue2")
      player:gainAnExtraTurn(true, jieyue.name)
      room:loseHp(to, 1, jieyue.name)
    end
  end,
})

return jieyue
