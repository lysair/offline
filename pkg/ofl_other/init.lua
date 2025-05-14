local extension = Package:new("ofl_other")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_other/skills")

Fk:loadTranslationTable{
  ["ofl_other"] = "线下-官正产品综合",
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
General:new(extension, "ofl__godmachao", "god", 4):addSkills { "ofl__shouli", "ofl__hengwu" }
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

General:new(extension, "ofl__sunhanhua", "wu", 3, 3, General.Female):addSkills { "ofl__chongxu", "ofl__miaojian", "ofl__lianhuas" }
Fk:loadTranslationTable{
  ["ofl__sunhanhua"] = "孙寒华",
  ["#ofl__sunhanhua"] = "挣绽的青莲",
  ["illustrator:ofl__sunhanhua"] = "圆子",

  ["~ofl__sunhanhua"] = "身腾紫云天门去，随声赴感佑兆民……",
}

--2024手杀欢乐斗地主合集：郑玄 祢衡
General:new(extension, "ofl__zhengxuan", "qun", 3):addSkills { "ofl__zhengjing" }
Fk:loadTranslationTable{
  ["ofl__zhengxuan"] = "郑玄",
  ["#ofl__zhengxuan"] = "兼采定道",
  ["illustrator:ofl__zhengxuan"] = "枭瞳",

  ["~ofl__zhengxuan"] = "学海无涯，憾吾生，有涯矣……",
}

General:new(extension, "ofl__miheng", "qun", 3):addSkills { "ofl__kuangcai", "mobile__shejian" }
Fk:loadTranslationTable{
  ["ofl__miheng"] = "祢衡",
  ["#ofl__miheng"] = "鸷鹗啄孤凤",
  ["illustrator:ofl__miheng"] = "聚一工作室",

  ["$mobile__shejian_ofl__miheng1"] = "强辩无人语，言辞可伤人。",
  ["$mobile__shejian_ofl__miheng2"] = "含兵为剑，傲舌以刃。",
  ["~ofl__miheng"] = "我还有话……要说……",
}

--九鼎：司马炎 华歆 韩龙
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

--陈寿道具礼盒
General:new(extension, "chenshou", "shu", 3):addSkills { "chenzhi", "dianmo", "zaibi" }
Fk:loadTranslationTable{
  ["chenshou"] = "陈寿",
  ["#chenshou"] = "婉而成章",
  ["illustrator:chenshou"] = "小罗没想好",
}
local poker = fk.CreateCard{
  name = "&poker",
  type = Card.TypeBasic,
  skill = "poker_skill",
  is_passive = true,
}
extension:loadCardSkels{poker}
extension:addCardSpec("poker")

--青史翰墨
--General:new(extension, "caohuan", "wei", 3):addSkills { "junweic", "moran" }
Fk:loadTranslationTable{
  ["caohuan"] = "曹奂",
  ["#caohuan"] = "陈留王",
  ["illustrator:caohuan"] = "小罗没想好",

  ["junweic"] = "君威",
  [":junweic"] = "每回合限一次，你可以将两张相同颜色的牌当【无懈可击】使用，然后你可以为目标普通锦囊牌额外指定至多两个目标。",
  ["moran"] = "默然",
  [":moran"] = "锁定技，当你受到伤害后，你选择1~3的数字，你在所选数字个回合结束后（包括当前回合）摸两倍的牌，在此期间你的所有技能失效。",
}

--General:new(extension, "liuxuan", "shu", 3):addSkills { "sifen", "funanl" }
Fk:loadTranslationTable{
  ["liuxuan"] = "刘璿",
  ["#liuxuan"] = "暗渊龙吟",
  ["illustrator:liuxuan"] = "荆芥",

  ["sifen"] = "俟奋",
  [":sifen"] = "出牌阶段限一次，你可以令一名其他角色将任意张牌当一张【决斗】使用，然后你摸两张牌，此阶段你可以将等量张红色牌当【决斗】对其使用。",
  ["funanl"] = "赴难",
  [":funanl"] = "主公技，每回合限一次，你可以发动〖激将〗，若没有角色响应，你失去1点体力并摸两张牌。",
}

--General:new(extension, "ofl__sunhao", "wu", 5):addSkills { "shezuo" }
Fk:loadTranslationTable{
  ["ofl__sunhao"] = "孙皓",
  ["#ofl__sunhao"] = "归命侯",
  ["illustrator:ofl__sunhao"] = "小罗没想好",

  ["shezuo"] = "设座",
  [":shezuo"] = "准备阶段，你可以选择一项，本回合下次拼点结算后拼点没赢的角色执行：1.依次弃置两张牌，不足则失去等量体力；"..
  "2.横置并受到1点火焰伤害；3.将所有手牌当任意一张普通锦囊牌使用。出牌阶段限一次，你可以摸一张牌并拼点。",
}

--General:new(extension, "ofl__liuxie", "qun", 3):addSkills { "jixul", "youchong" }
Fk:loadTranslationTable{
  ["ofl__liuxie"] = "刘协",
  ["#ofl__liuxie"] = "山阳公",
  ["illustrator:ofl__liuxie"] = "荆芥",

  ["jixul"] = "济恤",
  [":jixul"] = "出牌阶段每个角色组合限一次，你可以选择两名角色，若其手牌数之和小于任意两名除其以外角色的手牌数之和，你观看牌堆顶三张牌"..
  "并分配给选择的角色（每名角色至少一张）。",
  ["youchong"] = "优崇",
  [":youchong"] = "每回合限一次，当你需使用基本牌时，你可以选择任意名手牌数大于你的角色，这些角色可以将三张牌当一张你需要的牌代替你使用。",
}

--风云际会
--General:new(extension, "vd__caocao", "wei", 4):addSkills { "juebing", "fengxie" }
Fk:loadTranslationTable{
  ["vd__caocao"] = "曹操",
  ["#vd__caocao"] = "奉天从人望",
  ["illustrator:vd__caocao"] = "小罗没想好",

  ["juebing"] = "谲兵",
  [":juebing"] = "你可以将一张非【杀】手牌当【杀】使用，以此法使用的【杀】仅能被目标角色将一张非【闪】手牌当【闪】使用来响应。"..
  "若以此法使用的【杀】造成伤害，此【杀】不计入次数限制。此【杀】结算结束后，你和唯一目标角色依次可以使用弃牌堆中一张双方用于转化的牌。",
  ["fengxie"] = "奉挟",
  [":fengxie"] = "限定技，出牌阶段，你可以选择一名其他角色，你依次选择除其以外每名角色装备区内的一张牌，移动至目标角色的装备区内，"..
  "若无法移动，改为你获得之。然后明忠失去忠臣技，你获得之。",
}

--General:new(extension, "es__liubei", "shu", 4):addSkills { "huji", "houfa" }
Fk:loadTranslationTable{
  ["es__liubei"] = "刘备",
  ["#es__liubei"] = "仁兵伐无道",
  ["illustrator:es__liubei"] = "荆芥",
  ["huji"] = "互忌",
  [":huji"] = "每轮开始时，你可以选择一名不在你攻击范围内且你不在其攻击范围内的其他角色，其需赠予你一张手牌。若如此做，本轮每个回合结束时，"..
  "你与其攻击范围内包含对方的角色需弃置两张手牌，对对方造成1点伤害。",
  ["houfa"] = "后发",
  [":houfa"] = "准备阶段，你本轮攻击范围增加你已损失体力值。每回合限一次，当你对座次小于你的角色造成伤害时，你可以将手牌摸至其体力上限。",
}

--General:new(extension, "var__sunquan", "wu", 4):addSkills { "zhanlun", "jueyi" }
Fk:loadTranslationTable{
  ["var__sunquan"] = "孙权",
  ["#var__sunquan"] = "年少万兜鍪",
  ["illustrator:var__sunquan"] = "阿诚",
  ["zhanlun"] = "战论",
  [":zhanlun"] = "你的【杀】拥有助战：不计次数。此【杀】结算后，根据助战牌的颜色：黑色，你本回合使用的下一张【杀】伤害基数值+1；"..
  "红色，你和本回合参与过助战的角色各摸两张牌，此技能本回合失效。",
  ["jueyi"] = "决意",
  [":jueyi"] = "出牌阶段开始时，你可以重铸至多两张牌，所有角色本回合不能弃置与重铸牌花色相同的牌，直到有角色进入濒死状态。",
}

return extension
