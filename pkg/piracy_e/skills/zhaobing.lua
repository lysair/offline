local zhaobing = fk.CreateSkill {
  name = "ofl__zhaobing",
}

Fk:loadTranslationTable{
  ["ofl__zhaobing"] = "诏兵",
  [":ofl__zhaobing"] = "出牌阶段，你可以将“咒兵”如手牌般使用或打出。",

  ["$ofl__zhaobing1"] = "出现吧！",
  ["$ofl__zhaobing2"] = "你已经跑不出去了！",
}

zhaobing:addEffect("filter", {
  handly_cards = function (self, player)
    if player:hasSkill(zhaobing.name) and player.phase == Player.Play then
      local ids = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertTableIfNeed(ids, p:getPile("$ofl__zhoubing"))
      end
      return ids
    end
  end,
})

return zhaobing
