local extension = Package:new("ofl_mougong")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_mou/skills")

Fk:loadTranslationTable{
  ["ofl_mougong"] = "线下-谋攻篇",
  ["ofl_mou"] = "线下谋攻篇",
}

General:new(extension, "ofl_mou__yuanshao", "qun", 4):addSkills { "ofl_mou__luanji", "ofl_mou__xueyi" }
Fk:loadTranslationTable{
  ["ofl_mou__yuanshao"] = "谋袁绍",
  ["#ofl_mou__yuanshao"] = "高贵的名门",
  ["illustrator:ofl_mou__yuanshao"] = "荧光笔",

  ["~ofl_mou__yuanshao"] = "天命竟最终站在了……他那边……",
}

local jiangwei = General:new(extension, "ofl_mou__jiangwei", "shu", 4)
jiangwei:addSkills { "ofl_mou__tiaoxin", "ofl_mou__zhiji" }
jiangwei:addRelatedSkill("ofl_mou__beifa")
Fk:loadTranslationTable{
  ["ofl_mou__jiangwei"] = "谋姜维",
  ["#ofl_mou__jiangwei"] = "见危授命",
  ["illustrator:ofl_mou__jiangwei"] = "凝聚永恒",

  ["~ofl_mou__jiangwei"] = "这八阵天机，我也难以看破……",
}

General:new(extension, "ofl_mou__sunshangxiang", "shu", 4, 4, General.Female):addSkills {
  "ofl_mou__jieyin", "ofl_mou__liangzhu", "mou__xiaoji" }
Fk:loadTranslationTable{
  ["ofl_mou__sunshangxiang"] = "谋孙尚香",
  ["#ofl_mou__sunshangxiang"] = "骄豪明俏",
  ["illustrator:ofl_mou__sunshangxiang"] = "光域",

  ["$mou__xiaoji_ofl_mou__sunshangxiang1"] = "本小姐自幼弓马娴熟，百兵皆通！",
  ["$mou__xiaoji_ofl_mou__sunshangxiang2"] = "刀枪剑戟，皆不过寻常之兵，有何惧哉？",
  ["~ofl_mou__sunshangxiang"] = "今夫君已亡，复能……独生乎！",
}

--赵云

General:new(extension, "ofl_mou__yujin", "wei", 4):addSkills { "mou__xiayuan", "ofl_mou__jieyue" }
Fk:loadTranslationTable{
  ["ofl_mou__yujin"] = "谋于禁",
  ["#ofl_mou__yujin"] = "威严毅重",
  ["illustrator:ofl_mou__yujin"] = "7点Game",

  ["$mou__xiayuan_ofl_mou__yujin1"] = "粮草已足，必可大破蜀军！",
  ["$mou__xiayuan_ofl_mou__yujin2"] = "战事吃紧，援军速往前线！",
  ["~ofl_mou__yujin"] = "降以保军士，却污此身名……",
}

General:new(extension, "ofl_mou__pangtong", "shu", 3):addSkills { "ofl_mou__lianhuan", "niepan" }
Fk:loadTranslationTable{
  ["ofl_mou__pangtong"] = "谋庞统",
  ["#ofl_mou__pangtong"] = "凤雏",
  ["illustrator:ofl_mou__pangtong"] = "鬼画府",

  ["~ofl_mou__pangtong"] = "",
}

General:new(extension, "ofl_mou__ganning", "wu", 4):addSkills { "ofl_mou__qixi", "ofl_mou__fenwei" }
Fk:loadTranslationTable{
  ["ofl_mou__ganning"] = "谋甘宁",
  ["#ofl_mou__ganning"] = "兴王定霸",
  ["illustrator:ofl_mou__ganning"] = "铁杵",

  ["~ofl_mou__ganning"] = "折冲御侮半生世，忽忆当年锦帆时……",
}

--法正

local sunquan = General:new(extension, "ofl_mou__sunquan", "wu", 4)
sunquan:addSkills { "ofl_mou__zhiheng", "ofl_mou__tongye", "ofl_mou__jiuyuan" }
sunquan:addRelatedSkills { "mou__yingzi", "guzheng" }
Fk:loadTranslationTable{
  ["ofl_mou__sunquan"] = "谋孙权",
  ["#ofl_mou__sunquan"] = "江东大帝",
  ["illustrator:ofl_mou__sunquan"] = "陈层",

  ["~ofl_mou__sunquan"] = "天下一统，吾终不可得乎……",
}

General:new(extension, "ofl_mou__daqiao", "wu", 3, 3, General.Female):addSkills { "ofl_mou__guose", "ofl_mou__liuli" }
Fk:loadTranslationTable{
  ["ofl_mou__daqiao"] = "谋大乔",
  ["#ofl_mou__daqiao"] = "国色芳华",
  ["illustrator:ofl_mou__daqiao"] = "凡果",

  ["~ofl_mou__daqiao"] = "瞻彼日月，悠悠我思……",
}

