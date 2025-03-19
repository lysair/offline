local fengyin = fk.CreateSkill {
  name = "fengyin"
}

Fk:loadTranslationTable{
  ['fengyin'] = '奉印',
  ['#fengyin'] = '奉印: 你可以交给 %dest 一张【杀】，跳过其出牌阶段和弃牌阶段',
  [':fengyin'] = '其他角色的回合开始时，若其当前的体力值不小于你，你可以交给其一张【杀】，令其跳过其出牌阶段和弃牌阶段。',
  ['$fengyin1'] = '政在曹公，外家岂敢据此尊位。',
  ['$fengyin2'] = '天子都许，时局已安，某自当解绶奉印。',
}

fengyin:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(fengyin.name) and target ~= player and target.hp >= player.hp then
      return not player:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = 'slash',
      prompt = '#fengyin::' .. target.id,
      skill_name = fengyin.name,
    })
    if #card > 0 then
      event:setCostData(self, card[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local card = event:getCostData(self)
    room:moveCardTo(card, Player.Hand, target, fk.ReasonGive, fengyin.name, nil, true, player.id)
    target:skip(Player.Play)
    target:skip(Player.Discard)
  end,
})

return fengyin
