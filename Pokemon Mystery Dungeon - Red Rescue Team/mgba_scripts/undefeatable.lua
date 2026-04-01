--[[
     This script makes you and your partner inmortal.
     Run this script when you are inside a battle zone.
  ]]--

local function read_byte(addr) return emu:read8(addr) end
local function write_byte(addr, val) return emu:write8(addr,val) end

local function keep_alive()
  callbacks:add("frame", function()
    write_byte(PLAYER_HP_ADDR,read_byte(PLAYER_MAX_HP_ADDR))
    write_byte(PARTNER_HP_ADDR,read_byte(PARTNER_MAX_HP_ADDR))
    write_byte(BELLY_FULLNESS_ADDR, 0xFF)
  end)
  return val
end

-- Info

console:log("[+] Running script...\n\n" ..
	    " 	 GAME: " .. emu:getGameTitle() .. "\n" ..
	    " 	 CODE: "  .. emu:getGameCode() .. "\n" )

-- Change player and partner life
PLAYER_HP_ADDR = 0x200419e
PLAYER_MAX_HP_ADDR = 0x20041a0
PARTNER_HP_ADDR = 0x20043a6
PARTNER_MAX_HP_ADDR = 0x20043a8
BELLY_FULLNESS_ADDR = 0x020042cc
MAX_BELLY_FULLNESS_ADDR = 0x020042d0

write_byte(MAX_BELLY_FULLNESS_ADDR, 0xFF)
keep_alive()

console:log("	 Player life fixed to: " .. read_byte(PLAYER_MAX_HP_ADDR) .. " hp\n" .. 
            "	 Partner life fixed to: " .. read_byte(PARTNER_MAX_HP_ADDR) .. " hp\n" ..
            "  Player belly fixed to: 255/255\n" ..
	    "[+] End ") 
