---@class Utility : Object
local Utility = {}

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
Utility.JoinInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("Utility.JoinInsurrectionary")
--- 退出起义军
---@class Utility.QuitInsurrectionary: Utility.InsurrectionaryTriggerEvent
Utility.QuitInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("Utility.QuitInsurrectionary")

---@alias InsurrectionaryTrigFunc fun(self: TriggerSkill, event: Utility.InsurrectionaryTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.InsurrectionaryData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.InsurrectionaryTriggerEvent,
---  data: TrigSkelSpec<InsurrectionaryTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

return Utility
