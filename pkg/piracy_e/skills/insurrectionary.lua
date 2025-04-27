local insurrectionary = fk.CreateSkill {
  name = "insurrectionary&",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["insurrectionary&"] = "起义军",
  [":insurrectionary&"] = "锁定技，<br>起义军出牌阶段使用【杀】次数上限+1。<br>起义军的回合结束时，若本回合未对起义军角色使用过【杀】且"..
  "未对非起义军角色造成过伤害，需选择一项：1.失去起义军标记并弃置所有手牌；2.失去1点体力。<br>非起义军角色对起义军角色使用【杀】次数上限+1。",

  ["@[:]insurrectionary"] = "",
  ["insurrectionary_banner"] = "起义军",
  [":insurrectionary_banner"] = "锁定技，<br>起义军出牌阶段使用【杀】次数上限+1。<br>起义军的回合结束时，若本回合未对起义军角色使用过【杀】且"..
  "未对非起义军角色造成过伤害，需选择一项：1.失去起义军标记并弃置所有手牌；2.失去1点体力。<br>非起义军角色对起义军角色使用【杀】次数上限+1。",
  ["#JoinInsurrectionary"] = "%from 加入了起义军",
  ["#QuitInsurrectionary"] = "%from 退出了起义军",
  ["QuitInsurrectionary"] = "退出起义军并弃置所有手牌",
}

local U = require "packages/offline/ofl_util"

insurrectionary:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and U.isInsurrectionary(player) and not player.dead and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        return use.from == player and use.card.trueName == "slash" and
          table.find(use.tos, function (p)
            return U.isInsurrectionary(p)
          end) ~= nil
      end, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data
        return damage.from == player and not U.isInsurrectionary(damage.to)
      end) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"QuitInsurrectionary", "loseHp"},
      skill_name = insurrectionary.name,
    })
    if choice == "QuitInsurrectionary" then
      room:setPlayerMark(player, "@!insurrectionary", 0)
      local record = room:getBanner("insurrectionary") or {}
      table.removeOne(record, player.id)
      if #record == 0 then
        room:setBanner("insurrectionary", nil)
        room:setBanner("@[:]insurrectionary", nil)
      else
        room:setBanner("insurrectionary", record)
      end
      room:sendLog{
        type = "#QuitInsurrectionary",
        from = player.id,
        toast = true,
      }
      room.logic:trigger(U.QuitInsurrectionary, player, {who = player, reason = "game_rule"}, false)
      if not player:isKongcheng() then
        player:throwAllCards("h")
      end
    else
      room:loseHp(player, 1, insurrectionary.name)
    end
  end,
})

insurrectionary:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card, to)
    if Fk:currentRoom():getBanner("insurrectionary") and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      if U.isInsurrectionary(player) then
        return 1
      elseif U.isInsurrectionary(to) then
        return 1
      end
    end
  end,
})

return insurrectionary
