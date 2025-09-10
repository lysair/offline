local tianshu = fk.CreateSkill {
  name = "sxfy__tianshu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__tianshu"] = "天书",
  [":sxfy__tianshu"] = "锁定技，你的手牌上限+X（X为场上势力数-1）。",
}

tianshu:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(tianshu.name) then
      local kingdoms = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      return #kingdoms - 1
    end
  end,
})

return tianshu
