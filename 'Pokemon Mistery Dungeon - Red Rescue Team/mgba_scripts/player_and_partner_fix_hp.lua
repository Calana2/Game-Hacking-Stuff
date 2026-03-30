--[[
     This script makes you and your partner inmortal.
     Run this script when you are inside a battle zone.
  ]]--

local function read_byte(addr) return emu:read8(addr) end
local function write_byte(addr, val) return emu:write8(addr,val) end

local function keep_life(curr_hp_addr, max_hp_addr)
  local val = read_byte(max_hp_addr)
  callbacks:add("frame", function()
    write_byte(curr_hp_addr,val)
  end)
  return val
end

-- Info

console:log("[+] Running script...\n\n" ..
	    " 	 GAME: " .. emu:getGameTitle() .. "\n" ..
	    " 	 CODE: "  .. emu:getGameCode() .. "\n" )

-- Change player and partner life
local PLAYER_HP_ADDR = 0x200419e
local PLAYER_MAX_HP_ADDR = 0x20041a0
local PARTNER_HP_ADDR = 0x20043a6
local PARTNER_MAX_HP_ADDR = 0x20043a8

player_max_hp = keep_life(PLAYER_HP_ADDR,PLAYER_MAX_HP_ADDR)
partner_max_hp = keep_life(PARTNER_HP_ADDR,PARTNER_MAX_HP_ADDR)

console:log("	 Player life fixed to: " .. tostring(player_max_hp) .. " hp\n" .. 
            "	 Partner life fixed to: " .. tostring(partner_max_hp) .. " hp\n" ..
	    "[+] End ") 
