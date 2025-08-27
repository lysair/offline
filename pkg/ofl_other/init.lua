local extension = Package:new("ofl_other")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_other/skills")

Fk:loadTranslationTable{
  ["ofl_other"] = "线下-官正产品综合",
  ["rom"] = "风花雪月",
  ["sgsh"] = "三国杀·幻",
}

local generals = {}

generals.caesar = General:new(extension, "caesar", "west", 4)
generals.caesar:addSkills { "conqueror" }
generals.caesar.headnote = "LTK 3vs3 Expansion Pack (2013)"
Fk:loadTranslationTable{
  ["caesar"] = "Caesar",
  ["illustrator:caesar"] = "青骑士",
}

generals.sgsh__nanhualaoxian = General:new(extension, "sgsh__nanhualaoxian", "qun", 3)
generals.sgsh__nanhualaoxian:addSkills { "sgsh__jidao", "sgsh__feisheng", "sgsh__jinghe" }
generals.sgsh__nanhualaoxian.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__nanhualaoxian"] = "南华老仙",
  ["#sgsh__nanhualaoxian"] = "虚步太清",
  ["illustrator:sgsh__nanhualaoxian"] = "鬼画府",

  ["~sgsh__nanhualaoxian"] = "此理闻所未闻，参不透啊。",
}

generals.sgsh__zuoci = General:new(extension, "sgsh__zuoci", "qun", 3)
generals.sgsh__zuoci:addSkills { "sgsh__huashen", "sgsh__xinsheng" }
generals.sgsh__zuoci.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__zuoci"] = "左慈",
  ["#sgsh__zuoci"] = "谜之仙人",
  ["illustrator:sgsh__zuoci"] = "JanusLausDeo",

  ["~sgsh__zuoci"] = "万事，皆有因果。",
}

generals.sgsh__yuji = General:new(extension, "sgsh__yuji", "qun", 3)
generals.sgsh__yuji:addSkills { "sgsh__qianhuan", "sgsh__chanyuan" }
generals.sgsh__yuji.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__yuji"] = "于吉",
  ["#sgsh__yuji"] = "魂绕左右",
  ["illustrator:sgsh__yuji"] = "biou09",
}

generals.sgsh__jianggan = General:new(extension, "sgsh__jianggan", "wei", 3)
generals.sgsh__jianggan:addSkills { "sgsh__daoshu", "weicheng" }
generals.sgsh__jianggan.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__jianggan"] = "蒋干",
  ["#sgsh__jianggan"] = "锋镝悬信",
  ["illustrator:sgsh__jianggan"] = "艾吖",

  ["$weicheng_sgsh__jianggan1"] = "公瑾，吾之诚心，天地可鉴。",
  ["$weicheng_sgsh__jianggan2"] = "遥闻芳烈，故来叙阔。",
  ["~sgsh__jianggan"] = "蔡张之罪，非我之过呀！",
}

generals.sgsh__huaxiong = General:new(extension, "sgsh__huaxiong", "qun", 4)
generals.sgsh__huaxiong:addSkills { "sgsh__yaowu" }
generals.sgsh__huaxiong.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__huaxiong"] = "华雄",
  ["#sgsh__huaxiong"] = "魔将",
  ["illustrator:sgsh__huaxiong"] = "沉睡千年",

  ["~sgsh__huaxiong"] = "错失先机，呃啊！",
}

generals.sgsh__lisu = General:new(extension, "sgsh__lisu", "qun", 3)
generals.sgsh__lisu:addSkills { "sgsh__kuizhul", "sgsh__qiaoyan" }
generals.sgsh__lisu.headnote = "S0096三国杀·幻"
Fk:loadTranslationTable{
  ["sgsh__lisu"] = "李肃",
  ["#sgsh__lisu"] = "魔使",
  ["illustrator:sgsh__lisu"] = "福州明暗",

  ["~sgsh__lisu"] = "见利忘义，必遭天谴。",
}

generals.ofl__godmachao = General:new(extension, "ofl__godmachao", "god", 4)
generals.ofl__godmachao:addSkills { "ofl__shouli", "ofl__hengwu" }
generals.ofl__godmachao.headnote = "神马超道具礼盒"
Fk:loadTranslationTable{
  ["ofl__godmachao"] = "神马超",
  ["#ofl__godmachao"] = "雷挝缚苍",
  ["illustrator:ofl__godmachao"] = "鬼画府",

  ["~ofl__godmachao"] = "以战入圣，贪战而亡。",
}

