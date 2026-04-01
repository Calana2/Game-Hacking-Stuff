--[[
     Reverse unlock_friend_areas.lua
  ]]--

local function read_byte(addr) return emu:read8(addr) end
local function read_word(addr) return emu:read16(addr) end
local function read_dword(addr) return emu:read32(addr) end
local function write_byte(addr, val) return emu:write8(addr,val) end
local function write_word(addr, val) return emu:write16(addr,val) end
local function write_dword(addr, val) return emu:write32(addr,val) end

friend_area = {
 "Bountiful Sea",        -- c29
 "Shallow Beach",        -- c2a
 "Deep-Sea Current",     -- c2b
 "Deep-Sea Floor",       -- c2c
 "Deep-Sea Current",     -- c2d
 "Seafloor Cave",        -- c2e
 "Shallow Beach",        -- c2f
 "Mt. Deepgreen",        -- c30
 "Mt. Cleft",            -- c31
 "Mt. Moonview",         -- c32
 "Rainbow Peak",         -- c33
 "Wild Plains",          -- c34
 "Beau Plains",          -- c35
 "Sky Blue Plains",      -- c36
 "Safari",               -- c37
 "Scorched Plains",      -- c38
 "Sacred Field",         -- c39
 "Mist-Rise Forest",     -- c3a
 "Flyaway Forest",       -- c3b
 "Overgrown Forest",     -- c3c
 "Energetic Forest",     -- c3d
 "Mushroom Forest",      -- c3e
 "Healing Forest ",      -- c3f
 "Tansform Forest",      -- c40
 "Secretibe Forest",     -- c41
 "Rub-a-Dub-River",      -- c42
 "Tadpole Pond",         -- c43
 "Turtleshell Pond",     -- c44
 "Mystic Lake",          -- c45
 "Waterfall Lake",       -- c46
 "Peanut Swamp",         -- c47
 "Poison Swamp",         -- c48
 "Echo Cave",            -- c49
 "Cryptic Cave",         -- c4a
 "Dragon Cave",          -- c4b
 "Boulder Cave",         -- c4c
 "Jungle",               -- c4d
 "Decrepit Lab",         -- c4e
 "Mt. Discipline",       -- c4f
 "Thunder Meadows",      -- c50
 "Power Plant",          -- c51
 "Crater",               -- c52
 "Furnace Desert",       -- c53
 "Aged Chamber AN",      -- c54
 "Aged Chamber O?",      -- c55
 "Ancient Relic",        -- c56
 "Darkness Ridge",       -- c57
 "Frigid Cavern",        -- c58
 "Ice Floe Beach",       -- c59
 "Vocan Pit",            -- c5a
 "Stratos Lookout",      -- c5b
 "Ravaged Field",        -- c5c
 "Magnetic Quarry",      -- c5d
 "Legendary Island",     -- c5e
 "Southern Island",      -- c5f
 "Enclosed Island",      -- c60
 "Final Island",         -- c61
}

local function unlock_areas(_start,_end)
   local addr = _start
   local name_idx = 1
   while addr <= _end do
        if addr + 3 <= _end then
		      write_dword(addr, 0)
		      addr = addr + 4
          for _=0,3 do
            console:log(string.format("	 %-20s locked!",friend_area[name_idx]))
            name_idx = name_idx + 1
          end
	      else
		      write_byte(addr,0)
		      addr = addr + 1
          console:log(string.format("	 %-20s locked!",friend_area[name_idx]))
          name_idx = name_idx + 1
	end
   end
end	

-- Info
--
console:log("[+] Running script...\n\n" ..
	    " 	 GAME: " .. emu:getGameTitle() .. "\n" ..
	    " 	 CODE: "  .. emu:getGameCode() .. "\n" )

-- Unlock all the areas
--
local ADDR_START = 0x2038c29
local ADDR_END   = 0x2038c61

unlock_areas(ADDR_START,ADDR_END)

console:log("\n[+] End ") 
