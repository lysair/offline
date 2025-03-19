local tanlu = fk.CreateSkill {
  name = "tanlu"
}

Fk:loadTranslationTable{
  ['tanlu'] = '贪赂',
  ['#tanlu-invoke'] = '贪赂：你可以令 %dest 选择交给你手牌或你对其造成1点伤害',
  ['#tanlu-give'] = '贪赂：请交给 %src %arg张手牌，否则其对你造成1点伤害，你弃置其一张手牌',
  ['#tanlu-discard'] = '贪赂：弃置 %src 一张手牌',
  [':tanlu'] = '其他角色回合开始时，你可以令其选择一项：1.交给你X张手牌；2.你对其造成1点伤害，然后其弃置你一张手牌（X为你与其体力值之差）。',
}

tanlu:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(tanlu.name) and target ~= player and not target.dead
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = tanlu.name,
      prompt = "#tanlu-invoke::" .. target.id
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local n = math.abs(player.hp - target.hp)
    if n == 0 or target:getHandcardNum() < n then
    else
      local cards = room:askToCards(target, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = tanlu.name,
        cancelable = true,
        prompt = "#tanlu-give:" .. player.id .. "::" .. n
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, tanlu.name, nil, false, target.id)
        return
      end
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = tanlu.name,
    }
    if not target.dead and not player.dead and not player:isKongcheng() then
      local card = room:askToChooseCard(target, {
        target = player,
        flag = "h",
        skill_name = tanlu.name,
        prompt = "#tanlu-discard:" .. player.id
      })
      room:throwCard(card, tanlu.name, player, target)
    end
  end,
})

return tanlu
