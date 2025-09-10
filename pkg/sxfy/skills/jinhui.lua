local jinhui = fk.CreateSkill {
  name = "sxfy__jinhui",
}

Fk:loadTranslationTable{
  ["sxfy__jinhui"] = "锦绘",
  [":sxfy__jinhui"] = "准备阶段，你可以亮出牌堆顶的三张牌，令一名角色与你依次使用其中一张牌（不能连续使用相同颜色的牌）。",

  ["#sxfy__jinhui-choose"] = "锦绘：选择一名角色，与其依次使用一张亮出的牌",
  ["#sxfy__jinhui-use"] = "锦绘：请使用其中一张牌",
}

jinhui:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jinhui.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(3)
    room:turnOverCardsFromDrawPile(player, cards, jinhui.name)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = jinhui.name,
      prompt = "#sxfy__jinhui-choose",
      cancelable = false,
    })[1]
    local use = room:askToUseRealCard(to, {
      pattern = cards,
      skill_name = jinhui.name,
      prompt = "#sxfy__jinhui-use",
      extra_data = {
        bypass_times = true,
        extraUse = true,
        expand_pile = cards,
      }
    })
    if not player.dead then
      cards = table.filter(cards, function (id)
        return room:getCardArea(id) == Card.Processing and not (use and Fk:getCardById(id):compareColorWith(use.card))
      end)
      if #cards > 0 then
        room:askToUseRealCard(player, {
          pattern = cards,
          skill_name = jinhui.name,
          prompt = "#sxfy__jinhui-use",
          extra_data = {
            bypass_times = true,
            extraUse = true,
            expand_pile = cards,
          }
        })
      end
    end
    room:cleanProcessingArea(cards)
  end,
})

return jinhui
