local cheji = fk.CreateSkill {
  name = "ofl__cheji"
}

Fk:loadTranslationTable{
  ['ofl__cheji'] = '撤击',
  ['#ofl__cheji'] = '撤击：重铸任意张牌，然后令一名角色重铸等量张手牌，根据其重铸的基本牌执行效果',
  ['#ofl__cheji-choose'] = '撤击：令一名角色重铸%arg张手牌，根据其重铸的基本牌执行效果',
  ['#ofl__cheji-recast'] = '撤击：请重铸%arg张手牌，若包含：<br>【杀】你受到火焰伤害；【闪】你视为对指定角色使用【杀】；【桃】双方摸牌',
  ['#ofl__cheji-slash'] = '撤击：选择 %dest 视为使用【杀】的目标',
  [':ofl__cheji'] = '出牌阶段限一次，你可以重铸任意张牌，然后令一名其他角色重铸等量张手牌，若其重铸的牌包含：【杀】，你对其造成1点火焰伤害；【闪】，其对你指定的角色视为使用一张【杀】；【桃】，你与其各摸两张牌。',
}

cheji:addEffect('active', {
  anim_type = "offensive",
  min_card_num = 1,
  target_num = 0,
  prompt = "#ofl__cheji",
  can_use = function(self, player)
    return player:usedSkillTimes(cheji.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local n = #effect.cards
    room:recastCard(effect.cards, player, cheji.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getHandcardNum() >= n
    end)
    if #targets == 0 then return end
    local target = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__cheji-choose:::"..n,
      skill_name = cheji.name,
      cancelable = false
    })[1]
    target = room:getPlayerById(target)
    local cards = room:askToCards(target, {
      min_num = n,
      max_num = n,
      include_equip = false,
      pattern = nil,
      prompt = "#ofl__cheji-recast:::"..n
    })
    local names = table.map(cards, function (id)
      return Fk:getCardById(id).trueName
    end)
    room:recastCard(cards, target, cheji.name)
    if table.contains(names, "slash") and not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = cheji.name,
      }
    end
    if table.contains(names, "jink") and not player.dead and not target.dead then
      local tos = table.filter(room:getOtherPlayers(target), function (p)
        return target:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
      if #tos > 0 then
        local to = room:askToChoosePlayers(player, {
          targets = tos,
          min_num = 1,
          max_num = 1,
          prompt = "#ofl__cheji-slash::"..target.id,
          skill_name = cheji.name,
          cancelable = false
        })[1]
        room:useVirtualCard("slash", nil, target, room:getPlayerById(to), cheji.name, true)
      end
    end
    if table.contains(names, "peach") then
      if not player.dead then
        player:drawCards(2, cheji.name)
      end
      if not target.dead then
        target:drawCards(2, cheji.name)
      end
    end
  end,
})

return cheji
