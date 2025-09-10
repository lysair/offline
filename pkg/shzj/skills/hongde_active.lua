local hongde_active = fk.CreateSkill {
  name = "shzj_yiling__hongde_active",
}

Fk:loadTranslationTable{
  ["shzj_yiling__hongde_active"] = "弘德",
  ["shzj_yiling__hongde_discard"] = "弃一张牌",
}

hongde_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = UI.ComboBox { choices = {"draw1", "shzj_yiling__hongde_discard"} },
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    if #selected == 0 then
      if self.interaction.data == "draw1" then
        return true
      else
        if to_select == player then
          return table.find(player:getCardIds("he"), function (id)
            return not player:prohibitDiscard(id)
          end)
        else
          return not to_select:isNude()
        end
      end
    end
  end,
})

return hongde_active
