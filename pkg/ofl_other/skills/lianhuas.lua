local lianhuas = fk.CreateSkill {
  name = "ofl__lianhuas",
  dynamic_desc = function (self, player, lang)
    if player:getMark(self.name) > 0 then
      return "ofl__lianhuas0"
    else
      return "ofl__lianhuas_update"
    end
  end,
}

Fk:loadTranslationTable{
  ["ofl__lianhuas"] = "莲华",
  [":ofl__lianhuas"] = "当你成为其他角色使用【杀】的目标时，你摸一张牌。<br>"..
  "修改后：再令使用者选择一项：1.弃置一张牌；2.此【杀】对你无效。",

  [":ofl__lianhuas0"] = "当你成为【杀】的目标时，你摸一张牌。",
  [":ofl__lianhuas_update"] = "当你成为【杀】的目标时，你摸一张牌，然后使用者需弃置一张牌，否则取消之。",

  ["#ofl__lianhuas-discard"] = "莲华：你需弃置一张牌，否则此【杀】对 %src 无效",

  ["$ofl__lianhuas1"] = "执护道之宝器，御万邪之侵袭！",
  ["$ofl__lianhuas2"] = "定吾三魂七魄，保其不得丧倾！",
}

lianhuas:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianhuas.name) and
      data.card.trueName == "slash" and data.from ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, lianhuas.name)
    if player.dead or player:getMark(lianhuas.name) == 0 then return end
      if data.from.dead or data.from:isNude() or
      #room:askToDiscard(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = lianhuas.name,
        cancelable = true,
        prompt = "#ofl__lianhuas-discard:"..player.id,
      }) == 0 then
      data.use.nullifiedTargets = data.use.nullifiedTargets or {}
      table.insertIfNeed(data.use.nullifiedTargets, player)
    end
  end,
})

return lianhuas
