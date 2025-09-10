local sangu = fk.CreateSkill {
  name = "ofl__sangu",
}

Fk:loadTranslationTable{
  ["ofl__sangu"] = "三顾",
  [":ofl__sangu"] = "一名角色出牌阶段开始时，若其手牌数不小于其体力上限，你可以观看牌堆顶三张牌并亮出其中任意张牌名不同的基本牌或"..
  "普通锦囊牌。若如此做，此阶段每种牌名限一次，该角色可以将一张手牌当你亮出的一张牌使用。",

  ["#ofl__sangu-invoke"] = "三顾：你可以观看牌堆顶三张牌，令 %dest 本阶段可以将手牌当其中的牌使用",
  ["#ofl__sangu-show"] = "三顾：你可以亮出其中的基本牌或普通锦囊牌，%dest 本阶段可以将手牌当亮出的牌使用",
  ["@$ofl__sangu-phase"] = "三顾",
  ["ofl__sangu&"] = "三顾",

  ["$ofl__sangu1"] = "蒙先帝三顾祖父之恩，吾父子自当为国用命！",
  ["$ofl__sangu2"] = "祖孙三代世受君恩，当效吾祖鞠躬尽瘁。",
}

sangu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sangu.name) and target.phase == Player.Play and
      target:getHandcardNum() >= target.maxHp and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = sangu.name,
      prompt = "#ofl__sangu-invoke::" .. target.id
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__sangu_active",
      prompt = "#ofl__sangu-show::" .. target.id,
      cancelable = true,
      extra_data = {
        ofl__sangu = room:getNCards(3),
      }
    })
    if success and dat then
      room:showCards(dat.cards)
      if not target.dead then
        for _, id in ipairs(dat.cards) do
          room:addTableMarkIfNeed(target, "@$ofl__sangu-phase", Fk:getCardById(id).name)
        end
        room:handleAddLoseSkills(target, "ofl__sangu&", nil, false, true)
        room.logic:getCurrentEvent():findParent(GameEvent.Phase, true):addCleaner(function()
          room:handleAddLoseSkills(target, "-ofl__sangu&", nil, false, true)
        end)
      end
    end
  end,
})

return sangu
