local tonglu = fk.CreateSkill {
  name = "tonglu",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["tonglu"] = "通陆",
  [":tonglu"] = "觉醒技，每轮结束时，若你的手牌数大于体力值，你减1点体力上限，获得〖攻心〗〖博图〗和〖夺荆〗，然后你可以令拥有“伏”的角色"..
  "选择将座次移至你的上家或下家，你执行一个额外的回合。",

  ["#tonglu-invoke"] = "通陆：是否令 %dest 移至你的上家或下家，你获得一个额外回合？",
  ["tonglu_last"] = "移动至%src的上家",
  ["tonglu_next"] = "移动至%src的下家",
}

tonglu:addEffect(fk.RoundEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tonglu.name) and player:usedSkillTimes(tonglu.name, Player.HistoryGame) == 0
  end,
  can_wake = function (self, event, target, player, data)
    return player:getHandcardNum() > player.hp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player.dead then return end
    room:handleAddLoseSkills(player, "gongxin|botu|duojing")
    local to = table.find(room.alive_players, function (p)
      return table.contains(p:getTableMark("@@fujingl"), player.id)
    end)
    if to then
      if room:askToSkillInvoke(player, {
        skill_name = tonglu.name,
        prompt = "#tonglu-invoke::"..to.id,
      }) then
        room:doIndicate(player, {to})
        local choice = room:askToChoice(to, {
          choices = {"tonglu_last:"..player.id, "tonglu_next:"..player.id},
          skill_name = tonglu.name,
        })
        if choice:startsWith("tonglu_last") then
          room:moveSeatToNext(to, player, true)
        else
          room:moveSeatToNext(to, player)
        end
        player:gainAnExtraTurn(false, tonglu.name)
      end
    end
  end,
})

return tonglu
