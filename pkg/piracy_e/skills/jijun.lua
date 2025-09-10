local jijun = fk.CreateSkill {
  name = "ofl__jijun",
  derived_piles = "ofl__godzhangliang_fang",
}

Fk:loadTranslationTable{
  ["ofl__jijun"] = "集军",
  [":ofl__jijun"] = "当你使用牌指定你为目标后，你可以进行判定，然后选择一项：1.获得此牌；2.将判定牌置于武将牌上，称为“方”。",

  ["ofl__jijun1"] = "获得判定牌",
  ["ofl__jijun2"] = "将判定牌置为“方”",
  ["ofl__godzhangliang_fang"] = "方",

  ["$ofl__jijun1"] = "民军虽散，也可撼树。",
  ["$ofl__jijun2"] = "集天下万民，成百姓万军。",
}

jijun:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jijun.name) and data.to == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = jijun.name,
      pattern = ".",
    }
    room:judge(judge)
    if player.dead then return end
    if room:getCardArea(judge.card) == Card.DiscardPile then
      local choice = room:askToChoice(player, {
        choices = {"ofl__jijun1", "ofl__jijun2"},
        skill_name = jijun.name,
      })
      if choice == "ofl__jijun1" then
        room:moveCardTo(judge.card, Card.PlayerHand, player, fk.ReasonJustMove, jijun.name, nil, true, player)
      else
        player:addToPile("ofl__godzhangliang_fang", judge.card, true, jijun.name, player)
      end
    end
  end,
})

return jijun
