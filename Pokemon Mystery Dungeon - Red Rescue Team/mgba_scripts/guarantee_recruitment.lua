--[[
     At the current time this only works in the development api of mgba
     It will not recruit if the other two conditions are not met:
     - The player is adjacent to the enemy and delivers the final blow.
     - The player has a friend zone for that Pokemon.
  ]]--

--[[
     Recruitment Chance Random Value Algorithm (simplified)
            seed = &0x0203b454 
            rand = (seed * 0x5d588b65 + 1) >> 16
            random_number = rand * 1000 & 0xFFFF
            if random_number < recruitment_chance + recruitment_bonus
              then can join
   ]]--

function guarantee_recruitment()
  console:log("[+] Forcing recruitment...")
  emu:writeRegister("r7", -0x8000)   -- the minimum for a signed 16 bits value
end 

console:log("[+] Running script...\n\n" ..
            "    GAME: " .. emu:getGameTitle() .. "\n" ..
            "    CODE: "  .. emu:getGameCode() .. "\n" )

emu:setBreakpoint(guarantee_recruitment, 0x806F826)

console:log("\n[+] End ")



