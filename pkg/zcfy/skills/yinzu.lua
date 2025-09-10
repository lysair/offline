local yinzu = fk.CreateSkill {
  name = "yinzu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yinzu"] = "荫族",
  [":yinzu"] = "锁定技，手牌数大于体力值的角色攻击范围+1，手牌数不大于体力值的角色攻击范围-1。",
}

yinzu:addEffect("atkrange", {
  fixed_func = function (self, player)
    local n = #table.filter(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill(yinzu.name)
    end)
    if player:getHandcardNum() > player.hp then
      return n
    else
      return -n
    end
  end,
})

return yinzu