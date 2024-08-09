local ofl_other = require "packages/offline/ofl_other"
local espionage_beta = require "packages/offline/espionage_beta"
local fhyx = require "packages/offline/fhyx"
local jiuding = require "packages/offline/jiuding"
local sxfy_shaoyin = require "packages/offline/sxfy_shaoyin"
local sxfy_taiyin = require "packages/offline/sxfy_taiyin"
local tqt = require "packages/offline/assassins"
local zyz = require "packages/offline/bgmdiy"

local ofl_token = require "packages/offline/ofl_token"

Fk:loadTranslationTable{ ["offline"] = "线下" }

return {
  ofl_other,
  espionage_beta,
  fhyx,
  jiuding,
  sxfy_shaoyin,
  sxfy_taiyin,
  tqt,
  zyz,

  ofl_token,
}