generals.rom__liuhong = General:new(extension, "rom__liuhong", "qun", 4)
generals.rom__liuhong:addSkills { "rom__zhenglian" }
generals.rom__liuhong.headnote = "S0111风花雪月"
Fk:loadTranslationTable{
  ["rom__liuhong"] = "刘宏",
  ["#rom__liuhong"] = "汉灵帝",
  ["illustrator:rom__liuhong"] = "芝芝不加糖",
}

generals.godjiaxu = General:new(extension, "godjiaxu", "god", 4)
generals.godjiaxu:addSkills { "lianpoj", "zhaoluan" }
generals.godjiaxu.headnote = "三国杀珍藏：热爱（2024珍藏版）"
Fk:loadTranslationTable{
  ["godjiaxu"] = "神贾诩",
  ["#godjiaxu"] = "倒悬云衢",
  ["cv:godjiaxu"] = "酉良（新月杀原创）",
  ["illustrator:godjiaxu"] = "鬼画府",

  ["~godjiaxu"] = "虎兕出于柙，龟玉毁于椟中，谁之过与？",
}

generals.ofl__caojinyu = General:new(extension, "ofl__caojinyu", "wei", 3, 3, General.Female)
generals.ofl__caojinyu:addSkills { "ofl__yuqi", "ofl__shanshen", "ofl__xianjing" }
generals.ofl__caojinyu.headnote = "三国杀珍藏：热爱（2024珍藏版）"
Fk:loadTranslationTable{
  ["ofl__caojinyu"] = "曹金玉",
  ["#ofl__caojinyu"] = "瑞雪纷华",
  ["illustrator:ofl__caojinyu"] = "米糊PU",

  ["~ofl__caojinyu"] = "娘亲，雪人不怕冷吗？",
}

generals.ofl__sunhanhua = General:new(extension, "ofl__sunhanhua", "wu", 3, 3, General.Female)
generals.ofl__sunhanhua:addSkills { "ofl__chongxu", "ofl__miaojian", "ofl__lianhuas" }
generals.ofl__sunhanhua.headnote = "三国杀珍藏：热爱（2024珍藏版）"
Fk:loadTranslationTable{
  ["ofl__sunhanhua"] = "孙寒华",
  ["#ofl__sunhanhua"] = "挣绽的青莲",
  ["illustrator:ofl__sunhanhua"] = "圆子",

  ["~ofl__sunhanhua"] = "身腾紫云天门去，随声赴感佑兆民……",
}

generals.ofl__zhengxuan = General:new(extension, "ofl__zhengxuan", "qun", 3)
generals.ofl__zhengxuan:addSkills { "ofl__zhengjing" }
generals.ofl__zhengxuan.headnote = "S0147欢乐斗地主"
Fk:loadTranslationTable{
  ["ofl__zhengxuan"] = "郑玄",
  ["#ofl__zhengxuan"] = "兼采定道",
  ["illustrator:ofl__zhengxuan"] = "枭瞳",

  ["~ofl__zhengxuan"] = "学海无涯，憾吾生，有涯矣……",
}

generals.ofl__miheng = General:new(extension, "ofl__miheng", "qun", 3)
generals.ofl__miheng:addSkills { "ofl__kuangcai", "mobile__shejian" }
generals.ofl__miheng.headnote = "S0147欢乐斗地主"
Fk:loadTranslationTable{
  ["ofl__miheng"] = "祢衡",
  ["#ofl__miheng"] = "鸷鹗啄孤凤",
  ["illustrator:ofl__miheng"] = "聚一工作室",

  ["$mobile__shejian_ofl__miheng1"] = "强辩无人语，言辞可伤人。",
  ["$mobile__shejian_ofl__miheng2"] = "含兵为剑，傲舌以刃。",
  ["~ofl__miheng"] = "我还有话……要说……",
}

