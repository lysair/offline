local shenfen = fk.CreateSkill {
  name = "ofl_tx__shenfen",
}

Fk:loadTranslationTable{
  ["ofl_tx__shenfen"] = "神愤",
  [":ofl_tx__shenfen"] = "出牌阶段限一次，你可以弃置6枚“暴怒”标记，对所有其他角色随机造成共计4点伤害（每名角色至少1点），"..
  "然后这些角色弃置装备区内所有牌、弃置四张手牌，最后你翻面。",

  ["#shenfen"] = "神愤：弃6枚暴怒，对所有角色造成伤害并弃牌！",

  ["$ofl_tx__shenfen1"] = "凡人们，颤抖吧！这是神之怒火！",
  ["$ofl_tx__shenfen2"] = "这，才是活生生的地狱！",
}

shenfen:addEffect("active", {
  anim_type = "big",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(shenfen.name, Player.HistoryPhase) == 0 and
      player:getMark("@baonu") > 5 and #Fk:currentRoom().alive_players > 1
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:removePlayerMark(player, "@baonu", 6)
    local tos = room:getOtherPlayers(player)
    room:doIndicate(player, tos)
    local mapper = {}
    for _, p in ipairs(tos) do
      mapper[p] = 1
    end
    if #tos < 4 then
      local rest = 4 - #tos
      for _ = 1, rest do
        local p = table.random(tos)
        mapper[p] = mapper[p] + 1
      end
    end
    for _, p in ipairs(tos) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = mapper[p],
          skillName = shenfen.name,
        }
      end
    end
    for _, p in ipairs(tos) do
      if not p.dead then
        p:throwAllCards("e", shenfen.name)
      end
    end
    for _, p in ipairs(tos) do
      if not p.dead then
        room:askToDiscard(p, {
          min_num = 4,
          max_num = 4,
          include_equip = false,
          skill_name = shenfen.name,
          cancelable = false,
        })
      end
    end
    if not player.dead then
      player:turnOver()
    end
  end
})

return shenfen
