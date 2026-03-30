#!/bin/bash

# "Using bsdiff/bspatch because my implementation sucks."

echo -e "Millionare patch. Start a new game with:\n" \
        "- All the Heroes unlocked (max lvl, all the abilities)\n" \
        "- All the Levels available and completed\n" \
        "- All the Game Upgrades\n" \
        "- All the Encyclopedia entries available\n" \
        "- Zero cooldown for Reinforcement and Fire Ball\n" 

if ! command -v bspatch >/dev/null 2>&1
then
    echo -e "Install bspatch first.\n" \
            "Repo: https://github.com/mendsley/bsdiff"
    exit 1
fi

bspatch $1 $2 patch.bin
