local extension = Package:new("shzj")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/shzj/skills")

Fk:loadTranslationTable{
  ["shzj"] = "线下-山河煮酒",
  ["shzj_xiangfan"] = "龙起襄樊",
  ["shzj_yiling"] = "桃园挽歌",
}

General:new(extension, "shzj_xiangfan__guanyu", "shu", 4):addSkills { "chaojue", "junshen" }
Fk:loadTranslationTable{
  ["shzj_xiangfan__guanyu"] = "关羽",
  ["#shzj_xiangfan__guanyu"] = "国士无双",
  ["illustrator:shzj_xiangfan__guanyu"] = "鬼画府",
}

General:new(extension, "shzj_xiangfan__caoren", "wei", 4):addSkills { "lizhong", "juesui" }
Fk:loadTranslationTable{
  ["shzj_xiangfan__caoren"] = "曹仁",
  ["#shzj_xiangfan__caoren"] = "玉钤奉国",
  ["illustrator:shzj_xiangfan__caoren"] = "鬼画府",
}

General:new(extension, "shzj_xiangfan__pangde", "wei", 4):addSkills { "taiguan", "mashu" }
Fk:loadTranslationTable{
  ["shzj_xiangfan__pangde"] = "庞德",
  ["#shzj_xiangfan__pangde"] = "意怒气壮",
  ["illustrator:shzj_xiangfan__pangde"] = "鬼画府",
}

General:new(extension, "lvchang", "wei", 4):addSkills { "juwu", "shouxiang" }
Fk:loadTranslationTable{
  ["lvchang"] = "吕常",
  ["#lvchang"] = "险守襄阳",
  ["illustrator:lvchang"] = "戚屹",
}

local liubei = General:new(extension, "shzj_yiling__liubei", "shu", 4)
liubei:addSkills { "qingshil", "yilin", "chengming" }
liubei:addRelatedSkill("ex__rende")
Fk:loadTranslationTable{
  ["shzj_yiling__liubei"] = "刘备",
  ["#shzj_yiling__liubei"] = "见龙渊献",
  ["illustrator:shzj_yiling__liubei"] = "鬼画府",
}

General:new(extension, "shzj_yiling__luxun", "wu", 3):addSkills { "qianshou", "tanlong", "xibei" }
Fk:loadTranslationTable{
  ["shzj_yiling__luxun"] = "陆逊",
  ["#shzj_yiling__luxun"] = "社稷心膂",
  ["illustrator:shzj_yiling__luxun"] = "鬼画府",
}

General:new(extension, "shzj_yiling__wuban", "shu", 4):addSkills { "youjun", "jicheng" }
Fk:loadTranslationTable{
  ["shzj_yiling__wuban"] = "吴班",
  ["#shzj_yiling__wuban"] = "奉命诱贼",
  ["illustrator:shzj_yiling__wuban"] = "吕金宝",
}

General:new(extension, "shzj_yiling__chenshi", "shu", 4):addSkills { "zhuan" }
Fk:loadTranslationTable{
  ["shzj_yiling__chenshi"] = "陈式",
  ["#shzj_yiling__chenshi"] = "夹岸屯军",
  ["illustrator:shzj_yiling__chenshi"] = "凡果",
}

General:new(extension, "shzj_yiling__zhangnan", "shu", 4):addSkills { "fenwu" }
Fk:loadTranslationTable{
  ["shzj_yiling__zhangnan"] = "张南",
  ["#shzj_yiling__zhangnan"] = "澄辉的义烈",
  ["illustrator:shzj_yiling__zhangnan"] = "Aaron",
}

General:new(extension, "shzj_yiling__fengxi", "shu", 4):addSkills { "qingkou" }
Fk:loadTranslationTable{
  ["shzj_yiling__fengxi"] = "冯习",
  ["#shzj_yiling__fengxi"] = "赤胆的忠魂",
  ["illustrator:shzj_yiling__fengxi"] = "陈鑫",
}

General:new(extension, "chengji", "shu", 3):addSkills { "zhongen", "liebao" }
Fk:loadTranslationTable{
  ["chengji"] = "程畿",
  ["#chengji"] = "大义之诚",
  ["illustrator:chengji"] = "荆芥",
}

General:new(extension, "zhaorong", "shu", 4):addSkills { "yuantao" }
Fk:loadTranslationTable{
  ["zhaorong"] = "赵融",
  ["#zhaorong"] = "从龙别督",
  ["illustrator:zhaorong"] = "荆芥",
}

General:new(extension, "tanxiong", "wu", 4):addSkills { "lengjian", "sheju" }
Fk:loadTranslationTable{
  ["tanxiong"] = "谭雄",
  ["#tanxiong"] = "暗箭难防",
  ["illustrator:tanxiong"] = "荆芥",
}

