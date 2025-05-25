local extension = Package:new("piracy_e")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_e/skills")

Fk:loadTranslationTable{
  ["piracy_e"] = "线下-官盗E系列",
}

--E0026群雄逐鹿：
--黄巾之乱：神张梁 神张宝 神张角
--虎牢关之战：虎牢关吕布
--界桥之战：神袁绍 神文丑 神公孙瓒 神赵云
--长安之战（文和乱武）：神贾诩 樊稠 王允
General:new(extension, "ofl2__godjiaxu", "god", 3):addSkills { "ofl__bishi", "ofl__jianbing", "weimu" }
Fk:loadTranslationTable{
  ["ofl2__godjiaxu"] = "神贾诩",
  ["#ofl2__godjiaxu"] = "乱世之观者",
  ["illustrator:ofl2__godjiaxu"] = "小牛",
}

General:new(extension, "ofl__wangyun", "qun", 3):addSkills { "ofl__lianji", "ofl__moucheng" }
Fk:loadTranslationTable{
  ["ofl__wangyun"] = "王允",
  ["#ofl__wangyun"] = "计随鞘出",
  ["illustrator:ofl__wangyun"] = "YanBai",
}

--E0033兵合一处
General:new(extension, "es__caocao", "qun", 4):addSkills { "xiandao", "sancai", "yibing" }
Fk:loadTranslationTable{
  ["es__caocao"] = "曹操",
  ["#es__caocao"] = "谯水击蛟",
  ["illustrator:es__caocao"] = "墨心绘意",
}

--E0034暗金豪华版/S1标准版龙魂 龙羽飞
General:new(extension, "longyufei", "shu", 3, 4, General.Female):addSkills { "longyi", "zhenjue" }
Fk:loadTranslationTable{
  ["longyufei"] = "龙羽飞",
  ["#longyufei"] = "将星之魂",
  ["illustrator:longyufei"] = "DH",
}

--E0035问鼎中原：
--宛城之战：神曹操 神典韦 曹安民
General:new(extension, "ofl__caoanmin", "wei", 4):addSkills { "ofl__kuishe" }
Fk:loadTranslationTable{
  ["ofl__caoanmin"] = "曹安民",
  ["#ofl__caoanmin"] = "瓢取祸水",
  ["illustrator:ofl__caoanmin"] = "柏桦",
}

--下邳之战：神吕布
--官渡之战：神淳于琼 神张郃 神袁绍
--赤壁之战：神周瑜 神诸葛亮 神曹操 郭嘉

--E0037三分天下：
--渭水之战：神马超 神许褚
--合肥之战：神张辽
General:new(extension, "ofl__godzhangliao", "god", 4):addSkills { "ofl__tuji", "ofl__weizhen", "ofl__zhiti" }
Fk:loadTranslationTable{
  ["ofl__godzhangliao"] = "神张辽",
  ["#ofl__godzhangliao"] = "威震逍遥津",
  ["illustrator:ofl__godzhangliao"] = "Thinking",
}

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

--E0041分久必合：
--夷陵之战
--南中平定战：一堆神孟获？
--五丈原之战：神诸葛亮 神司马懿
--天下一统：
local wenyang = General:new(extension, "ofl__wenyang", "wei", 4)
wenyang.subkingdom = "wu"
wenyang:addSkills { "quedi", "ofl__choujue", "ofl__chuifeng", "ofl__chongjian" }
Fk:loadTranslationTable{
  ["ofl__wenyang"] = "文鸯",
  ["#ofl__wenyang"] = "独骑破军",
  ["illustrator:ofl__wenyang"] = "biou09",
}

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

--E0051 尊享版2023：曹丕 李严 关银屏 马云騄 黄权 周泰 范疆张达
General:new(extension, "ofl__duji", "wei", 3):addSkills { "ofl__yingshi", "ofl__andong" }
Fk:loadTranslationTable{
  ["ofl__duji"] = "杜畿",
  ["#ofl__duji"] = "卧镇京畿",
  ["illustrator:ofl__duji"] = "梦回唐朝_久吉",
}

