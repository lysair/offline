local fenwei = fk.CreateSkill{
  name = "shzj_yiling__fenwei",
}

Fk:loadTranslationTable{
  ["shzj_yiling__fenwei"] = "奋威",
  [":shzj_yiling__fenwei"] = "当一张锦囊牌指定至少两个目标后，你可以失去X点体力或〖奋威〗，令此牌对其中任意名目标角色无效"..
  "（X为你发动〖奋威〗次数，至少为1）。",

  ["#shzj_yiling__fenwei-choose"] = "奋威：你可以执行一项，令此%arg对任意个目标无效",
}

fenwei:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fenwei.name) and
      data.card.type == Card.TypeTrick and data.firstTarget and #data.use.tos > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "shzj_yiling__fenwei_active",
      prompt = "#shzj_yiling__fenwei-choose:::"..data.card:toLogString(),
      cancelable = true,
      extra_data = {
        exclusive_targets = table.map(data.use.tos, Util.IdMapper)
      }
    })
    if success and dat then
      event:setCostData(self, {tos = dat.targets, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertTable(data.use.nullifiedTargets, event:getCostData(self).tos)
    if event:getCostData(self).choice == "shzj_yiling__fenwei2" then
      room:handleAddLoseSkills(player, "-shzj_yiling__fenwei")
    else
      room:loseHp(player, math.max(player:usedSkillTimes(fenwei.name, Player.HistoryGame) - 1, 1), fenwei.name)
    end
  end,
})

return fenwei
