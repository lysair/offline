local extension = Package:new("ofl_other")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_other/skills")

Fk:loadTranslationTable{
  ["ofl_other"] = "官正产品综合",
  ["rom"] = "风花雪月",
  ["chaos"] = "文和乱武",
  ["sgsh"] = "三国杀·幻",
}

--英文版3v3：凯撒
General:new(extension, "caesar", "god", 4):addSkills { "conqueror" }
Fk:loadTranslationTable{
  ["caesar"] = "Caesar",
  ["illustrator:caesar"] = "青骑士",
}

--神马超道具礼盒
--General:new(extension, "ofl__godmachao", "god", 4):addSkills { "ofl__shouli", "ofl__hengwu" }
Fk:loadTranslationTable{
  ["ofl__godmachao"] = "神马超",
  ["#ofl__godmachao"] = "雷挝缚苍",
  ["illustrator:ofl__godmachao"] = "鬼画府",

  ["~ofl__godmachao"] = "以战入圣，贪战而亡。",
}

--风花雪月：七夕模式？
--General:new(extension, "rom__liuhong", "qun", 4):addSkills { "rom__zhenglian" }
Fk:loadTranslationTable{
  ["rom__liuhong"] = "刘宏",
  ["#rom__liuhong"] = "汉灵帝",
  ["illustrator:rom__liuhong"] = "芝芝不加糖",
}

--2024珍藏版：神贾诩 曹金玉 孙寒华
General:new(extension, "godjiaxu", "god", 4):addSkills { "lianpoj", "zhaoluan" }
Fk:loadTranslationTable{
  ["godjiaxu"] = "神贾诩",
  ["#godjiaxu"] = "倒悬云衢",
  ["cv:godjiaxu"] = "酉良",
  ["illustrator:godjiaxu"] = "鬼画府",

  ["~godjiaxu"] = "虎兕出于柙，龟玉毁于椟中，谁之过与？",
}

General:new(extension, "ofl__caojinyu", "wei", 3, 3, General.Female):addSkills { "ofl__yuqi", "ofl__shanshen", "ofl__xianjing" }
Fk:loadTranslationTable{
  ["ofl__caojinyu"] = "曹金玉",
  ["#ofl__caojinyu"] = "瑞雪纷华",
  ["illustrator:ofl__caojinyu"] = "米糊PU",

  ["~ofl__caojinyu"] = "娘亲，雪人不怕冷吗？",
}

--2024手杀欢乐斗地主合集：郑玄 祢衡
--General:new(extension, "ofl__zhengxuan", "qun", 3):addSkills { "ofl__zhengjing" }
Fk:loadTranslationTable{
  ["ofl__zhengxuan"] = "郑玄",
  ["#ofl__zhengxuan"] = "兼采定道",
  ["illustrator:ofl__zhengxuan"] = "",

  ["~ofl__zhengxuan"] = "",

  ["ofl__zhengjing"] = "整经",
  [":ofl__zhengjing"] = "出牌阶段限一次，你可以进行一次判定，若因此判定结果的点数之和不大于21，你选择一项：1.选择其中任意张牌令一名其他角色"..
  "获得，跳过其下个判定阶段和摸牌阶段，你获得其余判定牌；2.继续进行判定",
}

General:new(extension, "ofl__miheng", "qun", 3):addSkills { "ofl__kuangcai", "mobile__shejian" }
Fk:loadTranslationTable{
  ["ofl__miheng"] = "祢衡",
  ["#ofl__miheng"] = "鸷鹗啄孤凤",
  ["illustrator:ofl__miheng"] = "",

  ["~ofl__miheng"] = "",
}

--九鼎：司马炎
General:new(extension, "simayan", "jin", 3):addSkills { "juqi", "fengtu", "taishi" }
Fk:loadTranslationTable{
  ["simayan"] = "司马炎",
  ["#simayan"] = "晋武帝",
  ["illustrator:simayan"] = "鬼画府",
}

--太平天书：姜子牙 南极仙翁 申公豹
General:new(extension, "wm__jiangziya", "god", 3):addSkills { "xingzhou", "lieshen" }
Fk:loadTranslationTable{
  ["wm__jiangziya"] = "姜子牙",
  ["#wm__jiangziya"] = "武庙主祭",
}

local nanjixianweng = General:new(extension, "nanjixianweng", "god", 3)
nanjixianweng:addSkills { "shoufaj", "fuzhao" }
nanjixianweng:addRelatedSkills { "tiandu", "tianxiang", "qingguo", "ex__wusheng" }
Fk:loadTranslationTable{
  ["nanjixianweng"] = "南极仙翁",
  ["#nanjixianweng"] = "阐教真君",
}

General:new(extension, "shengongbao", "god", 3):addSkills { "zhuzhou", "yaoxian" }
Fk:loadTranslationTable{
  ["shengongbao"] = "申公豹",
  ["#shengongbao"] = "道友留步",
}

--星汉灿烂释武：应天司马懿
local godsimayi = General:new(extension, "ofl__godsimayi", "god", 4)
godsimayi:addSkills { "jilin", "yingyou", "yingtian" }
godsimayi:addRelatedSkills { "ex__guicai", "wansha", "lianpo" }
Fk:loadTranslationTable{
  ["ofl__godsimayi"] = "神司马懿",
  ["#ofl__godsimayi"] = "鉴往知来",
  ["illustrator:ofl__godsimayi"] = "墨三千",
}

return extension
