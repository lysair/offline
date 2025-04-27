---@class Utility : Object
local Utility = {}

------------------------------------------------------------------------------------------------------
local fhyx_pile = {
  {"slash", Card.Club, 4},
  {"thunder__slash", Card.Spade, 4},
  {"fire__slash", Card.Heart, 4},
  {"jink", Card.Diamond, 2},
  {"peach", Card.Heart, 6},
  {"analeptic", Card.Spade, 9},
  {"ex_nihilo", Card.Heart, 8},
  {"amazing_grace", Card.Heart, 4},
  {"dismantlement", Card.Spade, 3},
  {"snatch", Card.Diamond, 3},
  {"fire_attack", Card.Diamond, 2},
  {"duel", Card.Diamond, 1},
  {"savage_assault", Card.Spade, 13},
  {"archery_attack", Card.Heart, 1},
  {"nullification", Card.Heart, 13},
  {"indulgence", Card.Heart, 6},
  {"supply_shortage", Card.Spade, 10},
  {"iron_chain", Card.Club, 12},
  {"lightning", Card.Heart, 12},
  {"collateral", Card.Club, 13},
  {"god_salvation", Card.Heart, 1},
  {"eight_diagram", Card.Spade, 2},
  {"nioh_shield", Card.Club, 2},
  {"vine", Card.Spade, 2},
  {"silver_lion", Card.Club, 1},
  {"dilu", Card.Club, 5},
  {"chitu", Card.Heart, 5},
  {"dayuan", Card.Spade, 13},
  {"zixing", Card.Diamond, 13},
  {"hualiu", Card.Diamond, 13},
  {"zhuahuangfeidian", Card.Heart, 13},
  {"jueying", Card.Spade, 5},
  {"crossbow", Card.Diamond, 1},
  {"qinggang_sword", Card.Spade, 6},
  {"guding_blade", Card.Spade, 1},
  {"ice_sword", Card.Spade, 2},
  {"double_swords", Card.Spade, 2},
  {"blade", Card.Spade, 5},
  {"spear", Card.Spade, 12},
  {"axe", Card.Diamond, 5},
  {"fan", Card.Diamond, 1},
  {"halberd", Card.Diamond, 12},
  {"kylin_bow", Card.Heart, 5},
  {"role__wooden_ox", Card.Diamond, 5},
}

--为房间加载额外牌堆
Utility.PrepareExtraPile = function(room)
  if room:getBanner("fhyx_extra_pile") then return end
  local all_names = {}
  for _, card in ipairs(Fk.cards) do
    if not table.contains(room.disabled_packs, card.package.name) and not card.is_derived then
      if not all_names[card.name] then
        all_names[card.name] = card
      end
    end
  end
  local cards = {}
  for name, card in pairs(all_names) do
    local c = table.find(fhyx_pile, function(info)
      return info[1] == name
    end)
    local id
    if c then
      id = room:printCard(table.unpack(c)).id
    else
      id = room:printCard(name, card.suit, card.number).id
    end
    table.insert(cards, id)
    room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
  end
  room:setBanner("fhyx_extra_pile", cards)
  room:setBanner("@$fhyx_extra_pile", table.simpleClone(cards))
  room:addSkill("#fhyx_extra_pile&")
end

------------------------------------------------------------------------------------------------------
--- OflShouliData 数据
---@class OflShouliDataSpec
---@field public n integer @ 数量

---@class Utility.OflShouliData: OflShouliDataSpec, TriggerData
Utility.OflShouliData = TriggerData:subclass("OflShouliData")

--- TriggerEvent
---@class Utility.OflShouliTriggerEvent: TriggerEvent
---@field public data Utility.OflShouliData
Utility.OflShouliTriggerEvent = TriggerEvent:subclass("OflShouliEvent")

--- 狩骊
---@class Utility.OflShouliMarkChanged: Utility.OflShouliTriggerEvent
Utility.OflShouliMarkChanged = Utility.OflShouliTriggerEvent:subclass("fk.OflShouliMarkChanged")

---@alias OflShouliTrigFunc fun(self: TriggerSkill, event: Utility.OflShouliTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.OflShouliData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.OflShouliTriggerEvent,
---  data: TrigSkelSpec<OflShouliTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

------------------------------------------------------------------------------------------------------
--- InsurrectionaryData 数据
---@class InsurrectionaryDataSpec
---@field public who ServerPlayer @ 玩家
---@field public reason? string @ 原因

---@class Utility.InsurrectionaryData: InsurrectionaryDataSpec, TriggerData
Utility.InsurrectionaryData = TriggerData:subclass("InsurrectionaryData")

--- TriggerEvent
---@class Utility.InsurrectionaryTriggerEvent: TriggerEvent
---@field public data Utility.InsurrectionaryData
Utility.InsurrectionaryTriggerEvent = TriggerEvent:subclass("InsurrectionaryEvent")

--- 加入起义军
---@class Utility.JoinInsurrectionary: Utility.InsurrectionaryTriggerEvent
Utility.JoinInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("fk.JoinInsurrectionary")
--- 退出起义军
---@class Utility.QuitInsurrectionary: Utility.InsurrectionaryTriggerEvent
Utility.QuitInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("fk.QuitInsurrectionary")

---@alias InsurrectionaryTrigFunc fun(self: TriggerSkill, event: Utility.InsurrectionaryTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.InsurrectionaryData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.InsurrectionaryTriggerEvent,
---  data: TrigSkelSpec<InsurrectionaryTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

---加入起义军
---@param player ServerPlayer 玩家
---@param skill_name? string 原因
Utility.joinInsurrectionary = function (player, skill_name)
  local room = player.room
  room:setPlayerMark(player, "@!insurrectionary", 1)
  local record = room:getBanner("insurrectionary") or {}
  table.insert(record, player.id)
  room:setBanner("insurrectionary", record)
  room:setBanner("@[:]insurrectionary", "insurrectionary_banner")
  room:sendLog{
    type = "#JoinInsurrectionary",
    from = player.id,
    toast = true,
  }
  room:addSkill("insurrectionary&")
  room.logic:trigger(Utility.JoinInsurrectionary, player, {who = player, reason = skill_name or "game_rule"}, false)
end

Utility.isInsurrectionary = function(player)
  return table.contains(Fk:currentRoom():getBanner("insurrectionary") or {}, player.id)
end

return Utility
