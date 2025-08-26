local huoji = fk.CreateSkill({
  name = "ofl_mou__huoji",
  tags = { Skill.Quest },
})

Fk:loadTranslationTable{
  ["ofl_mou__huoji"] = "火计",
  [":ofl_mou__huoji"] = "使命技，出牌阶段限一次，你可以选择一名其他角色，对其及其同势力的其他角色各造成1点火焰伤害。<br>\
  ⬤　成功：准备阶段，若你本局游戏对其他角色造成过至少X点火焰伤害（X为本局游戏人数），你失去〖火计〗〖看破〗，获得〖观星〗〖空城〗。<br>\
  ⬤　失败：当你进入濒死状态时，使命失败。",

  ["#ofl_mou__huoji"] = "火计：选择一名角色，对所有与其势力相同的其他角色造成1点火焰伤害",
  ["@ofl_mou__huoji"] = "火计",

  ["$ofl_mou__huoji1"] = "以博望为炉，燃退敌之火。",
  ["$ofl_mou__huoji2"] = "等的，就是此刻！",
  ["$ofl_mou__huoji3"] = "大势已是如此，天火亦难助之。",
}

huoji:addEffect("active", {
  anim_type = "offensive",
  audio_index = { 1, 2 },
  prompt = "#ofl_mou__huoji",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:damage{
      from = player,
      to = target,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = huoji.name,
    }
    local targets = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if p ~= player and p ~= target and p.kingdom == target.kingdom then
        table.insert(targets, p)
      end
    end
    for _, p in ipairs(targets) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = huoji.name,
        }
      end
    end
  end,
})

huoji:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  audio_index = {1, 2},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huoji.name) and player.phase == Player.Start and
      not player:getQuestSkillState(huoji.name) and
      player:getMark("@ofl_mou__huoji") >= #player.room.players
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, huoji.name, false)
    room:handleAddLoseSkills(player, "-ofl_mou__huoji|-ofl_mou__kanpo|ofl_mou__guanxing|mou__kongcheng", nil, true, false)
    if player.general == "ofl_mou__wolong" then
      player.general = "ofl_mou__zhugeliang"
      room:broadcastProperty(player, "general")
    else
      player.deputyGeneral = "ofl_mou__zhugeliang"
      room:broadcastProperty(player, "deputyGeneral")
    end
    room:invalidateSkill(player, huoji.name)
  end,
})

huoji:addEffect(fk.EnterDying, {
  anim_type = "negative",
  audio_index = 3,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huoji.name) and not player:getQuestSkillState(huoji.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, huoji.name, true)
    room:setPlayerMark(player, huoji.name, 0)
    room:invalidateSkill(player, huoji.name)
  end,
})

huoji:addEffect(fk.Damage, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(huoji.name) and
      not player:getQuestSkillState(huoji.name) and data.damageType == fk.FireDamage
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_mou__huoji", data.damage)
  end,
})

huoji:addLoseEffect(function (self, player)
  player.room:setPlayerMark(player, "@ofl_mou__huoji", 0)
end)

return huoji
