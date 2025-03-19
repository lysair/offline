local zhouyuan = fk.CreateSkill {
  name = "ofl__zhouyuan"
}

Fk:loadTranslationTable{
  ['ofl__zhouyuan'] = '咒怨',
  ['#ofl__zhouyuan'] = '咒怨：令一名角色选择颜色，其将此颜色、你将另一种颜色的手牌置于武将牌上',
  ['#ofl__zhouyuan-choice'] = '咒怨：请选择一种颜色，你将此颜色、%src 将另一种颜色手牌分别置于武将牌上',
  ['ofl__zhoubing'] = '咒兵',
  ['#ofl__zhouyuan_delay'] = '咒怨',
  [':ofl__zhouyuan'] = '出牌阶段限一次，你可以选择一名其他角色，其将所有黑色/红色手牌扣置于其武将牌上，你将所有红色/黑色手牌置于武将牌上，这些牌称为“咒兵”。出牌阶段结束时，你与其收回“咒兵”。',
  ['$ofl__zhouyuan1'] = '习得一道新符，试试看吧！',
  ['$ofl__zhouyuan2'] = '这事，你管不了！',
}

zhouyuan:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zhouyuan",
  can_use = function(self, player)
    return player:usedSkillTimes(zhouyuan.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local choices = {}
    for _, id in ipairs(target:getCardIds("h")) do
      local color = Fk:getCardById(id):getColorString()
      if color ~= "nocolor" then
        table.insertIfNeed(choices, color)
      end
    end
    local color1 = room:askToChoice(target, {
      choices = choices,
      skill_name = zhouyuan.name,
      prompt = "#ofl__zhouyuan-choice:" .. player.id,
      detailed = false,
      all_choices = {"red", "black"}
    })
    local color2 = color1 == "black" and "red" or "black"
    local cards = table.filter(target:getCardIds("h"), function (id)
      return Fk:getCardById(id):getColorString() == color1
    end)
    target:addToPile("ofl__zhoubing", cards, false, zhouyuan.name, target.id)
    if not player.dead and not player:isKongcheng() then
      cards = table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getColorString() == color2
      end)
      if #cards > 0 then
        player:addToPile("ofl__zhoubing", cards, false, zhouyuan.name, player.id)
      end
    end
  end,
})

zhouyuan:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player)
    return #player:getPile("ofl__zhoubing") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    player.room:moveCardTo(player:getPile("ofl__zhoubing"), Card.PlayerHand, player, fk.ReasonJustMove, zhouyuan.name)
  end,
})

return zhouyuan
