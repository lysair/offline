local jushoup = fk.CreateSkill {
  name = "jushoup",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jushoup"] = "聚首",
  [":jushoup"] = "锁定技，游戏开始时，你获得起义军标记，然后令至多两名不为一号位且非起义军角色依次选择一项：1.获得起义军标记；"..
  "2.你获得其一张手牌。",

  ["#jushoup-choose"]= "聚首：你可以令至多两名角色选择成为起义军或你获得其一张手牌",
  ["#jushoup-ask"] = "聚首：点“确定”加入起义军（起义军技能点击左上角查看），或点“取消” %src 获得你一张手牌！",
  ["#jushoup-prey"] = "聚首：获得 %dest 一张手牌",
}

local U = require "packages/offline/ofl_util"

jushoup:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jushoup.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not U.isInsurrectionary(player) then
      U.joinInsurrectionary(player, jushoup.name)
    end
    local targets = table.filter(room.alive_players, function (p)
      return p.seat ~= 1 and not U.isInsurrectionary(p)
    end)
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 2,
      targets = table.map(targets, Util.IdMapper),
      prompt = "#jushoup-choose",
      skill_name = jushoup.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      for _, p in ipairs(tos) do
        if not p.dead then
          if p:isKongcheng() or player.dead or room:askToSkillInvoke(p, {
            skill_name = jushoup.name,
            prompt = "#jushoup-ask:"..player.id,
          }) then
            U.joinInsurrectionary(p, jushoup.name)
          else
            local card = room:askToChooseCard(player, {
              target = p,
              flag = "h",
              skill_name = jushoup.name,
              prompt = "#jushoup-prey::"..p.id,
            })
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jushoup.name, nil, false, player)
          end
        end
      end
    end
  end,
})

return jushoup
