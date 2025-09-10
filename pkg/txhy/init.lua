local extension = Package:new("txhy")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/txhy/skills")

Fk:loadTranslationTable{
  ["txhy"] = "线下-太虚幻魇",
  ["ofl_tx"] = "太虚幻魇",
  ["ofl_tx2"] = "太虚幻魇",
}

General:new(extension, "ofl_tx__zhangjiao", "qun", 8):addSkills {
  "ofl_tx__zhuhun",
  "ofl_tx__wangyuan",
  "ofl_tx__huangjin",
  "ol_ex__leiji",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangjiao"] = "张角",
  ["#ofl_tx__zhangjiao"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangjiao"] = "鬼画府",
}

General:new(extension, "ofl_tx__zhangliang", "qun", 6):addSkills {
  "ofl_tx__renfang",
  "ofl_tx__juemie",
  "chenglue",
  "ofl_tx__huangjin",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangliang"] = "张梁",
  ["#ofl_tx__zhangliang"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangliang"] = "鱼仔",
}

General:new(extension, "ofl_tx__zhangbao", "qun", 6):addSkills {
  "ol_ex__leiji",
  "ofl_tx__dizhou",
  "ofl_tx__didao",
  "ofl_tx__huangjin",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangbao"] = "张宝",
  ["#ofl_tx__zhangbao"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangbao"] = "鱼仔",
}

local zombie = General:new(extension, "ofl_tx__zombie", "qun", 3)
zombie.hidden = true
zombie:addSkills { "ofl_tx__shiyuan" }
Fk:loadTranslationTable{
  ["ofl_tx__zombie"] = "长怨尸兵",
  ["#ofl_tx__zombie"] = "太虚幻魇",
  ["illustrator:ofl_tx__zombie"] = "YanBai",
}

General:new(extension, "ofl_tx__zhangrang", "qun", 10):addSkills {
  "ofl_tx__huangmen",
  "ofl_tx__quanqing",
  "taoluan",
  "shefu",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangrang"] = "张让",
  ["#ofl_tx__zhangrang"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangrang"] = "铁杵",
}

General:new(extension, "ofl_tx__hejin", "qun", 6):addSkills {
  "os__linglu",
  "ofl_tx__zhuosheng",
  "os__mouzhu",
  "ofl_tx__mouqiang",
}
Fk:loadTranslationTable{
  ["ofl_tx__hejin"] = "何进",
  ["#ofl_tx__hejin"] = "太虚幻魇",
  ["illustrator:ofl_tx__hejin"] = "铁杵",
}

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

General:new(extension, "ofl_tx__guanyu", "shu", 5):addSkills {
  "ofl_tx__weizhen",
  "ex__wusheng",
  "nuzhan",
  "ofl_tx__jinmo",
  "mashu",
}
Fk:loadTranslationTable{
  ["ofl_tx__guanyu"] = "关羽",
  ["#ofl_tx__guanyu"] = "太虚幻魇",
  ["illustrator:tqt__fuwan"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__zhangfei", "shu", 5):addSkills {
  "ofl_tx__liyong",
  "os_ex__paoxiao",
  "os_ex__xuhe",
  "ofl_tx__jinmo",
  "mashu",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangfei"] = "张飞",
  ["#ofl_tx__zhangfei"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangfei"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__liubei", "shu", 5):addSkills {
  "ofl_tx__hengyi",
  "os__jiange",
  "os__jianming",
  "ofl_tx__jinmo",
  "mashu",
}
Fk:loadTranslationTable{
  ["ofl_tx__liubei"] = "刘备",
  ["#ofl_tx__liubei"] = "太虚幻魇",
  ["illustrator:ofl_tx__liubei"] = "深圳枭瞳",
}

General:new(extension, "ofl_tx2__zhaoyun", "shu", 5):addSkills {
  "ofl_tx__rulong",
  "longdan",
  "chongzhen",
  "os__jintao",
  "mashu",
}
Fk:loadTranslationTable{
  ["ofl_tx2__zhaoyun"] = "赵云",
  ["#ofl_tx2__zhaoyun"] = "太虚幻魇",
  ["illustrator:ofl_tx2__zhaoyun"] = "深圳枭瞳",
}

General:new(extension, "ofl_tx__wolong", "shu", 7):addSkills {
  "ofl_tx__xieyu",
  "ofl_tx__mozun",
  "ex__leiji",
  "ofl_tx__lianyu",
}
Fk:loadTranslationTable{
  ["ofl_tx__wolong"] = "卧龙诸葛亮",
  ["#ofl_tx__wolong"] = "太虚幻魇",
  ["illustrator:ofl_tx__wolong"] = "深圳枭瞳",
}

General:new(extension, "ofl_tx__xiaoqiao", "wu", 3, 3, General.Female):addSkills {
  "ofl_tx__moshi",
  "m_ex__tianxiang",
  "ofl_tx__hongyan",
  "os__manji",
}
Fk:loadTranslationTable{
  ["ofl_tx__xiaoqiao"] = "小乔",
  ["#ofl_tx__xiaoqiao"] = "太虚幻魇",
  ["illustrator:ofl_tx__xiaoqiao"] = "游卡",
}

General:new(extension, "ofl_tx__zhouyu", "wu", 3):addSkills {
  "ofl_tx__yingzi",
  "ofl_tx__yongguan",
  "ex__fanjian",
  "os__manji",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhouyu"] = "周瑜",
  ["#ofl_tx__zhouyu"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhouyu"] = "云涯",
}

General:new(extension, "ofl_tx__taishici", "wu", 4):addSkills {
  "ofl_tx__tianyi",
  "zhuandui",
  "ofl_tx__zhuicui",
  "os__jianming",
}
Fk:loadTranslationTable{
  ["ofl_tx__taishici"] = "太史慈",
  ["#ofl_tx__taishici"] = "太虚幻魇",
  ["illustrator:ofl_tx__taishici"] = "鱼仔",
}

General:new(extension, "ofl_tx__daqiao", "wu", 3, 3, General.Female):addSkills {
  "ofl_tx__tianzi",
  "tiandu",
  "ofl_tx__huangjin",
}
Fk:loadTranslationTable{
  ["ofl_tx__daqiao"] = "大乔",
  ["#ofl_tx__daqiao"] = "太虚幻魇",
  ["illustrator:ofl_tx__daqiao"] = "游卡",
}

General:new(extension, "ofl_tx__sunce", "wu", 6):addSkills {
  "ofl_tx__yongguan",
  "ofl_tx__benji",
  "ofl_tx__jiang",
  "m_ex__hunzi",
}
Fk:loadTranslationTable{
  ["ofl_tx__sunce"] = "孙策",
  ["#ofl_tx__sunce"] = "太虚幻魇",
  ["illustrator:ofl_tx__sunce"] = "town",
}

General:new(extension, "ofl_tx__guotupangji", "qun", 3):addSkills {
  "ofl_tx__jixi",
  "ol_ex__zhaxiang",
  "qingzhong",
  "zhaohan",
}
Fk:loadTranslationTable{
  ["ofl_tx__guotupangji"] = "郭图逄纪",
  ["#ofl_tx__guotupangji"] = "太虚幻魇",
  ["illustrator:ofl_tx__guotupangji"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__shenpei", "qun", 3):addSkills {
  "ofl_tx__kaishi",
  "sp__duanbing",
  "os__fenwu",
  "yuce",
}
Fk:loadTranslationTable{
  ["ofl_tx__shenpei"] = "审配",
  ["#ofl_tx__shenpei"] = "太虚幻魇",
  ["illustrator:ofl_tx__shenpei"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__jvshou", "qun", 3):addSkills {
  "ofl_tx__zhongjianh",
  "guzheng",
  "ofl_tx__mouduan",
  "ofl_tx__hemou",
}
Fk:loadTranslationTable{
  ["ofl_tx__jvshou"] = "沮授",
  ["#ofl_tx__jvshou"] = "太虚幻魇",
  ["illustrator:ofl_tx__jvshou"] = "鹿田",
}

General:new(extension, "ofl_tx__yuanshao", "qun", 6):addSkills {
  "ofl_tx__tiancheng",
  "m_ex__luanji",
  "tushe",
  "jueyong",
}
Fk:loadTranslationTable{
  ["ofl_tx__yuanshao"] = "袁绍",
  ["#ofl_tx__yuanshao"] = "太虚幻魇",
  ["illustrator:ofl_tx__yuanshao"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__yanliangwenchou", "qun", 5):addSkills {
  "ofl_tx__shuangsha",
  "ofl_tx__xianxi",
  "ofl_tx__yongdou",
  "ofl_tx__choujue",
  "jueyong",
}
Fk:loadTranslationTable{
  ["ofl_tx__yanliangwenchou"] = "颜良文丑",
  ["#ofl_tx__yanliangwenchou"] = "太虚幻魇",
  ["illustrator:ofl_tx__yanliangwenchou"] = "错落宇宙",
}

General:new(extension, "ofl_tx__zhangxiu", "qun", 5):addSkills {
  "xiongluan",
  "congjian",
  "ofl_tx__longdan",
  "ofl_tx__maojin",
}
Fk:loadTranslationTable{
  ["ofl_tx__zhangxiu"] = "张绣",
  ["#ofl_tx__zhangxiu"] = "太虚幻魇",
  ["illustrator:ofl_tx__zhangxiu"] = "深圳枭瞳",
}

General:new(extension, "ofl_tx__ganning", "qun", 6):addSkills {
  "jinfan",
  "sheque",
  "ofl_tx__shanji",
  "shelie",
}
Fk:loadTranslationTable{
  ["ofl_tx__ganning"] = "甘宁",
  ["#ofl_tx__ganning"] = "太虚幻魇",
  ["illustrator:ofl_tx__ganning"] = "深圳枭瞳",
}

local liuqi = General:new(extension, "ofl_tx__liuqi", "qun", 4)
liuqi:addSkills {
  "wenji",
  "fengliang",
  "ofl_tx__chouti",
  "os__jiezhan",
}
liuqi:addRelatedSkills { "tiaoxin", "ofl_tx__duanyuan", "ofl_tx__xianyuan" }
Fk:loadTranslationTable{
  ["ofl_tx__liuqi"] = "刘琦",
  ["#ofl_tx__liuqi"] = "太虚幻魇",
  ["illustrator:ofl_tx__liuqi"] = "深圳枭瞳",
}

General:new(extension, "ofl_tx__liubiao", "qun", 4):addSkills {
  "ofl_tx__jiyang",
  "m_ex__zongshi",
  "ofl_tx__rujing",
  "ofl_tx__huyi",
  "tiandu",
}
Fk:loadTranslationTable{
  ["ofl_tx__liubiao"] = "刘表",
  ["#ofl_tx__liubiao"] = "太虚幻魇",
  ["illustrator:ofl_tx__liubiao"] = "凝聚永恒",
}

General:new(extension, "ofl_tx__caifuren", "qun", 3, 3, General.Female):addSkills {
  "ofl_tx__mimou",
  "ofl_tx__huli",
  "ofl_tx__lianzhan",
  "ofl_tx__yingji",
}
Fk:loadTranslationTable{
  ["ofl_tx__caifuren"] = "蔡夫人",
  ["#ofl_tx__caifuren"] = "太虚幻魇",
  ["illustrator:ofl_tx__caifuren"] = "凝聚永恒",
}

return extension
