local cuanwei_active = fk.CreateSkill {
  name = "#ofl_tx__cuanwei_active",
}

Fk:loadTranslationTable{
  ["#ofl_tx__cuanwei_active"] = "篡位",
}

cuanwei_active:addEffect("active", {
  interaction = UI.Spin { from = 1, to = 4 },
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
})

return cuanwei_active