General:new(extension, "ofl_mou__caocao", "wei", 4):addSkills { "ofl_mou__jianxiong", "mou__qingzheng", "mou__hujia" }
Fk:loadTranslationTable{
  ["ofl_mou__caocao"] = "谋曹操",
  ["#ofl_mou__caocao"] = "魏武大帝",
  ["illustrator:ofl_mou__caocao"] = "第七个桔子",

  ["$mou__qingzheng_ofl_mou__caocao1"] = "治国当行严法，可慑逆臣乱心！",
  ["$mou__qingzheng_ofl_mou__caocao2"] = "犯禁自当棒杀，岂因权贵宽宥！",
  ["$mou__hujia_ofl_mou__caocao1"] = "众将速归，护我退贼！",
  ["$mou__hujia_ofl_mou__caocao2"] = "亲征不可轻退，速诛眼前之贼！",
  ["~ofl_mou__caocao"] = "惜天不假年，未成夙愿……",
  ["!ofl_mou__caocao"] = "天下烽烟起逐鹿，吾代弱主扫六合！",
}

General:new(extension, "ofl_mou__liubei", "shu", 4):addSkills { "mou__rende", "ofl_mou__zhangwu", "mou__jijiang" }
Fk:loadTranslationTable{
  ["ofl_mou__liubei"] = "谋刘备",
  ["#ofl_mou__liubei"] = "雄才盖世",
  ["illustrator:ofl_mou__liubei"] = "无鳏",

  ["$mou__rende_ofl_mou__liubei1"] = "修德累仁，则汉道克昌！",
  ["$mou__rende_ofl_mou__liubei2"] = "迈仁树德，焘宇内无疆！",
  ["$mou__jijiang_ofl_mou__liubei1"] = "诸位将军，可愿与我共匡汉室？",
  ["$mou__jijiang_ofl_mou__liubei2"] = "汉家国祚，百姓攸业，皆系诸位将军！",
  ["~ofl_mou__liubei"] = "朕躬德薄，望吾儿切勿效之……",
}

General:new(extension, "ofl_mou__menghuo", "shu", 4):addSkills { "ofl_mou__huoshou", "ofl_mou__zaiqi" }
Fk:loadTranslationTable{
  ["ofl_mou__menghuo"] = "谋孟获",
  ["#ofl_mou__menghuo"] = "南蛮王",
  ["illustrator:ofl_mou__menghuo"] = "石琨",

  ["~ofl_mou__menghuo"] = "南中子弟，有死无降！",
}

--诸葛亮

General:new(extension, "ofl_mou__xiaoqiao", "wu", 3, 3, General.Female):addSkills { "ofl_mou__tianxiang", "ofl_mou__hongyan" }
Fk:loadTranslationTable{
  ["ofl_mou__xiaoqiao"] = "谋小乔",
  ["#ofl_mou__xiaoqiao"] = "矫情之花",
  ["illustrator:ofl_mou__xiaoqiao"] = "黯荧岛",

  ["~ofl_mou__xiaoqiao"] = "红颜易逝，天香难湮……",
}

General:new(extension, "ofl_mou__huangyueying", "shu", 3, 3, General.Female):addSkills { "ofl_mou__jizhi", "ofl_mou__qicai" }
Fk:loadTranslationTable{
  ["ofl_mou__huangyueying"] = "谋黄月英",
  ["#ofl_mou__huangyueying"] = "足智多谋",
  ["illustrator:ofl_mou__huangyueying"] = "光域",

  ["~ofl_mou__huangyueying"] = "夫君尽忠节，妾身亦如是……",
}

General:new(extension, "ofl_mou__guanyu", "shu", 4):addSkills { "ofl_mou__wusheng", "ofl_mou__yijue" }
Fk:loadTranslationTable{
  ["ofl_mou__guanyu"] = "谋关羽",
  ["#ofl_mou__guanyu"] = "关圣帝君",
  ["illustrator:ofl_mou__guanyu"] = "鬼画府",

  ["~ofl_mou__guanyu"] = "大哥知遇之恩，云长来世再报了……",
}

--荀彧

General:new(extension, "ofl_mou__gongsunzan", "qun", 4):addSkills { "ofl_mou__yicong", "ofl_mou__qiaomeng" }
Fk:loadTranslationTable{
  ["ofl_mou__gongsunzan"] = "谋公孙瓒",
  ["#ofl_mou__gongsunzan"] = "劲震幽土",
  ["illustrator:ofl_mou__gongsunzan"] = "XXX",
}

General:new(extension, "ofl_mou__jiaxu", "qun", 3):addSkills { "ofl_mou__wansha", "ofl_mou__luanwu", "ofl_mou__weimu" }
Fk:loadTranslationTable{
  ["ofl_mou__jiaxu"] = "谋贾诩",
  ["#ofl_mou__jiaxu"] = "计深似海",
  ["illustrator:ofl_mou__jiaxu"] = "时空立方",
}

return extension
