local ofl__chongxu = fk.CreateSkill { name = "ofl__chongxu" }

Fk:loadTranslationTable {
  ['ofl__chongxu'] = '冲虚',
  ['#ofl__chongxu'] = '冲虚：猜测牌堆顶两张牌颜色是否相同，猜对获得之或升级技能，猜错获得其中一张',
  ['ofl__chongxu_yes'] = '相同',
  ['ofl__chongxu_no'] = '不同',
  ['ofl__chongxu_get'] = '获得这些牌',
  ['miaojian_update'] = '升级〖妙剑〗',
  ['lianhuas_update'] = '升级〖莲华〗',
  ['@miaojian'] = '妙剑',
  ['status3'] = '三阶',
  ['@lianhuas'] = '莲华',
  ['status2'] = '二阶',
  [':ofl__chongxu'] = '出牌阶段限一次，你可以猜测牌堆顶两张牌颜色是否相同，然后亮出之，若你猜对，你可以选择一项：1.获得之；2.修改〖妙剑〗；3.修改〖莲华〗；若你猜错，你可以获得其中一张牌。',
  ['$ofl__chongxu1'] = '阳炁冲三关，斩尸除阴魔。',
  ['$ofl__chongxu2'] = '蒲团清静坐，神归了道真。',
}

ofl__chongxu:addEffect('active', {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__chongxu",
  interaction = function()
    return UI.ComboBox {choices = {"ofl__chongxu_yes", "ofl__chongxu_no"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(ofl__chongxu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(2)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = ofl__chongxu.name,
      proposer = player.id,
    })
    room:sendCardVirtName(cards, ofl__chongxu.name)
    room:delay(2000)
    if (skill.interaction.data == "ofl__chongxu_yes" and Fk:getCardById(cards[1]).color == Fk:getCardById(cards[2]).color) or
      (skill.interaction.data == "ofl__chongxu_no" and Fk:getCardById(cards[1]).color ~= Fk:getCardById(cards[2]).color) then
      local all_choices = {"ofl__chongxu_get", "miaojian_update", "lianhuas_update"}
      local choices = table.simpleClone(all_choices)
      if player:getMark("@miaojian") == "status3" then
        table.removeOne(choices, "miaojian_update")
      end
      if player:getMark("@lianhuas") == "status3" then
        table.removeOne(choices, "lianhuas_update")
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = ofl__chongxu.name,
        all_choices = all_choices
      })
      if choice == "ofl__chongxu_get" then
        room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id, ofl__chongxu.name)
      else
        if choice == "miaojian_update" then
          if player:getMark("@miaojian") == 0 then
            room:setPlayerMark(player, "@miaojian", "status2")
          else
            room:setPlayerMark(player, "@miaojian", "status3")
          end
        elseif choice == "lianhuas_update" then
          if player:getMark("@lianhuas") == 0 then
            room:setPlayerMark(player, "@lianhuas", "status2")
          else
            room:setPlayerMark(player, "@lianhuas", "status3")
          end
        end
      end
    else
      local chosen = room:askToChooseCards(player, {
        min_card_num = 0,
        max_card_num = 1,
        expand_pile = { ofl__chongxu.name, cards },
        skill_name = ofl__chongxu.name,
        prompt = "$ChooseCard"
      })
      if #chosen == 1 then
        room:obtainCard(player, chosen, true, fk.ReasonJustMove, player.id, ofl__chongxu.name)
      end
    end
    room:cleanProcessingArea(cards, ofl__chongxu.name)
  end,
})

return ofl__chongxu
