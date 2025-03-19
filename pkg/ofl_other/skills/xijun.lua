local xijun = fk.CreateSkill {
  name = "xijun"
}

Fk:loadTranslationTable{
  ['xijun'] = '袭军',
  ['#xijun'] = '袭军：你可以将一张黑色牌当【杀】或【决斗】使用或打出，受到此牌伤害的角色本回合不能回复体力！',
  ['#xijun_trigger'] = '袭军',
  ['#xijun_delay'] = '袭军',
  ['@@xijun-turn'] = '禁止回复体力',
  [':xijun'] = '每回合限两次，出牌阶段或当你受到伤害后，你可以将一张黑色牌当【杀】或【决斗】使用或打出，当一名角色受到此牌造成的伤害后，防止其本回合回复体力。',
}

xijun:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = "#xijun",
  interaction = function(self)
    local all_names = {"slash", "duel"}
    local names = U.getViewAsCardNames(Self, xijun.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = xijun.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    player.room:addPlayerMark(player, "xijun-turn", 1)
  end,
  enabled_at_play = function (self, player)
    return player:getMark("xijun-turn") < 2
  end,
  enabled_at_response = function (self, player)
    return player:getMark("xijun-turn") < 2 and player.phase == Player.Play
  end,
})

xijun:addEffect(fk.Damaged, {
  anim_type = "masochism",
  main_skill = xijun,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xijun.name) and player:getMark("xijun-turn") < 2
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askToUseActiveSkill(player, {
      skill_name = "xijun",
      prompt = "#xijun",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extra_use = true,
      }
    })
    if success and dat then
      event:setCostData(self, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "xijun-turn", 1)
    local card = xijun:viewAs(event:getCostData(self).cards)
    room:useCard{
      from = player.id,
      tos = table.map(event:getCostData(self).targets, function(id) return {id} end),
      card = card,
    }
  end,
})

xijun:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Damaged then
        return data.card and table.contains(data.card.skillNames, "xijun") and not player.dead
      elseif event == fk.PreHpRecover then
        return player:getMark("@@xijun-turn") > 0
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      player.room:setPlayerMark(player, "@@xijun-turn", 1)
    else
      return true
    end
  end,
})

return xijun
