local danxin = fk.CreateSkill {
  name = "sxfy__danxin",
}

Fk:loadTranslationTable{
  ["sxfy__danxin"] = "殚心",
  [":sxfy__danxin"] = "当你受到伤害后，你可以发动一次〖矫诏〗且改为你获得其展示的一张牌。",

  ["#sxfy__danxin-choose"] = "殚心：你可以对一名角色发动“矫诏”，且改为你获得其展示的一张牌",
}

danxin:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(danxin.name) and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "sxfy__jiaozhao",
      prompt = "#sxfy__danxin-choose:::"..data.card:toLogString(),
      cancelable = true,
      skip = true,
    })
    if success and dat then
      event:setCostData(self, {tos = dat.targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local skill = Fk.skills["sxfy__jiaozhao"]
    skill.extra_data = skill.extra_data or {}
    skill.extra_data.sxfy__danxin = true
    skill:onUse(player.room, {
      from = player,
      tos = event:getCostData(self).tos,
    })
  end,
})

return danxin
