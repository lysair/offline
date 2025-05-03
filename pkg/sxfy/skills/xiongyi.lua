local xiongyi = fk.CreateSkill {
  name = "sxfy__xiongyi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__xiongyi"] = "雄异",
  [":sxfy__xiongyi"] = "限定技，出牌阶段，你可以令任意名角色依次可以使用一张【杀】（不可被响应），然后这些角色重复此流程直到有角色不使用。",

  ["#sxfy__xiongyi"] = "雄异：令任意名角色可以依次使用不可被响应的【杀】！",
  ["#sxfy__xiongyi-slash"] = "雄异：请使用一张不可被响应的【杀】，或点“取消”终止此流程",
}

xiongyi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__xiongyi",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xiongyi.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    room:sortByAction(effect.tos)
    while true do
      for _, target in ipairs(effect.tos) do
        if target.dead then
          return
        else
          local use = room:askToUseCard(target, {
            skill_name = xiongyi.name,
            pattern = "slash",
            prompt = "#sxfy__xiongyi-slash",
            cancelable = true,
            extra_data = {
              bypass_times = true,
            },
          })
          if use then
            use.disresponsiveList = table.simpleClone(room.players)
            use.extraUse = true
            room:useCard(use)
          else
            return
          end
        end
      end
    end
  end,
})

return xiongyi