General:new(extension, "ofl__xiahouxuan", "wei", 3):addSkills { "ofl__huanfu", "qingyix", "zeyue" }
Fk:loadTranslationTable{
  ["ofl__xiahouxuan"] = "夏侯玄",
  ["#ofl__xiahouxuan"] = "明皎月影",
  ["illustrator:ofl__xiahouxuan"] = "MUMU",

  ["$qingyix_ofl__xiahouxuan1"] = "今大将军执政，各位何不各抒己见，以言其得失？",
  ["$qingyix_ofl__xiahouxuan2"] = "天下未定，诸位当为国而进忠言，不可缄默不语。",
  ["$zeyue_ofl__xiahouxuan1"] = "官才用人，国之柄也，岂可授予他人？",
  ["$zeyue_ofl__xiahouxuan2"] = "世家豪族把持朝政，实乃国之巨蠹！",
  ["~ofl__xiahouxuan"] = "吾岂苟存自客于寇虏乎？",
}

--E8002全武将大合集奢华版（神张飞盒）
General:new(extension, "ofl__guozhao", "wei", 3, 3, General.Female):addSkills { "ofl__pianchong", "ofl__zunwei" }
Fk:loadTranslationTable{
  ["ofl__guozhao"] = "郭照",
  ["#ofl__guozhao"] = "碧海青天",
  ["illustrator:ofl__guozhao"] = "张晓溪",

  ["~ofl__guozhao"] = "红袖揾烟雨，泪尽垂青花。",
}

--E14001T至宝
General:new(extension, "zhouji", "wu", 3, 3, General.Female):addSkills { "ofl__yanmouz", "ofl__zhanyan", "ofl__yuhuo" }
Fk:loadTranslationTable{
  ["zhouji"] = "周姬",
  ["#zhouji"] = "江东的红莲",
  ["illustrator:zhouji"] = "xerez",
}

--E14001T匡鼎炎汉：鄂焕
local ehuan = General:new(extension, "ehuan", "qun", 5)
ehuan.subkingdom = "shu"
ehuan:addSkills { "ofl__diwan", "ofl__suiluan", "ofl__conghan" }
Fk:loadTranslationTable{
  ["ehuan"] = "鄂焕",
  ["#ehuan"] = "牙门汉将",
  ["illustrator:ehuan"] = "小强",
}

--E7005T决战巅峰：钟会
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

--E5003T荆襄风云
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

--E1002T全武将尊享
General:new(extension, "tianchuan", "qun", 3, 3, General.Female):addSkills { "huying", "qianjing", "bianchi" }
Fk:loadTranslationTable{
  ["tianchuan"] = "田钏",
  ["#tianchuan"] = "潜行之狐",
  ["illustrator:tianchuan"] = "苍月白龙",
}

--E3005至臻·权谋
General:new(extension, "ofl__jiling", "qun", 4):addSkills { "ofl__shuangren" }
Fk:loadTranslationTable{
  ["ofl__jiling"] = "纪灵",
  ["#ofl__jiling"] = "仲家的主将",
  ["illustrator:ofl__jiling"] = "铁杵文化",
}

--E24001T至臻·侠客行
local penghu = General:new(extension, "penghu", "qun", 5)
penghu:addSkills { "juqian", "zhepo", "yizhongp" }
penghu:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["penghu"] = "彭虎",
  ["#penghu"] = "鄱阳风浪",
  ["illustrator:penghu"] = "花弟",
}

local pengqi = General:new(extension, "pengqi", "qun", 3, 3, General.Female)
pengqi:addSkills { "jushoup", "liaoluan", "huaying", "ofl__jizhong" }
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

--E5002风云志·汉末风云
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

--E11001T蛇年限定礼盒
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

--E7006T肃问
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

--E150017至臻-全武将典藏
local caocaoyuanshao = General:new(extension, "caocaoyuanshao", "qun", 4)
caocaoyuanshao.subkingdom = "wei"
caocaoyuanshao:addSkills { "guibei", "jiechu", "daojue", "tuonan" }
caocaoyuanshao:addRelatedSkills { "ofl__qingzheng", "ofl__zhian", "feiying", "ol_ex__hujia", "shenliy", "ofl__zhuni", "shishouy" }
Fk:loadTranslationTable{
  ["caocaoyuanshao"] = "曹操袁绍",
  ["#caocaoyuanshao"] = "总角之交",
  ["illustrator:caocaoyuanshao"] = "荆芥",
}

