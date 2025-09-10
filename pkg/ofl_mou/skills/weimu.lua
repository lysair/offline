local weimu = fk.CreateSkill({
  name = "ofl_mou__weimu",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl_mou__weimu"] = "帷幕",
  [":ofl_mou__weimu"] = "锁定技，当你成为黑色锦囊牌的目标时，取消之。每轮开始时，你从额外牌堆获得一张黑色锦囊牌或者防具牌。",

  ["#ofl_mou__weimu-prey"] = "帷幕：获得其中一张牌",

  ["$ofl_mou__weimu1"] = "幕后，才是我的主战场。",
  ["$ofl_mou__weimu2"] = "你对我的了解，不过是管中窥豹！",
}

local U = require "packages/offline/ofl_util"

weimu:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weimu.name) and
      data.card.type == Card.TypeTrick and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(player)
  end,
})

weimu:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(weimu.name) and
      table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
        local card = Fk:getCardById(id)
        return (Fk:getCardById(id).type == Card.TypeTrick and card.color == Card.Black) or
          Fk:getCardById(id).sub_type == Card.SubtypeArmor
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      local card = Fk:getCardById(id)
      return (Fk:getCardById(id).type == Card.TypeTrick and card.color == Card.Black) or
        Fk:getCardById(id).sub_type == Card.SubtypeArmor
    end)
    if #ids > 0 then
      local card = room:askToChooseCard(player, {
        target = player,
        flag = { card_data = {{ "toObtain", ids }} },
        skill_name = weimu.name,
        prompt = "#ofl_mou__weimu-prey",
      })
      room:moveCardTo(card, Player.Hand, player, fk.ReasonJustMove, weimu.name, nil, true, player, MarkEnum.DestructIntoDiscard)
    end
  end,
})

weimu:addAcquireEffect(function (self, player, is_start)
  U.PrepareExtraPile(player.room)
end)

return weimu
