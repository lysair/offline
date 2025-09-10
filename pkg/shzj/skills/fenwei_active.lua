local fenwei_active = fk.CreateSkill {
  name = "shzj_yiling__fenwei_active",
}

Fk:loadTranslationTable{
  ["shzj_yiling__fenwei_active"] = "奋威",
  ["shzj_yiling__fenwei1"] = "失去%arg点体力",
  ["shzj_yiling__fenwei2"] = "失去“奋威”",
}

fenwei_active:addEffect("active", {
  card_num = 0,
  min_target_num = 1,
  interaction = function (self, player)
    local n = math.max(player:usedSkillTimes("shzj_yiling__fenwei", Player.HistoryGame), 1)
    return UI.ComboBox { choices = {"shzj_yiling__fenwei1:::"..n, "shzj_yiling__fenwei2"} }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return table.contains(self.exclusive_targets, to_select.id)
  end,
})

return fenwei_active
