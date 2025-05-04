local yizhu_active = fk.CreateSkill {
  name = "ofl_shiji__yizhu_active",
}

Fk:loadTranslationTable{
  ["ofl_shiji__yizhu_active"] = "遗珠",
}

yizhu_active:addEffect("active", {
  card_num = 1,
  target_num = 0,
  interaction = function(self, player)
    return UI.Spin {
      from = 1,
      to = self.ofl_shiji__yizhu_num,
    }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):matchPattern(self.ofl_shiji__yizhu_pattern)
  end,
})

return yizhu_active
