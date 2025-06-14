local extension = Package:new("ofl_other")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_other/skills")

Fk:loadTranslationTable{
  ["ofl_other"] = "线下-官正产品综合",
  ["rom"] = "风花雪月",
  ["sgsh"] = "三国杀·幻",
}

--英文版3v3：凯撒
General:new(extension, "caesar", "god", 4):addSkills { "conqueror" }
Fk:loadTranslationTable{
  ["caesar"] = "Caesar",
  ["illustrator:caesar"] = "青骑士",
}

--三国杀·幻
General:new(extension, "sgsh__nanhualaoxian", "qun", 3):addSkills { "sgsh__jidao", "sgsh__feisheng", "sgsh__jinghe" }
Fk:loadTranslationTable{
  ["sgsh__nanhualaoxian"] = "南华老仙",
  ["#sgsh__nanhualaoxian"] = "虚步太清",
  ["illustrator:sgsh__nanhualaoxian"] = "鬼画府",

  ["~sgsh__nanhualaoxian"] = "此理闻所未闻，参不透啊。",
}

General:new(extension, "sgsh__zuoci", "qun", 3):addSkills { "sgsh__huashen", "sgsh__xinsheng" }
Fk:loadTranslationTable{
  ["sgsh__zuoci"] = "左慈",
  ["#sgsh__zuoci"] = "谜之仙人",
  ["illustrator:sgsh__zuoci"] = "JanusLausDeo",

  ["~sgsh__zuoci"] = "万事，皆有因果。",
}

General:new(extension, "sgsh__yuji", "qun", 3):addSkills { "sgsh__qianhuan", "sgsh__chanyuan" }
Fk:loadTranslationTable{
  ["sgsh__yuji"] = "于吉",
  ["#sgsh__yuji"] = "魂绕左右",
  ["illustrator:sgsh__yuji"] = "biou09",
}

General:new(extension, "sgsh__jianggan", "wei", 3):addSkills { "sgsh__daoshu", "weicheng" }
Fk:loadTranslationTable{
  ["sgsh__jianggan"] = "蒋干",
  ["#sgsh__jianggan"] = "锋镝悬信",
  ["illustrator:sgsh__jianggan"] = "",

  ["$weicheng_sgsh__jianggan1"] = "公瑾，吾之诚心，天地可鉴。",
  ["$weicheng_sgsh__jianggan2"] = "遥闻芳烈，故来叙阔。",
  ["~sgsh__jianggan"] = "蔡张之罪，非我之过呀！",
}

General:new(extension, "sgsh__huaxiong", "qun", 4):addSkills { "sgsh__yaowu" }
Fk:loadTranslationTable{
  ["sgsh__huaxiong"] = "华雄",
  ["#sgsh__huaxiong"] = "魔将",
  ["illustrator:sgsh__huaxiong"] = "沉睡千年",

  ["~sgsh__huaxiong"] = "错失先机，呃啊！",
}

General:new(extension, "sgsh__lisu", "qun", 3):addSkills { "sgsh__kuizhul", "sgsh__qiaoyan" }
Fk:loadTranslationTable{
  ["sgsh__lisu"] = "李肃",
  ["#sgsh__lisu"] = "",
  ["illustrator:sgsh__lisu"] = "",

  ["~sgsh__lisu"] = "见利忘义，必遭天谴。",
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
General:new(extension, "rom__liuhong", "qun", 4):addSkills { "rom__zhenglian" }
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

--风云际会
General:new(extension, "vd__caocao", "wei", 4):addSkills { "juebing", "fengxie" }
Fk:loadTranslationTable{
  ["vd__caocao"] = "曹操",
  ["#vd__caocao"] = "奉天从人望",
  ["illustrator:vd__caocao"] = "小罗没想好",
}

General:new(extension, "es__liubei", "shu", 4):addSkills { "huji", "houfa" }
Fk:loadTranslationTable{
  ["es__liubei"] = "刘备",
  ["#es__liubei"] = "仁兵伐无道",
  ["illustrator:es__liubei"] = "荆芥",
}

General:new(extension, "var__sunquan", "wu", 4):addSkills { "zhanlun", "jueyi" }
Fk:loadTranslationTable{
  ["var__sunquan"] = "孙权",
  ["#var__sunquan"] = "年少万兜鍪",
  ["illustrator:var__sunquan"] = "阿诚",
}

return extension
