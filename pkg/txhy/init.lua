local extension = Package:new("txhy")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/txhy/skills")

Fk:loadTranslationTable{
  ["txhy"] = "线下-太虚幻魇",
  ["ofl_tx"] = "太虚幻魇",
  ["ofl_tx2"] = "太虚幻魇",
}

--张角 张梁 张宝 长安尸兵 张让 何进

General:new(extension, "ofl_tx__lijue", "qun", 4):addSkills {
  "ofl_tx__langxi",
  "ofl_tx__xiongjun",
  "ofl_tx__baoxi",
}
Fk:loadTranslationTable{
  ["ofl_tx__lijue"] = "李傕",
  ["#ofl_tx__lijue"] = "太虚幻魇",
  ["illustrator:ofl_tx__lijue"] = "鱼仔",
}

General:new(extension, "ofl_tx__fanchou", "qun", 4):addSkills {
  "ofl_tx__xiongjun",
  "ofl_tx__xiongzhen",
  "ofl_tx__xingluan",
}
Fk:loadTranslationTable{
  ["ofl_tx__fanchou"] = "樊稠",
  ["#ofl_tx__fanchou"] = "太虚幻魇",
  ["illustrator:ofl_tx__fanchou"] = "鱼仔",
}

General:new(extension, "ofl_tx__zhangji", "qun", 4):addSkills {
  "ofl_tx__xiongjun",
  "ofl_tx__lueming",
  "ofl_tx__juelve",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangji"] = "张济",
  ["#ofl_tx__zhangji"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangji"] = "YanBai",
}

General:new(extension, "ofl_tx__guosi", "qun", 4):addSkills {
  "ofl_tx__xiongjun",
  "ofl_tx__jiaodao",
  "ofl_tx__tanluan",
  "sidao",
}
Fk:loadTranslationTable{
  ["ofl_tx__guosi"] = "郭汜",
  ["#ofl_tx__guosi"] = "太虚幻魇",
  ["illustrator:ofl_tx__guosi"] = "秋呆呆",
}

General:new(extension, "ofl_tx2__gaoshun", "qun", 4):addSkills {
  "ofl_tx__xiongjun",
  "ofl_tx__xiongzhen",
  "xianzhen",
  "jinjiu",
}
Fk:loadTranslationTable{
  ["ofl_tx2__gaoshun"] = "高顺",
  ["#ofl_tx2__gaoshun"] = "太虚幻魇",
  ["illustrator:ofl_tx2__gaoshun"] = "巴萨小马",
}

General:new(extension, "ofl_tx__liru", "qun", 3):addSkills {
  "m_ex__juece",
  "m_ex__mieji",
  "ofl_tx__fencheng",
  "ofl_tx__moshi",
}
Fk:loadTranslationTable{
  ["ofl_tx__liru"] = "李儒",
  ["#ofl_tx__liru"] = "太虚幻魇",
  ["illustrator:ofl_tx__liru"] = "鬼画府",
}

General:new(extension, "ofl_tx__dongzhuo", "qun", 8):addSkills {
  "benghuai",
  "ofl_tx__jiuchi",
  "ofl_tx__mowang",
  "ofl_tx__shicheng",
}
Fk:loadTranslationTable{
  ["ofl_tx__dongzhuo"] = "董卓",
  ["#ofl_tx__dongzhuo"] = "太虚幻魇",
  ["illustrator:ofl_tx__dongzhuo"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__jiling", "qun", 4):addSkills {
  "ofl_tx__shuangren",
  "ofl_tx__fengren",
  "ofl_tx__zhonggu",
  "ex__tieji",
}
Fk:loadTranslationTable{
  ["ofl_tx__jiling"] = "纪灵",
  ["#ofl_tx__jiling"] = "太虚幻魇",
  ["illustrator:ofl_tx__jiling"] = "樱花闪乱",
}

General:new(extension, "ofl_tx__dragon", "qun", 4):addSkills {
  "ofl_tx__hailong",
  "longyin",
  "longdan",
  "longnu",
}
Fk:loadTranslationTable{
  ["ofl_tx__dragon"] = "骸骨龙",
  ["#ofl_tx__dragon"] = "太虚幻魇",
  ["illustrator:ofl_tx__dragon"] = "游卡",
}

General:new(extension, "ofl_tx__yuanshu", "qun", 6):addSkills {
  "ofl_tx__yongsi",
  "ofl_tx__daihan",
  "ofl_tx__zhonggu",
  "ofl_tx__cuanwei",
  "ofl_tx__juhun",
}
Fk:loadTranslationTable{
  ["ofl_tx__yuanshu"] = "袁术",
  ["#ofl_tx__yuanshu"] = "太虚幻魇",
  ["illustrator:ofl_tx__yuanshu"] = "鱼仔",
}

General:new(extension, "ofl_tx__yuejiu", "qun", 4):addSkills {
  "ofl_tx__cuijin",
  "ofl_tx__zhonggu",
  "ofl_tx__fushi",
  "ofl_tx__liwei",
}
Fk:loadTranslationTable{
  ["ofl_tx__yuejiu"] = "乐就",
  ["#ofl_tx__yuejiu"] = "太虚幻魇",
  ["illustrator:ofl_tx__yuejiu"] = "铁杵",
}

General:new(extension, "ofl_tx__chengong", "qun", 3):addSkills {
  "mingce",
  "zhichi",
  "miji",
}
Fk:loadTranslationTable{
  ["ofl_tx__chengong"] = "陈宫",
  ["#ofl_tx__chengong"] = "太虚幻魇",
  ["illustrator:ofl_tx__chengong"] = "zoo",
}

General:new(extension, "ofl_tx__zhangliao", "qun", 4):addSkills {
  "ofl_tx__weifeng",
  "os__jiange",
  "zhuhai",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangliao"] = "张辽",
  ["#ofl_tx__zhangliao"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangliao"] = "王强",
}

General:new(extension, "ofl_tx__gaoshun", "qun", 4):addSkills {
  "ofl_tx__jinjiu",
  "ofl_tx__zhanjiang",
  "ofl_tx__pimi",
}
Fk:loadTranslationTable{
  ["ofl_tx__gaoshun"] = "高顺",
  ["#ofl_tx__gaoshun"] = "太虚幻魇",
  ["illustrator:ofl_tx__gaoshun"] = "白",
}

General:new(extension, "ofl_tx__lvbu", "qun", 6):addSkills {
  "ofl_tx__moji",
  "ofl_tx__wushuang",
  "liyu",
  "ofl_tx__jiwu",
}
Fk:loadTranslationTable{
  ["ofl_tx__lvbu"] = "吕布",
  ["#ofl_tx__lvbu"] = "太虚幻魇",
  ["illustrator:ofl_tx__lvbu"] = "彭宇",
}

General:new(extension, "ofl_tx__diaochan", "qun", 3, 3, General.Female):addSkills {
  "ofl_tx__baijun",
  "ofl_tx__zhanjiang",
  "ofl_tx__biyue",
}
Fk:loadTranslationTable{
  ["ofl_tx__diaochan"] = "貂蝉",
  ["#ofl_tx__diaochan"] = "太虚幻魇",
  ["illustrator:ofl_tx__diaochan"] = "青岛君桓",
}

General:new(extension, "ofl_tx__godlvbu", "god", 8):addSkills {
  "ofl_tx__shenfen",
  "kuangbao",
  "ofl_tx__xiuluo",
  "ofl_tx__duanjin",
}
Fk:loadTranslationTable{
  ["ofl_tx__godlvbu"] = "神吕布",
  ["#ofl_tx__godlvbu"] = "太虚幻魇",
  ["illustrator:ofl_tx__godlvbu"] = "云涯",
}

General:new(extension, "ofl_tx__quyi", "qun", 4):addSkills {
  "ofl_tx__juedou",
  "ofl_tx__fanquan",
  "fuji",
  "ofl_tx__jiaozi",
}
Fk:loadTranslationTable{
  ["ofl_tx__quyi"] = "麴义",
  ["#ofl_tx__quyi"] = "太虚幻魇",
  ["illustrator:ofl_tx__quyi"] = "游卡",
}

General:new(extension, "ofl_tx__zhaoyun", "qun", 4):addSkills {
  "ofl_tx__longwu",
  "ofl_tx__lianzhan",
  "ofl_tx__juedou",
  "yajiao",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhaoyun"] = "赵云",
  ["#ofl_tx__zhaoyun"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhaoyun"] = "JUJU&zoo",
}

General:new(extension, "ofl_tx__gongsunzan", "qun", 6):addSkills {
  "ofl_tx__fanquan",
  "ofl_tx__juedou",
  "ofl_tx__lianzhan",
  "ofl_tx__majiang",
  "ofl_tx__fenqian",
}
Fk:loadTranslationTable{
  ["ofl_tx__gongsunzan"] = "公孙瓒",
  ["#ofl_tx__gongsunzan"] = "太虚幻魇",
  ["illustrator:ofl_tx__gongsunzan"] = "鱼仔",
}

--[[
General:new(extension, "ofl_tx__guanyu", "shu", 5):addSkills {
  "ofl_tx__weizhen",
  "ex__wusheng",
  "nuzhan",
  "ofl_tx__jinmo",
  "mashu",
}]]
Fk:loadTranslationTable{
  ["ofl_tx__guanyu"] = "关羽",
  ["#ofl_tx__guanyu"] = "太虚幻魇",
  ["illustrator:tqt__fuwan"] = "凝聚永恒",

  ["ofl_tx__weizhen"] = "巍镇",
  [":ofl_tx__weizhen"] = "出牌阶段开始时，你可以指定一名其他角色，此阶段当你对其造成伤害后，你摸X张牌并令其获得X枚“镇”标记（X为伤害值）。"..
  "弃牌阶段结束时，有“镇”标记的角色选择一项并移去所有“镇”标记：1.交给你“镇”标记数量张红色牌；2.不能使用或打出手牌直到你下回合开始。"..
  "若其选择1，则你执行<a href='os__coop'>同心效果</a>：从游戏外获得一张【决斗】。",
  ["ofl_tx__jinmo"] = "浸魔",
  [":ofl_tx__jinmo"] = "锁定技，当你受到伤害时，你令此伤害-1并获得一枚“魔”标记。"..
  "弃牌阶段结束时，你受到X点无来源伤害（X为“魔”标记数），然后从牌堆获得Y张伤害类牌（Y为你本次受到的伤害值）。"..
  "回合结束时，你移去所有“魔”标记。",
}

return extension
