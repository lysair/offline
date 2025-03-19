local sanshou = fk.CreateSkill {
  name = "ofl__sanshou"
}

Fk:loadTranslationTable{
  ['ofl__sanshou'] = '三首',
  ['ofl__godzhangjiao'] = '神张角',
  ['ofl__godzhangbao'] = '神张宝',
  ['ofl__godzhangliang'] = '神张梁',
  ['#ofl__sanshou-choose'] = '三首：选择此阶段要变为的武将',
  [':ofl__sanshou'] = '锁定技，你的准备阶段和结束阶段改为出牌阶段，并在此阶段将武将牌改为张宝或张梁。此阶段结束后把武将牌替换回张角。',
}

sanshou:addEffect(fk.EventPhaseChanging, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanshou.name) and table.contains({Player.Start, Player.Finish}, data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.to = Player.Play
    local isDeputy = true
    if player.general == "ofl__godzhangjiao" then
      isDeputy = false
    end
    room:setPlayerMark(player, "ofl__sanshou-phase", isDeputy and 2 or 1)
    local result = room:askToCustomDialog(
      player,
      {
        skill_name = sanshou.name,
        qml_path = "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
        extra_data = {
          {"ofl__godzhangbao", "ofl__godzhangliang"},
          {Fk.generals["ofl__godzhangbao"]:getSkillNameList(), Fk.generals["ofl__godzhangliang"]:getSkillNameList()},
          "#ofl__sanshou-choose",
        }
      }
    )
    if result == "" then
      result = "ofl__godzhangbao"
    else
      result = table.unpack(json.decode(result))
    end
    room:changeHero(player, result, false, isDeputy, true, false, false)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("ofl__sanshou-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:changeHero(player, "ofl__godzhangjiao", false, player:getMark("ofl__sanshou-phase") == 2, true, false, false)
  end,
})

return sanshou
