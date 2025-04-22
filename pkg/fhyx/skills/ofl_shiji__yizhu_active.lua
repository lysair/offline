local ofl_shiji__yizhu_active = fk.CreateSkill {
  name = "ofl_shiji__yizhu_active"
}

Fk:loadTranslationTable{
  ['ofl_shiji__yizhu_active'] = '遗珠',
}

ofl_shiji__yizhu_active:addEffect('active', {
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):matchPattern(player:getMark("ofl_shiji__yizhu-tmp")[1])
  end,
  target_num = 0,
  interaction = function(self, event)
    local choices = {}
    for i = 1, self.player:getMark("ofl_shiji__yizhu-tmp")[2], 1 do
      table.insert(choices, tostring(i))
    end
    return UI.ComboBox { choices = choices }
  end,
})

return ofl_shiji__yizhu_active
