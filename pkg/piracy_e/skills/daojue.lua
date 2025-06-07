local daojue = fk.CreateSkill {
  name = "daojue",
  tags = { Skill.Quest },
}

Fk:loadTranslationTable{
  ["daojue"] = "道抉",
  [":daojue"] = "使命技，当你首次受到一种花色的牌造成的伤害时，防止此伤害，你选择一项：1.获得造成伤害的牌；2.使用一张指定"..
  "所有其他角色为目标的【杀】。<br>\
  ⬤　成功：当你因此获得至少三张牌后，你失去〖劫出〗，变更势力至魏，获得〖清正〗〖治暗〗〖护驾〗。<br>\
  ⬤　失败：当你因此使用至少三张【杀】后，你失去〖劫出〗，变更势力至群，获得〖神离〗〖诛逆〗〖士首〗。",

  ["@daojue"] = "道抉",
  ["#daojue1-slash"] = "道抉：使用一张指定所有其他角色为目标的【杀】",
  ["#daojue2-slash"] = "道抉：使用一张指定所有其他角色为目标的【杀】，或点“取消”获得%arg",
}

daojue:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(daojue.name) and
      data.extra_data and data.extra_data.daojue
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    local prompt = "#daojue1-slash"
    if room:getCardArea(data.card) == Card.Processing then
      prompt = "#daojue2-slash:::"..data.card:toLogString()
    end
    local use = room:askToUseCard(target, {
      skill_name = daojue.name,
      pattern = "slash",
      prompt = prompt,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
      }
    })
    if use then
      room:addPlayerMark(player, "daojue1", 1)
      use.extraUse = true
      use.tos = table.filter(room:getOtherPlayers(player, false), function (p)
        return not player:isProhibited(p, use.card)
      end)
      room:useCard(use)
      if not player.dead and player:getMark("daojue1") > 2 and player:hasSkill(daojue.name) then
        room:updateQuestSkillState(player, daojue.name, true)
        room:invalidateSkill(player, daojue.name)
        room:setPlayerMark(player, "@daojue", 0)
        room:changeKingdom(player, "qun", true)
        room:handleAddLoseSkills(player, "-jiechu|shenliy|ofl__zhuni|shishouy")
      end
    elseif room:getCardArea(data.card) == Card.Processing then
      room:addPlayerMark(player, "daojue2", 1)
      room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, daojue.name, nil, true, player)
      if not player.dead and player:getMark("daojue2") > 2 and player:hasSkill(daojue.name) then
        room:updateQuestSkillState(player, daojue.name, false)
        room:invalidateSkill(player, daojue.name)
        room:setPlayerMark(player, "@daojue", 0)
        room:changeKingdom(player, "wei", true)
        room:handleAddLoseSkills(player, "-jiechu|ofl__qingzheng|ofl__zhian|ol_ex__hujia")
      end
    end
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(daojue.name, true) and
      data.card and data.card.suit ~= Card.NoSuit and
      not table.contains(player:getTableMark("@daojue"), data.card:getSuitString(true)) and
      player:getMark(MarkEnum.QuestSkillPreName .. daojue.name) == 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, "@daojue", data.card:getSuitString(true))
    data.extra_data = data.extra_data or {}
    data.extra_data.daojue = true
  end,
})

daojue:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local record = {}
    room.logic:getActualDamageEvents(1, function (e)
      local damage = e.data
      if damage.to == player and damage.card and damage.card.suit ~= Card.NoSuit then
        table.insertIfNeed(record, damage.card:getSuitString(true))
        return #record == 4
      end
    end, Player.HistoryGame)
    if #record > 0 then
      room:setPlayerMark(player, "@daojue", record)
    end
  end
end)

daojue:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@daojue", 0)
end)

return daojue
