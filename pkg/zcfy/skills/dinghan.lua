local dinghan = fk.CreateSkill {
  name = "sxfy__dinghan",
}

Fk:loadTranslationTable{
  ["sxfy__dinghan"] = "定汉",
  [":sxfy__dinghan"] = "出牌阶段，你可以将一张锦囊牌当【奇正相生】使用；你可以将一张【奇正相生】当任意普通锦囊牌使用。",

  ["#sxfy__dinghan"] = "定汉：将一张锦囊牌当【奇正相生】使用，或将一张【奇正相生】当任意普通锦囊牌使用",
}

dinghan:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick",
  prompt = "#sxfy__dinghan",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    if player.phase == Player.Play then
      table.insert(all_names, "raid_and_frontal_attack")
    end
    local names = player:getViewAsCardNames(dinghan.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if self.interaction.data == "raid_and_frontal_attack" then
        return Fk:getCardById(to_select).type == Card.TypeTrick
      else
        return Fk:getCardById(to_select).trueName == "raid_and_frontal_attack"
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = dinghan.name
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

return dinghan
