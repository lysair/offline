
local chengjiz = fk.CreateSkill {
  name = "sxfy__chengjiz",
}

Fk:loadTranslationTable{
  ["sxfy__chengjiz"] = "承继",
  [":sxfy__chengjiz"] = "你可以将两张颜色不同的牌当【杀】使用或打出。",

  ["#sxfy__chengjiz"] = "承继：你可以将两张颜色不同的牌当【杀】使用或打出",
}

chengjiz:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#sxfy__chengjiz",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      return Fk:getCardById(to_select):compareColorWith(Fk:getCardById(selected[1]), true)
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
})

return chengjiz
