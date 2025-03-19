local rom__zhenglian = fk.CreateSkill {
  name = "rom__zhenglian"
}

Fk:loadTranslationTable{
  ['rom__zhenglian'] = '征敛',
  ['#rom__zhenglian-ask'] = '征敛：交给 %src 一张牌，否则有可能被其要求弃牌',
  ['#rom__zhenglian-discard'] = '征敛：你可以令一名选择否的角色弃置 %arg 张牌',
  [':rom__zhenglian'] = '准备阶段，你可以令所有其他角色依次选择是否交给你一张牌。所有角色选择完毕后，你可以令一名选择否的角色弃置X张牌（X为选择否的角色数）。',
}

rom__zhenglian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(rom__zhenglian.name) and player.phase == Player.Start 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local prompt = "#rom__zhenglian-ask:" .. player.id
    local tos = {}
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p.dead then
        local card = room:askToCards(p, {
          min_num = 1,
          max_num = 1,
          skill_name = rom__zhenglian.name,
          cancelable = true,
          prompt = prompt
        })
        if #card > 0 then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, rom__zhenglian.name, nil, false, player.id)
        else
          table.insert(tos, p)
        end
      end
    end
    local num = #tos
    tos = table.map(table.filter(tos, function(p) return not p:isNude() end), Util.IdMapper)
    local to = room:askToChoosePlayers(player, {
      targets = tos,
      min_num = 1,
      max_num = 1,
      prompt = "#rom__zhenglian-discard:::" .. num,
      skill_name = rom__zhenglian.name
    })
    if #to > 0 then
      room:askToDiscard(room:getPlayerById(to[1].id), {
        min_num = num,
        max_num = num,
        include_equip = true,
        skill_name = rom__zhenglian.name
      })
    end
  end
})

return rom__zhenglian
