# this file is compiled last (before calling main())

# register npc-s
array_foreach(npcReg, (i, npc) => registerNpc(npc));
