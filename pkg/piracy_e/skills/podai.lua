local podai = fk.CreateSkill {
  name = "ofl__podai",
}

Fk:loadTranslationTable{
  ["ofl__podai"] = "破怠",
  [":ofl__podai"] = "每轮各限一次，一名角色的回合开始或结束时，你可以选择一顶：1.令其描述中含有基本牌名或数字的一个技能失效；2.令其摸三张牌，"..
  "然后对其造成1点火焰伤害。",

  ["#ofl__podai-invoke"] = "破怠：是否对 %dest 执行一项？",
  ["ofl__podai2"] = "令其摸三张牌，对其造成1点火焰伤害",
  ["ofl__podai1"] = "令其一个描述中含有基本牌名或数字的技能失效",
  ["#ofl__podai-skill"] = "破怠：令 %dest 的一个技能失效！",
  ["#ofl__podai"] = "%from 令 %to 的技能“%arg”失效！",
}

local spec = {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(podai.name) and not target.dead then
      local choices = {}
      if player:getMark("ofl__podai2-round") == 0 then
        table.insert(choices, "ofl__podai2")
      end
      if player:getMark("ofl__podai1-round") == 0 then
        for _, card in pairs(Fk.all_card_types) do
          if card.type == Card.TypeBasic then
            for _, s in ipairs(target:getSkillNameList()) do
              if string.find(Fk:translate(":"..s, "zh_CN"), "【"..Fk:translate(card.trueName, "zh_CN").."】") then
                table.insert(choices, "ofl__podai1")
                if #choices > 0 then
                  event:setCostData(self, choices)
                  return true
                end
              end
            end
          end
        end
        for _, s in ipairs(target:getSkillNameList()) do
          if table.find({
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "零", "一", "二", "三", "四", "五", "六", "七", "八", "九",
            "两", "十", "百", "千", "万"
          }, function (str)
            return string.find(Fk:translate(":"..s, "zh_CN"), str) ~= nil
          end) then
            table.insert(choices, "ofl__podai1")
            if #choices > 0 then
              event:setCostData(self, choices)
              return true
            end
          end
        end
      end
      if #choices > 0 then
        event:setCostData(self, choices)
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local choices = event:getCostData(self)
    table.insert(choices, "Cancel")
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = podai.name,
      prompt = "#ofl__podai-invoke::"..target.id,
      all_choices = {"ofl__podai1", "ofl__podai2", "Cancel"},
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    room:setPlayerMark(player, choice.."-round", 1)
    if choice == "ofl__podai1" then
      local skills = {}
      for _, card in pairs(Fk.all_card_types) do
        if card.type == Card.TypeBasic then
          for _, s in ipairs(target:getSkillNameList()) do
            if string.find(Fk:translate(":"..s, "zh_CN"), "【"..Fk:translate(card.trueName, "zh_CN").."】") then
              table.insertIfNeed(skills, s)
            end
          end
        end
      end
      for _, s in ipairs(target:getSkillNameList()) do
          if table.find({
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "零", "一", "二", "三", "四", "五", "六", "七", "八", "九",
            "两", "十", "百", "千", "万"
          }, function (str)
          return string.find(Fk:translate(":"..s, "zh_CN"), str) ~= nil
          end) then
          table.insertIfNeed(skills, s)
        end
      end
      if #skills > 0 then
        choice = room:askToCustomDialog(player, {
          skill_name = podai.name,
          qml_path = "packages/utility/qml/ChooseSkillBox.qml",
          extra_data = { skills, 1, 1, "#ofl__podai-skill::"..target.id, {} },
        })
        if choice == "" then
          choice = table.random(skills)
        else
          choice = json.decode(choice)[1]
        end
        room:sendLog{
          type = "#ofl__podai",
          from = player.id,
          to = { target.id },
          arg = choice,
          toast = true,
        }
        room:invalidateSkill(target, choice, nil, podai.name)
      end
    else
      target:drawCards(3, podai.name)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = podai.name,
        }
      end
    end
  end,
}

podai:addEffect(fk.TurnStart, spec)
podai:addEffect(fk.TurnEnd, spec)

podai:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "ofl__podai1-round", 0)
  player.room:setPlayerMark(player, "ofl__podai2-round", 0)
end)

return podai
