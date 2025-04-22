local extension = Package:new("piracy_e")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_e/skills")

Fk:loadTranslationTable{
  ["piracy_e"] = "官盗E系列",
}

--E0034暗金豪华版/S1标准版龙魂 龙羽飞
General:new(extension, "longyufei", "shu", 3, 4, General.Female):addSkills { "longyi", "zhenjue" }
Fk:loadTranslationTable{
  ["longyufei"] = "龙羽飞",
  ["#longyufei"] = "将星之魂",
  ["illustrator:longyufei"] = "DH",
}

--官盗E系列战役-群雄逐鹿E0026：
--黄巾之乱：神张梁 神张宝 神张角
--虎牢关之战：虎牢关吕布
--界桥之战：神袁绍 神文丑 神公孙瓒 神赵云
--长安之战（文和乱武）：神贾诩 樊稠 王允
General:new(extension, "ofl__wangyun", "qun", 3):addSkills { "ofl__lianji", "ofl__moucheng" }
Fk:loadTranslationTable{
  ["ofl__wangyun"] = "王允",
  ["#ofl__wangyun"] = "计随鞘出",
  ["illustrator:ofl__wangyun"] = "鬼画府",
}

--官盗E系列战役-问鼎中原E0035：
--宛城之战：神曹操 神典韦 曹安民
--下邳之战：神吕布
--官渡之战：神淳于琼 神张郃 神袁绍
--赤壁之战：神周瑜 神诸葛亮 神曹操 郭嘉

--官盗E系列战役-三分天下E0037：
--渭水之战：神马超 神许褚
--合肥之战：神张辽
--襄樊之战：神关羽 神于禁
--定军山之战：神法正 神黄忠 神张郃 神夏侯渊
--国战转身份：孟达
local mengda = General:new(extension, "ofl__mengda", "wei", 4)
mengda.subkingdom = "shu"
mengda:addSkills { "ofl__qiuan", "ofl__liangfan" }
Fk:loadTranslationTable{
  ["ofl__mengda"] = "孟达",
  ["#ofl__mengda"] = "怠军反复",
  ["designer:ofl__mengda"] = "韩旭",
  ["illustrator:ofl__mengda"] = "张帅",

  ["~ofl__mengda"] = "吾一生寡信，今报应果然来矣……",
}

--官盗E系列战役-分久必合E0041：
--夷陵之战
--南中平定战：一堆神孟获？
--五丈原之战：神诸葛亮 神司马懿
--天下一统：文鸯
--国战转身份：文钦 钟会 孙綝
local wenqin = General:new(extension, "ofl__wenqin", "wei", 4)
wenqin.subkingdom = "wu"
wenqin:addSkills { "ofl__jinfa" }
Fk:loadTranslationTable{
  ["ofl__wenqin"] = "文钦",
  ["#ofl__wenqin"] = "勇而无算",
  ["designer:ofl__wenqin"] = "逍遥鱼叔",
  ["illustrator:ofl__wenqin"] = "匠人绘-零二",

  ["~ofl__wenqin"] = "公休，汝这是何意，呃……",
}

General:new(extension, "ofl__sunchen", "wu", 4):addSkills { "ofl__shilus", "ofl__xiongnve" }
Fk:loadTranslationTable{
  ["ofl__sunchen"] = "孙綝",
  ["#ofl__sunchen"] = "食髓的朝堂客",
  ["designer:ofl__sunchen"] = "逍遥鱼叔",
  ["illustrator:ofl__sunchen"] = "depp",

  ["~ofl__sunchen"] = "愿陛下念臣昔日之功，陛下？陛下！！",
}

--官盗E14至宝：周姬
General:new(extension, "zhouji", "wu", 3, 3, General.Female):addSkills { "ofl__yanmouz", "ofl__zhanyan", "ofl__yuhuo" }
Fk:loadTranslationTable{
  ["zhouji"] = "周姬",
  ["#zhouji"] = "江东的红莲",
  ["illustrator:zhouji"] = "xerez",
}

--官盗E14001T匡鼎炎汉：鄂焕
local ehuan = General:new(extension, "ehuan", "qun", 5)
ehuan.subkingdom = "shu"
ehuan:addSkills { "ofl__diwan", "ofl__suiluan", "ofl__conghan" }
Fk:loadTranslationTable{
  ["ehuan"] = "鄂焕",
  ["#ehuan"] = "牙门汉将",
  ["illustrator:ehuan"] = "小强",
}

--官盗E7005T决战巅峰：钟会
local zhonghui = General:new(extension, "ofl__zhonghui", "wei", 4)
zhonghui:addSkills { "mouchuan", "zizhong", "jizun", "qingsuan" }
zhonghui:addRelatedSkills { "daohe", "zhiyiz" }
Fk:loadTranslationTable{
  ["ofl__zhonghui"] = "钟会",
  ["#ofl__zhonghui"] = "统定河山",
  ["cv:ofl__zhonghui"] = "Kazami",
  ["illustrator:ofl__zhonghui"] = "磐蒲",

  ["~ofl__zhonghui"] = "时也…命也…",
}

