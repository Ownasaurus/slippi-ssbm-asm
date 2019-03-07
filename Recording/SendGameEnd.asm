#To be inserted at 8016d30c
.include "../Common/Common.s"
.include "Recording.s"

################################################################################
# Routine: SendGameEnd
# ------------------------------------------------------------------------------
# Description: Send information about the end of a game to Slippi Device
################################################################################

.set REG_PlayerData,30
.set REG_Buffer,29
.set REG_BufferOffset,28
.set REG_PlayerSlot,27
.set REG_GameEndID,26
.set REG_SceneThinkStruct,25

backup

# check if VS Mode
  branchl r12,FN_IsVSMode
  cmpwi r3,0x0
  beq Injection_Exit

# check if game end ID != 0
 load REG_SceneThinkStruct,0x8016d30c
 lbz REG_GameEndID,0x0(REG_SceneThinkStruct)
 cmpwi r3,0
 beq Injection_Exit

# get buffer
  lwz REG_Buffer,frameDataBuffer(r13)

# request game information from slippi
  li r3, 0x39
  stb r3,0x0(REG_Buffer)

# check byte that will tell us whether the game was won by stock loss or by ragequit (2 = stock loss, 7 = no contest)
  lbz r3,0x8(REG_SceneThinkStruct)
  stb r3,0x1(REG_Buffer)
# check if LRA start
  cmpwi r3,0x7
  bne NoLRAStart
# find Who LRA Started
  lbz r3,0x1(REG_SceneThinkStruct)
  b StoreLRAStarter
NoLRAStart:
  li  r3,-1
StoreLRAStarter:
  stb r3,0x2(REG_Buffer)

#------------- Transfer Buffer ------------
  mr  r3,REG_Buffer
  li  r4,GAME_END_PAYLOAD_LENGTH+1
  li  r5,CONST_ExiWrite
  branchl r12,FN_EXITransferBuffer

Injection_Exit:
  restore
  lwz	r0, 0x003C (sp)
