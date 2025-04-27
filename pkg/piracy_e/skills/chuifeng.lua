local chuifeng = fk.CreateSkill {
  name = "ofl__chuifeng",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"wei"},
}

Fk:loadTranslationTable{
  ["ofl__chuifeng"] = "椎锋",
  [":ofl__chuifeng"] = "魏势力技，你可以失去1点体力，视为使用一张【杀】或【决斗】。",

  ["#ofl__chuifeng"] = "椎锋：失去1点体力，视为使用一张【杀】或【决斗】",
}

local U = require "packages/utility/utility"

chuifeng:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = "#ofl__chuifeng",
  interaction = function (self, player)
    local all_names = {"slash", "duel"}
    local names = player:getViewAsCardNames(chuifeng.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = chuifeng.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:loseHp(player, 1, chuifeng.name)
  end,
  enabled_at_play = function(self, player)
    return player.hp > 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player.hp > 0
  end,
})

return chuifeng
