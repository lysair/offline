local liangzhu = fk.CreateSkill {
  name = "ofl_mou__liangzhu",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"shu"}
}

Fk:loadTranslationTable{
  ["ofl_mou__liangzhu"] = "良助",
  [":ofl_mou__liangzhu"] = "蜀势力技，出牌阶段限一次，你可以将一名其他角色装备区内一张牌置于你的武将牌上，称为“妆”，然后你令一名其他角色"..
  "回复1点体力。",

  ["#ofl_mou__liangzhu"] = "良助：将一名角色装备区内一张牌置为“妆”，然后令一名其他角色回复1点体力",
  ["#ofl_mou__liangzhu-recover"] = "良助：令一名其他角色回复1点体力",

  ["$ofl_mou__liangzhu1"] = "既为使君妇，当助使君归。",
  ["$ofl_mou__liangzhu2"] = "愿随夫君，成一方枭雄之业！",
}

liangzhu:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_mou__liangzhu",
  derived_piles = "mou__liangzhu_dowry",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(liangzhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = liangzhu.name,
    })
    player:addToPile("mou__liangzhu_dowry", card, true, liangzhu.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:isWounded()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = liangzhu.name,
      prompt = "#ofl_mou__liangzhu-recover",
      cancelable = false,
    })[1]
    room:recover({
      who = to,
      num = 1,
      recoverBy = player,
      skillName = liangzhu.name,
    })
  end,
})

return liangzhu