--官盗E5003T荆襄风云：周瑜 关羽 神刘表 神曹仁
General:new(extension, "ofl__zhouyu", "wu", 3):addSkills { "ofl__xiongzi", "ofl__zhanyanz" }
Fk:loadTranslationTable{
  ["ofl__zhouyu"] = "周瑜",
  ["#ofl__zhouyu"] = "雄姿英发",
  ["illustrator:ofl__zhouyu"] = "魔奇士",
}

General:new(extension, "godliubiao", "god", 4):addSkills { "xiongju", "fujing", "yongrong" }
Fk:loadTranslationTable{
  ["godliubiao"] = "神刘表",
  ["#godliubiao"] = "称雄荆襄",
  ["illustrator:godliubiao"] = "六道目",
}

local godcaoren = General:new(extension, "godcaoren", "god", 4)
godcaoren:addSkills { "ofl__jushou" }
godcaoren:addRelatedSkills { "ofl__tuwei" }
Fk:loadTranslationTable{
  ["godcaoren"] = "神曹仁",
  ["#godcaoren"] = "征南将军",
  ["illustrator:godcaoren"] = "凡果",
}

--官盗E10全武将尊享：田钏
General:new(extension, "tianchuan", "qun", 3, 3, General.Female):addSkills { "huying", "qianjing", "bianchi" }
Fk:loadTranslationTable{
  ["tianchuan"] = "田钏",
  ["#tianchuan"] = "潜行之狐",
  ["illustrator:tianchuan"] = "苍月白龙",
}

--官盗E3至臻·权谋：纪灵
General:new(extension, "ofl__jiling", "qun", 4):addSkills { "ofl__shuangren" }
Fk:loadTranslationTable{
  ["ofl__jiling"] = "纪灵",
  ["#ofl__jiling"] = "仲家的主将",
  ["illustrator:ofl__jiling"] = "铁杵文化",
}

--官盗E24侠客行：彭虎 彭绮 罗厉 祖郎 崔廉 单福
local penghu = General:new(extension, "penghu", "qun", 5)
penghu:addSkills { "juqian", "zhepo", "yizhongp" }
penghu:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["penghu"] = "彭虎",
  ["#penghu"] = "鄱阳风浪",
  ["illustrator:penghu"] = "花弟",
}

local pengqi = General:new(extension, "pengqi", "qun", 3, 3, General.Female)
pengqi:addSkills { "jushoup", "liaoluan", "huaying", "jizhongp" }
pengqi:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["pengqi"] = "彭绮",
  ["#pengqi"] = "百花缭乱",
  ["illustrator:pengqi"] = "xerez",
}

local luoli = General:new(extension, "luoli", "qun", 4)
luoli:addSkills { "juluan", "xianxing" }
luoli:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["luoli"] = "罗厉",
  ["#luoli"] = "庐江义寇",
  ["illustrator:luoli"] = "红字虾",
}

local zulang = General:new(extension, "zulang", "qun", 5)
zulang.subkingdom = "wu"
zulang:addSkills { "xijun", "haokou", "ronggui" }
zulang:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["zulang"] = "祖郎",
  ["#zulang"] = "抵力坚存",
  ["illustrator:zulang"] = "XXX",
}

General:new(extension, "cuilian", "qun", 4):addSkills { "tanlu", "jubian" }
Fk:loadTranslationTable{
  ["cuilian"] = "崔廉",
  ["#cuilian"] = "缚树行鞭",
  ["illustrator:cuilian"] = "花花",
}

local shanfu = General:new(extension, "ofl__xushu", "qun", 3)
shanfu.subkingdom = "shu"
shanfu:addSkills { "bimeng", "zhue", "fuzhux" }
Fk:loadTranslationTable{
  ["ofl__xushu"] = "单福",
  ["#ofl__xushu"] = "忠孝万全",
  ["illustrator:ofl__xushu"] = "木美人",
}

--官盗E5002：风云志·汉末风云

--官盗E10：蛇年限定礼盒

--官盗E7肃问：雍闿 车胄
local yongkai = General:new(extension, "yongkai", "shu", 5)
yongkai.subkingdom = "wu"
yongkai:addSkills { "xiaofany", "jiaohu", "quanpan", "huoluan" }
Fk:loadTranslationTable{
  ["yongkai"] = "雍闿",
  ["#yongkai"] = "惑动南中",
  ["illustrator:yongkai"] = "HIM",
}

General:new(extension, "ofl__chezhou", "wei", 6):addSkills { "anmou", "tousuan" }
Fk:loadTranslationTable{
  ["ofl__chezhou"] = "车胄",
  ["#ofl__chezhou"] = "反受其害",
  ["illustrator:ofl__chezhou"] = "YanBai",
}


return extension
