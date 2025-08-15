local extension = Package:new("shzj")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/shzj/skills")

Fk:loadTranslationTable{
  ["shzj"] = "线下-山河煮酒",
  ["shzj_xiangfan"] = "龙起襄樊",
  ["shzj_yiling"] = "桃园挽歌",
  ["shzj_guansuo"] = "关索传",
  ["shzj_juedai"] = "绝代智将",
}

--龙起襄樊
General:new(extension, "shzj_xiangfan__yujin", "wei", 4):addSkills { "shzj_xiangfan__yizhong" }
Fk:loadTranslationTable{
  ["shzj_xiangfan__yujin"] = "于禁",
  ["#shzj_xiangfan__yujin"] = "讨暴坚垒",
  ["illustrator:shzj_xiangfan__yujin"] = "幽色工作室",
}

General:new(extension, "lvchang", "wei", 3):addSkills { "juwu", "shouxiang" }
Fk:loadTranslationTable{
  ["lvchang"] = "吕常",
  ["#lvchang"] = "险守襄阳",
  ["illustrator:lvchang"] = "戚屹",
}

General:new(extension, "shzj_xiangfan__pangde", "wei", 4):addSkills { "taiguan", "mashu" }
Fk:loadTranslationTable{
  ["shzj_xiangfan__pangde"] = "庞德",
  ["#shzj_xiangfan__pangde"] = "意怒气壮",
  ["illustrator:shzj_xiangfan__pangde"] = "鬼画府",
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

--桃园挽歌
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

General:new(extension, "shzj_yiling__huangzhong", "shu", 4):addSkills { "ol_ex__liegong", "yizhuang" }
Fk:loadTranslationTable{
  ["shzj_yiling__huangzhong"] = "黄忠",
  ["#shzj_yiling__huangzhong"] = "炎汉后将军",
  ["illustrator:shzj_yiling__huangzhong"] = "吴涛",
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

General:new(extension, "shzj_yiling__ganning", "wu", 4):addSkills { "shzj_yiling__qixi", "shzj_yiling__fenwei" }
Fk:loadTranslationTable{
  ["shzj_yiling__ganning"] = "甘宁",
  ["#shzj_yiling__ganning"] = "锦帆英豪",
  ["illustrator:shzj_yiling__ganning"] = "鬼画府",
}

General:new(extension, "shzj_yiling__shamoke", "shu", 4):addSkills { "jilis", "manyong" }
Fk:loadTranslationTable{
  ["shzj_yiling__shamoke"] = "沙摩柯",
  ["#shzj_yiling__shamoke"] = "狂喜胜战",
  ["illustrator:shzj_yiling__shamoke"] = "铁杵文化",
}

General:new(extension, "shzj_yiling__buzhi", "wu", 3):addSkills { "shzj_yiling__hongde", "shzj_yiling__dingpan" }
Fk:loadTranslationTable{
  ["shzj_yiling__buzhi"] = "步骘",
  ["#shzj_yiling__buzhi"] = "积跬靖边",
  ["illustrator:shzj_yiling__buzhi"] = "匠人绘",
}

General:new(extension, "shzj_yiling__godliubei", "god", 6):addSkills { "shzj_yiling__longnu", "jieying", "taoyuan" }
Fk:loadTranslationTable{
  ["shzj_yiling__godliubei"] = "神刘备",
  ["#shzj_yiling__godliubei"] = "桃园挽歌",
  ["illustrator:shzj_yiling__godliubei"] = "点睛",
}

General:new(extension, "shzj_yiling__godguanyu", "god", 5):addSkills { "shzj_yiling__wushen", "shzj_yiling__wuhun" }
Fk:loadTranslationTable{
  ["shzj_yiling__godguanyu"] = "神关羽",
  ["#shzj_yiling__godguanyu"] = "桃园挽歌",
  ["illustrator:shzj_yiling__godguanyu"] = "梦想君",
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

General:new(extension, "anying", "qun", 3):addSkills { "liupo", "zhuiling", "xihun", "xianqi", "fansheng" }
Fk:loadTranslationTable{
  ["anying"] = "暗影",
  ["#anying"] = "黑影笼罩",
  ["illustrator:anying"] = "黑白画谱",
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

--关索传
General:new(extension, "shzj_guansuo__guanping", "shu", 4):addSkills { "shzj_guansuo__longyin", "shzj_guansuo__jiezhong" }
Fk:loadTranslationTable{
  ["shzj_guansuo__guanping"] = "关平",
  ["#shzj_guansuo__guanping"] = "忠臣孝子",
  ["illustrator:shzj_guansuo__guanping"] = "枭瞳",

  ["~shzj_guansuo__guanping"] = "荆州已失守，还请父亲……暂退……",
}

General:new(extension, "shzj_guansuo__zhoucang", "shu", 4):addSkills { "shzj_guansuo__zhongyong" }
Fk:loadTranslationTable{
  ["shzj_guansuo__zhoucang"] = "周仓",
  ["#shzj_guansuo__zhoucang"] = "忠勇当先",
  ["illustrator:shzj_guansuo__zhoucang"] = "黑夜",

  ["~shzj_guansuo__zhoucang"] = "将军既死，何求苟活。",
}

local liaohua = General:new(extension, "shzj_guansuo__liaohua", "shu", 4, 5)
liaohua:addSkills { "zhawang", "xigui" }
liaohua:addRelatedSkills { "ol_ex__zhaxiang", "ty_ex__dangxian" }
Fk:loadTranslationTable{
  ["shzj_guansuo__liaohua"] = "廖化",
  ["#shzj_guansuo__liaohua"] = "历尽沧桑",
  ["illustrator:shzj_guansuo__liaohua"] = "巴萨小马",
}

General:new(extension, "shendan", "shu", 4):addSkills { "lianxiang", "pingmeng" }
Fk:loadTranslationTable{
  ["shendan"] = "申耽",
  ["#shendan"] = "败阵降曹",
  ["illustrator:shendan"] = "狗爷",
}

General:new(extension, "shenyis", "shu", 4):addSkills { "lianxiang", "panfengs" }
Fk:loadTranslationTable{
  ["shenyis"] = "申仪",
  ["#shenyis"] = "背汉顺曹",
  ["illustrator:shenyis"] = "狗爷",
}

General:new(extension, "shzj_guansuo__xusheng", "wu", 4):addSkills { "shzj_guansuo__pojun" }
Fk:loadTranslationTable{
  ["shzj_guansuo__xusheng"] = "徐盛",
  ["#shzj_guansuo__xusheng"] = "江东的铁壁",
  ["illustrator:shzj_guansuo__xusheng"] = "凡果",

  ["~shzj_guansuo__xusheng"] = "来世…愿再为我江东之臣！",
}

local lvmeng = General:new(extension, "shzj_guansuo__lvmeng", "wu", 3, 4)
lvmeng.shield = 1
lvmeng:addSkills { "fujingl", "fujiang", "tonglu" }
lvmeng:addRelatedSkills { "gongxin", "botu", "duojing" }
Fk:loadTranslationTable{
  ["shzj_guansuo__lvmeng"] = "吕蒙",
  ["#shzj_guansuo__lvmeng"] = "青龙入命",
  ["illustrator:shzj_guansuo__lvmeng"] = "小罗没想好",
}

local guansuo = General:new(extension, "shzj_guansuo__guansuo", "shu", 4)
guansuo:addSkills { "qianfu", "chengyuan", "yuxiangs" }
guansuo:addRelatedSkills { "yinglong", "shzj_guansuo__xiefang" }
Fk:loadTranslationTable{
  ["shzj_guansuo__guansuo"] = "关索",
  ["#shzj_guansuo__guansuo"] = "蜃龙傲天",
  ["illustrator:shzj_guansuo__guansuo"] = "荆芥",
}

General:new(extension, "huaci", "qun", 3, 6, General.Bigender):addSkills { "shiyao", "zuoyu", "shzj_guansuo__duyi", "juliaoh" }
Fk:loadTranslationTable{
  ["huaci"] = "华雌",
  ["#huaci"] = "献躯验方",
  ["illustrator:huaci"] = "小罗没想好",
}

General:new(extension, "shzj_guansuo__guanyinping", "shu", 3, 3, General.Female):addSkills {
  "shzj_guansuo__xueji", "shzj_guansuo__huxiao", "shzj_guansuo__wuji" }
Fk:loadTranslationTable{
  ["shzj_guansuo__guanyinping"] = "关银屏",
  ["#shzj_guansuo__guanyinping"] = "凤舞九天",
  ["illustrator:shzj_guansuo__guanyinping"] = "鬼画府",

  ["~shzj_guansuo__guanyinping"] = "既已新年，自当欣颜……",
}

General:new(extension, "shzj_guansuo__lvchang", "wei", 4):addSkills { "shzj_guansuo__shouxiang", "shzj_guansuo__juwu" }
Fk:loadTranslationTable{
  ["shzj_guansuo__lvchang"] = "吕常",
  ["#shzj_guansuo__lvchang"] = "御敌用威",
  ["illustrator:shzj_guansuo__lvchang"] = "荆芥",
}

General:new(extension, "shzj_guansuo__luxun", "wu", 3):addSkills { "shzj_guansuo__qianxun", "shzj_guansuo__lianying" }
Fk:loadTranslationTable{
  ["shzj_guansuo__luxun"] = "陆逊",
  ["#shzj_guansuo__luxun"] = "儒生雄才",
  ["illustrator:shzj_guansuo__luxun"] = "深圳枭瞳",

  ["~shzj_guansuo__luxun"] = "陛下欲令二宫相争，臣惶恐，先行一步！",
}

--绝代智将
General:new(extension, "shzj_juedai__liaohua", "shu", 4):addSkills { "shzj_juedai__dangxian", "shzj_juedai__fuli" }
Fk:loadTranslationTable{
  ["shzj_juedai__liaohua"] = "廖化",
  ["#shzj_juedai__liaohua"] = "果敢刚直",
  ["illustrator:shzj_juedai__liaohua"] = "凝聚永恒",

  ["~shzj_juedai__liaohua"] = "为大汉而死，老夫死而无憾……",
}

General:new(extension, "shzj_juedai__huangchong", "shu", 3):addSkills { "shzj_juedai__juxianh", "shzj_juedai__lijunh" }
Fk:loadTranslationTable{
  ["shzj_juedai__huangchong"] = "黄崇",
  ["#shzj_juedai__huangchong"] = "星陨绵竹",
  ["illustrator:shzj_juedai__huangchong"] = "绘绘子酱",
}

--[[
local jiangwei = General:new(extension, "shzj_juedai__jiangwei", "shu", 4)
jiangwei:addSkills { "juta", "linze", "fujij" }
jiangwei:addRelatedSkills { "buji", "m_ex__tiaoxin", "kunfenEx" }]]
Fk:loadTranslationTable{
  ["shzj_juedai__jiangwei"] = "姜维",
  ["#shzj_juedai__jiangwei"] = "残薪续志",
  ["illustrator:shzj_juedai__jiangwei"] = "鬼画府",

  ["juta"] = "据沓",
  [":juta"] = "锁定技，其他角色计算与你的距离+1。当其他角色使用牌指定你为目标时，其需弃置你与其距离数张牌，否则此牌对你无效。"..
  "当你使用【杀】结算结束后，你失去〖据沓〗，获得〖不戢〗。",
  ["linze"] = "麟择",
  [":linze"] = "锁定技，若你的体力值减已损失体力值：不小于0，你视为拥有〖挑衅〗；不大于0，你视为拥有〖困奋〗。",
  ["fujij"] = "扶稷",
  [":fujij"] = "限定技，结束阶段，若一号位本局于其回合内弃置过牌，你可以于本回合结束后执行一个额外回合；"..
  "当你于此额外回合内杀死角色后，你摸三张牌，回复体力至体力上限，令此技能视为未发动过。",
  ["buji"] = "不戢",
  [":buji"] = "当你获得或弃置牌后，你可以展示并使用其中一张牌（无次数限制），若未造成伤害，你失去1点体力。",
}

General:new(extension, "liuyin", "shu", 4):addSkills { "guwei" }
Fk:loadTranslationTable{
  ["liuyin"] = "柳隐",
  ["#liuyin"] = "御军定守",
  ["illustrator:liuyin"] = "荆芥",
}
--[[
local huoyi = General:new(extension, "huoyi", "shu", 4)
huoyi:addSkills { "zhongjue", "qingming" }
huoyi:addRelatedSkills { "liefa" }]]
Fk:loadTranslationTable{
  ["huoyi"] = "霍弋",
  ["#huoyi"] = "三世忠烈",
  ["illustrator:huoyi"] = "荆芥",

  ["zhongjue"] = "忠绝",
  [":zhongjue"] = "锁定技，游戏开始时，你令一名其他角色本局游戏使用牌无次数限制，然后其获得武将牌上的一个主公技。",
  ["qingming"] = "请命",
  [":qingming"] = "出牌阶段开始时，你可以与“忠绝”角色议事，你不展示意见牌，改为将上一张被使用或打出的牌的颜色作为意见。"..
  "若意见与其相同，你摸两张牌并获得〖烈伐〗，然后跳过本回合的弃牌阶段。",
  ["liefa"] = "烈伐",
  [":liefa"] = "你可以视为使用一张目标不包含你的基本牌，然后选择一项：1.失去1点体力或失去本技能；2.弃置两张牌。",
}

General:new(extension, "zhaoguang", "shu", 4):addSkills { "shzj_juedai__yizan", "zhengui" }
Fk:loadTranslationTable{
  ["zhaoguang"] = "赵广",
  ["#zhaoguang"] = "还中独断",
  ["illustrator:zhaoguang"] = "云涯",
}

General:new(extension, "zhaotong", "shu", 4):addSkills { "shzj_juedai__yizan", "shuge" }
Fk:loadTranslationTable{
  ["zhaotong"] = "赵统",
  ["#zhaotong"] = "戍边驻阁",
  ["illustrator:zhaotong"] = "云涯",
}

--General:new(extension, "shzj_juedai__zhugezhan", "shu", 4):addSkills { "shzj_xiangfan__zhongwang", "shzj_xiangfan__fuyin" }
Fk:loadTranslationTable{
  ["shzj_juedai__zhugezhan"] = "诸葛瞻",
  ["#shzj_juedai__zhugezhan"] = "绵竹之殇",
  ["illustrator:shzj_juedai__zhugezhan"] = "凝聚永恒",

  ["shzj_xiangfan__zhongwang"] = "众望",
  [":shzj_xiangfan__zhongwang"] = "锁定技，摸牌阶段，你改为令所有其他角色依次选择是否将至少一张牌置于牌堆顶，然后你摸五张牌；"..
  "回合结束时，若你本回合满足以下至少两项条件，则本回合以此法将牌置于牌堆顶的角色各摸两张牌，否则你与这些角色各失去1点体力："..
  "造成过伤害；未弃置过牌；手牌最少。",
  ["shzj_xiangfan__fuyin"] = "负荫",
  [":shzj_xiangfan__fuyin"] = "锁定技，你的手牌上限+X（X为蜀势力角色数）。当你成为【杀】的目标时，若为本回合首次，取消之；"..
  "否则你本回合不能回复体力。",
}

--General:new(extension, "xiahouhan", "qun", 3, 3, General.Female):addSkills { "jieyi", "linei", "tongxin" }
Fk:loadTranslationTable{
  ["xiahouhan"] = "夏侯含",
  ["#xiahouhan"] = "飘萍半生",
  ["illustrator:xiahouhan"] = "小罗没想好",

  ["jieyi"] = "结衣",
  [":jieyi"] = "每轮开始时，你可以令一名男性角色交给你至少一张牌，其本轮称为“结衣”角色，然后若其手牌数大于其交给你的牌数，你可以失去1点体力，"..
  "令你本轮可以多发动一次〖理内〗。",
  ["linei"] = "理内",
  [":linei"] = "每轮限一次，当“结衣”角色获得牌后，若其手牌数大于体力值，你可以获得其X张牌并令其回复1点体力（X为其手牌数与体力值之差，至多为3）。",
  ["tongxin"] = "同心",
  [":tongxin"] = "锁定技，当你或“结衣”角色摸牌阶段结束时，对方摸等同于此阶段摸牌数的牌。",
}

--[[
local xiahouhan = General:new(extension, "shzj_juedai__xiahouhan", "qun", 3, 3, General.Female)
xiahouhan:addSkills { "zhuhui", "hanci" }
xiahouhan:addRelatedSkills { "ex__qingjian", "jijiu" }]]
Fk:loadTranslationTable{
  ["shzj_juedai__xiahouhan"] = "夏侯含",
  ["#shzj_juedai__xiahouhan"] = "绮梦年华",
  ["illustrator:shzj_juedai__xiahouhan"] = "小罗没想好",

  ["zhuhui"] = "烛晦",
  [":zhuhui"] = "每轮限一次，一名男性角色的回合开始时，你可以令其选择一项：<br>"..
  "你获得〖清俭〗直到本轮结束，然后其交给你至少一张手牌；<br>"..
  "你获得〖急救〗直到本轮结束，然后其受到至少1点雷电伤害。",
  ["hanci"] = "寒慈",
  [":hanci"] = "锁定技，当一名角色获得技能后，你与其各摸一张牌。",
}

local lukang = General:new(extension, "shzj_juedai__lukang", "wu", 4)
lukang:addSkills { "shzj_juedai__qianjie", "shzj_juedai__jueyan", "shzj_juedai__huairou" }
lukang:addRelatedSkills{ "ex__jizhi" }
Fk:loadTranslationTable{
  ["shzj_juedai__lukang"] = "陆抗",
  ["#shzj_juedai__lukang"] = "社稷之瑰宝",
  ["illustrator:shzj_juedai__lukang"] = "腥鱼仔",

}

General:new(extension, "shzj_juedai__dingfeng", "wu", 4):addSkills { "shzj_juedai__duanbing", "sp__fenxun" }
Fk:loadTranslationTable{
  ["shzj_juedai__dingfeng"] = "丁奉",
  ["#shzj_juedai__dingfeng"] = "寿春解围",
  ["illustrator:shzj_juedai__dingfeng"] = "天纵世纪",
}

--General:new(extension, "shield_guard", "wei", 6):addSkills { "shzj_juedai__jianwei", "shzj_juedai__shuwei", "shzj_juedai__shouwei" }
Fk:loadTranslationTable{
  ["shield_guard"] = "重甲侍卫",
  ["#shield_guard"] = "讨灭叛军",
  ["illustrator:shield_guard"] = "",

  ["shzj_juedai__jianwei"] = "坚卫",
  [":shzj_juedai__jianwei"] = "锁定技，若你没有防具，视为你装备【白银狮子】。",
  ["shzj_juedai__shuwei"] = "戍卫",
  [":shzj_juedai__shuwei"] = "锁定技，出牌阶段，你至多使用X张牌。你使用【杀】伤害基数值改为X（X为你的体力值）。",
  ["shzj_juedai__shouwei"] = "守卫",
  [":shzj_juedai__shouwei"] = "每回合每项限一次，当其他角色失去体力后，你摸一张牌或回复1点体力。",
}

--General:new(extension, "yaokehui", "qun", 5):addSkills { "qiangdu" }
Fk:loadTranslationTable{
  ["yaokehui"] = "姚柯回",
  ["#yaokehui"] = "绥戎校尉",
  ["illustrator:yaokehui"] = "荆芥",

  ["qiangdu"] = "羌督",
  [":qiangdu"] = "其他角色的出牌阶段开始时，你可以摸一张牌并交给其一张牌，然后当其本回合首次使用仅指定唯一目标的【杀】或普通锦囊牌结算结束后，"..
  "你可以视为使用此牌（无距离限制），若你指定的目标与其指定的目标不完全相同，你失去1点体力。",
}

--General:new(extension, "liuyuan", "qun", 3):addSkills { "jianxi", "chaofu", "shzj_juedai__tuicheng" }
Fk:loadTranslationTable{
  ["liuyuan"] = "刘渊",
  ["#liuyuan"] = "留质洛阳",
  ["illustrator:liuyuan"] = "塞拉斯",

  ["jianxi"] = "兼习",
  [":jianxi"] = "当你受到伤害后，你可以摸一张牌并展示之，然后你声明并获得一个描述中包含此牌牌名且不在场上的技能，或你使用基本牌的数值+1。",
  ["chaofu"] = "朝缚",
  [":chaofu"] = "锁定技，若你的技能数小于一号位，当你使用基本牌后，你减1点体力上限；你受到的伤害值均改为1。",
  ["shzj_juedai__tuicheng"] = "推诚",
  [":shzj_juedai__tuicheng"] = "出牌阶段限一次，你可以将一张伤害牌当无次数限制的基本牌对两名角色使用，然后令其中一名角色获得此牌。",
}

General:new(extension, "shzj_juedai__zhanghu", "wei", 4):addSkills { "shzj_xiangfan__cuijian" }
Fk:loadTranslationTable{
  ["shzj_juedai__zhanghu"] = "张虎",
  ["#shzj_juedai__zhanghu"] = "晋阳侯",
  ["illustrator:shzj_juedai__zhanghu"] = "君桓文化",
}

--General:new(extension, "huliew", "wei", 4):addSkills { "chengxih", "zhaoeh" }
Fk:loadTranslationTable{
  ["huliew"] = "胡烈",
  ["#huliew"] = "玄武定澜",
  ["illustrator:huliew"] = "荆芥",

  ["chengxih"] = "乘袭",
  [":chengxih"] = "当你使用牌指定唯一目标时，你可以令目标角色展示所有手牌，然后其重铸至少一张牌，此牌额外结算其未重铸的花色数次。",
  ["zhaoeh"] = "昭恶",
  [":zhaoeh"] = "限定技，你失去过牌的回合结束时，你可以展示当前回合角色所有手牌，然后令至多X名角色对其使用至多X张【杀】（X为其展示的伤害牌数）。",
}

--General:new(extension, "shzj_juedai__zhonghui", "wei", 4):addSkills { "quanwei", "quanshu", "quanqing", "qiangyi" }
Fk:loadTranslationTable{
  ["shzj_juedai__zhonghui"] = "钟会",
  ["#shzj_juedai__zhonghui"] = "荡涤山河",
  ["illustrator:shzj_juedai__zhonghui"] = "鬼画府",

  ["quanwei"] = "权威",
  [":quanwei"] = "准备阶段，你可以展示一张手牌，和一名其他角色议事，若议事结果与你展示的牌颜色相同，你依次跳过本回合下任意个阶段，"..
  "令至多两名角色回复等量的体力；否则，你可以减1点体力上限，获得与你意见不同的角色的所有手牌。",
  ["quanshu"] = "权术",
  [":quanshu"] = "当你议事结束后或当你受到伤害后，你可以摸X张牌并蓄谋；你的手牌上限+X（X为你场上的牌数）。",
  ["quanqing"] = "权倾",
  [":quanqing"] = "限定技，结束阶段，你可以对攻击范围内的角色发动〖权威〗，然后你可以变更势力并获得〖戕异〗。",
  ["qiangyi"] = "戕异",
  [":qiangyi"] = "主公技，当你蓄谋后，你获得一张【影】；你可以将【影】当"..
  "<a href=':destroy_indiscrimintely'>【玉石皆碎】</a>对势力与你相同的角色使用。",

  ["destroy_indiscrimintely"] = "玉石皆碎",--红桃4
  [":destroy_indiscrimintely"] = "锦囊牌<br/>"..
  "<b>时机</b>：出牌阶段<br/>"..
  "<b>目标</b>：一名角色<br/>"..
  "<b>效果</b>：你对目标角色造成1点伤害，然后你失去1点体力。",

  ["destroy_indiscrimintely_skill"] = "玉石皆碎",
  ["#destroy_indiscrimintely_skill"] = "对一名角色造成1点伤害，你失去1点体力",
}

General:new(extension, "zhugexu", "wei", 3):addSkills { "tuizhi", "qianjunz", "guluo" }
Fk:loadTranslationTable{
  ["zhugexu"] = "诸葛绪",
  ["#zhugexu"] = "疑途独落",
  ["illustrator:zhugexu"] = "荆芥",
}

General:new(extension, "shzj_juedai__yuechen", "wei", 4):addSkills { "shzj_xiangfan__porui" }
Fk:loadTranslationTable{
  ["shzj_juedai__yuechen"] = "乐綝",
  ["#shzj_juedai__yuechen"] = "广昌亭侯",
  ["illustrator:shzj_juedai__yuechen"] = "错落宇宙",
}

return extension
