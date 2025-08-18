local jiechu = fk.CreateSkill {
  name = "jiechu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["jiechu"] = "劫出",
  [":jiechu"] = "转换技，阳：出牌阶段，你可以视为使用一张【顺手牵羊】，然后目标角色可以对你使用一张【杀】；阴：当你成为【杀】的目标时，"..
  "你可以弃置一张牌，改变此【杀】的花色和属性。",

  ["#jiechu-yang"] = "劫出：视为使用一张【顺手牵羊】，目标角色可以对你使用一张【杀】",
  ["#jiechu-slash"] = "劫出：你可以对 %src 使用一张【杀】",
  ["#jiechu-yin"] = "劫出：你可以弃置一张牌，改变此【杀】的花色和属性",
  ["#jiechu-suit"] = "劫出：选择改变此【杀】的花色",
  ["#jiechu-type"] = "劫出：选择改变此【杀】的属性",
  ["#jiechuChange"] = "%from 将 %arg 改为 %arg2",
}

local U = require "packages/utility/utility"

jiechu:addEffect("viewas", {
  anim_type = "switch",
  prompt = "#jiechu-yang",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("snatch")
    card.skillName = jiechu.name
    return card
  end,
  after_use = function (self, player, use)
    if not player.dead then
      local room = player.room
      local tos = table.filter(use.tos, function (p)
        return not p.dead
      end)
      room:sortByAction(tos)
      for _, p in ipairs(tos) do
        if player.dead then return end
        if not p.dead then
          local u = room:askToUseCard(p, {
            skill_name = jiechu.name,
            pattern = "slash",
            prompt = "#jiechu-slash:"..player.id,
            extra_data = {
              bypass_distances = true,
              bypass_times = true,
              exclusive_targets = {player.id},
            }
          })
          if u then
            u.extraUse = true
            room:useCard(u)
          end
        end
      end
    end
  end,
  enabled_at_play = function (self, player)
    return player:getSwitchSkillState(jiechu.name, false) == fk.SwitchYang
  end,
})

jiechu:addEffect(fk.TargetConfirming, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jiechu.name) and
      player:getSwitchSkillState(jiechu.name, false) == fk.SwitchYin and data.card.trueName == "slash" and
      not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = jiechu.name,
      prompt = "#jiechu-yin",
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards[1], jiechu.name, player, player)
    if player.dead then return end
    local suit = room:askToChoice(player, {
      choices = {"log_spade", "log_heart", "log_club", "log_diamond"},
      skill_name = jiechu.name,
      prompt = "#jiechu-suit",
    })
    suit = U.ConvertSuit(suit, "sym", "int")
    local names = table.filter(Fk:getAllCardNames("b"), function (name)
      return Fk:cloneCard(name).trueName == "slash"
    end)
    local name = room:askToChoice(player, {
      choices = names,
      skill_name = jiechu.name,
      prompt = "#jiechu-type",
    })
    local card = Fk:cloneCard(name, suit, data.card.number)
    if data.card.suit == suit and data.card.name == name then return end
    room:sendLog{
      from = player.id,
      type = "#jiechuChange",
      arg = data.card:toLogString(),
      arg2 = card:toLogString(),
      toast = true,
    }
    data:changeCard(name, suit, data.card.number, jiechu.name)
  end,
})

jiechu:addAI(nil, "vs_skill")

return jiechu
