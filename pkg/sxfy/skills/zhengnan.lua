
local zhengnan = fk.CreateSkill {
  name = "sxfy__zhengnan",
}

Fk:loadTranslationTable{
  ["sxfy__zhengnan"] = "征南",
  [":sxfy__zhengnan"] = "准备阶段，你可以将一张红色手牌当【杀】使用，若因此杀死了角色，你摸两张牌。",

  ["#sxfy__zhengnan-slash"] = "征南：你可以将一张红色手牌当【杀】使用",
}

zhengnan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhengnan.name) and player.phase == Player.Start and
      #player:getHandlyIds() > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = zhengnan.name,
      prompt = "#sxfy__zhengnan-slash",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      card_filter = {
        n = 1,
        pattern = ".|.|heart,diamond",
        cards = player:getHandlyIds(),
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

zhengnan:addEffect(fk.Death, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.damage and data.damage.from and data.damage.from == player and not player.dead and
      data.damage.card and table.contains(data.damage.card.skillNames, zhengnan.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, zhengnan.name)
  end,
})

return zhengnan
