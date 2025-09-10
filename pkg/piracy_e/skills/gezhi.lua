local gezhi = fk.CreateSkill{
  name = "ofl__gezhi",
}

Fk:loadTranslationTable{
  ["ofl__gezhi"] = "革制",
  [":ofl__gezhi"] = "当你使用牌时，你可以重铸三种类别的牌各一张，然后选择一项：1.回复1点体力；2.使用下一张牌无次数限制；"..
  "3.对一名其他角色造成1点伤害（每名角色限选一次）。",

  ["#ofl__gezhi-invoke"] = "革制：你可以重铸三种类别的牌各一张，然后执行效果",
  ["ofl__gezhi2"] = "使用下一张牌无次数限制",
  ["ofl__gezhi3"] = "对一名其他角色造成1点伤害",
  ["@@ofl__gezhi2"] = "革制",
  ["#ofl__gezhi-choose"] = "革制：对一名其他角色造成1点伤害",

  ["$ofl__gezhi1"] = "发奋图兴，社稷也！",
  ["$ofl__gezhi2"] = "国泰民安，夫复何求！",
}

gezhi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(gezhi.name) and #player:getCardIds("he") > 2
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__gezhi_active",
      prompt = "#ofl__gezhi-invoke",
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:recastCard(event:getCostData(self).cards, player, gezhi.name)
    if player.dead then return end
    local choices = {"ofl__gezhi2"}
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not table.contains(player:getTableMark(gezhi.name), p.id)
    end)
    if #targets > 0 then
      table.insert(choices, "ofl__gezhi3")
    end
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = gezhi.name,
      all_choices = {"recover", "ofl__gezhi2", "ofl__gezhi3"},
    })
    if choice == "recover" then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = gezhi.name,
      }
    elseif choice == "ofl__gezhi2" then
      room:setPlayerMark(player, "@@ofl__gezhi2", 1)
    elseif choice == "ofl__gezhi3" then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = gezhi.name,
        prompt = "#ofl__gezhi-choose",
        cancelable = true,
      })
      if #to > 0 then
        room:addTableMark(player, gezhi.name, to[1].id)
        room:damage{
          from = player,
          to = to[1],
          damage = 1,
          skillName = gezhi.name,
        }
      else
        room:setPlayerMark(player, "@@ofl__gezhi2", 1)
      end
    end
  end,
})

gezhi:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__gezhi2") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl__gezhi2", 0)
    data.extraUse = true
  end,
})

gezhi:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:getMark("@@ofl__gezhi2") > 0
  end,
})

return gezhi
