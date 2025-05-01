local extension = Package:new("piracy_e")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_e/skills")

Fk:loadTranslationTable{
  ["piracy_e"] = "线下-官盗E系列",
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
  ["illustrator:ofl__wangyun"] = "YanBai",
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
local wenyang = General:new(extension, "ofl__wenyang", "wei", 4)
wenyang.subkingdom = "wu"
wenyang:addSkills { "quedi", "ofl__choujue", "ofl__chuifeng", "ofl__chongjian" }
Fk:loadTranslationTable{
  ["ofl__wenyang"] = "文鸯",
  ["#ofl__wenyang"] = "独骑破军",
  ["illustrator:ofl__wenyang"] = "biou09",
}

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

General:new(extension, "ofl2__zhonghui", "wei", 4):addSkills { "ofl__quanji", "ofl__paiyi" }
Fk:loadTranslationTable{
  ["ofl2__zhonghui"] = "钟会",
  ["#ofl2__zhonghui"] = "桀骜的野心家",
  ["illustrator:ofl2__zhonghui"] = "磐蒲",

  ["~ofl2__zhonghui"] = "",
}

General:new(extension, "ofl__sunchen", "wu", 4):addSkills { "ofl__shilus", "ofl__xiongnve" }
Fk:loadTranslationTable{
  ["ofl__sunchen"] = "孙綝",
  ["#ofl__sunchen"] = "食髓的朝堂客",
  ["designer:ofl__sunchen"] = "逍遥鱼叔",
  ["illustrator:ofl__sunchen"] = "depp",

  ["~ofl__sunchen"] = "愿陛下念臣昔日之功，陛下？陛下！！",
}

--官盗E0051 尊享版2023：曹丕 杜畿 夏侯玄 李严 关银屏 马云騄 黄权 周泰 范疆张达

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
  ["illustrator:ofl__zhonghui"] = "黯荧岛工作室",

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
General:new(extension, "ofl__godzhangjiao", "god", 4):addSkills { "ofl__mingdao", "ofl__zhongfu", "ofl__dangjing", "ofl__sanshou" }
Fk:loadTranslationTable{
  ["ofl__godzhangjiao"] = "神张角",
  ["#ofl__godzhangjiao"] = "庇佑万千",
  ["illustrator:ofl__godzhangjiao"] = "鬼画府",
}

local godzhangbao = General:new(extension, "ofl__godzhangbao", "god", 4)
godzhangbao.hidden = true
godzhangbao:addSkills { "ofl__zhouyuan", "ofl__zhaobing", "ofl__sanshou" }
Fk:loadTranslationTable{
  ["ofl__godzhangbao"] = "神张宝",
  ["#ofl__godzhangbao"] = "庇佑万千",
  ["illustrator:ofl__godzhangbao"] = "NOVART",

  ["~ofl__godzhangbao"] = "这咒不管用了吗……？",
}

local godzhangliang = General:new(extension, "ofl__godzhangliang", "god", 4)
godzhangliang.hidden = true
godzhangliang:addSkills { "ofl__jijun", "ofl__fangtong", "ofl__sanshou" }
Fk:loadTranslationTable{
  ["ofl__godzhangliang"] = "神张梁",
  ["#ofl__godzhangliang"] = "庇佑万千",
  ["illustrator:ofl__godzhangliang"] = "王强",

  ["~ofl__godzhangliang"] = "黄天之道，哥哥我们错了吗？",
}

General:new(extension, "yanzhengh", "qun", 4):addSkills { "ofl__dishi", "ofl__xianxiang" }
Fk:loadTranslationTable{
  ["yanzhengh"] = "严政",
  ["#yanzhengh"] = "献首投降",
  ["illustrator:yanzhengh"] = "Xiaoi",
}

General:new(extension, "bairao", "qun", 5):addSkills { "ofl__huoyin" }
Fk:loadTranslationTable{
  ["bairao"] = "白绕",
  ["#bairao"] = "黑山寇首",
  ["illustrator:bairao"] = "君桓文化",
}

General:new(extension, "busi", "qun", 4, 6):addSkills { "ofl__weiluan", "ofl__tianpan", "ofl__gaiming" }
Fk:loadTranslationTable{
  ["busi"] = "卜巳",
  ["#busi"] = "黄巾渠帅",
  ["illustrator:busi"] = "千秋秋千秋",
}

local suigu = General:new(extension, "suigu", "qun", 5)
suigu:addSkills { "ofl__tunquan", "ofl__qianjun" }
suigu:addRelatedSkill("luanji")
Fk:loadTranslationTable{
  ["suigu"] = "眭固",
  ["#suigu"] = "兔入犬城",
  ["illustrator:suigu"] = "君桓文化",
}

General:new(extension, "heman", "qun", 5, 6):addSkills { "ofl__juedian", "ofl__nitian" }
Fk:loadTranslationTable{
  ["heman"] = "何曼",
  ["#heman"] = "截天夜叉",
  ["illustrator:heman"] = "千秋秋千秋",
}

General:new(extension, "yudu", "qun", 4):addSkills { "ofl__dafu", "ofl__jipin" }
Fk:loadTranslationTable{
  ["yudu"] = "于毒",
  ["#yudu"] = "劫富济贫",
  ["illustrator:yudu"] = "MUMU1",
}

General:new(extension, "tangzhou", "qun", 4):addSkills { "ofl__jukou", "ofl__shupan" }
Fk:loadTranslationTable{
  ["tangzhou"] = "唐周",
  ["#tangzhou"] = "叛门高足",
  ["illustrator:tangzhou"] = "sky",
}

General:new(extension, "bocai", "qun", 5):addSkills { "ofl__kunjun", "ofl__yingzhan", "ofl__cuiji" }
Fk:loadTranslationTable{
  ["bocai"] = "波才",
  ["#bocai"] = "黄巾执首",
  ["illustrator:bocai"] = "HOOO",
}

General:new(extension, "chengyuanzhi", "qun", 5):addSkills { "ofl__wuxiao", "ofl__qianhu" }
Fk:loadTranslationTable{
  ["chengyuanzhi"] = "程远志",
  ["#chengyuanzhi"] = "逆流而动",
  ["illustrator:chengyuanzhi"] = "HOOO",
}

General:new(extension, "dengmao", "qun", 5):addSkills { "ofl__paoxi", "ofl__houying" }
Fk:loadTranslationTable{
  ["dengmao"] = "邓茂",
  ["#dengmao"] = "逆势而行",
  ["illustrator:dengmao"] = "HOOO",
}

General:new(extension, "gaosheng", "qun", 5):addSkills { "ofl__xiongshi", "ofl__difeng" }
Fk:loadTranslationTable{
  ["gaosheng"] = "高升",
  ["#gaosheng"] = "地公之锋",
  ["illustrator:gaosheng"] = "livsinno",
}

General:new(extension, "fuyun", "qun", 4):addSkills { "ofl__suiqu", "ofl__yure" }
Fk:loadTranslationTable{
  ["fuyun"] = "浮云",
  ["#fuyun"] = "黄天末代",
  ["illustrator:fuyun"] = "苍月白龙",
}

General:new(extension, "taosheng", "qun", 5):addSkills { "ofl__zainei", "ofl__hanwei" }
Fk:loadTranslationTable{
  ["taosheng"] = "陶升",
  ["#taosheng"] = "平汉将军",
  ["illustrator:taosheng"] = "佚名",
}

General:new(extension, "godhuangfusong", "god", 4):addSkills { "ofl__shice", "ofl__podai" }
Fk:loadTranslationTable{
  ["godhuangfusong"] = "神皇甫嵩",
  ["#godhuangfusong"] = "厥功至伟",
  ["illustrator:godhuangfusong"] = "王宁",
}

General:new(extension, "godluzhi", "god", 4):addSkills { "ofl__zhengan", "ofl__weizhu", "ofl__zequan" }
Fk:loadTranslationTable{
  ["godluzhi"] = "神卢植",
  ["#godluzhi"] = "鏖战广宗",
  ["illustrator:godluzhi"] = "聚一_L.M.YANG",
}

General:new(extension, "godzhujun", "god", 4):addSkills { "ofl__cheji", "ofl__jicui", "ofl__kuixiang" }
Fk:loadTranslationTable{
  ["godzhujun"] = "神朱儁",
  ["#godzhujun"] = "围师必阙",
  ["illustrator:godzhujun"] = "鱼仔",
}

--官盗E10：蛇年限定礼盒
General:new(extension, "ofl__zhangrang", "qun", 4):addSkills { "ofl__taoluan", "changshi" }
Fk:loadTranslationTable{
  ["ofl__zhangrang"] = "张让",
  ["#ofl__zhangrang"] = "妄尊帝父",
  ["illustrator:ofl__zhangrang"] = "凡果",
}

General:new(extension, "ofl__zhaozhong", "qun", 4):addSkills { "ofl__chiyan", "changshi" }
Fk:loadTranslationTable{
  ["ofl__zhaozhong"] = "赵忠",
  ["#ofl__zhaozhong"] = "宦刑啄心",
  ["illustrator:ofl__zhaozhong"] = "凡果",
}

General:new(extension, "ofl__sunzhang", "qun", 4):addSkills { "ofl__zimou", "changshi" }
Fk:loadTranslationTable{
  ["ofl__sunzhang"] = "孙璋",
  ["#ofl__sunzhang"] = "唯利是从",
  ["illustrator:ofl__sunzhang"] = "鬼画府",
}

General:new(extension, "ofl__bilan", "qun", 4):addSkills { "ofl__picai", "changshi" }
Fk:loadTranslationTable{
  ["ofl__bilan"] = "毕岚",
  ["#ofl__bilan"] = "糜财广筑",
  ["illustrator:ofl__bilan"] = "鬼画府",
}

General:new(extension, "ofl__xiayun", "qun", 4):addSkills { "ofl__yaozhuo", "changshi" }
Fk:loadTranslationTable{
  ["ofl__xiayun"] = "夏恽",
  ["#ofl__xiayun"] = "言蔽朝尊",
  ["illustrator:ofl__xiayun"] = "铁杵文化",
}

local lisong = General:new(extension, "ofl__lisong", "qun", 4)
lisong:addSkills { "ofl__kuiji", "changshi" }
lisong:addRelatedSkill("chouhai")
Fk:loadTranslationTable{
  ["ofl__lisong"] = "栗嵩",
  ["#ofl__lisong"] = "道察衕异",
  ["illustrator:ofl__lisong"] = "铁杵文化",
}

General:new(extension, "ofl__duangui", "qun", 4):addSkills { "ofl__chihe", "changshi" }
Fk:loadTranslationTable{
  ["ofl__duangui"] = "段珪",
  ["#ofl__duangui"] = "断途避圣",
  ["illustrator:ofl__duangui"] = "鬼画府",
}

General:new(extension, "ofl__guosheng", "qun", 4):addSkills { "ofl__niqu", "changshi" }
Fk:loadTranslationTable{
  ["ofl__guosheng"] = "郭胜",
  ["#ofl__guosheng"] = "诱杀党朋",
  ["illustrator:ofl__guosheng"] = "鬼画府",
}

General:new(extension, "ofl__gaowang", "qun", 4):addSkills { "ofl__miaoyu", "changshi" }
Fk:loadTranslationTable{
  ["ofl__gaowang"] = "高望",
  ["#ofl__gaowang"] = "蛇蝎为药",
  ["illustrator:ofl__gaowang"] = "鬼画府",
}

General:new(extension, "ofl__hankui", "qun", 4):addSkills { "ofl__xiaolu", "changshi" }
Fk:loadTranslationTable{
  ["ofl__hankui"] = "韩悝",
  ["#ofl__hankui"] = "贪财好贿",
  ["illustrator:ofl__hankui"] = "鬼画府",
}

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

--官盗E9：全武将太虚幻境
--General:new(extension, "quexiaojiang", "qun", 4):addSkills { "anmou", "tousuan" }
Fk:loadTranslationTable{
  ["quexiaojiang"] = "曲阿小将",
  ["#quexiaojiang"] = "",
  ["illustrator:quexiaojiang"] = "",
}

--官盗2025尊享
local caocaoyuanshao = General:new(extension, "caocaoyuanshao", "qun", 4)
caocaoyuanshao.subkingdom = "wei"
caocaoyuanshao:addSkills { "guibei", "jiechu", "daojue", "tuonan" }
caocaoyuanshao:addRelatedSkills { "ofl__qingzheng", "ofl__zhian", "feiying", "ol_ex__hujia", "shenliy", "ofl__zhuni", "shishouy" }
Fk:loadTranslationTable{
  ["caocaoyuanshao"] = "曹操袁绍",
  ["#caocaoyuanshao"] = "总角之交",
  ["illustrator:caocaoyuanshao"] = "荆芥",
}

--官盗E：风云志·长安风云
--李傕 郭汜 张济 王允 吕布 樊稠 神贾诩 神曹操 神李傕郭汜 神王允 丧尸

return extension
