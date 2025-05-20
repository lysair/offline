local jixul = fk.CreateSkill {
  name = "jixul",
}

Fk:loadTranslationTable {
  ["jixul"] = "济恤",
  [":jixul"] = "出牌阶段每个角色组合限一次，你可以选择两名角色，若其手牌数之和小于任意两名除其以外角色的手牌数之和，你观看牌堆顶三张牌"..
  "并分配给选择的角色（每名角色至少一张）。",

  ["#jixul"] = "济恤：选择两名角色，若其手牌数之和为最小，你观看牌堆顶三张牌并分配给选择的角色",
  ["#jixul-give"] = "济恤：将这些牌分配给目标角色，每名角色至少一张",
  ["jixul_tip_yes"] = "可分配",
  ["jixul_tip_no"] = "不可分配",
}

jixul:addEffect("active", {
  anim_type = "support",
  prompt = "#jixul",
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    if #selected == 0 then
      if table.every(Fk:currentRoom().alive_players, function (p)
        if p == to_select then
          return true
        else
          return table.find(player:getTableMark("jixul-phase"), function (info)
            return (info[1] == p.id and info[2] == to_select.id) or (info[1] == to_select.id and info[2] == p.id)
          end)
        end
      end) then
        return false
      end
      return true
    elseif #selected == 1 then
      if table.find(player:getTableMark("jixul-phase"), function (info)
        return (info[1] == to_select.id and info[2] == selected[1].id) or (info[1] == selected[1].id and info[2] == to_select.id)
      end) then
        return false
      end
      return true
    end
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if not selectable or #selected < 1 then return end
    local nums = table.map(Fk:currentRoom().alive_players, function (p)
      return p:getHandcardNum()
    end)
    local p1, p2 = to_select, selected[1]
    if #selected == 2 then
      p1, p2 = selected[1], selected[2]
    end
    local n = p1:getHandcardNum() + p2:getHandcardNum()
    table.removeOne(nums, p1:getHandcardNum())
    table.removeOne(nums, p2:getHandcardNum())
    table.sort(nums)
    local yes = #nums < 2
    if not yes then
      yes = n < nums[1] + nums[2]
    end
    if yes then
      return "jixul_tip_yes"
    else
      return "jixul_tip_no"
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addTableMark(player, "jixul-phase", {effect.tos[1].id, effect.tos[2].id})
    local n = effect.tos[1]:getHandcardNum() + effect.tos[2]:getHandcardNum()
    local nums = table.map(room.alive_players, function (p)
      return p:getHandcardNum()
    end)
    table.removeOne(nums, effect.tos[1]:getHandcardNum())
    table.removeOne(nums, effect.tos[2]:getHandcardNum())
    table.sort(nums)
    local yes = #nums < 2
    if not yes then
      yes = n < nums[1] + nums[2]
    end
    if yes then
      local cards = room:getNCards(3)
      room:askToYiji(player, {
        cards = cards,
        targets = effect.tos,
        skill_name = jixul.name,
        min_num = 3,
        max_num = 3,
        prompt = "#jixul-give",
        expand_pile = cards,
        single_max = 2,
      })
    end
  end,
})

return jixul
