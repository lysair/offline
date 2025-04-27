local jieyin = fk.CreateSkill{
  name = "ofl_mou__jieyin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__jieyin"] = "结姻",
  [":ofl_mou__jieyin"] = "锁定技，出牌阶段开始时，你令一名手牌数不大于你的角色选择一项：1.若其有手牌，其交给你两张手牌（不足则全给），"..
  "然后其获得1点护甲；2.你回复1点体力并获得所有“妆”，然后减1点体力上限，变更势力为吴。",

  ["#ofl_mou__jieyin-give"] = "结姻：请交给 %src 两张手牌，你获得1点护甲",
  ["#ofl_mou__jieyin-choice"] = "结姻：交给 %src 两张手牌（不足则全给），你获得1点护甲；或其变更为吴势力",
  ["#ofl_mou__jieyin-choose"] = "结姻：令一名角色选择一项",

  ["$ofl_mou__jieyin1"] = "窈窕之姿，可配夫君之勇？",
  ["$ofl_mou__jieyin2"] = "君既反目生嫌，妾又何需隐忍！",
}

jieyin:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieyin.name) and player.phase == Player.Play
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:getHandcardNum() <= player:getHandcardNum()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jieyin.name,
      prompt = "#ofl_mou__jieyin-choose",
      cancelable = false,
    })
    event:setCostData(self, {tos = to})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if #player:getPile("mou__liangzhu_dowry") == 0 then
      if to:isKongcheng() then
        if player:isWounded() then
          room:recover{
            who = player,
            num = 1,
            recoverBy = player,
            skillName = jieyin.name,
          }
        end
      else
        if to == player then
          room:changeShield(to, 1)
          return
        else
          local cards = to:getCardIds("h")
          if #cards > 2 then
            cards = room:askToCards(to, {
              min_num = 2,
              max_num = 2,
              include_equip = false,
              skill_name = jieyin.name,
              prompt = "#ofl_mou__jieyin-give:"..player.id,
              cancelable = false,
            })
          end
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, jieyin.name, nil, false, to)
          if not to.dead then
            room:changeShield(to, 1)
          end
        end
      end
    else
      local cards = {}
      if not to:isKongcheng() then
        cards = to:getCardIds("h")
        if #cards > 2 then
          cards = room:askToCards(to, {
            min_num = 2,
            max_num = 2,
            include_equip = false,
            skill_name = jieyin.name,
            prompt = "#ofl_mou__jieyin-give:"..player.id,
            cancelable = false,
          })
        end
      end
      if #cards > 0 then
        if to == player then
          room:changeShield(to, 1)
          return
        else
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, jieyin.name, nil, false, to)
          if not to.dead then
            room:changeShield(to, 1)
          end
        end
      else
        if player:isWounded() then
          room:recover{
            who = player,
            num = 1,
            recoverBy = player,
            skillName = jieyin.name,
          }
        end
        if player.dead then return end
        if #player:getPile("mou__liangzhu_dowry") > 0 then
          room:obtainCard(player, player:getPile("mou__liangzhu_dowry"), false, fk.ReasonJustMove, player, jieyin.name)
        end
        if player.dead then return end
        room:changeMaxHp(player, -1)
        if player.dead then return end
        room:changeKingdom(player, "wu", true)
      end
    end
  end,
})

return jieyin
