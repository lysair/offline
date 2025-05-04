local dinghan = fk.CreateSkill {
  name = "ofl_shiji__dinghan",
}

Fk:loadTranslationTable{
  ["ofl_shiji__dinghan"] = "定汉",
  [":ofl_shiji__dinghan"] = "准备阶段，你可以移除一张智囊牌的记录，然后重新记录一张智囊牌（初始为【无中生有】【过河拆桥】【无懈可击】）。",

  ["#ofl_shiji__dinghan-invoke"] = "定汉：你可以修改一张本局游戏的智囊牌牌名",
  ["#ofl_shiji__dinghan-remove"] = "定汉：选择要移除的智囊牌",
  ["#ofl_shiji__dinghan-add"] = "定汉：选择要增加的智囊牌",
  ["@$ofl_shiji__dinghan"] = "智囊",

  ["$ofl_shiji__dinghan1"] = "不求有功于社稷，但求无过于本心。",
  ["$ofl_shiji__dinghan2"] = "投忠君之士，谋定国之计。",
}

dinghan:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dinghan.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = dinghan.name,
      prompt = "#ofl_shiji__dinghan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local zhinang = room:getBanner("Zhinang")
    if zhinang then
      zhinang = table.simpleClone(zhinang)
    else
      zhinang = {"ex_nihilo", "dismantlement", "nullification"}
    end
    local choice = room:askToChoice(player, {
      choices = room:getBanner("Zhinang"),
      skill_name = dinghan.name,
      prompt = "#ofl_shiji__dinghan-remove",
    })
    table.removeOne(zhinang, choice)
    local choices = table.simpleClone(Fk:getAllCardNames("t"))
    for _, name in ipairs(zhinang) do
      table.removeOne(choices, name)
    end
    choice = room:askToChoice(player, {
      choices = choices,
      skill_name = dinghan.name,
      prompt = "#ofl_shiji__dinghan-add",
      all_choices = Fk:getAllCardNames("t"),
    })
    table.insert(zhinang, choice)
    room:setTag("Zhinang", zhinang)
    room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getBanner("Zhinang"))
  end,
})

dinghan:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner("Zhinang") then
    room:setBanner("Zhinang", {"dismantlement", "nullification", "ex_nihilo"})
  end
  room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getBanner("Zhinang"))
end)

dinghan:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$ofl_shiji__dinghan", 0)
end)

return dinghan
