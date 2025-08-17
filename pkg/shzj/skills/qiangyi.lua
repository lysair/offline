local qiangyi = fk.CreateSkill {
  name = "qiangyi",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["qiangyi"] = "戕异",
  [":qiangyi"] = "主公技，当你<a href='premeditate_href'>“蓄谋”</a>后，你获得一张【影】；你可以将【影】当"..
  "<a href=':destroy_indiscrimintely'>【玉石皆碎】</a>对势力与你相同的角色使用。",

  ["#qiangyi"] = "戕异：你可以将【影】当【玉石皆碎】对势力与你相同的角色使用",
}

local U = require "packages/utility/utility"

qiangyi:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "destroy_indiscrimintely",
  prompt = "#qiangyi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "shade"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("destroy_indiscrimintely")
    card.skillName = qiangyi.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

qiangyi:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    return card and table.contains(card.skillNames, qiangyi.name) and from and to and
      from.kingdom ~= to.kingdom
  end,
})

qiangyi:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qiangyi.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerJudge then
          for _, info in ipairs(move.moveInfo) do
            if player:getVirualEquip(info.cardId) and player:getVirualEquip(info.cardId).name == "premeditate" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(U.getShade(room, 1), Card.PlayerHand, player, fk.ReasonJustMove, qiangyi.name, nil, true, player)
  end,
})

return qiangyi
