local haokou = fk.CreateSkill {
  name = "haokou"
}

Fk:loadTranslationTable{
  ['haokou'] = '豪寇',
  [':haokou'] = '群势力技，锁定技，游戏开始时，你获得起义军标记；当你失去起义军标记后，你变更势力至吴。',
}

haokou:addEffect({fk.GameStart, "fk.QuitInsurrectionary"}, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(haokou.name) then
      if event == fk.GameStart then
        return not IsInsurrectionary(player)
      elseif event == "fk.QuitInsurrectionary" then
        return player.kingdom ~= "wu"
      end
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.GameStart then
      JoinInsurrectionary(player)
      room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)
    elseif event == "fk.QuitInsurrectionary" then
      room:changeKingdom(player, "wu", true)
    end
  end,
})

return haokou
  ```

