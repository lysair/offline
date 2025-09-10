local yizhao = fk.CreateSkill {
  name = "qshm__yizhao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qshm__yizhao"] = "异兆",
  [":qshm__yizhao"] = "锁定技，当你使用或打出一张牌时，获得等同于此牌点数的“黄”标记，然后若“黄”标记数的十位数变化，你观看牌堆顶十张牌，"..
  "展示并获得其中任意张点数为变化后十位数的牌。",

  ["@zhangjiao_huang"] = "黄",
  ["#qshm__yizhao-prey"] = "异兆：获得其中任意张点数为%arg的牌",

  ["$qshm__yizhao1"] = "苍天离析，汉祚倾颓，逢甲子之岁可问道太平。",
  ["$qshm__yizhao2"] = "紫微离北，七杀掠日，此天地欲复以吾为刍狗。",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yizhao.name) and data.card.number > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n1 = tostring(player:getMark("@zhangjiao_huang"))
    room:addPlayerMark(player, "@zhangjiao_huang", data.card.number)
    local n2 = tostring(player:getMark("@zhangjiao_huang"))
    if #n1 == 1 then
      if #n2 == 1 then return end
    else
      if n1:sub(#n1 - 1, #n1 - 1) == n2:sub(#n2 - 1, #n2 - 1) then return end
    end
    local x = n2:sub(#n2 - 1, #n2 - 1)
    if x == "0" then x = "10" end
    local cards = room:getNCards(10)
    local cardmap = room:askToArrangeCards(player, {
      skill_name = yizhao.name,
      card_map = {cards, "Top", "toObtain"},
      prompt = "#qshm__yizhao-prey:::"..x,
      pattern = ".|"..x,
    })
    if #cardmap[2] > 0 then
      room:showCards(cardmap[2])
      room:moveCardTo(cardmap[2], Player.Hand, player, fk.ReasonJustMove, yizhao.name, nil, true, player)
    end
  end,
}

yizhao:addEffect(fk.CardUsing, spec)
yizhao:addEffect(fk.CardResponding, spec)

yizhao:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@zhangjiao_huang", 0)
end)

return yizhao