General:new(extension, "liue", "wu", 5):addSkills { "xiyu" }
Fk:loadTranslationTable{
  ["liue"] = "刘阿",
  ["#liue"] = "西抵怒龙",
  ["illustrator:liue"] = "荆芥",
}

General:new(extension, "shzj_yiling__shamoke", "shu", 4):addSkills { "jilis", "manyong" }
Fk:loadTranslationTable{
  ["shzj_yiling__shamoke"] = "沙摩柯",
  ["#shzj_yiling__shamoke"] = "狂喜胜战",
  ["illustrator:shzj_yiling__shamoke"] = "铁杵文化",
}

General:new(extension, "shzj_yiling__godliubei", "god", 6):addSkills { "shzj_yiling__longnu", "jieying", "taoyuan" }
Fk:loadTranslationTable{
  ["shzj_yiling__godliubei"] = "神刘备",
  ["#shzj_yiling__godliubei"] = "桃园挽歌",
  ["illustrator:shzj_yiling__godliubei"] = "点睛",
}

General:new(extension, "fanjiang", "wu", 4):addSkills { "bianzhua", "benxiang", "xiezhan" }
Fk:loadTranslationTable{
  ["fanjiang"] = "范疆",
  ["#fanjiang"] = "有死无生",
  ["illustrator:fanjiang"] = "Qiyi",
}

local zhangda = General:new(extension, "zhangda", "wu", 4)
zhangda.hidden = true
zhangda:addSkills { "xingsha", "xianshouz", "xiezhan" }
Fk:loadTranslationTable{
  ["zhangda"] = "张达",
  ["#zhangda"] = "有死无生",
  ["illustrator:zhangda"] = "Qiyi",
}

General:new(extension, "shzj_yiling__guanyu", "shu", 5):addSkills { "shzj_yiling__wusheng", "chengshig", "fuwei" }
Fk:loadTranslationTable{
  ["shzj_yiling__guanyu"] = "神秘将军",
  ["#shzj_yiling__guanyu"] = "卷土重来",
  ["illustrator:shzj_yiling__guanyu"] = "MUMU",
}

General:new(extension, "yanque", "qun", 4):addSkills { "siji", "cangshen" }
Fk:loadTranslationTable{
  ["yanque"] = "阎鹊",
  ["#yanque"] = "神出鬼没",
  ["illustrator:yanque"] = "紫芒小侠",
}

General:new(extension, "wuque", "qun", 4):addSkills { "ansha", "cangshen", "xiongren" }
Fk:loadTranslationTable{
  ["wuque"] = "乌鹊",
  ["#wuque"] = "密执生死",
  ["illustrator:wuque"] = "Mr_Sleeping",
}

General:new(extension, "wangque", "qun", 3):addSkills { "daifa", "cangshen" }
Fk:loadTranslationTable{
  ["wangque"] = "亡鹊",
  ["#wangque"] = "神鬼莫测",
  ["illustrator:wangque"] = "黑羽",
}

General:new(extension, "shzj_yiling__guanxings", "shu", 4):addSkills { "conglong", "xianwu" }
Fk:loadTranslationTable{
  ["shzj_yiling__guanxings"] = "关兴",
  ["#shzj_yiling__guanxings"] = "少有令问",
  ["illustrator:shzj_yiling__guanxings"] = "君桓文化",
}

General:new(extension, "shzj_yiling__sunquan", "shu", 3):addSkills { "fuhans", "chende", "wansu" }
Fk:loadTranslationTable{
  ["shzj_yiling__sunquan"] = "孙权",
  ["#shzj_yiling__sunquan"] = "<font color='green'>大汉吴王</font>",
  ["illustrator:shzj_yiling__sunquan"] = "荆芥",
}

General:new(extension, "shzj_yiling__ganning", "wu", 4):addSkills { "shzj_yiling__qixi", "shzj_yiling__fenwei" }
Fk:loadTranslationTable{
  ["shzj_yiling__ganning"] = "甘宁",
  ["#shzj_yiling__ganning"] = "锦帆英豪",
  ["illustrator:shzj_yiling__ganning"] = "鬼画府",
}

General:new(extension, "shzj_yiling__buzhi", "wu", 3):addSkills { "shzj_yiling__hongde", "shzj_yiling__dingpan" }
Fk:loadTranslationTable{
  ["shzj_yiling__buzhi"] = "步骘",
  ["#shzj_yiling__buzhi"] = "积跬靖边",
  ["illustrator:shzj_yiling__buzhi"] = "匠人绘",
}

General:new(extension, "anying", "qun", 3):addSkills { "liupo", "zhuiling", "xihun", "xianqi", "fansheng" }
Fk:loadTranslationTable{
  ["anying"] = "暗影",
  ["#anying"] = "黑影笼罩",
  ["illustrator:anying"] = "黑白画谱",
}

return extension
