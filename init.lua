local ofl_other = require "packages/offline/ofl_other"
local espionage_beta = require "packages/offline/espionage_beta"
local feihongyinxue = require "packages/offline/feihongyinxue"
local jiuding = require "packages/offline/jiuding"
local shzj = require "packages/offline/shzj"
local sxfy_shaoyin = require "packages/offline/sxfy_shaoyin"
local sxfy_taiyin = require "packages/offline/sxfy_taiyin"
local sxfy_shaoyang = require "packages/offline/sxfy_shaoyang"
local tqt = require "packages/offline/assassins"
local zyz = require "packages/offline/bgmdiy"

local ofl_token = require "packages/offline/ofl_token"

Fk:loadTranslationTable{ ["offline"] = "线下" }

return {
  ofl_other,
  espionage_beta,
  feihongyinxue,
  jiuding,
  shzj,
  sxfy_shaoyin,
  sxfy_taiyin,
  sxfy_shaoyang,
  tqt,
  zyz,

  ofl_token,
}
