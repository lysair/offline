local extension = Package("assassins")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["assassins"] = "铜雀台",
  ["tqt"] = "铜雀台",
}

local fuwan = General(extension, "tqt__fuwan", "qun", 3)
local fengyin = fk.CreateTriggerSkill{
  name = "fengyin",
  anim_type = "control",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.hp >= player.hp then
      return not player:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCard(player, 1, 1, false, self.name, true, 'slash',
      '#fengyin::' .. target.id)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = self.cost_data
    room:moveCardTo(card, Player.Hand, target, fk.ReasonGive, self.name, nil, true, player.id)
    target:skip(Player.Play)
    target:skip(Player.Discard)
  end
}
local chizhong = fk.CreateTriggerSkill{
  name = "chizhong",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
  end,
}
local chizhongMax = fk.CreateMaxCardsSkill{
  name = "#chizhong_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(chizhong) then
      return player.maxHp
    end
  end
}
chizhong:addRelatedSkill(chizhongMax)
fuwan:addSkill(fengyin)
fuwan:addSkill(chizhong)

Fk:loadTranslationTable{
  ["#tqt__fuwan"] = "沉毅的国丈",
  ["tqt__fuwan"] = "伏完",
	["designer:tqt__fuwan"] = "凌天翼",
	["illustrator:tqt__fuwan"] = "LiuHeng",
	["fengyin"] = "奉印",
	[":fengyin"] = "其他角色的回合开始时，若其当前的体力值不小于你，你可以交给其一张【杀】，令其跳过其出牌阶段和弃牌阶段。",
	["#fengyin"] = "奉印: 你可以交给 %dest 一张【杀】，跳过其出牌阶段和弃牌阶段",
	["chizhong"] = "持重",
	[":chizhong"] = "锁定技，你的手牌上限等于你的体力上限；有角色死亡时，你加1点体力上限。",
}

return extension
