
local skill_pool = {
  --标
  "qingguo", "wusheng", "qixi", "guose", "jijiu",
  --神话再临
  "guhuo", "huoji", "kanpo", "lianhuan", "shuangxiong", "luanji", "duanliang", "jiuchi", "longhun",
  --SP
  "mozhi", "chixin", "jieyue",
  --一将成名
  "qice", "fuhun", "zhanjue", "jiaozhao", "taoluan",
  --界限突破
  "ex__wusheng", "ex__guose",
  --手杀
  "m_ex__guhuo", "m_ex__huoji", "m_ex__kanpo", "m_ex__lianhuan", "m_ex__shuangxiong", "m_ex__luanji", "m_ex__duanliang", "m_ex__jianying",
  "mou__guose", "mou__lianhuan", "mou__luanji", "mou__wusheng",
  "yizan", "mobile__xiaoxi", "zujin", "guli", "baoxi",
  --OL
  "ol_ex__huoji", "ol_ex__kanpo", "ol_ex__lianhuan", "ol_ex__shuangxiong", "ol_ex__luanji", "ol_ex__duanliang", "changbiao", "ol_ex__fuhun",
  "qingleng", "caiwang", "pozhu", "cihuang", "miuyan", "suji", "ol__niluan", "zonglue", "kanpod", "kenshang", "liyongw",
  "weilingy", "lunzhan", "jiewan", "guifu", "zhanding", "jiexuan", "fuxun", "liantao", "xixiang", "zhujiu",
  "kouchao", "leiluan", "jiawei",
  --新服
  "ty_ex__zhuhai", "ty_ex__zhanjue", "limu", "ty_ex__jiaozhao",
  "shouli", "juewu", "tymou__lunshi", "wuwei", "lifengc",
  "ty__niluan", "weiwu", "xiongmang", "ty__taoluan", "heqia", "jieling", "kuiji", "mansi", "posuo", "huahuo", "ty__shichou", "miaoxian",
  "zhaowen",
  --国际服
  "os__cairu",
  --江山如故
  "nianen", "js__chuanxin", "danxinl", "ciying", "qinrao",
  --线下
  "ofl__sangu", "ofl_mou__luanji", "ofl_mou__lianhuan", "ofl_mou__guose", "ofl_mou__wusheng",
  "longyi", "ofl__moucheng", "xijun", "bimeng", "ofl__dishi", "ofl__cuiji", "qianmu", "ofl__yanggu", "yangwu",
  "junshen", "fenwu", "qingkou", "shzj_yiling__longnu", "shzj_yiling__wusheng", "siji", "ansha", "daifa", "xianwu",
  "sxfy__xiongxia", "sxfy__shuchen", "sxfy__chengjiz", "sxfy__zhanjue", "sxfy__zhengnan", "sxfy__youdi", "sxfy__zhitu",
}

local dianmo = fk.CreateSkill {
  name = "dianmo",
  dynamic_desc = function (self, player, lang)
    Fk:loadTranslationTable{
      ["dianmo_skill_pool"] = "技能池如下（已排除房间禁卡）：<br>"..
      table.concat(table.map(Fk:currentRoom():getBanner(self.name), function (s)
        return "<a href=':"..s.."'>"..Fk:translate(s, lang).."</a>"
      end), "  "),
    }
    return "dianmo_inner"
  end,
}

Fk:loadTranslationTable{
  ["dianmo"] = "点墨",
  [":dianmo"] = "准备阶段或当你每回合首次受到伤害后，你可以观看两个转化牌类技能，选择其中一个获得（至多四个）"..
  "或替换一个已有技能，然后摸空置的技能数张牌。",

  [":dianmo_inner"] = "准备阶段或当你每回合首次受到伤害后，你可以观看两个<a href='dianmo_skill_pool'>转化牌类技能</a>，"..
  "选择其中一个获得（至多四个）或替换一个已有技能，然后摸空置的技能数张牌。",

  ["#dianmo-get"] = "点墨：选择要获得的一个技能",
  ["#dianmo-replace"] = "点墨：是否替换现有的“点墨”技能？（上限4个，现有%arg个）",
  ["#dianmo-discard"] = "点墨：选择丢弃的“点墨”技能",
}

local spec = {
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skills = table.filter(room:getBanner(dianmo.name), function (s)
      return Fk.skills[s] and not player:hasSkill(s, true)
    end)
    local choice = room:askToCustomDialog(player, {
      skill_name = dianmo.name,
      qml_path = "packages/utility/qml/ChooseSkillBox.qml",
      extra_data = { table.random(skills, 2), 1, 1, "#dianmo-get", {} },
    })
    if choice == "" then
      choice = table.random(skills)
    else
      choice = choice[1]
    end
    local exist_skills = table.filter(player:getTableMark(dianmo.name), function (s)
      return player:hasSkill(s, true)
    end)
    if #exist_skills > 0 then
      if #exist_skills == 4 or
        room:askToSkillInvoke(player, {
          skill_name = dianmo.name,
          prompt = "#dianmo-replace:::"..#exist_skills,
        }) then
        local choice2 = room:askToCustomDialog(player, {
          skill_name = dianmo.name,
          qml_path = "packages/utility/qml/ChooseSkillBox.qml",
          extra_data = { exist_skills, 1, 1, "#dianmo-discard", {} },
        })
        if choice2 == "" then
          choice2 = table.random(exist_skills)
        else
          choice2 = choice2[1]
        end
        table.removeOne(exist_skills, choice2)
        table.insert(exist_skills, choice)
        room:setPlayerMark(player, dianmo.name, exist_skills)
        room:handleAddLoseSkills(player, choice.."|-"..choice2)
        if #exist_skills < 4 and not player.dead then
          player:drawCards(4 - #exist_skills, dianmo.name)
        end
        return
      end
    end
    table.insertIfNeed(exist_skills, choice)
    room:setPlayerMark(player, dianmo.name, exist_skills)
    room:handleAddLoseSkills(player, choice)
    if #exist_skills < 4 and not player.dead then
      player:drawCards(4 - #exist_skills, dianmo.name)
    end
  end,
}

dianmo:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(dianmo.name) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function(e)
        return e.data.to == player
      end, Player.HistoryTurn)
      return #damage_events == 1 and damage_events[1].data == data
    end
  end,
  on_use = spec.on_use,
})

dianmo:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(dianmo.name) and player.phase == Player.Start
  end,
  on_use = spec.on_use,
})

dianmo:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(dianmo.name) then
    local all_skills = {}
    for _, g in ipairs(room.general_pile) do
      for _, s in ipairs(Fk.generals[g]:getSkillNameList()) do
        table.insert(all_skills, s)
      end
    end
    local skills = table.filter(skill_pool, function(s)
      return table.contains(all_skills, s)
    end)
    room:setBanner(dianmo.name, skills)
  end
end)

return dianmo
