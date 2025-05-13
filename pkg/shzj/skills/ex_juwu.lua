local juwu = fk.CreateSkill {
  name = "shzj_guansuo__juwu",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__juwu"] = "拒武",
  [":shzj_guansuo__juwu"] = "摸牌阶段，你可以多摸X张牌，然后你选择至多等量名角色，依次交给这些角色一张牌，或对其使用一张【杀】或【桃】"..
  "（X为攻击范围内含有你的角色数，至多为3）。",

  ["#shzj_guansuo__juwu-invoke"] = "拒武：你可以多摸%arg张牌",
  ["#shzj_guansuo__juwu-choose"] = "拒武：你可以选择至多%arg名角色，交给这些角色牌或对其使用【杀】或【桃】",
  ["#shzj_guansuo__juwu-use"] = "拒武：对 %dest 使用一张【杀】或【桃】，或点“取消”交给其一张牌",
  ["#shzj_guansuo__juwu-give"] = "拒武：请交给 %dest 一张牌",
}

juwu:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(juwu.name) and
      table.find(player.room.alive_players, function(p)
        return p:inMyAttackRange(player)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    n = math.min(n, 3)
    if room:askToSkillInvoke(player, {
      skill_name = juwu.name,
      prompt = "#shzj_guansuo__juwu-invoke:::"..n,
    }) then
      event:setCostData(self, {choice = n})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = event:getCostData(self).choice
    data.n = data.n + n
    data.extra_data = data.extra_data or {}
    data.extra_data.shzj_guansuo__juwu = n
  end,
})

juwu:addEffect(fk.AfterDrawNCards, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.extra_data and data.extra_data.shzj_guansuo__juwu
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = data.extra_data.shzj_guansuo__juwu
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = n,
      targets = room.alive_players,
      skill_name = juwu.name,
      prompt = "#shzj_guansuo__juwu-choose:::"..n,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = table.simpleClone(event:getCostData(self).tos)
    for _, p in ipairs(tos) do
      if player.dead then return end
      if not p.dead then
        local use = room:askToUseCard(player, {
          skill_name = juwu.name,
          pattern = "slash,peach",
          prompt = "#shzj_guansuo__juwu-use::"..p.id,
          cancelable = true,
          extra_data = {
            bypass_distances = true,
            bypass_times = true,
            must_targets = { p.id },
            fix_targets = { p.id }
          }
        })
        if use then
          use.extraUse = true
          if #use.tos == 0 then
            use.tos = {p}
          end
          room:useCard(use)
        elseif not player:isNude() then
          local card = room:askToCards(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = juwu.name,
            prompt = "#shzj_guansuo__juwu-give::"..p.id,
            cancelable = false,
          })
          room:moveCardTo(card, Card.PlayerHand, p, fk.ReasonGive, juwu.name, nil, false, player)
        end
      end
    end
  end,
})

return juwu