generals.wm__jiangziya = General:new(extension, "wm__jiangziya", "god", 3)
generals.wm__jiangziya:addSkills { "xingzhou", "lieshen" }
generals.wm__jiangziya.headnote = "S0163TP太平天书"
Fk:loadTranslationTable{
  ["wm__jiangziya"] = "姜子牙",
  ["#wm__jiangziya"] = "武庙主祭",
}

generals.nanjixianweng = General:new(extension, "nanjixianweng", "god", 3)
generals.nanjixianweng:addSkills { "shoufaj", "fuzhao" }
generals.nanjixianweng:addRelatedSkills { "tiandu", "tianxiang", "qingguo", "ex__wusheng" }
generals.nanjixianweng.headnote = "S0163TP太平天书"
Fk:loadTranslationTable{
  ["nanjixianweng"] = "南极仙翁",
  ["#nanjixianweng"] = "阐教真君",
}

generals.shengongbao = General:new(extension, "shengongbao", "god", 3)
generals.shengongbao:addSkills { "zhuzhou", "yaoxian" }
generals.shengongbao.headnote = "S0163TP太平天书"
Fk:loadTranslationTable{
  ["shengongbao"] = "申公豹",
  ["#shengongbao"] = "道友留步",
}

generals.ofl__godsimayi = General:new(extension, "ofl__godsimayi", "god", 4)
generals.ofl__godsimayi:addSkills { "jilin", "yingyou", "yingtian" }
generals.ofl__godsimayi:addRelatedSkills { "ex__guicai", "wansha", "lianpo" }
generals.ofl__godsimayi.headnote = "ZH023星汉灿烂：释武"
Fk:loadTranslationTable{
  ["ofl__godsimayi"] = "神司马懿",
  ["#ofl__godsimayi"] = "鉴往知来",
  ["illustrator:ofl__godsimayi"] = "墨三千",
}

generals.vd__caocao = General:new(extension, "vd__caocao", "wei", 4)
generals.vd__caocao:addSkills { "juebing", "fengxie" }
generals.vd__caocao.headnote = "S0189风云际会"
Fk:loadTranslationTable{
  ["vd__caocao"] = "曹操",
  ["#vd__caocao"] = "奉天从人望",
  ["illustrator:vd__caocao"] = "小罗没想好",
}

generals.es__liubei = General:new(extension, "es__liubei", "shu", 4)
generals.es__liubei:addSkills { "huji", "houfa" }
generals.es__liubei.headnote = "S0189风云际会"
Fk:loadTranslationTable{
  ["es__liubei"] = "刘备",
  ["#es__liubei"] = "仁兵伐无道",
  ["illustrator:es__liubei"] = "荆芥",
}

generals.var__sunquan = General:new(extension, "var__sunquan", "wu", 4)
generals.var__sunquan:addSkills { "zhanlun", "jueyi" }
generals.var__sunquan.headnote = "S0189风云际会"
Fk:loadTranslationTable{
  ["var__sunquan"] = "孙权",
  ["#var__sunquan"] = "年少万兜鍪",
  ["illustrator:var__sunquan"] = "阿诚",
}

generals.ofl__sunshangxiang = General:new(extension, "ofl__sunshangxiang", "shu", 4, 4, General.Female)
generals.ofl__sunshangxiang.subkingdom = "wu"
generals.ofl__sunshangxiang:addSkills { "qiankun" }
generals.ofl__sunshangxiang.headnote = "ZH050龙兴云属：启"
Fk:loadTranslationTable{
  ["ofl__sunshangxiang"] = "孙尚香",
  ["illustrator:ofl__sunshangxiang"] = "小罗没想好",
}

generals.ofl__zhugeguo = General:new(extension, "ofl__zhugeguo", "shu", 3, 3, General.Female)
generals.ofl__zhugeguo:addSkills { "ofl__qirang", "ofl__yuhua" }
generals.ofl__zhugeguo.headnote = "S0197国际服-太虚幻魇"
Fk:loadTranslationTable{
  ["ofl__zhugeguo"] = "诸葛果",
  ["#ofl__zhugeguo"] = "凤阁乘烟",
  ["illustrator:ofl__zhugeguo"] = "夏季和杨杨",

  ["~ofl__zhugeguo"] = "浮华落尽轻似梦，淡看苍生几轮回。",
}

return extension
