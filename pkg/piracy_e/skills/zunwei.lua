local zunwei = fk.CreateSkill {
  name = "ofl__zunwei",
  dynamic_desc = function (self, player)
    if #player:getTableMark(self.name) == 3 then
      return "dummyskill"
    else
      local choices = {}
      for i = 1, 3, 1 do
        if not table.contains(player:getTableMark(self.name), "ofl__zunwei"..i) then
          table.insert(choices, Fk:translate("ofl__zunwei"..i))
        else
          table.insert(choices, "<font color=\'gray\'>"..Fk:translate("ofl__zunwei"..i).."</font>")
        end
      end
      return "ofl__zunwei_inner:"..table.concat(choices, "；")
    end
  end,
}

Fk:loadTranslationTable{
  ["ofl__zunwei"] = "尊位",
  [":ofl__zunwei"] = "出牌阶段限一次，你可以选择一项，然后移除该选项：1.将手牌数摸至全场最多；"..
  "2.随机使用牌堆中的装备牌，直到你装备区牌数为全场最多；3.将体力回复至全场最多。",

  [":ofl__zunwei_inner"] = "出牌阶段限一次，你可以选择一项，然后移除该选项：{1}。",

  ["#ofl__zunwei"] = "尊位：选择执行一项效果",
  ["ofl__zunwei1"] = "将手牌摸至全场最多",
  ["ofl__zunwei2"] = "随机使用装备牌至全场最多",
  ["ofl__zunwei3"] = "回复体力至全场最多",

  ["$ofl__zunwei1"] = "皇后位尊，当居后宫之极。",
  ["$ofl__zunwei2"] = "位尊着霞帔，名重戴凤冠。",
}

zunwei:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, zunwei.name, 0)
end)

zunwei:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__zunwei",
  card_num = 0,
  target_num = 0,
  interaction = function(self, player)
    local choices, all_choices = {}, {}
    for i = 1, 3 do
      local choice = "ofl__zunwei"..i
      table.insert(all_choices, choice)
      if not table.contains(player:getTableMark(zunwei.name), choice) then
        table.insert(choices, choice)
      end
    end
    return UI.ComboBox {choices = choices, all_choices = all_choices}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(zunwei.name, Player.HistoryPhase) == 0 and
      table.find({1, 2, 3}, function (i)
        return not table.contains(player:getTableMark(zunwei.name), "ofl__zunwei"..i)
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    room:addTableMark(player, zunwei.name, choice)
    if choice == "ofl__zunwei1" then
      local nums = table.map(room.players, function (p)
        return p:getHandcardNum()
      end)
      local x = math.max(table.unpack(nums)) - player:getHandcardNum()
      if x > 0 then
        player:drawCards(x, zunwei.name)
      end
    elseif choice == "ofl__zunwei2" then
      local cards = {}
      local card
      while not player.dead and
        not table.every(room.players, function (p)
          return #player:getCardIds("e") >= #p:getCardIds("e")
        end) do
        cards = table.filter(room.draw_pile, function (id)
          card = Fk:getCardById(id)
          return player:hasEmptyEquipSlot(card.sub_type) and player:canUseTo(card, player)
        end)
        if #cards > 0 then
          room:useCard{
            from = player,
            tos = {player},
            card = Fk:getCardById(table.random(cards)),
          }
        else
          break
        end
      end
    elseif choice == "ofl__zunwei3" and player:isWounded() then
      local nums = table.map(room.players, function (p)
        return p.hp
      end)
      local x = math.max(table.unpack(nums)) - player.hp
      if x > 0 then
        room:recover{
          who = player,
          num = x,
          recoverBy = player,
          skillName = zunwei.name,
        }
      end
    end
  end,
})

return zunwei
