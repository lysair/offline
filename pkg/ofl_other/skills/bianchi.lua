local bianchi = fk.CreateSkill {
  name = "bianchi"
}

Fk:loadTranslationTable{
  ['bianchi'] = '鞭笞',
  ['bianchi1'] = '%src 操纵你执行一个额外出牌阶段！',
  ['bianchi2'] = '失去2点体力',
  [':bianchi'] = '限定技，结束阶段，你可以弃置场上所有<a href=>【刑鞭】</a>，然后令所有因此弃置【刑鞭】的其他角色依次选择一项：1.你操纵其执行一个额外的出牌阶段，此阶段内其至多使用两张牌；2.失去2点体力。',
}

bianchi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(bianchi.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end)
      end) and
      player:usedSkillTimes(bianchi.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local targets = table.filter(room:getAlivePlayers(), function(p)
      return table.find(p:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(targets) do
      if not p.dead then
        local cards = table.filter(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end)
        if #cards > 0 then
          room:throwCard(cards, bianchi.name, p, player)
        end
      end
    end
    for _, p in ipairs(targets) do
      if p ~= player and not p.dead then
        if player.dead then
          room:loseHp(p, 2, bianchi.name)
        else
          local choice = room:askToChoice(p, { choices = {"bianchi1:"..player.id, "bianchi2"}, skill_name = bianchi.name })
          if choice == "bianchi2" then
            room:loseHp(p, 2, bianchi.name)
          else
            player:control(p)
            room:setPlayerMark(p, "bianchi-tmp", 1)
            p:gainAnExtraPhase(Player.Play, false)
            room:setPlayerMark(p, "bianchi-tmp", 0)
            p:control(p)
          end
        end
      end
    end
  end,
})

bianchi:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player)
    return target == player and player.phase == Player.Play and player:getMark("bianchi-tmp") > 0
  end,
  on_refresh = function(self, event, target, player)
    player.room:addPlayerMark(player, "bianchi-phase", 1)
  end,
})

local bianchi_prohibit = fk.CreateSkill {
  name = "#bianchi_prohibit"
}
bianchi_prohibit:addEffect('prohibit', {
  prohibit_use = function(self, player)
    return player:getMark("bianchi-tmp") > 0 and player.phase == Player.Play and player:getMark("bianchi-phase") > 1
  end,
})

return bianchi
