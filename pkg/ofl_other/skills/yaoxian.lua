local yaoxian = fk.CreateSkill {
  name = "yaoxian"
}

Fk:loadTranslationTable{
  ['yaoxian'] = '邀仙',
  ['#yaoxian'] = '邀仙：令一名角色摸两张牌，然后其需对你指定的角色使用【杀】或失去1点体力',
  ['#yaoxian-choose'] = '邀仙：选择一名角色，%dest 需对其使用【杀】或失去1点体力',
  ['#yaoxian-slash'] = '邀仙：对 %dest 使用一张【杀】，否则你失去1点体力',
  [':yaoxian'] = '出牌阶段限一次，你可以令一名角色摸两张牌，然后其需对你指定的另一名其他角色使用【杀】，否则其失去1点体力。',
}

yaoxian:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#yaoxian",
  can_use = function(self, player)
    return player:usedSkillTimes(yaoxian.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(2, yaoxian.name)
    if player.dead or target.dead then return end
    local targets = table.filter(room:getOtherPlayers(target), function (p)
      return p ~= player
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#yaoxian-choose::" .. target.id,
      skill_name = yaoxian.name,
      cancelable = false,
      no_indicate = true
    })
    to = room:getPlayerById(to[1])
    room:doIndicate(player.id, {target.id})
    room:doIndicate(target.id, {to.id})
    local use = room:askToUseCard(target, {
      skill_name = yaoxian.name,
      pattern = "slash",
      prompt = "#yaoxian-slash::" .. to.id,
      cancelable = true,
      extra_data = {bypass_times = true, must_targets = {to.id}}
    })
    if use then
      use.extraUse = true
      room:useCard(use)
    else
      room:loseHp(target, 1, yaoxian.name)
    end
  end,
})

return yaoxian
