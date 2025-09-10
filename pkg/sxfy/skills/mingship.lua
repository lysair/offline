local mingship = fk.CreateSkill{
  name = "sxfy__mingship",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__mingship"] = "明识",
  [":sxfy__mingship"] = "限定技，出牌阶段，你可以选择一项：1.摸两张牌；2.回复1点体力；3.对一名角色造成1点伤害；4.移动场上一张牌。",

  ["#sxfy__mingship"] = "明识：你可以选择一项",
  ["sxfy__mingship_damage"] = "对一名角色造成1点伤害",
  ["sxfy__mingship_move"] = "移动场上一张牌",
}

mingship:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__mingship",
  interaction = function(self, player)
    local all_choices = { "draw2", "recover", "sxfy__mingship_damage", "sxfy__mingship_move" }
    local choices = table.simpleClone(all_choices)
    if not player:isWounded() then
      table.remove(choices, 2)
    end
    return UI.ComboBox { choices = choices , all_choices = all_choices }
  end,
  card_num = 0,
  target_num = function(self)
    if self.interaction.data == "sxfy__mingship_damage" then
      return 1
    elseif self.interaction.data == "sxfy__mingship_move" then
      return 2
    end

    return 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(mingship.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if self.interaction.data == "draw2" or self.interaction.data == "recover" then
      return false
    elseif self.interaction.data == "sxfy__mingship_damage" then
      return #selected == 0
    elseif self.interaction.data == "sxfy__mingship_move" then
      if #selected == 0 then
        return true
      elseif #selected == 1 then
        return to_select:canMoveCardsInBoardTo(selected[1]) or selected[1]:canMoveCardsInBoardTo(to_select)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    if choice == "draw2" then
      player:drawCards(2, mingship.name)
    elseif choice == "recover" then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = mingship.name,
      }
    elseif choice == "sxfy__mingship_damage" then
      room:damage{
        from = player,
        to = effect.tos[1],
        damage = 1,
        skillName = mingship.name,
      }
    elseif choice == "sxfy__mingship_move" then
      room:askToMoveCardInBoard(player, {
        target_one = effect.tos[1],
        target_two = effect.tos[2],
        skill_name = mingship.name,
      })
    end
  end,
})

return mingship
