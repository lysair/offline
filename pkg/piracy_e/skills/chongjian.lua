local chongjian = fk.CreateSkill {
  name = "ofl__chongjian",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"wu"},
}

Fk:loadTranslationTable{
  ["ofl__chongjian"] = "冲坚",
  [":ofl__chongjian"] = "吴势力技，你可以将一张装备牌当【酒】或【杀】使用。",

  ["#ofl__chongjian"] = "冲坚：将装备牌当【酒】或【杀】使用",
}

chongjian:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,analeptic",
  prompt = "#ofl__chongjian",
  interaction = function (self, player)
    local all_names = {"slash", "analeptic"}
    local names = player:getViewAsCardNames(chongjian.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = chongjian.name
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
})

return chongjian
