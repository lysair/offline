local juemie = fk.CreateSkill({
  name = "ofl_tx__juemie",
})

Fk:loadTranslationTable{
  ["ofl_tx__juemie"] = "绝灭",
  [":ofl_tx__juemie"] = "出牌阶段限一次，你可以移去36枚“人方”标记，<a href='os__shifa_href'>施法</a>：对X名角色造成6点雷电伤害。",

  ["#ofl_tx__juemie"] = "绝灭：移去36枚“人方”标记，施法，第X个回合结束时对X名角色各造成6点雷电伤害！",
  ["@ofl_tx__juemie"] = "绝灭 施法",
  ["#ofl_tx__juemie-choose"] = "绝灭：对%arg名角色各造成6点雷电伤害！",
}

juemie:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__juemie",
  card_num = 0,
  target_num = 0,
  interaction = UI.Spin { from = 1, to = 3 },
  can_use = function (self, player)
    return player:usedSkillTimes(juemie.name, Player.HistoryPhase) == 0 and
      player:getMark("@ofl_tx__renfang") > 35
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:removePlayerMark(player, "@ofl_tx__renfang", 36)
    room:setPlayerMark(player, "@ofl_tx__juemie", self.interaction.data)
    room:setPlayerMark(player, juemie.name, self.interaction.data)
  end,
})

juemie:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@ofl_tx__juemie") > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@ofl_tx__juemie", 1)
    if player:getMark("@ofl_tx__juemie") == 0 then
      local n = player:getMark(juemie.name)
      room:setPlayerMark(player, juemie.name, 0)
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = n,
        targets = room.alive_players,
        skill_name = juemie.name,
        prompt = "#ofl_tx__juemie-choose:::"..n,
        cancelable = true,
      })
      if #tos > 0 then
        room:sortByAction(tos)
        for _, p in ipairs(tos) do
          if not p.dead then
            room:damage {
              from = player,
              to = p,
              damage = 6,
              damageType = fk.ThunderDamage,
              skillName = juemie.name,
            }
          end
        end
      end
    end
  end,
})

return juemie