--E9004T全武将太虚幻境
local quexiaojiang = General:new(extension, "quexiaojiang", "qun", 4)
quexiaojiang:addSkills { "yingzhen", "yuanjue", "aoyong" }
quexiaojiang:addRelatedSkill("tongkai")
Fk:loadTranslationTable{
  ["quexiaojiang"] = "曲阿小将",
  ["#quexiaojiang"] = "神人何惧",
  ["illustrator:quexiaojiang"] = "荆芥",
}

--E5003长安风云
General:new(extension, "ofl__lijue", "qun", 6):addSkills { "cuixi", "jujun" }
Fk:loadTranslationTable{
  ["ofl__lijue"] = "李傕",
  ["#ofl__lijue"] = "奸谋恶勇",
  ["illustrator:ofl__lijue"] = "梦回唐朝",
}

local guosi = General:new(extension, "ofl__guosi", "qun", 4)
guosi:addSkills { "sixi", "lvedao" }
guosi:addRelatedSkill("ofl__bixiong")
Fk:loadTranslationTable{
  ["ofl__guosi"] = "郭汜",
  ["#ofl__guosi"] = "党豺为虐",
  ["illustrator:ofl__guosi"] = "MUMU",
}

General:new(extension, "ofl__godjiaxu", "god", 3):addSkills { "sangluan", "shibaoj", "chuce", "longmu" }
Fk:loadTranslationTable{
  ["ofl__godjiaxu"] = "神贾诩",
  ["#ofl__godjiaxu"] = "丧尸出笼",
  ["illustrator:ofl__godjiaxu"] = "一品咸鱼堡",
}

local zombie = General:new(extension, "ofl__zombie", "qun", 2, 4)
zombie.hidden = true
zombie:addSkills { "shibian", "ganran" }
Fk:loadTranslationTable{
  ["ofl__zombie"] = "丧尸",
  ["#ofl__zombie"] = "丧尸围城",
  ["illustrator:ofl__zombie"] = "YanBai",
}

local wangyun = General:new(extension, "ofl2__wangyun", "qun", 3)
wangyun:addSkills { "ofl2__lianji", "ofl2__moucheng" }
wangyun:addRelatedSkill("ofl2__jingong")
Fk:loadTranslationTable{
  ["ofl2__wangyun"] = "王允",
  ["#ofl2__wangyun"] = "忠魂不泯",
  ["illustrator:ofl2__wangyun"] = "L",
}

General:new(extension, "ofl2__lvbu", "qun", 5):addSkills { "wushuang", "ofl2__liyu" }
Fk:loadTranslationTable{
  ["ofl2__lvbu"] = "吕布",
  ["#ofl2__lvbu"] = "武的化身",
  ["illustrator:ofl2__lvbu"] = "SY",
}

General:new(extension, "ofl__godcaocao", "god", 4):addSkills { "zhaozhao", "jieao" }
Fk:loadTranslationTable{
  ["ofl__godcaocao"] = "神曹操",
  ["#ofl__godcaocao"] = "挟圣诏王",
  ["illustrator:ofl__godcaocao"] = "云涯",
}

General:new(extension, "godlijueguosi", "god", 5):addSkills { "weiju", "sixiong" }
Fk:loadTranslationTable{
  ["godlijueguosi"] = "神李傕郭汜",
  ["#godlijueguosi"] = "祸乱长安",
  ["illustrator:godlijueguosi"] = "旭",
}

General:new(extension, "ofl__fanchou", "qun", 4):addSkills { "xingwei", "qianmu" }
Fk:loadTranslationTable{
  ["ofl__fanchou"] = "樊稠",
  ["#ofl__fanchou"] = "庸生变难",
  ["illustrator:ofl__fanchou"] = "三道纹",
}

General:new(extension, "ofl__zhangji", "qun", 4):addSkills { "silve", "suibian" }
Fk:loadTranslationTable{
  ["ofl__zhangji"] = "张济",
  ["#ofl__zhangji"] = "武威雄豪",
  ["illustrator:ofl__zhangji"] = "君桓文化",
}

General:new(extension, "godwangyun", "god", 4):addSkills { "anchao", "yurong", "ofl__dingxi" }
Fk:loadTranslationTable{
  ["godwangyun"] = "神王允",
  ["#godwangyun"] = "百策御军",
  ["illustrator:godwangyun"] = "alien",
}

return extension
