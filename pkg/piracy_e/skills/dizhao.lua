local dizhao = fk.CreateSkill{
  name = "ofl__dizhao",
}

Fk:loadTranslationTable{
  ["ofl__dizhao"] = "帝诏",
  [":ofl__dizhao"] = "每轮各限一次，你可以视为使用一张基本牌，然后令一名其他角色摸一张牌；"..
  "你可以视为使用一张普通锦囊牌，然后令一名其他角色回复1点体力。",

  ["#ofl__dizhao"] = "帝诏：视为使用基本牌，令一名其他角色摸一张牌；或视为使用锦囊牌，令一名其他角色回复体力",
  ["#ofl__dizhao-draw"] = "帝诏：令一名其他角色摸一张牌",
  ["#ofl__dizhao-recover"] = "帝诏：令一名其他角色回复1点体力",
}

dizhao:addEffect("viewas", {
  anim_type = "support",
  pattern = ".",
  prompt = "#ofl__dizhao",
  interaction = function(self, player)
    local all_names = {}
    if not table.contains(player:getTableMark("ofl__dizhao-round"), "basic") then
      table.insertTable(all_names,Fk:getAllCardNames("b"))
    end
    if not table.contains(player:getTableMark("ofl__dizhao-round"), "trick") then
      table.insertTable(all_names,Fk:getAllCardNames("t"))
    end
    local names = player:getViewAsCardNames(dizhao.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = dizhao.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "ofl__dizhao-round", use.card:getTypeString())
  end,
  after_use = function (self, player, use)
    if not player.dead and #player.room:getOtherPlayers(player, false) > 0 then
      local room = player.room
      if use.card.type == Card.TypeBasic then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = room:getOtherPlayers(player, false),
          skill_name = dizhao.name,
          prompt = "#ofl__dizhao-draw",
          cancelable = false,
        })[1]
        to:drawCards(1, dizhao.name)
      else
        local targets = table.filter(room:getOtherPlayers(player, false), function(p)
          return p:isWounded()
        end)
        if #targets > 0 then
          local to = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = targets,
            skill_name = dizhao.name,
            prompt = "#ofl__dizhao-recover",
            cancelable = false,
          })[1]
          room:recover{
            who = to,
            num = 1,
            recoverBy = player,
            skillName = dizhao.name,
          }
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return #player:getTableMark("ofl__dizhao-round") < 2
  end,
  enabled_at_response = function(self, player, response)
    if response or #player:getTableMark("ofl__dizhao-round") == 2 then return end
    if not table.contains(player:getTableMark("ofl__dizhao-round"), "basic") then
      if #player:getViewAsCardNames(dizhao.name, Fk:getAllCardNames("b")) > 0 then
        return true
      end
    end
    if not table.contains(player:getTableMark("ofl__dizhao-round"), "trick") then
      if #player:getViewAsCardNames(dizhao.name, Fk:getAllCardNames("t")) > 0 then
        return true
      end
    end
  end,
  enabled_at_nullification = function (self, player, data)
    return not table.contains(player:getTableMark("ofl__dizhao-round"), "trick")
  end,
})

dizhao:addAI(nil, "vs_skill")

return dizhao
