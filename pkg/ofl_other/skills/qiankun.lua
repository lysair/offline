local qiankun = fk.CreateSkill {
  name = "qiankun",
}

Fk:loadTranslationTable{
  ["qiankun"] = "乾坤",
  [":qiankun"] = "无视其他玩家任何装备牌的效果。",
}

--距离技1
qiankun:addEffect("distance", {
  correct_func = function (self, from, to)
    local excludeSkills = {}
    if from:hasSkill(qiankun.name) and from ~= to then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= from then
          for _, id in ipairs(p:getCardIds("e")) do
            local equip = p:getVirualEquip(id) --[[@as EquipCard]]
            if equip == nil and table.contains(p:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
              equip = Fk:getCardById(id) --[[@as EquipCard]]
            end
            if equip and equip.type == Card.TypeEquip then
              for _, skill in ipairs(equip:getEquipSkills(p)) do
                table.insertIfNeed(excludeSkills, skill.name)
              end
            end
          end
        end
      end
    end
    if to:hasSkill(qiankun.name) and from ~= to then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= to then
          for _, id in ipairs(p:getCardIds("e")) do
            local equip = p:getVirualEquip(id) --[[@as EquipCard]]
            if equip == nil and table.contains(p:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
              equip = Fk:getCardById(id) --[[@as EquipCard]]
            end
            if equip and equip.type == Card.TypeEquip then
              for _, skill in ipairs(equip:getEquipSkills(p)) do
                table.insertIfNeed(excludeSkills, skill.name)
              end
            end
          end
        end
      end
    end
    if #excludeSkills > 0 then
      local ret = 0
      local status_skills = Fk:currentRoom().status_skills[DistanceSkill] or Util.DummyTable  ---@type DistanceSkill[]
      for _, skill in ipairs(status_skills) do
        if table.contains(excludeSkills, skill.name) then
          local correct = skill:getCorrect(from, to)
          ret = ret - (correct or 0)
        end
      end
      return ret
    end
  end,
})

--距离技2
qiankun:addEffect("distance", {
  fixed_func = function (self, from, to)
    local excludeSkills = {}
    if from:hasSkill(qiankun.name) and from ~= to then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= from then
          for _, id in ipairs(p:getCardIds("e")) do
            local equip = p:getVirualEquip(id) --[[@as EquipCard]]
            if equip == nil and table.contains(p:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
              equip = Fk:getCardById(id) --[[@as EquipCard]]
            end
            if equip and equip.type == Card.TypeEquip then
              for _, skill in ipairs(equip:getEquipSkills(p)) do
                table.insertIfNeed(excludeSkills, skill.name)
              end
            end
          end
        end
      end
    end
    if to:hasSkill(qiankun.name) and from ~= to then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= to then
          for _, id in ipairs(p:getCardIds("e")) do
            local equip = p:getVirualEquip(id) --[[@as EquipCard]]
            if equip == nil and table.contains(p:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
              equip = Fk:getCardById(id) --[[@as EquipCard]]
            end
            if equip and equip.type == Card.TypeEquip then
              for _, skill in ipairs(equip:getEquipSkills(p)) do
                table.insertIfNeed(excludeSkills, skill.name)
              end
            end
          end
        end
      end
    end
    if #excludeSkills > 0 then
      local status_skills = Fk:currentRoom().status_skills[DistanceSkill] or Util.DummyTable  ---@type DistanceSkill[]
      for _, skill in ipairs(status_skills) do
        if skill ~= self and not table.contains(excludeSkills, skill.name) then
          local fixed = skill:getFixed(from, to)
          if fixed ~= nil then
            return math.max(fixed, 1)
          end
        end
      end
    end
  end,
})

--攻击范围失效
qiankun:addEffect("atkrange", {
  without_func = function (self, from, to)
    return to:hasSkill(qiankun.name) and
      not from:inMyAttackRange(to, nil, from:getCardIds("e"), {self.name})
  end,
})

--防具失效
qiankun:addEffect("invalidity", {
  invalidity_func = function(self, player, skill)
    if skill:getSkeleton() and skill:getSkeleton().attached_equip and
      Fk:cloneCard(skill:getSkeleton().attached_equip).sub_type == Card.SubtypeArmor then
      if not RoomInstance then return end
      local logic = RoomInstance.logic
      local event = logic:getCurrentEvent()
      local from = nil
      repeat
        local data = event.data
        if event.event == GameEvent.SkillEffect then
          ---@cast data SkillEffectData
          if not data.skill.cardSkill then
            from = data.who
            break
          end
        elseif event.event == GameEvent.Damage then
          ---@cast data DamageData
          if data.to ~= player then return false end
          from = data.from
          break
        elseif event.event == GameEvent.UseCard then
          ---@cast data UseCardData
          if not table.contains(data.tos, player) then return false end
          from = data.from
          break
        end
        event = event.parent
      until event == nil
      return from and from:hasSkill(qiankun.name) and from ~= player
    end
  end
})

--武器失效
qiankun:addEffect("invalidity", {
  invalidity_func = function(self, player, skill)
    if skill:getSkeleton() and skill:getSkeleton().attached_equip and
      Fk:cloneCard(skill:getSkeleton().attached_equip).sub_type == Card.SubtypeWeapon then
      if not RoomInstance then return end
      local logic = RoomInstance.logic
      local event = logic:getCurrentEvent()
      repeat
        local data = event.data
        --寒冰剑、古锭刀
        if event.event == GameEvent.Damage then
          ---@cast data DamageData
          if data.from  ~= player then return false end
          return data.to:hasSkill(qiankun.name)
        --青釭剑、雌雄双股剑、朱雀羽扇
        --分叉摆了
        elseif event.event == GameEvent.UseCard then
          ---@cast data UseCardData
          if data.from  ~= player then return false end
          return table.find(data.tos, function (p)
            return p:hasSkill(qiankun.name)
          end)
        --青龙偃月刀、贯石斧
        elseif event.event == GameEvent.CardEffect then
          ---@cast data CardEffectData
          if data.from  ~= player then return false end
          return data.to:hasSkill(qiankun.name)
        end
        event = event.parent
      until event == nil
    end
  end
})

qiankun:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    if to and to:hasSkill(qiankun.name) and from and from ~= to and card then
      if card.type == Card.TypeEquip then  --逐鹿装备
        return true
      elseif card:isVirtual() then
        for _, id in ipairs(from:getCardIds("e")) do
          local equip = from:getVirualEquip(id) --[[@as EquipCard]]
          if equip == nil and table.contains(from:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
            equip = Fk:getCardById(id) --[[@as EquipCard]]
          end
          if equip and equip.type == Card.TypeEquip then
            if table.contains(card.skillNames, equip.name) then  --禁用丈八
              return true
            end
            for _, skill in ipairs(equip:getEquipSkills(from)) do  --禁用玄剑
              if table.contains(card.skillNames, skill.name) then
                return true
              end
            end
          end
        end
      end
    end
  end,
})

qiankun:addEffect(fk.BeforeCardsMove, {  --禁用木马
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(qiankun.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerEquip and
          move.proposer and move.proposer ~= player and
          move.skillName then
          for _, id in ipairs(move.proposer:getCardIds("e")) do
            local equip = move.proposer:getVirualEquip(id) --[[@as EquipCard]]
            if equip == nil and table.contains(move.proposer:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
              equip = Fk:getCardById(id) --[[@as EquipCard]]
            end
            if equip and equip.type == Card.TypeEquip then
              for _, skill in ipairs(equip:getEquipSkills(move.proposer)) do
                print(skill.name)
                if skill.name == move.skillName then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerEquip and
        move.proposer and move.proposer ~= player and
        move.skillName then
        for _, id in ipairs(move.proposer:getCardIds("e")) do
          local equip = move.proposer:getVirualEquip(id) --[[@as EquipCard]]
          if equip == nil and table.contains(move.proposer:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
            equip = Fk:getCardById(id) --[[@as EquipCard]]
          end
          if equip and equip.type == Card.TypeEquip then
            for _, skill in ipairs(equip:getEquipSkills(move.proposer)) do
              if skill.name == move.skillName then
                for _, info in ipairs(move.moveInfo) do
                  table.insert(ids, info.cardId)
                end
              end
            end
          end
        end
      end
    end
    room:cancelMove(data, ids)
  end,
})

--摆了：连弩、方天画戟、夜行衣、春秋笔
--其他衍生装备没看

return qiankun
