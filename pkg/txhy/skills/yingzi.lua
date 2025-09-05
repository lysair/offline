
local yingzi = fk.CreateSkill{
  name = "ofl_tx__yingzi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__yingzi"] = "英姿",
  [":ofl_tx__yingzi"] = "锁定技，摸牌阶段，你多摸X张牌（X为游戏轮数，至多为3）；你的手牌上限为你的体力上限。",

  ["$ofl_tx__yingzi1"] = "哈哈哈哈哈哈哈哈！",
  ["$ofl_tx__yingzi2"] = "伯符，且看我这一手！",
}

yingzi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    data.n = data.n + math.min(player.room:getBanner("RoundCount"), 3)
  end,
})

yingzi:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:hasSkill(self.name) then
      return player.maxHp
    end
  end
})

return yingzi
