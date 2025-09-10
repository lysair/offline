local quanqing = fk.CreateSkill {
  name = "quanqing",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["quanqing"] = "权倾",
  [":quanqing"] = "限定技，结束阶段，你可以对攻击范围内的所有角色发动〖权威〗，然后你可以变更势力并获得〖戕异〗。",

  ["#quanqing-invoke"] = "权倾：展示一张手牌，对攻击范围内的所有角色发动“权威”！",
  ["#quanqing-choice"] = "权倾：你可以变更势力，获得“戕异”",
}

local U = require "packages/utility/utility"

quanqing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(quanqing.name) and player.phase == Player.Finish and
      player:usedEffectTimes(self.name, Player.HistoryGame) == 0 and
      not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:inMyAttackRange(player)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = quanqing.name,
      prompt = "#quanqing-invoke",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards or {}
    local color1 = Fk:getCardById(card[1]):getColorString()
    player:showCards(card)
    if player.dead then return end
    if not player:isKongcheng() then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p:inMyAttackRange(player) and not p:isKongcheng()
      end)
      if #targets > 0 then
        room:doIndicate(player, targets)
        local discussion = U.Discussion(player, table.connect(targets, {player}), "quanwei")
        if player.dead then return end
        if discussion.color ~= color1 and
          room:askToSkillInvoke(player, {
            skill_name = "quanwei",
            prompt = "#quanwei-maxhp",
          }) then
          room:changeMaxHp(player, -1)
          if player.dead then return end
          room:sortByAction(targets)
          local moves = {}
          for _, p in ipairs(targets) do
            if not p.dead and not p:isKongcheng() then
              table.insert(moves, {
                ids = p:getCardIds("h"),
                from = p,
                to = player,
                toArea = Card.PlayerHand,
                moveReason = fk.ReasonPrey,
                skillName = "quanwei",
                proposer = player,
              })
            end
          end
          if #moves > 0 then
            room:moveCards(table.unpack(moves))
            if player.dead then return end
          end
        end
      end
    end
    local kingdoms = Fk:getKingdomMap("god")
    table.removeOne(kingdoms, player.kingdom)
    if #kingdoms > 0 then
      table.insert(kingdoms, "Cancel")
      local choice = room:askToChoice(player, {
        choices = kingdoms,
        skill_name = quanqing.name,
        prompt = "#quanqing-choice",
      })
      if choice ~= "Cancel" then
        room:changeKingdom(player, choice, true)
        if not player.dead then
          room:handleAddLoseSkills(player, "qiangyi")
        end
      end
    end
  end,
})

return quanqing
