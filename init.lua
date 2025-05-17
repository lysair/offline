-- SPDX-License-Identifier: GPL-3.0-or-later

local modes = Package:new("ofl__gamemode", Package.SpecialPack)

modes:loadSkillSkelsByPath("./packages/offline/pkg/gamemodes/rule_skills")

modes:addGameMode(require "packages/offline/pkg/gamemodes/sgsh_mode")

local ofl_other = require "packages/offline/pkg/ofl_other"
local fhyx = require "packages/offline/pkg/fhyx"
local ofl_mou = require "packages/offline/pkg/ofl_mou"
local piracy_e = require "packages/offline/pkg/piracy_e"
local piracy_s = require "packages/offline/pkg/piracy_s"
local espionage_beta = require "packages/offline/pkg/espionage_beta"
local shzj = require "packages/offline/pkg/shzj"
local sxfy = require "packages/offline/pkg/sxfy"
local assassins = require "packages/offline/pkg/assassins"
local bgmdiy = require "packages/offline/pkg/bgmdiy"

local ofl_token = require "packages/offline/pkg/ofl_token"

Fk:loadTranslationTable{
  ["offline"] = "线下",
  ["ofl"] = "线下",
  ["ofl2"] = "线下",
  ["ofl3"] = "线下",
  ["ofl4"] = "线下",
}

return {
  modes,

  ofl_other,
  fhyx,
  ofl_mou,
  piracy_e,
  piracy_s,
  espionage_beta,
  shzj,
  sxfy,
  assassins,
  bgmdiy,

  ofl_token,
}
