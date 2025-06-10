local shouli = fk.CreateSkill {
  name = "ofl2__shouli",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["ofl2__shouli"] = "狩骊",
  [":ofl2__shouli"] = "锁定技，游戏开始时，所有角色依次选择一项：1.使用一张坐骑牌，然后摸一张牌；2.随机从游戏外使用一张"..
  "<a href='ofl__shouli_href'>坐骑指示物</a>。<br>你可以将场上的一张进攻坐骑当【杀】、防御马当【闪】使用或打出，"..
  "以此法失去坐骑的角色本回合非锁定技失效，你与其本回合受到的伤害+1且改为雷电伤害。",

  ["ofl__shouli_href"] = "包括7张标准版和军争篇的坐骑牌和1张国战势备篇的“惊帆”",

  ["#ofl2__shouli-slash"] = "狩骊：将场上的一张进攻马当【杀】使用或打出（先选【杀】的目标）",
  ["#ofl2__shouli-jink"] = "狩骊：将场上的一张防御马当【闪】使用或打出",
  ["#ofl2__shouli-horse"] = "狩骊：选择一名装备着 %arg 的角色",
  ["#ofl2__shouli-use"] = "狩骊：使用一张坐骑牌并摸一张牌，或点“取消”随机从游戏外使用一张坐骑牌",
  ["@@ofl2__shouli-turn"] = "狩骊",

  ["$ofl2__shouli1"] = "敢缚苍龙擒猛虎，一枪纵横定天山！",
  ["$ofl2__shouli2"] = "马踏祁连山河动，兵起玄黄奈何天！",
}

shouli:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = function(self, player, card, selected_targets)
    return "#shouli-" .. self.interaction.data
  end,
  interaction = function(self, player)
    local names = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.find(p:getEquipments(Card.SubtypeOffensiveRide), function (id)
        return #player:getViewAsCardNames(shouli.name, {"slash"}, {id}) > 0
      end) then
        table.insertIfNeed(names, "slash")
      end
      if table.find(p:getEquipments(Card.SubtypeDefensiveRide), function (id)
        return #player:getViewAsCardNames(shouli.name, {"jink"}, {id}) > 0
      end) then
        table.insertIfNeed(names, "jink")
      end
      if #names == 2 then break end
    end
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = {"slash", "jink"}}
  end,
  view_as = function(self, player, cards)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = shouli.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local horse_type = use.card.trueName == "slash" and Card.SubtypeOffensiveRide or Card.SubtypeDefensiveRide
    local horse_name = use.card.trueName == "slash" and "offensive_horse" or "defensive_horse"
    local targets = table.filter(room.alive_players, function (p)
      return #p:getEquipments(horse_type) > 0
    end)
    local to = room:askToChoosePlayers(player, {
      skill_name = shouli.name,
      min_num = 1,
      max_num = 1,
      targets = targets,
      prompt = "#ofl2__shouli-horse:::" .. horse_name,
      cancelable = false,
      no_indicate = true,
    })[1]
    room:addPlayerMark(to, "@@ofl2__shouli-turn", 1)
    if to ~= player then
      room:addPlayerMark(player, "@@ofl2__shouli-turn", 1)
    end
    room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    use.card:addSubcards(to:getEquipments(horse_type))
  end,
  enabled_at_play = function(self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.find(p:getEquipments(Card.SubtypeOffensiveRide), function (id)
        return #player:getViewAsCardNames(shouli.name, {"slash"}, {id}) > 0
      end) then
        return true
      end
    end
  end,
  enabled_at_response = function(self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.find(p:getEquipments(Card.SubtypeOffensiveRide), function (id)
        return #player:getViewAsCardNames(shouli.name, {"slash"}, {id}) > 0
      end) then
        return true
      end
      if table.find(p:getEquipments(Card.SubtypeDefensiveRide), function (id)
        return #player:getViewAsCardNames(shouli.name, {"jink"}, {id}) > 0
      end) then
        return true
      end
    end
  end,
})

shouli:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shouli.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, room.alive_players)
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local ids = table.filter(p:getHandlyIds(), function (id)
          return Fk:getCardById(id).sub_type == Card.SubtypeDefensiveRide or
            Fk:getCardById(id).sub_type == Card.SubtypeOffensiveRide
        end)
        local use = room:askToUseCard(p, {
          skill_name = shouli.name,
          pattern = tostring(Exppattern{ id = ids }),
          prompt = "#ofl2__shouli-use",
          cancelable = true,
        })
        if use then
          room:useCard(use)
          if not p.dead then
            p:drawCards(1, shouli.name)
          end
        else
          local cards = table.filter(room:getBanner(shouli.name), function (id)
            return room:getCardArea(id) == Card.Void and p:canUseTo(Fk:getCardById(id), p)
          end)
          if #cards > 0 then
            local horse = Fk:getCardById(table.random(cards))
            room:useCard{
              from = p,
              tos = {p},
              card = horse,
            }
          end
        end
      end
    end
  end,
})

shouli:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl2__shouli-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    data.damageType = fk.ThunderDamage
  end,
})

shouli:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(shouli.name) then
    local cards = {
      room:printCard("dilu", Card.Club, 5).id,
      room:printCard("jueying", Card.Spade, 5).id,
      room:printCard("zhuahuangfeidian", Card.Heart, 13).id,
      room:printCard("chitu", Card.Heart, 5).id,
      room:printCard("dayuan", Card.Spade, 13).id,
      room:printCard("zixing", Card.Diamond, 13).id,
      room:printCard("hualiu", Card.Diamond, 13).id,
      room:printCard("jingfan", Card.Heart, 3).id,
    }
    room:setBanner(shouli.name, cards)
  end
end)

return shouli
