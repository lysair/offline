local dingxi = fk.CreateSkill {
  name = "ofl__dingxi",
  dynamic_desc = function (self, player, lang)
    return "ofl__dingxi_inner:"..(4 + player:getMark(self.name) - player:usedSkillTimes(self.name, Player.HistoryGame))
  end,
}

Fk:loadTranslationTable{
  ["ofl__dingxi"] = "定西",
  [":ofl__dingxi"] = "每局游戏限四次，当你需使用非装备牌时，你可以展示牌堆顶的一张牌，若与你需使用的牌类别相同，视为你使用你需要的牌；"..
  "否则你从牌堆底摸一张牌。每连续相同两次，你回复所有体力；每连续相同三次，你对所有其他角色各造成1点伤害。",

  [":ofl__dingxi_inner"] = "（还剩{1}次）当你需使用非装备牌时，你可以展示牌堆顶的一张牌，若与你需使用的牌类别相同，视为你使用你需要的牌；"..
  "否则你从牌堆底摸一张牌。每连续相同两次，你回复所有体力；每连续相同三次，你对所有其他角色各造成1点伤害。",

  ["#ofl__dingxi"] = "定西：声明你要使用的牌和目标，然后展示牌堆顶一张牌，若类别相同则视为使用，否则从牌堆底摸一张牌",
  ["@dingxi"] = "定西成功",
}

dingxi:addEffect("viewas", {
  anim_type = "offensive",
  pattern = ".",
  prompt = "#ofl__dingxi",
  times = function(self, player)
    return 4 + player:getMark(dingxi.name) - player:usedSkillTimes(dingxi.name, Player.HistoryGame)
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("btd")
    local names = player:getViewAsCardNames(dingxi.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = dingxi.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local card = room:getNCards(1)
    room:showCards(card)
    if Fk:getCardById(card[1]).type == use.card.type then
      room:addPlayerMark(player, "@dingxi", 1)
      use.extra_data = use.extra_data or {}
      use.extra_data.dingxi = player:getMark("@dingxi")
    else
      room:setPlayerMark(player, "@dingxi", 0)
      player:drawCards(1, dingxi.name, "bottom")
      return dingxi.name
    end
  end,
  after_use = function (self, player, use)
    if player.dead then return end
    local room = player.room
    local n = use.extra_data.dingxi
    if n % 2 == 0 and player:isWounded() then
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = dingxi.name,
      }
    end
    if n % 3 == 0 then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p.dead then
          room:damage{
            from = player,
            to = p,
            damage = 1,
            skillName = dingxi.name,
          }
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(dingxi.name, Player.HistoryGame) < 4 + player:getMark(dingxi.name)
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(dingxi.name, Player.HistoryGame) < 4 + player:getMark(dingxi.name)
  end,
})

dingxi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "@dingxi", 0)
  room:setPlayerMark(player, dingxi.name, 0)
  player:setSkillUseHistory(dingxi.name, 0, Player.HistoryGame)
end)

return dingxi
