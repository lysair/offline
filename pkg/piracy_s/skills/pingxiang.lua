local pingxiang = fk.CreateSkill {
  name = "ofl__pingxiang",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__pingxiang"] = "平襄",
  [":ofl__pingxiang"] = "限定技，出牌阶段，若你的体力上限大于9，你可以减9点体力上限。若如此做，你失去技能〖九伐〗且本局游戏内你的手牌上限等于"..
  "体力上限，然后你可以视为使用至多九张火【杀】。",

  ["#ofl__pingxiang"] = "平襄：你可以减9点体力上限，视为使用至多九张火【杀】！",
  ["#ofl__pingxiang-slash"] = "平襄：你可以视为使用火【杀】（第%arg张，共9张）！",

  ["$ofl__pingxiang1"] = "此身独继隆中志，功成再拜五丈原！",
  ["$ofl__pingxiang2"] = "平北襄乱之心，纵身加斧钺，亦不改半分！",
}

pingxiang:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__pingxiang",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player.maxHp > 9 and player:usedSkillTimes(pingxiang.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:changeMaxHp(player, -9)
    if player.dead then return end
    room:handleAddLoseSkills(player, "-ofl__jiufa")
    for i = 1, 9 do
      if player.dead or not room:askToUseVirtualCard(player, {
        name = "fire__slash",
        skill_name = pingxiang.name,
        prompt = "#ofl__pingxiang-slash:::" .. i,
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      }) then
        break
      end
    end
  end,
})

pingxiang:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:usedSkillTimes(pingxiang.name, Player.HistoryGame) > 0 then
      return player.maxHp
    end
  end
})

return pingxiang
