local zimou = fk.CreateSkill {
  name = "ofl__zimou"
}

Fk:loadTranslationTable{
  ['ofl__zimou'] = '自谋',
  ['#ofl__zimou1-give'] = '自谋：请交给 %src 一张牌',
  ['#ofl__zimou-discard'] = '自谋：弃置 %src 一张牌',
  ['#ofl__zimou2-give'] = '自谋：交给 %src 一张牌，或点“取消”弃置其一张牌并受到其造成的1点伤害',
  [':ofl__zimou'] = '锁定技，出牌阶段开始时，你令所有其他角色依次选择一项：1.交给你一张牌；2.弃置你一张牌，然后你对其造成1点伤害。',
  ['$ofl__zimou1'] = '在宫里当差，还不是为这利字！',
  ['$ofl__zimou2'] = '闻谤而怒，见誉而喜，汝万万不能啊！'
}

zimou:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(zimou.name) and player.phase == Player.Play
      and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if player.dead then return end
      if not p.dead then
        if player:isNude() then
          if not p:isNude() then
            local card = room:askToCards(p, {
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = zimou.name,
              cancelable = false,
              prompt = "#ofl__zimou1-give:"..player.id
            })
            room:moveCardTo(card[1], Card.PlayerHand, player, fk.ReasonGive, zimou.name, nil, false, p.id)
          end
        else
          if p:isNude() then
            local card =  room:askToChooseCard(p, {
              target = player,
              flag = "he",
              skill_name = zimou.name,
              prompt = "#ofl__zimou-discard:"..player.id
            })
            room:throwCard(card, zimou.name, player, p)
            if not p.dead then
              room:damage{
                from = player,
                to = p,
                damage = 1,
                skillName = zimou.name,
              }
            end
          else
            local card = room:askToCards(p, {
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = zimou.name,
              cancelable = true,
              prompt = "#ofl__zimou2-give:"..player.id
            })
            if #card > 0 then
              room:moveCardTo(card[1], Card.PlayerHand, player, fk.ReasonGive, zimou.name, nil, false, p.id)
            else
              card = room:askToChooseCard(p, {
                target = player,
                flag = "he",
                skill_name = zimou.name,
                prompt = "#ofl__zimou-discard:"..player.id
              })
              room:throwCard(card, zimou.name, player, p)
              if not p.dead then
                room:damage{
                  from = player,
                  to = p,
                  damage = 1,
                  skillName = zimou.name,
                }
              end
            end
          end
        end
      end
    end
  end,
})

return zimou
