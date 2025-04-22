local zhongfu = fk.CreateSkill {
  name = "ofl__zhongfu"
}

Fk:loadTranslationTable{
  ['ofl__zhongfu'] = '众附',
  ['#ofl__zhongfu-choice'] = '众附：你可以声明本轮生效的“众附”花色，然后令手牌数最少的角色依次选择一项',
  ['@ofl__zhongfu-round'] = '众附',
  ['#ofl__zhongfu-ask'] = '众附：点“取消”摸一张牌；或将一张牌置于牌堆顶，本轮你造成伤害后 %src 可发动“瞑道”',
  ['@@ofl__zhongfu_target-round'] = '信众',
  ['#ofl__zhongfu_delay'] = '众附',
  [':ofl__zhongfu'] = '每轮开始时，你可以声明一种花色，然后令手牌最少的角色依次选择一项：1.将一张牌置于牌堆顶；2.从牌堆底摸一张牌。本轮当以此法失去牌的角色造成伤害后，你可以发动一次〖瞑道〗。',
}

zhongfu:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongfu.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {choices = {"log_spade", "log_heart", "log_club", "log_diamond", "Cancel"}, prompt = "#ofl__zhongfu-choice"})
    if choice ~= "Cancel" then
      local targets = table.filter(room.alive_players, function (p)
        return table.every(room.alive_players, function (q)
          return p:getHandcardNum() <= q:getHandcardNum()
        end)
      end)
      event:setCostData(skill, {tos = table.map(targets, Util.IdMapper), choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl__zhongfu-round", event:getCostData(skill).choice)
    for _, id in ipairs(event:getCostData(skill).tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        if p:isNude() then
          p:drawCards(1, zhongfu.name, "bottom")
        else
          local card = room:askToCards(p, {min_num = 1, max_num = 1, include_equip = true, skill_name = zhongfu.name, cancelable = true, prompt = "#ofl__zhongfu-ask:"..player.id})
          if #card > 0 then
            if not player.dead then
              room:addTableMark(player, "ofl__zhongfu-round", id)
              room:setPlayerMark(p, "@@ofl__zhongfu_target-round", 1)
            end
            room:moveCards({
              ids = card,
              from = id,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = zhongfu.name,
              drawPilePosition = 1,
            })
          else
            p:drawCards(1, zhongfu.name, "bottom")
          end
        end
      end
    end
  end,
})

zhongfu:addEffect(fk.Damage, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target and table.contains(player:getTableMark("ofl__zhongfu-round"), target.id) and
      table.find({3, 4, 5, 6}, function (sub_type)
        return player:hasEmptyEquipSlot(sub_type)
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    mingdao:doCost(event, target, player, data)
  end,
})

return zhongfu
