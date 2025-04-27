local shouli_active = fk.CreateSkill{
  name = "ofl__shouli_active",
}

Fk:loadTranslationTable{
  ["ofl__shouli_active"] = "狩骊",
}

shouli_active:addEffect("active", {
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected < 2 then
      if #selected == 0 then
        return to_select ~= player and to_select:getMark(self.mark) > 0
      elseif #selected == 1 then
        return to_select == selected[1]:getNextAlive() or selected[1] == to_select:getNextAlive()
      end
    end
  end,
})

return shouli_active
