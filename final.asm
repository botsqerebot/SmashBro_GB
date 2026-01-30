;* BEGINNING OF main.asm	
;* INCLUDE "include.asm"	
;Liberaries and global variables	
;* INCLUDE "libs/hardware.inc"	
;******************************************************************************	
; Game Boy hardware constant definitions	
; https://github.com/gbdev/hardware.inc	
;******************************************************************************	
	
; To the extent possible under law, the authors of this work have	
; waived all copyright and related or neighboring rights to the work.	
; See https://creativecommons.org/publicdomain/zero/1.0/ for details.	
; SPDX-License-Identifier: CC0-1.0	
	
; If this file was already included, don't do it again	
if !def(HARDWARE_INC)	
	
; Check for the minimum supported RGBDS version	
if !def(__RGBDS_MAJOR__) || !def(__RGBDS_MINOR__) || !def(__RGBDS_PATCH__)	
    fail "This version of 'hardware.inc' requires RGBDS version 0.5.0 or later"	
endc	
if __RGBDS_MAJOR__ == 0 && __RGBDS_MINOR__ < 5	
    fail "This version of 'hardware.inc' requires RGBDS version 0.5.0 or later."	
endc	
	
; Define the include guard and the current hardware.inc version	
; (do this after the RGBDS version check since the `def` syntax depends on it)	
def HARDWARE_INC equ 1	
def HARDWARE_INC_VERSION equs "5.3.0"	
	
; Usage: rev_Check_hardware_inc <min_ver>	
; Examples:	
;     rev_Check_hardware_inc 1.2.3	
;     rev_Check_hardware_inc 1.2   (equivalent to 1.2.0)	
;     rev_Check_hardware_inc 1     (equivalent to 1.0.0)	
MACRO rev_Check_hardware_inc	
    if _NARG == 1 ; Actual invocation by the user	
        def hw_inc_cur_ver\@ equs strrpl("{HARDWARE_INC_VERSION}", ".", ",")	
        def hw_inc_min_ver\@ equs strrpl("\1", ".", ",")	
        rev_Check_hardware_inc {hw_inc_cur_ver\@}, {hw_inc_min_ver\@}, 0, 0	
        purge hw_inc_cur_ver\@, hw_inc_min_ver\@	
    else ; Recursive invocation	
        if \1 != \4 || (\2 < \5 || (\2 == \5 && \3 < \6))	
            fail "Version \1.\2.\3 of 'hardware.inc' is incompatible with requested version \4.\5.\6"	
        endc	
    endc	
ENDM	
	
DEF _VRAM        EQU $8000 ; $8000->$9FFF	
DEF _VRAM8000    EQU _VRAM	
DEF _VRAM8800    EQU _VRAM+$800	
DEF _VRAM9000    EQU _VRAM+$1000	
DEF _SCRN0       EQU $9800 ; $9800->$9BFF	
DEF _SCRN1       EQU $9C00 ; $9C00->$9FFF	
DEF _SRAM        EQU $A000 ; $A000->$BFFF	
DEF _RAM         EQU $C000 ; $C000->$CFFF / $C000->$DFFF	
DEF _RAMBANK     EQU $D000 ; $D000->$DFFF	
DEF _OAMRAM      EQU $FE00 ; $FE00->$FE9F	
DEF _IO          EQU $FF00 ; $FF00->$FF7F,$FFFF	
DEF _AUD3WAVERAM EQU $FF30 ; $FF30->$FF3F	
DEF _HRAM        EQU $FF80 ; $FF80->$FFF	
	
;******************************************************************************	
; Memory-mapped registers ($FFxx range)	
;******************************************************************************	
	
; -- JOYP / P1 ($FF00) --------------------------------------------------------	
; Joypad face buttons	
def rJOYP equ $FF00	
	
def B_JOYP_GET_BUTTONS  equ 5 ; 0 = reading buttons     [r/w]	
def B_JOYP_GET_CTRL_PAD equ 4 ; 0 = reading Control Pad [r/w]	
    def JOYP_GET equ %00_11_0000 ; select which inputs to read from the lower nybble	
        def JOYP_GET_BUTTONS  equ %00_01_0000 ; reading A/B/Select/Start buttons	
        def JOYP_GET_CTRL_PAD equ %00_10_0000 ; reading Control Pad directions	
        def JOYP_GET_NONE     equ %00_11_0000 ; reading nothing	
	
def B_JOYP_START  equ 3 ; 0 = Start is pressed  (if reading buttons)     [ro]	
def B_JOYP_SELECT equ 2 ; 0 = Select is pressed (if reading buttons)     [ro]	
def B_JOYP_B      equ 1 ; 0 = B is pressed      (if reading buttons)     [ro]	
def B_JOYP_A      equ 0 ; 0 = A is pressed      (if reading buttons)     [ro]	
def B_JOYP_DOWN   equ 3 ; 0 = Down is pressed   (if reading Control Pad) [ro]	
def B_JOYP_UP     equ 2 ; 0 = Up is pressed     (if reading Control Pad) [ro]	
def B_JOYP_LEFT   equ 1 ; 0 = Left is pressed   (if reading Control Pad) [ro]	
def B_JOYP_RIGHT  equ 0 ; 0 = Right is pressed  (if reading Control Pad) [ro]	
    def JOYP_INPUTS equ %0000_1111 ; bits equal to 0 indicate pressed (when reading inputs)	
    def JOYP_START  equ 1 << B_JOYP_START	
    def JOYP_SELECT equ 1 << B_JOYP_SELECT	
    def JOYP_B      equ 1 << B_JOYP_B	
    def JOYP_A      equ 1 << B_JOYP_A	
    def JOYP_DOWN   equ 1 << B_JOYP_DOWN	
    def JOYP_UP     equ 1 << B_JOYP_UP	
    def JOYP_LEFT   equ 1 << B_JOYP_LEFT	
    def JOYP_RIGHT  equ 1 << B_JOYP_RIGHT	
	
; SGB command packet transfer uses for JOYP bits	
def B_JOYP_SGB_ONE  equ 5 ; 0 = sending 1 bit	
def B_JOYP_SGB_ZERO equ 4 ; 0 = sending 0 bit	
    def JOYP_SGB_START  equ %00_00_0000 ; start SGB packet transfer	
    def JOYP_SGB_ONE    equ %00_01_0000 ; send 1 bit	
    def JOYP_SGB_ZERO   equ %00_10_0000 ; send 0 bit	
    def JOYP_SGB_FINISH equ %00_11_0000 ; finish SGB packet transfer	
	
; Combined input byte, with Control Pad in high nybble (conventional order)	
def B_PAD_DOWN   equ 7	
def B_PAD_UP     equ 6	
def B_PAD_LEFT   equ 5	
def B_PAD_RIGHT  equ 4	
def B_PAD_START  equ 3	
def B_PAD_SELECT equ 2	
def B_PAD_B      equ 1	
def B_PAD_A      equ 0	
    def PAD_CTRL_PAD equ %1111_0000	
    def PAD_BUTTONS  equ %0000_1111	
    def PAD_DOWN     equ 1 << B_PAD_DOWN	
    def PAD_UP       equ 1 << B_PAD_UP	
    def PAD_LEFT     equ 1 << B_PAD_LEFT	
    def PAD_RIGHT    equ 1 << B_PAD_RIGHT	
    def PAD_START    equ 1 << B_PAD_START	
    def PAD_SELECT   equ 1 << B_PAD_SELECT	
    def PAD_B        equ 1 << B_PAD_B	
    def PAD_A        equ 1 << B_PAD_A	
	
; Combined input byte, with Control Pad in low nybble (swapped order)	
def B_PAD_SWAP_START  equ 7	
def B_PAD_SWAP_SELECT equ 6	
def B_PAD_SWAP_B      equ 5	
def B_PAD_SWAP_A      equ 4	
def B_PAD_SWAP_DOWN   equ 3	
def B_PAD_SWAP_UP     equ 2	
def B_PAD_SWAP_LEFT   equ 1	
def B_PAD_SWAP_RIGHT  equ 0	
    def PAD_SWAP_CTRL_PAD equ %0000_1111	
    def PAD_SWAP_BUTTONS  equ %1111_0000	
    def PAD_SWAP_START    equ 1 << B_PAD_SWAP_START	
    def PAD_SWAP_SELECT   equ 1 << B_PAD_SWAP_SELECT	
    def PAD_SWAP_B        equ 1 << B_PAD_SWAP_B	
    def PAD_SWAP_A        equ 1 << B_PAD_SWAP_A	
    def PAD_SWAP_DOWN     equ 1 << B_PAD_SWAP_DOWN	
    def PAD_SWAP_UP       equ 1 << B_PAD_SWAP_UP	
    def PAD_SWAP_LEFT     equ 1 << B_PAD_SWAP_LEFT	
    def PAD_SWAP_RIGHT    equ 1 << B_PAD_SWAP_RIGHT	
	
; -- SB ($FF01) ---------------------------------------------------------------	
; Serial transfer data [r/w]	
def rSB equ $FF01	
	
; -- SC ($FF02) ---------------------------------------------------------------	
; Serial transfer control	
def rSC equ $FF02	
	
def B_SC_START  equ 7 ; reading 1 = transfer in progress, writing 1 = start transfer        [r/w]	
def B_SC_SPEED  equ 1 ; (CGB only) 1 = use faster internal clock                            [r/w]	
def B_SC_SOURCE equ 0 ; 0 = use external clock ("slave"), 1 = use internal clock ("master") [r/w]	
    def SC_START  equ 1 << B_SC_START	
    def SC_SPEED  equ 1 << B_SC_SPEED	
        def SC_SLOW equ 0 << B_SC_SPEED	
        def SC_FAST equ 1 << B_SC_SPEED	
    def SC_SOURCE equ 1 << B_SC_SOURCE	
        def SC_EXTERNAL equ 0 << B_SC_SOURCE	
        def SC_INTERNAL equ 1 << B_SC_SOURCE	
	
; -- $FF03 is unused ----------------------------------------------------------	
	
; -- DIV ($FF04) --------------------------------------------------------------	
; Divider register [r/w]	
def rDIV equ $FF04	
	
; -- TIMA ($FF05) -------------------------------------------------------------	
; Timer counter [r/w]	
def rTIMA equ $FF05	
	
; -- TMA ($FF06) --------------------------------------------------------------	
; Timer modulo [r/w]	
def rTMA equ $FF06	
	
; -- TAC ($FF07) --------------------------------------------------------------	
; Timer control	
def rTAC equ $FF07	
	
def B_TAC_START equ 2 ; enable incrementing TIMA [r/w]	
    def TAC_STOP  equ 0 << B_TAC_START	
    def TAC_START equ 1 << B_TAC_START	
	
def TAC_CLOCK equ %000000_11 ; the frequency at which TIMA increments [r/w]	
    def TAC_4KHZ   equ %000000_00 ; every 256 M-cycles = ~4 KHz on DMG	
    def TAC_262KHZ equ %000000_01 ; every 4 M-cycles = ~262 KHz on DMG	
    def TAC_65KHZ  equ %000000_10 ; every 16 M-cycles = ~65 KHz on DMG	
    def TAC_16KHZ  equ %000000_11 ; every 64 M-cycles = ~16 KHz on DMG	
	
; -- $FF08-$FF0E are unused ---------------------------------------------------	
	
; -- IF ($FF0F) ---------------------------------------------------------------	
; Pending interrupts	
def rIF equ $FF0F	
	
def B_IF_JOYPAD equ 4 ; 1 = joypad interrupt is pending [r/w]	
def B_IF_SERIAL equ 3 ; 1 = serial interrupt is pending [r/w]	
def B_IF_TIMER  equ 2 ; 1 = timer  interrupt is pending [r/w]	
def B_IF_STAT   equ 1 ; 1 = STAT   interrupt is pending [r/w]	
def B_IF_VBLANK equ 0 ; 1 = VBlank interrupt is pending [r/w]	
    def IF_JOYPAD equ 1 << B_IF_JOYPAD	
    def IF_SERIAL equ 1 << B_IF_SERIAL	
    def IF_TIMER  equ 1 << B_IF_TIMER	
    def IF_STAT   equ 1 << B_IF_STAT	
    def IF_VBLANK equ 1 << B_IF_VBLANK	
	
; -- AUD1SWEEP / NR10 ($FF10) -------------------------------------------------	
; Audio channel 1 sweep	
def rAUD1SWEEP equ $FF10	
	
def AUD1SWEEP_TIME equ %0_111_0000 ; how long between sweep iterations	
                                   ; (in 128 Hz ticks, ~7.8 ms apart) [r/w]	
	
def B_AUD1SWEEP_DIR equ 3 ; sweep direction [r/w]	
    def AUD1SWEEP_DIR equ 1 << B_AUD1SWEEP_DIR	
        def AUD1SWEEP_UP   equ 0 << B_AUD1SWEEP_DIR	
        def AUD1SWEEP_DOWN equ 1 << B_AUD1SWEEP_DIR	
	
def AUD1SWEEP_SHIFT equ %00000_111 ; how much the period increases/decreases per iteration [r/w]	
	
; -- AUD1LEN / NR11 ($FF11) ---------------------------------------------------	
; Audio channel 1 length timer and duty cycle	
def rAUD1LEN equ $FF11	
	
def AUD1LEN_DUTY equ %11_000000 ; ratio of time spent high vs. time spent low [r/w]	
    def AUD1LEN_DUTY_12_5 equ %00_000000 ; 12.5%	
    def AUD1LEN_DUTY_25   equ %01_000000 ; 25%	
    def AUD1LEN_DUTY_50   equ %10_000000 ; 50%	
    def AUD1LEN_DUTY_75   equ %11_000000 ; 75%	
	
def AUD1LEN_TIMER equ %00_111111 ; initial length timer (0-63) [wo]	
	
; -- AUD1ENV / NR12 ($FF12) ---------------------------------------------------	
; Audio channel 1 volume and envelope	
def rAUD1ENV equ $FF12	
	
def AUD1ENV_INIT_VOLUME equ %1111_0000 ; initial volume [r/w]	
	
def B_AUD1ENV_DIR equ 3 ; direction of volume envelope [r/w]	
    def AUD1ENV_DIR equ 1 << B_AUD1ENV_DIR	
        def AUD1ENV_DOWN equ 0 << B_AUD1ENV_DIR	
        def AUD1ENV_UP   equ 1 << B_AUD1ENV_DIR	
	
def AUD1ENV_PACE equ %00000_111 ; how long between envelope iterations	
                                ; (in 64 Hz ticks, ~15.6 ms apart) [r/w]	
	
; -- AUD1LOW / NR13 ($FF13) ---------------------------------------------------	
; Audio channel 1 period (low 8 bits) [wo]	
def rAUD1LOW equ $FF13	
	
; -- AUD1HIGH / NR14 ($FF14) --------------------------------------------------	
; Audio channel 1 period (high 3 bits) and control	
def rAUD1HIGH equ $FF14	
	
def B_AUD1HIGH_RESTART    equ 7 ; 1 = restart the channel [wo]	
def B_AUD1HIGH_LEN_ENABLE equ 6 ; 1 = reset the channel after the length timer expires [r/w]	
    def AUD1HIGH_RESTART    equ 1 << B_AUD1HIGH_RESTART	
    def AUD1HIGH_LENGTH_OFF equ 0 << B_AUD1HIGH_LEN_ENABLE	
    def AUD1HIGH_LENGTH_ON  equ 1 << B_AUD1HIGH_LEN_ENABLE	
	
def AUD1HIGH_PERIOD_HIGH equ %00000_111 ; upper 3 bits of the channel's period [r/w]	
	
; -- $FF15 is unused ----------------------------------------------------------	
	
; -- AUD2LEN / NR21 ($FF16) ---------------------------------------------------	
; Audio channel 2 length timer and duty cycle	
def rAUD2LEN equ $FF16	
	
def AUD2LEN_DUTY equ %11_000000 ; ratio of time spent high vs. time spent low [r/w]	
    def AUD2LEN_DUTY_12_5 equ %00_000000 ; 12.5%	
    def AUD2LEN_DUTY_25   equ %01_000000 ; 25%	
    def AUD2LEN_DUTY_50   equ %10_000000 ; 50%	
    def AUD2LEN_DUTY_75   equ %11_000000 ; 75%	
	
def AUD2LEN_TIMER equ %00_111111 ; initial length timer (0-63) [wo]	
	
; -- AUD2ENV / NR22 ($FF17) ---------------------------------------------------	
; Audio channel 2 volume and envelope	
def rAUD2ENV equ $FF17	
	
def AUD2ENV_INIT_VOLUME equ %1111_0000 ; initial volume [r/w]	
	
def B_AUD2ENV_DIR equ 3 ; direction of volume envelope [r/w]	
    def AUD2ENV_DIR equ 1 << B_AUD2ENV_DIR	
        def AUD2ENV_DOWN equ 0 << B_AUD2ENV_DIR	
        def AUD2ENV_UP   equ 1 << B_AUD2ENV_DIR	
	
def AUD2ENV_PACE equ %00000_111 ; how long between envelope iterations	
                                ; (in 64 Hz ticks, ~15.6 ms apart) [r/w]	
	
; -- AUD2LOW / NR23 ($FF18) ---------------------------------------------------	
; Audio channel 2 period (low 8 bits) [wo]	
def rAUD2LOW equ $FF18	
	
; -- AUD2HIGH / NR24 ($FF19) --------------------------------------------------	
; Audio channel 2 period (high 3 bits) and control	
def rAUD2HIGH equ $FF19	
	
def B_AUD2HIGH_RESTART    equ 7 ; 1 = restart the channel [wo]	
def B_AUD2HIGH_LEN_ENABLE equ 6 ; 1 = reset the channel after the length timer expires [r/w]	
    def AUD2HIGH_RESTART    equ 1 << B_AUD2HIGH_RESTART	
    def AUD2HIGH_LENGTH_OFF equ 0 << B_AUD2HIGH_LEN_ENABLE	
    def AUD2HIGH_LENGTH_ON  equ 1 << B_AUD2HIGH_LEN_ENABLE	
	
def AUD2HIGH_PERIOD_HIGH equ %00000_111 ; upper 3 bits of the channel's period [r/w]	
	
; -- AUD3ENA / NR30 ($FF1A) ---------------------------------------------------	
; Audio channel 3 enable	
def rAUD3ENA equ $FF1A	
	
def B_AUD3ENA_ENABLE equ 7 ; 1 = channel is active [r/w]	
    def AUD3ENA_OFF equ 0 << B_AUD3ENA_ENABLE	
    def AUD3ENA_ON  equ 1 << B_AUD3ENA_ENABLE	
	
; -- AUD3LEN / NR31 ($FF1B) ---------------------------------------------------	
; Audio channel 3 length timer [wo]	
def rAUD3LEN equ $FF1B	
	
; -- AUD3LEVEL / NR32 ($FF1C) -------------------------------------------------	
; Audio channel 3 volume	
def rAUD3LEVEL equ $FF1C	
	
def AUD3LEVEL_VOLUME equ %0_11_00000 ; volume level [r/w]	
    def AUD3LEVEL_MUTE equ %0_00_00000 ; 0% (muted)	
    def AUD3LEVEL_100  equ %0_01_00000 ; 100%	
    def AUD3LEVEL_50   equ %0_10_00000 ; 50%	
    def AUD3LEVEL_25   equ %0_11_00000 ; 25%	
	
; -- AUD3LOW / NR33 ($FF1D) ---------------------------------------------------	
; Audio channel 3 period (low 8 bits) [wo]	
def rAUD3LOW equ $FF1D	
	
; -- AUD3HIGH / NR34 ($FF1E) --------------------------------------------------	
; Audio channel 3 period (high 3 bits) and control	
def rAUD3HIGH equ $FF1E	
	
def B_AUD3HIGH_RESTART    equ 7 ; 1 = restart the channel [wo]	
def B_AUD3HIGH_LEN_ENABLE equ 6 ; 1 = reset the channel after the length timer expires [r/w]	
    def AUD3HIGH_RESTART    equ 1 << B_AUD3HIGH_RESTART	
    def AUD3HIGH_LENGTH_OFF equ 0 << B_AUD3HIGH_LEN_ENABLE	
    def AUD3HIGH_LENGTH_ON  equ 1 << B_AUD3HIGH_LEN_ENABLE	
	
def AUD3HIGH_PERIOD_HIGH equ %00000_111 ; upper 3 bits of the channel's period [r/w]	
	
; -- $FF1F is unused ----------------------------------------------------------	
	
; -- AUD4LEN / NR41 ($FF20) ---------------------------------------------------	
; Audio channel 4 length timer	
def rAUD4LEN equ $FF20	
	
def AUD4LEN_TIMER equ %00_111111 ; initial length timer (0-63) [wo]	
	
; -- AUD4ENV / NR42 ($FF21) ---------------------------------------------------	
; Audio channel 4 volume and envelope	
def rAUD4ENV equ $FF21	
	
def AUD4ENV_INIT_VOLUME equ %1111_0000 ; initial volume [r/w]	
	
def B_AUD4ENV_DIR equ 3 ; direction of volume envelope [r/w]	
    def AUD4ENV_DIR equ 1 << B_AUD4ENV_DIR	
        def AUD4ENV_DOWN equ 0 << B_AUD4ENV_DIR	
        def AUD4ENV_UP   equ 1 << B_AUD4ENV_DIR	
	
def AUD4ENV_PACE equ %00000_111 ; how long between envelope iterations	
                                ; (in 64 Hz ticks, ~15.6 ms apart) [r/w]	
	
; -- AUD4POLY / NR43 ($FF22) --------------------------------------------------	
; Audio channel 4 period and randomness	
def rAUD4POLY equ $FF22	
	
def AUD4POLY_SHIFT equ %1111_0000 ; coarse control of the channel's period [r/w]	
	
def B_AUD4POLY_WIDTH equ 3 ; controls the noise generator (LFSR)'s step width [r/w]	
    def AUD4POLY_15STEP equ 0 << B_AUD4POLY_WIDTH	
    def AUD4POLY_7STEP  equ 1 << B_AUD4POLY_WIDTH	
	
def AUD4POLY_DIV equ %00000_111 ; fine control of the channel's period [r/w]	
	
; -- AUD4GO / NR44 ($FF23) ----------------------------------------------------	
; Audio channel 4 control	
def rAUD4GO equ $FF23	
	
def B_AUD4GO_RESTART    equ 7 ; 1 = restart the channel [wo]	
def B_AUD4GO_LEN_ENABLE equ 6 ; 1 = reset the channel after the length timer expires [r/w]	
    def AUD4GO_RESTART    equ 1 << B_AUD4GO_RESTART	
    def AUD4GO_LENGTH_OFF equ 0 << B_AUD4GO_LEN_ENABLE	
    def AUD4GO_LENGTH_ON  equ 1 << B_AUD4GO_LEN_ENABLE	
	
; -- AUDVOL / NR50 ($FF24) ----------------------------------------------------	
; Audio master volume and VIN mixer	
def rAUDVOL equ $FF24	
	
def B_AUDVOL_VIN_LEFT  equ 7 ; 1 = output VIN to left ear (SO2, speaker 2) [r/w]	
    def AUDVOL_VIN_LEFT equ 1 << B_AUDVOL_VIN_LEFT	
	
def AUDVOL_LEFT equ %0_111_0000 ; 0 = barely audible, 7 = full volume [r/w]	
	
def B_AUDVOL_VIN_RIGHT equ 3 ; 1 = output VIN to right ear (SO1, speaker 1) [r/w]	
    def AUDVOL_VIN_RIGHT equ 1 << B_AUDVOL_VIN_RIGHT	
	
def AUDVOL_RIGHT equ %00000_111 ; 0 = barely audible, 7 = full volume [r/w]	
	
; -- AUDTERM / NR51 ($FF25) ---------------------------------------------------	
; Audio channel mixer	
def rAUDTERM equ $FF25	
	
def B_AUDTERM_4_LEFT  equ 7 ; 1 = output channel 4 to left  ear [r/w]	
def B_AUDTERM_3_LEFT  equ 6 ; 1 = output channel 3 to left  ear [r/w]	
def B_AUDTERM_2_LEFT  equ 5 ; 1 = output channel 2 to left  ear [r/w]	
def B_AUDTERM_1_LEFT  equ 4 ; 1 = output channel 1 to left  ear [r/w]	
def B_AUDTERM_4_RIGHT equ 3 ; 1 = output channel 4 to right ear [r/w]	
def B_AUDTERM_3_RIGHT equ 2 ; 1 = output channel 3 to right ear [r/w]	
def B_AUDTERM_2_RIGHT equ 1 ; 1 = output channel 2 to right ear [r/w]	
def B_AUDTERM_1_RIGHT equ 0 ; 1 = output channel 1 to right ear [r/w]	
    def AUDTERM_4_LEFT  equ 1 << B_AUDTERM_4_LEFT	
    def AUDTERM_3_LEFT  equ 1 << B_AUDTERM_3_LEFT	
    def AUDTERM_2_LEFT  equ 1 << B_AUDTERM_2_LEFT	
    def AUDTERM_1_LEFT  equ 1 << B_AUDTERM_1_LEFT	
    def AUDTERM_4_RIGHT equ 1 << B_AUDTERM_4_RIGHT	
    def AUDTERM_3_RIGHT equ 1 << B_AUDTERM_3_RIGHT	
    def AUDTERM_2_RIGHT equ 1 << B_AUDTERM_2_RIGHT	
    def AUDTERM_1_RIGHT equ 1 << B_AUDTERM_1_RIGHT	
	
; -- AUDENA / NR52 ($FF26) ----------------------------------------------------	
; Audio master enable	
def rAUDENA equ $FF26	
	
def B_AUDENA_ENABLE     equ 7 ; 0 = disable the APU (resets all audio registers to 0!) [r/w]	
def B_AUDENA_ENABLE_CH4 equ 3 ; 1 = channel 4 is running [ro]	
def B_AUDENA_ENABLE_CH3 equ 2 ; 1 = channel 3 is running [ro]	
def B_AUDENA_ENABLE_CH2 equ 1 ; 1 = channel 2 is running [ro]	
def B_AUDENA_ENABLE_CH1 equ 0 ; 1 = channel 1 is running [ro]	
    def AUDENA_OFF     equ 0 << B_AUDENA_ENABLE	
    def AUDENA_ON      equ 1 << B_AUDENA_ENABLE	
    def AUDENA_CH4_OFF equ 0 << B_AUDENA_ENABLE_CH4	
    def AUDENA_CH4_ON  equ 1 << B_AUDENA_ENABLE_CH4	
    def AUDENA_CH3_OFF equ 0 << B_AUDENA_ENABLE_CH3	
    def AUDENA_CH3_ON  equ 1 << B_AUDENA_ENABLE_CH3	
    def AUDENA_CH2_OFF equ 0 << B_AUDENA_ENABLE_CH2	
    def AUDENA_CH2_ON  equ 1 << B_AUDENA_ENABLE_CH2	
    def AUDENA_CH1_OFF equ 0 << B_AUDENA_ENABLE_CH1	
    def AUDENA_CH1_ON  equ 1 << B_AUDENA_ENABLE_CH1	
	
; -- $FF27-$FF2F are unused ---------------------------------------------------	
	
; -- AUD3WAVE ($FF30-$FF3F) ---------------------------------------------------	
; Audio channel 3 wave pattern RAM [r/w]	
def rAUD3WAVE_0 equ $FF30	
def rAUD3WAVE_1 equ $FF31	
def rAUD3WAVE_2 equ $FF32	
def rAUD3WAVE_3 equ $FF33	
def rAUD3WAVE_4 equ $FF34	
def rAUD3WAVE_5 equ $FF35	
def rAUD3WAVE_6 equ $FF36	
def rAUD3WAVE_7 equ $FF37	
def rAUD3WAVE_8 equ $FF38	
def rAUD3WAVE_9 equ $FF39	
def rAUD3WAVE_A equ $FF3A	
def rAUD3WAVE_B equ $FF3B	
def rAUD3WAVE_C equ $FF3C	
def rAUD3WAVE_D equ $FF3D	
def rAUD3WAVE_E equ $FF3E	
def rAUD3WAVE_F equ $FF3F	
	
; -- LCDC ($FF40) -------------------------------------------------------------	
; PPU graphics control	
def rLCDC equ $FF40	
	
def B_LCDC_ENABLE   equ 7 ; whether the PPU (and LCD) are turned on          [r/w]	
def B_LCDC_WIN_MAP  equ 6 ; which tilemap the Window reads from              [r/w]	
def B_LCDC_WINDOW   equ 5 ; whether the Window is enabled                    [r/w]	
def B_LCDC_BLOCKS   equ 4 ; which "tile blocks" the BG and Window use        [r/w]	
def B_LCDC_BG_MAP   equ 3 ; which tilemap the BG reads from                  [r/w]	
def B_LCDC_OBJ_SIZE equ 2 ; how many pixels tall each OBJ is                 [r/w]	
def B_LCDC_OBJS     equ 1 ; whether OBJs are enabled                         [r/w]	
def B_LCDC_BG       equ 0 ; (DMG only) whether the BG is enabled             [r/w]	
def B_LCDC_PRIO     equ 0 ; (CGB only) whether OBJ priority bits are enabled [r/w]	
    def LCDC_ENABLE   equ 1 << B_LCDC_ENABLE	
        def LCDC_OFF equ 0 << B_LCDC_ENABLE	
        def LCDC_ON  equ 1 << B_LCDC_ENABLE	
    def LCDC_WIN_MAP  equ 1 << B_LCDC_WIN_MAP	
        def LCDC_WIN_9800 equ 0 << B_LCDC_WIN_MAP	
        def LCDC_WIN_9C00 equ 1 << B_LCDC_WIN_MAP	
    def LCDC_WINDOW   equ 1 << B_LCDC_WINDOW	
        def LCDC_WIN_OFF equ 0 << B_LCDC_WINDOW	
        def LCDC_WIN_ON  equ 1 << B_LCDC_WINDOW	
    def LCDC_BLOCKS   equ 1 << B_LCDC_BLOCKS	
        def LCDC_BLOCK21 equ 0 << B_LCDC_BLOCKS	
        def LCDC_BLOCK01 equ 1 << B_LCDC_BLOCKS	
    def LCDC_BG_MAP   equ 1 << B_LCDC_BG_MAP	
        def LCDC_BG_9800 equ 0 << B_LCDC_BG_MAP	
        def LCDC_BG_9C00 equ 1 << B_LCDC_BG_MAP	
    def LCDC_OBJ_SIZE equ 1 << B_LCDC_OBJ_SIZE	
        def LCDC_OBJ_8  equ 0 << B_LCDC_OBJ_SIZE	
        def LCDC_OBJ_16 equ 1 << B_LCDC_OBJ_SIZE	
    def LCDC_OBJS     equ 1 << B_LCDC_OBJS	
        def LCDC_OBJ_OFF equ 0 << B_LCDC_OBJS	
        def LCDC_OBJ_ON  equ 1 << B_LCDC_OBJS	
    def LCDC_BG       equ 1 << B_LCDC_BG	
        def LCDC_BG_OFF equ 0 << B_LCDC_BG	
        def LCDC_BG_ON  equ 1 << B_LCDC_BG	
    def LCDC_PRIO     equ 1 << B_LCDC_PRIO	
        def LCDC_PRIO_OFF equ 0 << B_LCDC_PRIO	
        def LCDC_PRIO_ON  equ 1 << B_LCDC_PRIO	
	
; -- STAT ($FF41) -------------------------------------------------------------	
; Graphics status and interrupt control	
def rSTAT equ $FF41	
	
def B_STAT_LYC    equ 6 ; 1 = LY match triggers the STAT interrupt [r/w]	
def B_STAT_MODE_2 equ 5 ; 1 = OAM Scan triggers the PPU interrupt  [r/w]	
def B_STAT_MODE_1 equ 4 ; 1 = VBlank triggers the PPU interrupt    [r/w]	
def B_STAT_MODE_0 equ 3 ; 1 = HBlank triggers the PPU interrupt    [r/w]	
def B_STAT_LYCF   equ 2 ; 1 = LY is currently equal to LYC         [ro]	
def B_STAT_BUSY   equ 1 ; 1 = the PPU is currently accessing VRAM  [ro]	
    def STAT_LYC    equ 1 << B_STAT_LYC	
    def STAT_MODE_2 equ 1 << B_STAT_MODE_2	
    def STAT_MODE_1 equ 1 << B_STAT_MODE_1	
    def STAT_MODE_0 equ 1 << B_STAT_MODE_0	
    def STAT_LYCF   equ 1 << B_STAT_LYCF	
    def STAT_BUSY   equ 1 << B_STAT_BUSY	
	
def STAT_MODE equ %000000_11 ; PPU's current status [ro]	
    def STAT_HBLANK equ %000000_00 ; waiting after a line's rendering (HBlank)	
    def STAT_VBLANK equ %000000_01 ; waiting between frames (VBlank)	
    def STAT_OAM    equ %000000_10 ; checking which OBJs will be rendered on this line (OAM scan)	
    def STAT_LCD    equ %000000_11 ; pushing pixels to the LCD	
	
; -- SCY ($FF42) --------------------------------------------------------------	
; Background Y scroll offset (in pixels) [r/w]	
def rSCY equ $FF42	
	
; -- SCX ($FF43) --------------------------------------------------------------	
; Background X scroll offset (in pixels) [r/w]	
def rSCX equ $FF43	
	
; -- LY ($FF44) ---------------------------------------------------------------	
; Y coordinate of the line currently processed by the PPU (0-153) [ro]	
def rLY equ $FF44	
	
def LY_VBLANK equ 144 ; 144-153 is the VBlank period	
	
; -- LYC ($FF45) --------------------------------------------------------------	
; Value that LY is constantly compared to [r/w]	
def rLYC equ $FF45	
	
; -- DMA ($FF46) --------------------------------------------------------------	
; OAM DMA start address (high 8 bits) and start [wo]	
def rDMA equ $FF46	
	
; -- BGP ($FF47) --------------------------------------------------------------	
; (DMG only) Background color mapping [r/w]	
def rBGP equ $FF47	
	
def BGP_SGB_TRANSFER equ %11_10_01_00 ; set BGP to this value before SGB VRAM transfer	
	
; -- OBP0 ($FF48) -------------------------------------------------------------	
; (DMG only) OBJ color mapping #0 [r/w]	
def rOBP0 equ $FF48	
	
; -- OBP1 ($FF49) -------------------------------------------------------------	
; (DMG only) OBJ color mapping #1 [r/w]	
def rOBP1 equ $FF49	
	
; -- WY ($FF4A) ---------------------------------------------------------------	
; Y coordinate of the Window's top-left pixel (0-143) [r/w]	
def rWY equ $FF4A	
	
; -- WX ($FF4B) ---------------------------------------------------------------	
; X coordinate of the Window's top-left pixel, plus 7 (7-166) [r/w]	
def rWX equ $FF4B	
	
def WX_OFS equ 7 ; subtract this to get the actual Window X coordinate	
	
; -- SYS / KEY0 ($FF4C) -------------------------------------------------------	
; (CGB boot ROM only) CPU mode select	
def rSYS equ $FF4C	
	
; This is known as the "CPU mode register" in Fig. 11 of this patent:	
; https://patents.google.com/patent/US6322447B1/en?oq=US6322447bi	
; "OBJ priority mode designating register" in the same patent	
; Credit to @mattcurrie for this finding!	
	
def SYS_MODE equ %0000_11_00 ; current system mode [r/w]	
    def SYS_CGB  equ %0000_00_00 ; CGB mode	
    def SYS_DMG  equ %0000_01_00 ; DMG compatibility mode	
    def SYS_PGB1 equ %0000_10_00 ; LCD is driven externally, CPU is stopped	
    def SYS_PGB2 equ %0000_11_00 ; LCD is driven externally, CPU is running	
	
; -- SPD / KEY1 ($FF4D) -------------------------------------------------------	
; (CGB only) Double-speed mode control	
def rSPD equ $FF4D	
	
def B_SPD_DOUBLE  equ 7 ; current clock speed                                  [ro]	
def B_SPD_PREPARE equ 0 ; 1 = next `stop` instruction will switch clock speeds [r/w]	
    def SPD_SINGLE  equ 0 << B_SPD_DOUBLE	
    def SPD_DOUBLE  equ 1 << B_SPD_DOUBLE	
    def SPD_PREPARE equ 1 << B_SPD_PREPARE	
	
; -- $FF4E is unused ----------------------------------------------------------	
	
; -- VBK ($FF4F) --------------------------------------------------------------	
; (CGB only) VRAM bank number (0 or 1)	
def rVBK equ $FF4F	
	
def VBK_BANK equ %0000000_1 ; mapped VRAM bank [r/w]	
	
; -- BANK ($FF50) -------------------------------------------------------------	
; (boot ROM only) Boot ROM mapping control	
def rBANK equ $FF50	
	
def B_BANK_ON equ 0 ; whether the boot ROM is mapped [wo]	
    def BANK_ON  equ 0 << B_BANK_ON	
    def BANK_OFF equ 1 << B_BANK_ON	
	
; -- VDMA_SRC_HIGH / HDMA1 ($FF51) --------------------------------------------	
; (CGB only) VRAM DMA source address (high 8 bits) [wo]	
def rVDMA_SRC_HIGH equ $FF51	
	
; -- VDMA_SRC_LOW / HDMA2 ($FF52) ---------------------------------------------	
; (CGB only) VRAM DMA source address (low 8 bits) [wo]	
def rVDMA_SRC_LOW equ $FF52	
	
; -- VDMA_DEST_HIGH / HDMA3 ($FF53) -------------------------------------------	
; (CGB only) VRAM DMA destination address (high 8 bits) [wo]	
def rVDMA_DEST_HIGH equ $FF53	
	
; -- VDMA_DEST_LOW / HDMA4 ($FF54) --------------------------------------------	
; (CGB only) VRAM DMA destination address (low 8 bits) [wo]	
def rVDMA_DEST_LOW equ $FF54	
	
; -- VDMA_LEN / HDMA5 ($FF55) -------------------------------------------------	
; (CGB only) VRAM DMA length, mode, and start	
def rVDMA_LEN equ $FF55	
	
def B_VDMA_LEN_MODE equ 7 ; on write: VRAM DMA mode [wo]	
    def VDMA_LEN_MODE equ 1 << B_VDMA_LEN_MODE	
        def VDMA_LEN_MODE_GENERAL equ 0 << B_VDMA_LEN_MODE ; GDMA (general-purpose)	
        def VDMA_LEN_MODE_HBLANK  equ 1 << B_VDMA_LEN_MODE ; HDMA (HBlank)	
	
def B_VDMA_LEN_BUSY equ 7 ; on read: is a VRAM DMA active?	
    def VDMA_LEN_BUSY equ 1 << B_VDMA_LEN_BUSY	
        def VDMA_LEN_NO  equ 0 << B_VDMA_LEN_BUSY	
        def VDMA_LEN_YES equ 1 << B_VDMA_LEN_BUSY	
	
def VDMA_LEN_SIZE equ %0_1111111 ; how many 16-byte blocks (minus 1) to transfer [r/w]	
	
; -- RP ($FF56) ---------------------------------------------------------------	
; (CGB only) Infrared communications port	
def rRP equ $FF56	
	
def RP_READ equ %11_000000 ; whether the IR read is enabled [r/w]	
    def RP_DISABLE equ %00_000000	
    def RP_ENABLE  equ %11_000000	
	
def B_RP_DATA_IN equ 1 ; 0 = IR light is being received [ro]	
def B_RP_LED_ON  equ 0 ; 1 = IR light is being sent     [r/w]	
    def RP_DATA_IN equ 1 << B_RP_DATA_IN	
    def RP_LED_ON  equ 1 << B_RP_LED_ON	
        def RP_WRITE_LOW  equ 0 << B_RP_LED_ON	
        def RP_WRITE_HIGH equ 1 << B_RP_LED_ON	
	
; -- $FF57-$FF67 are unused ---------------------------------------------------	
	
; -- BGPI / BCPS ($FF68) ------------------------------------------------------	
; (CGB only) Background palette I/O index	
def rBGPI equ $FF68	
	
def B_BGPI_AUTOINC equ 7 ; whether the index field is incremented after each write to BCPD [r/w]	
    def BGPI_AUTOINC equ 1 << B_BGPI_AUTOINC	
	
def BGPI_INDEX equ %00_111111 ; the index within Palette RAM accessed via BCPD [r/w]	
	
; -- BGPD / BCPD ($FF69) ------------------------------------------------------	
; (CGB only) Background palette I/O access [r/w]	
def rBGPD equ $FF69	
	
; -- OBPI / OCPS ($FF6A) ------------------------------------------------------	
; (CGB only) OBJ palette I/O index	
def rOBPI equ $FF6A	
	
def B_OBPI_AUTOINC equ 7 ; whether the index field is incremented after each write to OBPD [r/w]	
    def OBPI_AUTOINC equ 1 << B_OBPI_AUTOINC	
	
def OBPI_INDEX equ %00_111111 ; the index within Palette RAM accessed via OBPD [r/w]	
	
; -- OBPD / OCPD ($FF6B) ------------------------------------------------------	
; (CGB only) OBJ palette I/O access [r/w]	
def rOBPD equ $FF6B	
	
; -- OPRI ($FF6C) -------------------------------------------------------------	
; (CGB boot ROM only) OBJ draw priority mode	
def rOPRI equ $FF6C	
	
def B_OPRI_PRIORITY equ 0 ; which drawing priority is used for OBJs [r/w]	
    def OPRI_PRIORITY equ 1 << B_OPRI_PRIORITY	
        def OPRI_OAM   equ 0 << B_OPRI_PRIORITY ; CGB mode default: earliest OBJ in OAM wins	
        def OPRI_COORD equ 1 << B_OPRI_PRIORITY ; DMG mode default: leftmost OBJ wins	
	
; -- $FF6D-$FF6F are unused ---------------------------------------------------	
	
; -- WBK / SVBK ($FF70) -------------------------------------------------------	
; (CGB only) WRAM bank number	
def rWBK equ $FF70	
	
def WBK_BANK equ %00000_111 ; mapped WRAM bank (0-7) [r/w]	
	
; -- $FF71-$FF75 are unused ---------------------------------------------------	
	
; -- PCM12 ($FF76) ------------------------------------------------------------	
; Audio channels 1 and 2 output	
def rPCM12 equ $FF76	
	
def PCM12_CH2 equ %1111_0000 ; audio channel 2 output [ro]	
def PCM12_CH1 equ %0000_1111 ; audio channel 1 output [ro]	
	
; -- PCM34 ($FF77) ------------------------------------------------------------	
; Audio channels 3 and 4 output	
def rPCM34 equ $FF77	
	
def PCM34_CH4 equ %1111_0000 ; audio channel 4 output [ro]	
def PCM34_CH3 equ %0000_1111 ; audio channel 3 output [ro]	
	
; -- $FF78-$FF7F are unused ---------------------------------------------------	
	
; -- IE ($FFFF) ---------------------------------------------------------------	
; Interrupt enable	
def rIE equ $FFFF	
	
def B_IE_JOYPAD equ 4 ; 1 = joypad interrupt is enabled [r/w]	
def B_IE_SERIAL equ 3 ; 1 = serial interrupt is enabled [r/w]	
def B_IE_TIMER  equ 2 ; 1 = timer  interrupt is enabled [r/w]	
def B_IE_STAT   equ 1 ; 1 = STAT   interrupt is enabled [r/w]	
def B_IE_VBLANK equ 0 ; 1 = VBlank interrupt is enabled [r/w]	
    def IE_JOYPAD equ 1 << B_IE_JOYPAD	
    def IE_SERIAL equ 1 << B_IE_SERIAL	
    def IE_TIMER  equ 1 << B_IE_TIMER	
    def IE_STAT   equ 1 << B_IE_STAT	
    def IE_VBLANK equ 1 << B_IE_VBLANK	
	
	
;******************************************************************************	
; Cartridge registers (MBC)	
;******************************************************************************	
	
; Note that these "registers" are each actually accessible at an entire address range;	
; however, one address for each of these ranges is considered the "canonical" one, and	
; these addresses are what's provided here.	
	
	
; ** Common to most MBCs ******************************************************	
	
; -- RAMG ($0000-$1FFF) -------------------------------------------------------	
; Whether SRAM can be accessed [wo]	
def rRAMG equ $0000	
	
; Common values (not for HuC1 or HuC-3)	
def RAMG_SRAM_DISABLE equ $00	
def RAMG_SRAM_ENABLE  equ $0A ; some MBCs accept any value whose low nybble is $A	
	
; (HuC-3 only) switch SRAM to map cartridge RAM, RTC, or IR	
def RAMG_CART_RAM_RO   equ $00 ; select cartridge RAM [ro]	
def RAMG_CART_RAM      equ $0A ; select cartridge RAM [r/w]	
def RAMG_RTC_IN        equ $0B ; select RTC command/argument [wo]	
    def RAMG_RTC_IN_CMD equ %0_111_0000 ; command	
    def RAMG_RTC_IN_ARG equ %0_000_1111 ; argument	
def RAMG_RTC_OUT       equ $0C ; select RTC command/response [ro]	
    def RAMG_RTC_OUT_CMD    equ %0_111_0000 ; command	
    def RAMG_RTC_OUT_RESULT equ %0_000_1111 ; result	
def RAMG_RTC_SEMAPHORE equ $0D ; select RTC semaphore [r/w]	
def RAMG_IR            equ $0E ; (HuC1 and HuC-3 only) select IR [r/w]	
	
; -- ROMB ($2000-$3FFF) -------------------------------------------------------	
; ROM bank number (not for MBC5 or MBC6) [wo]	
def rROMB equ $2000	
	
; -- RAMB ($4000-$5FFF) -------------------------------------------------------	
; SRAM bank number (not for MBC2, MBC6, or MBC7) [wo]	
def rRAMB equ $4000	
	
; (MBC3 only) Special RAM bank numbers that actually map values into RTCREG	
def RAMB_RTC_S  equ $08 ; seconds counter (0-59)	
def RAMB_RTC_M  equ $09 ; minutes counter (0-59)	
def RAMB_RTC_H  equ $0A ; hours counter (0-23)	
def RAMB_RTC_DL equ $0B ; days counter, low byte (0-255)	
def RAMB_RTC_DH equ $0C ; days counter, high bit and other flags	
    def B_RAMB_RTC_DH_CARRY equ 7 ; 1 = days counter overflowed    [wo]	
    def B_RAMB_RTC_DH_HALT  equ 6 ; 0 = run timer, 1 = stop timer  [wo]	
    def B_RAMB_RTC_DH_HIGH  equ 0 ; days counter, high bit (bit 8) [wo]	
        def RAMB_RTC_DH_CARRY equ 1 << B_RAMB_RTC_DH_CARRY	
        def RAMB_RTC_DH_HALT  equ 1 << B_RAMB_RTC_DH_HALT	
        def RAMB_RTC_DH_HIGH  equ 1 << B_RAMB_RTC_DH_HIGH	
	
def B_RAMB_RUMBLE equ 3 ; (MBC5 and MBC7 only) enable the rumble motor (if any)	
    def RAMB_RUMBLE equ 1 << B_RAMB_RUMBLE	
        def RAMB_RUMBLE_OFF equ 0 << B_RAMB_RUMBLE	
        def RAMB_RUMBLE_ON  equ 1 << B_RAMB_RUMBLE	
	
	
; ** MBC1 and MMM01 only ******************************************************	
	
; -- BMODE ($6000-$7FFF) ------------------------------------------------------	
; Banking mode select [wo]	
def rBMODE equ $6000	
	
def BMODE_SIMPLE   equ $00 ; locks ROMB and RAMB to bank 0	
def BMODE_ADVANCED equ $01 ; allows bank-switching with RAMB	
	
	
; ** MBC2 only ****************************************************************	
	
; -- ROM2B ($0000-$3FFF with bit 8 set) ---------------------------------------	
; ROM bank number [wo]	
def rROM2B equ $2100	
	
	
; ** MBC3 only ****************************************************************	
	
; -- RTCLATCH ($6000-$7FFF) ---------------------------------------------------	
; RTC latch clock data [wo]	
def rRTCLATCH equ $6000	
	
; Write $00 then $01 to latch the current time into RTCREG	
def RTCLATCH_START  equ $00	
def RTCLATCH_FINISH equ $01	
	
; -- RTCREG ($A000-$BFFF) -----------------------------------------------------	
; RTC register [r/w]	
def rRTCREG equ $A000	
	
	
; ** MBC5 only ****************************************************************	
	
; -- ROMB0 ($2000-$2FFF) ------------------------------------------------------	
; ROM bank number low byte (bits 0-7) [wo]	
def rROMB0 equ $2000	
	
; -- ROMB1 ($3000-$3FFF) ------------------------------------------------------	
; ROM bank number high bit (bit 8) [wo]	
def rROMB1 equ $3000	
	
	
; ** MBC6 only ****************************************************************	
	
; -- RAMBA ($0400-$07FF) ------------------------------------------------------	
; RAM bank A number [wo]	
def rRAMBA equ $0400	
	
; -- RAMBB ($0800-$0BFF) ------------------------------------------------------	
; RAM bank B number [wo]	
def rRAMBB equ $0800	
	
; -- FLASH ($0C00-$0FFF) ------------------------------------------------------	
; Whether the flash chip can be accessed [wo]	
def rFLASH equ $0C00	
	
; -- FMODE ($1000) ------------------------------------------------------------	
; Write mode select for the flash chip	
def rFMODE equ $1000	
	
; -- ROMBA ($2000-$27FF) ------------------------------------------------------	
; ROM/Flash bank A number [wo]	
def rROMBA equ $2000	
	
; -- FLASHA ($2800-$2FFF) -----------------------------------------------------	
; ROM/Flash bank A select [wo]	
def rFLASHA equ $2800	
	
; -- ROMBB ($3000-$37FF) ------------------------------------------------------	
; ROM/Flash bank B number [wo]	
def rROMBB equ $3000	
	
; -- FLASHB ($3800-$3FFF) -----------------------------------------------------	
; ROM/Flash bank B select [wo]	
def rFLASHB equ $3800	
	
	
; ** MBC7 only ****************************************************************	
	
; -- RAMREG ($4000-$5FFF) -----------------------------------------------------	
; Enable RAM register access [wo]	
def rRAMREG equ $4000	
	
def RAMREG_ENABLE equ $40	
	
; -- ACCLATCH0 ($Ax0x) --------------------------------------------------------	
; Latch accelerometer start [wo]	
def rACCLATCH0 equ $A000	
	
; Write $55 to ACCLATCH0 to erase the latched data	
def ACCLATCH0_START equ $55	
	
; -- ACCLATCH1 ($Ax1x) --------------------------------------------------------	
; Latch accelerometer finish [wo]	
def rACCLATCH1 equ $A010	
	
; Write $AA to ACCLATCH1 to latch the accelerometer and update ACCEL*	
def ACCLATCH1_FINISH equ $AA	
	
; -- ACCELX0 ($Ax2x) ----------------------------------------------------------	
; Accelerometer X value low byte [ro]	
def rACCELX0 equ $A020	
	
; -- ACCELX1 ($Ax3x) ----------------------------------------------------------	
; Accelerometer X value high byte [ro]	
def rACCELX1 equ $A030	
	
; -- ACCELY0 ($Ax4x) ----------------------------------------------------------	
; Accelerometer Y value low byte [ro]	
def rACCELY0 equ $A040	
	
; -- ACCELY1 ($Ax5x) ----------------------------------------------------------	
; Accelerometer Y value high byte [ro]	
def rACCELY1 equ $A050	
	
; -- EEPROM ($Ax8x) -----------------------------------------------------------	
; EEPROM access [r/w]	
def rEEPROM equ $A080	
	
	
; ** HuC1 only ****************************************************************	
	
; -- IRREG ($A000-$BFFF) ------------------------------------------------------	
; IR register [r/w]	
def rIRREG equ $A000	
	
; whether the IR transmitter sees light	
def IR_LED_OFF equ $C0	
def IR_LED_ON  equ $C1	
	
	
;******************************************************************************	
; Screen-related constants	
;******************************************************************************	
	
def SCREEN_WIDTH_PX  equ 160 ; width of screen in pixels	
def SCREEN_HEIGHT_PX equ 144 ; height of screen in pixels	
def SCREEN_WIDTH     equ  20 ; width of screen in bytes	
def SCREEN_HEIGHT    equ  18 ; height of screen in bytes	
def SCREEN_AREA      equ SCREEN_WIDTH * SCREEN_HEIGHT ; size of screen in bytes	
	
def TILEMAP_WIDTH_PX  equ 256 ; width of tilemap in pixels	
def TILEMAP_HEIGHT_PX equ 256 ; height of tilemap in pixels	
def TILEMAP_WIDTH     equ  32 ; width of tilemap in bytes	
def TILEMAP_HEIGHT    equ  32 ; height of tilemap in bytes	
def TILEMAP_AREA      equ TILEMAP_WIDTH * TILEMAP_HEIGHT ; size of tilemap in bytes	
	
def TILE_WIDTH  equ  8 ; width of tile in pixels	
def TILE_HEIGHT equ  8 ; height of tile in pixels	
def TILE_SIZE   equ 16 ; size of tile in bytes (2 bits/pixel)	
	
def COLOR_SIZE equ 2 ; size of color in bytes (little-endian BGR555)	
def PAL_COLORS equ 4 ; colors per palette	
def PAL_SIZE   equ COLOR_SIZE * PAL_COLORS ; size of palette in bytes	
	
def COLOR_CH_WIDTH equ 5 ; bits per RGB color channel	
def COLOR_CH_MAX   equ (1 << COLOR_CH_WIDTH) - 1	
    def B_COLOR_RED   equ COLOR_CH_WIDTH * 0 ; bits 4-0	
    def B_COLOR_GREEN equ COLOR_CH_WIDTH * 1 ; bits 9-5	
    def B_COLOR_BLUE  equ COLOR_CH_WIDTH * 2 ; bits 14-10	
        def COLOR_RED        equ %000_11111  ; for the low byte	
        def COLOR_GREEN_LOW  equ %111_00000  ; for the low byte	
        def COLOR_GREEN_HIGH equ %0_00000_11 ; for the high byte	
        def COLOR_BLUE       equ %0_11111_00 ; for the high byte	
	
; (DMG only) grayscale shade indexes for BGP, OBP0, and OBP1	
def SHADE_WHITE equ %00	
def SHADE_LIGHT equ %01	
def SHADE_DARK  equ %10	
def SHADE_BLACK equ %11	
	
; Tilemaps the BG or Window can read from (controlled by LCDC)	
def TILEMAP0 equ $9800 ; $9800-$9BFF	
def TILEMAP1 equ $9C00 ; $9C00-$9FFF	
	
; (CGB only) BG tile attribute fields	
def B_BG_PRIO  equ 7 ; whether the BG tile colors 1-3 are drawn above OBJs	
def B_BG_YFLIP equ 6 ; whether the whole BG tile is flipped vertically	
def B_BG_XFLIP equ 5 ; whether the whole BG tile is flipped horizontally	
def B_BG_BANK1 equ 3 ; which VRAM bank the BG tile is taken from	
def BG_PALETTE equ %00000_111 ; which palette the BG tile uses	
    def BG_PRIO  equ 1 << B_BG_PRIO	
    def BG_YFLIP equ 1 << B_BG_YFLIP	
    def BG_XFLIP equ 1 << B_BG_XFLIP	
    def BG_BANK0 equ 0 << B_BG_BANK1	
    def BG_BANK1 equ 1 << B_BG_BANK1	
	
	
;******************************************************************************	
; OBJ-related constants	
;******************************************************************************	
	
; OAM attribute field offsets	
rsreset	
def OAMA_Y      rb ; 0	
    def OAM_Y_OFS equ 16 ; subtract 16 from what's written to OAM to get the real Y position	
def OAMA_X      rb ; 1	
    def OAM_X_OFS equ  8 ; subtract 8 from what's written to OAM to get the real X position	
def OAMA_TILEID rb ; 2	
def OAMA_FLAGS  rb ; 3	
    def B_OAM_PRIO  equ 7 ; whether the OBJ is drawn below BG colors 1-3	
    def B_OAM_YFLIP equ 6 ; whether the whole OBJ is flipped vertically	
    def B_OAM_XFLIP equ 5 ; whether the whole OBJ is flipped horizontally	
    def B_OAM_PAL1  equ 4 ; (DMG only) which of the two palettes the OBJ uses	
    def B_OAM_BANK1 equ 3 ; (CGB only) which VRAM bank the OBJ takes its tile(s) from	
    def OAM_PALETTE equ %00000_111 ; (CGB only) which palette the OBJ uses	
        def OAM_PRIO  equ 1 << B_OAM_PRIO	
        def OAM_YFLIP equ 1 << B_OAM_YFLIP	
        def OAM_XFLIP equ 1 << B_OAM_XFLIP	
        def OAM_PAL0  equ 0 << B_OAM_PAL1	
        def OAM_PAL1  equ 1 << B_OAM_PAL1	
        def OAM_BANK0 equ 0 << B_OAM_BANK1	
        def OAM_BANK1 equ 1 << B_OAM_BANK1	
def OBJ_SIZE    rb 0 ; size of OBJ in bytes = 4	
	
def OAM_COUNT equ 40 ; how many OBJs there are room for in OAM	
def OAM_SIZE  equ OBJ_SIZE * OAM_COUNT	
	
	
;******************************************************************************	
; Audio channel RAM addresses	
;******************************************************************************	
	
def AUD1RAM equ $FF10 ; $FF10-$FF14	
def AUD2RAM equ $FF15 ; $FF15-$FF19	
def AUD3RAM equ $FF1A ; $FF1A-$FF1E	
def AUD4RAM equ $FF1F ; $FF1F-$FF23	
def AUDRAM_SIZE equ 5 ; size of each audio channel RAM in bytes	
	
;def _AUD3WAVERAM equ $FF30 ; $FF30-$FF3F	
def AUD3WAVE_SIZE equ 16 ; size of wave pattern RAM in bytes	
	
	
;******************************************************************************	
; Interrupt vector addresses	
;******************************************************************************	
	
def INT_HANDLER_VBLANK equ $0040 ; VBlank interrupt handler address	
def INT_HANDLER_STAT   equ $0048 ; STAT   interrupt handler address	
def INT_HANDLER_TIMER  equ $0050 ; timer  interrupt handler address	
def INT_HANDLER_SERIAL equ $0058 ; serial interrupt handler address	
def INT_HANDLER_JOYPAD equ $0060 ; joypad interrupt handler address	
	
	
;******************************************************************************	
; Boot-up register values	
;******************************************************************************	
	
; Register A = CPU type	
def BOOTUP_A_DMG equ $01	
def BOOTUP_A_CGB equ $11 ; CGB or AGB	
def BOOTUP_A_MGB equ $FF	
    def BOOTUP_A_SGB  equ BOOTUP_A_DMG	
    def BOOTUP_A_SGB2 equ BOOTUP_A_MGB	
	
; Register B = CPU qualifier (if A is BOOTUP_A_CGB)	
def B_BOOTUP_B_AGB equ 0	
    def BOOTUP_B_CGB equ 0 << B_BOOTUP_B_AGB	
    def BOOTUP_B_AGB equ 1 << B_BOOTUP_B_AGB	
	
; Register C = CPU qualifier	
def BOOTUP_C_DMG equ $13	
def BOOTUP_C_SGB equ $14	
def BOOTUP_C_CGB equ $00 ; CGB or AGB	
	
; Register D = color qualifier	
def BOOTUP_D_MONO  equ $00 ; DMG, MGB, SGB, or CGB or AGB in DMG mode	
def BOOTUP_D_COLOR equ $FF ; CGB or AGB	
	
; Register E = CPU qualifier (distinguishes DMG variants)	
def BOOTUP_E_DMG0        equ $C1	
def BOOTUP_E_DMG         equ $C8	
def BOOTUP_E_SGB         equ $00	
def BOOTUP_E_CGB_DMGMODE equ $08 ; CGB or AGB in DMG mode	
def BOOTUP_E_CGB         equ $56 ; CGB or AGB	
	
	
;******************************************************************************	
; Aliases	
;******************************************************************************	
	
; Prefer the standard names to these aliases, which may be official but are	
; less directly meaningful or human-readable.	
	
def rP1 equ rJOYP	
	
def rNR10 equ rAUD1SWEEP	
def rNR11 equ rAUD1LEN	
def rNR12 equ rAUD1ENV	
def rNR13 equ rAUD1LOW	
def rNR14 equ rAUD1HIGH	
def rNR21 equ rAUD2LEN	
def rNR22 equ rAUD2ENV	
def rNR23 equ rAUD2LOW	
def rNR24 equ rAUD2HIGH	
def rNR30 equ rAUD3ENA	
def rNR31 equ rAUD3LEN	
def rNR32 equ rAUD3LEVEL	
def rNR33 equ rAUD3LOW	
def rNR34 equ rAUD3HIGH	
def rNR41 equ rAUD4LEN	
def rNR42 equ rAUD4ENV	
def rNR43 equ rAUD4POLY	
def rNR44 equ rAUD4GO	
def rNR50 equ rAUDVOL	
def rNR51 equ rAUDTERM	
def rNR52 equ rAUDENA	
	
def rKEY0 equ rSYS	
def rKEY1 equ rSPD	
	
def rHDMA1 equ rVDMA_SRC_HIGH	
def rHDMA2 equ rVDMA_SRC_LOW	
def rHDMA3 equ rVDMA_DEST_HIGH	
def rHDMA4 equ rVDMA_DEST_LOW	
def rHDMA5 equ rVDMA_LEN	
	
def rBCPS equ rBGPI	
def rBCPD equ rBGPD	
	
def rOCPS equ rOBPI	
def rOCPD equ rOBPD	
	
def rSVBK equ rWBK	
	
endc ; HARDWARE_INC	
;* END OF INCLUDE "libs/hardware.inc"	
;* INCLUDE "libs/variables.asm"	
section "Variables", wram0	
	
;A variable with 8 bits	
VariableExample: ds 1	
	
;Current frames. Max 255 (256) frames counted	
wFramesCounter: ds 1	
	
;--------------------------------------------------------	
;   Bit 0-3:    Buttons	
;   Bit 4-7:    DPad	
	
;   Bit 0   A       Mask $01	
;   Bit 1   B       Mask $02	
;   Bit 2   Select  Mask $04	
;   Bit 3   Start   Mask $08	
;   Bit 4   Right   Mask $10	
;   Bit 5   Left    Mask $20	
;   Bit 6   Up      Mask $40	
;   Bit 7   Down    Mask $80	
currentInput: ds 1	
lastInput: ds 1	
	
;--------------------------	
;0 = Start Screen	
;1 = Walking Screen	
gameState: ds 1	
	
;-------------------------	
;0 = Default map	
;1 = First official map	
selectedBattleMap: ds 1	
	
;0 = False	
;nz (Not zero) = true	
readyLoadSprites: ds 1	
	
;Says if the obj sprite should be flipped	
;0 = False	
;1 = Up	
;2 = Down	
;3 = Left	
;4 = Right	
FlipSpritesDir: ds 1	
	
;Sets the last direction that the character is facing	
;0 = False	
;1 = Up	
;2 = Down	
;3 = Left	
;4 = Right	
CurrentFlipSpritesDir: ds 1	
	
	
playerX: ds 1	
playerTileX: ds 1	
playerY: ds 1	
playerTileY: ds 1	
currentTileStandingOn: ds 1	
	
;This is the currently selected character from the player.	
;IDs are stored in the CharacterID file	
playerSelectedCharacter: ds 1	
	
currentlyJumping: ds 1	
;The rest of how high the character should be jumping.	
pixelsLeftHopping: ds 1	
	
hoppingHeight: ds 1	
	
currentPositionStartArrowX: ds 1	
currentPositionStartArrowY: ds 1	
startScreenState: ds 1	
	
;0 = Top	
;n = longer down	
;-------	
;Reset to 0 when changing scene	
startScreenMenuSelection: ds 1	
;* END OF INCLUDE "libs/variables.asm"	
;* INCLUDE "libs/CharacterID.asm"	
; Here we define the ID of every character in the game	
	
DEF WizardID EQU 1	
DEF WarriorID EQU 2	
;* END OF INCLUDE "libs/CharacterID.asm"	
	
	
;------------------------------------------------------------------------	
	
;The game states	
SECTION "GameState", ROM0	
	
;* INCLUDE "states/start.asm"	
StartScreen_State:	
	    ld a, [startScreenState]
	    cp 0
	    jr z, StartScreen_State.viewStartScreen
	    cp 1
	    jr z, StartScreen_State.viewCharacterSelectScreen
	    cp 2
	    jr z, StartScreen_State.viewMapSelectScreen
	
	    jr StartScreen_State.viewStartScreen
	    ret
	
	
	
.viewStartScreen:	
	    ld a, [currentInput]
	    bit 7, a
	    call nz, StartScreen_State.incStartScreenSelection
	
	    ld a, [currentInput]
	    bit 6, a
	    call nz, StartScreen_State.decStartScreenSelection
	
	    ld a, [currentInput]
	    bit 0, a
	    call nz, StartScreen_State.passToCorrectState
	
    ;ld a, [startScreenMenuSelection]	
    ;cp 2	
    ;call z, StartScreen_State.startGameCheck	
	
	
    	
	    call StartScreen_State.changeArrowLocation
    	
	    ret
	
.viewCharacterSelectScreen:	
	    ld a, [currentInput]
	    bit 7, a
	    call nz, StartScreen_State.incStartScreenSelection
	
	    ld a, [currentInput]
	    bit 6, a
	    call nz, StartScreen_State.decStartScreenSelection
	
	    ld a, [currentInput]
	    bit 0, a
	    call nz, StartScreen_State.characterSelectionSet
	
	    ld a, [currentInput]
	    bit 1, a
	    call nz, GoToGame_State
	
	    call StartScreen_State.changeArrowLocation
	
	    ret
	
.characterSelectionSet:	
	    ld a, [startScreenMenuSelection]
	    ld b, a
	    cp 0
	    call z, StartScreen_State.setCharacter0
	    ld a, b
	    cp 1
	    call z, StartScreen_State.setCharacter1
	
	    ret
	
.setCharacter0:	
	    ld a, WizardID
	    ld [playerSelectedCharacter], a 
	    ret
	
.setCharacter1:	
	    ld a, WarriorID
	    ld [playerSelectedCharacter], a 
	    ret
	
.viewMapSelectScreen:	
	    ret
	
.passToCorrectState:	
	    ld a, [startScreenMenuSelection]
	    ld b, a
	    cp 0
	    jp z, GoToSelectCharacter_State
	    ld a, b
	    cp 1
	    jp z, GoToSelectMap_State
	    ld a, b
	    cp 2
	    jp z, GoToGame_State
	    ret
	
	
	
.incStartScreenSelection:	
	    ld a, [startScreenMenuSelection]
	    cp 2
	    ret z
	
	    ld a, [lastInput]
	    bit 7, a
	    ret nz
	
	    ld a, [startScreenMenuSelection]
	    inc a
	    ld [startScreenMenuSelection], a
	    ret
	
.decStartScreenSelection:	
	    ld a, [startScreenMenuSelection]
	    cp 0
	    ret z
	
	    ld a, [lastInput]
	    bit 6, a
	    ret nz
	
	    ld a, [startScreenMenuSelection]
	    dec a
	    ld [startScreenMenuSelection], a
	    ret
    	
	
.changeArrowLocation:	
	    ld a, [startScreenState]
	    ld b, a
	    cp 0
	    call z, StartScreen_State.setStartScreenLocation
	    ld a, b
	    cp 1
	    call z, StartScreen_State.setCharacterSelectLocation
    	
    	
	    ld b, 1
	    ld hl, _OAMRAM
	    jp StartScreen_State.LoadArrowLoop
	    ret
	
.setStartScreenLocation:	
	    ld de, StartScreen_State.startScreenArrowLocations
	    call StartScreen_State.setSelection
	    ret
	
.setCharacterSelectLocation:	
	    ld de, StartScreen_State.characterSelectArrowLocations
	    call StartScreen_State.setSelection
	    ret
	
.LoadArrowLoop:	
	    ld a, [de]
	    inc de
	    ld [hli], a
 	
	    ;X position
	    ld a, [de]
	    inc de
	    ld [hli], a
	
	    ;Tile ID
	    ld a, 0
	    ld [hli], a
	    ret
	
.startScreenArrowLocations: 	
	    db 9 * 8, 6 * 8
	    db 11 * 8, 6 * 8
	    db 16 * 8, 6 * 8
	
.characterSelectArrowLocations:	
	    db 6 * 8, 8 * 8
	    db 8 * 8, 8 * 8
	    db 16 * 8, 2 * 8
	
.setSelection	
	    ld a, [startScreenMenuSelection]
.setSelectionLoop	
	    cp 0
	    ret z
	
	    inc de
	    inc de
	
	    dec a
	
	    jr StartScreen_State.setSelectionLoop
    	
	
	
	
GoToStart_State:	
	    ld a, 0
	    ld [gameState], a
	    ld [startScreenState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	
	    call WaitVBlank
	    ret
	
GoToSelectCharacter_State:	
	    ld a, 0
	    ld [gameState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	
	    ld a, 1
	    ld [startScreenState], a
	
	    call WaitVBlank
	    ret
	
GoToSelectMap_State:	
	    ld a, 0
	    ld [gameState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	
	    ld a, 2
	    ld [startScreenState], a
    	
	    call WaitVBlank
	    ret
;* END OF INCLUDE "states/start.asm"	
;* INCLUDE "states/game.asm"	
Playing_State:	
	    call checkCollision
    	
	    ld a, [currentInput]
	    bit 3, a
	    jp nz, GoToStart_State
	
	    call MovingCharacterTypes
	
	
	    ret
	
GoToGame_State:	
	    ld a, 1
	    ld [gameState], a
	    ld [readyLoadSprites], a
    	
	    call WaitVBlank
	
    	
	
	    ret
; Loaded sources do not match the ROM from 23EC to 7FFF	
	
	; Data from 23EC to 3FFF (7188 bytes)
	ds 7188, $00
	; Data from 4000 to 7FFF (16384 bytes)
	ds 16384, $FF
;* END OF INCLUDE "states/game.asm"	
	
	
	
	
;------------------------------------------------------------------------	
	
;The functions and code assosiated with the game, like walking	
SECTION "GameCode", ROM0	
	
;* INCLUDE "func/printConsole.asm"	
;To write a debug message to emulicious do:	
;   debug_message "What you want to write in anperstands"	
	
MACRO debug_message	
    ld      d,d	
    jr      :+	
    dw      $6464           ; Two ASCII characters: "dd"	
    dw      $0000           ; Identifier for this debug message type	
    db      \1	
:	
ENDM	
	
MACRO deb_msg	
        ld      d,d	
        jr      :+	
        dw      $6464           ; Two ASCII characters: "dd"	
        dw      $0001           ; Identifier for this debug message type	
        dw      \1	
        dw      bank(\1)	
:	
endm	
	
;* END OF INCLUDE "func/printConsole.asm"	
;* INCLUDE "func/input.asm"	
section "Input Buttons", ROM0	
	
;   Bit 0-3:    Buttons	
;   Bit 4-7:    DPad	
	
;   Bit 0   A       Mask $01	
;   Bit 1   B       Mask $02	
;   Bit 2   Select  Mask $04	
;   Bit 3   Start   Mask $08	
	
;   Bit 4   Right   Mask $10	
;   Bit 5   Left    Mask $20	
;   Bit 6   Up      Mask $40	
;   Bit 7   Down    Mask $80	
	
;ldh accesess the higher places in ram with hardware variables, $FF00 - $FFFF	
InputButton:	
    	
	    ;Read d-pad
	    ld a, JOYP_GET_CTRL_PAD     ;Loads the number that we send to the joypad register to ask for dpad
	    call .onenibble
	    swap a                      ;Swaps the lower 4 bits with the higher bits so we can have the whole input in one byte
	    ld b, a                     ;Store the input in b so we can accesess the other buttons
	
	    ;Read buttons    
	    ld a, JOYP_GET_BUTTONS      ;Loads the number that we send to the joypad register to ask for buttons
	    call .onenibble
	    or b                        ;Combines the inputs into one single byte to have everything 
	    cpl                         ; Invert the bits so 1 is pressed
	
	    ld [currentInput], a    ;Stores the current input
	
	    ret
	
	
;Only gives out the 4 important bits of input 	
.onenibble:	
	    ldh [rJOYP], a              ;sends a request to the joypad register with either the value for the dpad or buttons, this will give a return
	    call .knownRet              ;a function that just take time so that the output stabalize, takes 10 cycles
	    ldh a, [rJOYP]              ;fetch the joypad multible times until it gets stable
	    ldh a, [rJOYP]
	    ldh a, [rJOYP]
	    and $0F                     ;0F = 00001111, The "and" masks the bits. Will only return 1 in the byte if both bits are 1. This will make it only keep the button inputs and remove the command we used to specify the buttons or dpad
	    ret
    	
.knownRet:	
	    ret
;* END OF INCLUDE "func/input.asm"	
;* INCLUDE "func/vblank.asm"	
WaitVBlank:	
	    ld a, [rLY]
	    cp 144
	    jp c, WaitVBlank
    	
	    ;Turn off lcd to change the graphics
	    ld a, 0
	    ld [rLCDC], a
	
	    ;changes what to load depending on the gamestate
	    ld a, [gameState]
	    cp 0
	    call z, SetupChosenStartScreen
	    cp 1
	    call z, SetupChosenMap
	
	    call ClearOAM
	
	    ld a, [gameState]
	    cp 0
	    call z, WaitVBlank.loadStartStateSprites
	    cp 1
	    call z,  WaitVBlank.loadGameStateSprites
    	
    	
	    ;Turn on lcd
	    ld a, LCDC_ON | LCDC_BG_ON |LCDC_OBJ_ON
	    ld [rLCDC], a
	
	
	    ;Set pallette for background
	    ld a, %11100100
	    ld [rBGP], a
	
	    ;Set object pallette and sprite pallette
	    ld a, %11100100
	    ld [rOBP0], a
	    ld [rOBP1], a
	
	    ret
	
	
	
;-------------------------------------------------------------------------------	
	
.loadStartStateSprites:	
	    ld de, SelectArrow
	    ld bc, 1 * 16
	    ld hl, $8000
	    call CopyTiles
	    ret
	
	    ld b, 1
	    ld de, selectArrowData
	    call z, SetupSpriteData
	
	    ret
	
	
	
.loadGameStateSprites:	
	    ;Loads the sprite textures to memory if sprites are now viewable
	    ld a, [readyLoadSprites]
	    cp 1
	    ld de, Wizard
	    ld bc, WizardNumSprites
	    call z, loadPlayerSprites
	
	    ld de, Wizard
	    ld bc, WizardNumSprites
	    call z, loadCPUSprites
	
	    ld b, 4
	    ld de, wizardSpriteData
	    call z, SetupSpriteData
	
	    ret
	
	
selectArrowData:	
	    ; Y, X, Tile ID
	    db 100, 100, 0            ; Left top
;---------------------------------------------------------------------------------	
;Loading the main game world map (outside)	
SetupChosenMap:	
	    ld a, [selectedBattleMap]
	    cp 0
	    call z, LoadBattleArena1
	    cp 1
	    call z, LoadChineseStadium
	    ret
LoadWorldMap:	
	    ;Copy tile data
	    ld de, First
	    ld hl, $9000
	    ld bc, 4 * 16
	    call CopyTiles
	
	    ;Copy tile map
	    ld de, WorldTileMap
	    ld hl, $9800
	    ld bc, WorldTileMapWidth * WorldTileMapHeight
	    call CopyTilemap
	
	    ret
	
LoadBattleArena1:	
	    ;Copy tile data
	    ld de, First
	    ld hl, $9000
	    ld bc, 4 * 16
	    call CopyTiles
	
	    ;Copy tile map
	    ld de, BattleArena
	    ld hl, $9800
	    ld bc, BattleArenaWidth * BattleArenaHeight
	    call CopyTilemap
	
	    ret
	
LoadChineseStadium:	
	    ;Copy tile data
	    ld de, ChineseStadionTiles
	    ld hl, $9000
	    ld bc, 11 * 16
	    call CopyTiles
	
	    ;Copy tile map
	    ld de, ChineseStadium
	    ld hl, $9800
	    ld bc, ChineseStadiumWidth * ChineseStadiumHeight
	    call CopyTilemap
	
	    ret
	
SetupChosenStartScreen:	
	    ld a, [startScreenState]
	    cp 0
	    jp z, LoadStartScreen
	    cp 1
	    jp z, LoadCharacterSelectScreen
	    ret
	
;Loads the menu screen, also called start screen	
LoadStartScreen:	
	    ;Copy tile data
	    ld de, Letters
	    ld hl, $9000
	    ld bc, 26 * 16
	    call CopyTiles
	
	    ;Copy tile map
	    ld de, StartScreenMap
	    ld hl, $9800
	    ld bc, StartScreenWidth * StartScreenHeight
	    call CopyTilemap
	
	    ret
	
LoadCharacterSelectScreen:	
	    ;Copy tile data
	    ld de, Letters
	    ld hl, $9000
	    ld bc, 26 * 16
	    call CopyTiles
	
	    ;Copy tile map
	    ld de, CharacterSelectScreen
	    ld hl, $9800
	    ld bc, CharacterSelectScreenWidth * CharacterSelectScreenHeight
	    call CopyTilemap
	
	    ret
	
CopyTiles:	
	    ld a, [de]
	    ld [hli], a
	    inc de
	    dec bc
	    ld a, b
	    or a, c
	    jp nz, CopyTiles
	    ret ;Returns to the initial caller of the function
    	
CopyTilemap:	
	    ld a, [de]
	    ld [hli], a
	    inc de
	    dec bc
	    ld a, b
	    or a, c
	    jp nz, CopyTilemap
	    ret
;* END OF INCLUDE "func/vblank.asm"	
;* INCLUDE "func/viewSprites.asm"	
;Always load the data under into memory before use, else game crash	
;Loads the sprites to the main character	
;Usecase:	
; ld de, TheWantedCharacter	
; ld bc, TheNumOfTiles      Found in the SpriteDEFFile	
loadPlayerSprites:	
	    ld hl, $8000        ;This is the memory location for the player. Never write over this
	    call CopyTiles
	    ret
	
;Always load the data under into memory before use, else game crash	
; ld de, TheWantedCharacter	
; ld bc, TheNumOfTiles      Found in the SpriteDEFFile	
loadCPUSprites:	
	    ld hl, $8040
	    call CopyTiles
	    ret
	
	
;Usage instruction:	
;------------	
;ld de, (The definition of the sprite youll use, x, y and tile id)	
;ld b, (The total sprites for the defenition)	
SetupSpriteData:	
	    ld hl, _OAMRAM
	    jp LoadSpriteLoop
	
LoadSpriteLoop:	
	    ;Y position
	    ld a, [de]
	    ld c, a
	    ld a, [playerY]
	    add c
	    inc de
	    ld [hli], a
 	
	    ;X position
	    ld a, [de]
	    ld c, a
	    ld a, [playerX]
	    add c
	    inc de
	    ld [hli], a
	
	    ;Tile ID
	    ld a, [de]
	    inc de
	    ld [hli], a
	
	    ld a, [FlipSpritesDir]
	    cp 3
	    call z, flipSprites
	    call nz, notFlipSprites
	
	    dec b
	    jr nz, LoadSpriteLoop
	    ret
	
	
flipSprites:	
	    ;Attributes (0 right now)
	    ld a, [B_OAM_YFLIP]
	    ld [hli], a
	    ret
	
notFlipSprites:	
	    xor a
	    ld [hli], a
	    ret
;* END OF INCLUDE "func/viewSprites.asm"	
;* INCLUDE "func/movingCharacter/basicMovement.asm"	
ClearOAM:	
	    ld a, 0
	    ld b, 160
	    ld hl, STARTOF(OAM)
ClearOAMLoop:	
	    ld [hli], a
	    dec b
	    jp nz, ClearOAMLoop
    	
	    ret
	
MovingCharacterTypes:	
	    call MovingType
	    cp FLYING
	    jp z, FlyingMovement
	    cp WALKING
	    ;jp z, WalkingMovement
	    cp HOPPING
	    jp z, HoppingMovement
	
	    ;fallBack
	    jp FlyingMovement
	
MovingType:	
	    ld a, [playerSelectedCharacter]
	    ld hl, CharacterMovementTable
	    ld d, 0
	    ld e, a
	    add hl, de
	    ld a, [hl]
	    ret
	
HoppingMovement:	
	    ;First check if the character is currently jumping
	    ld a, [pixelsLeftHopping]
	    cp 0
	    call nz, ContinueCharacterJump
    	
	    ;Checks if last input also was up
	    ld a, [currentInput]
	    and %01000000
	    ld b, a
	    ld a, [lastInput]
	    and %01000000
	    cp b
	    call nz, CharacterJump
	    call z, ReadyFallingDown
	
	    ld a, [currentInput]
	    bit 7, a
    ;call nz, MoveDown	
	
	    ld a, [currentInput]
	    bit 4, a
	    call nz, GoRight
	
	    ld a, [currentInput]
	    bit 5, a
	    call nz, GoLeft
	
	    ld a, [playerX]
	    call ChangePlayerOAMXAdv
    	
	    ld a, [playerY]
	    call ChangePlayerOAMY
	
	    ret
	
FlyingMovement:	
	    ld a, [currentInput]
	    bit 6, a
	    call nz, MoveUp
	
	    ld a, [currentInput]
	    bit 7, a
	    call nz, MoveDown
	
	    ld a, [currentInput]
	    bit 4, a
	    call nz, GoRight
	
	    ld a, [currentInput]
	    bit 5, a
	    call nz, GoLeft
	
	    ld a, [playerX]
	    call ChangePlayerOAMXAdv
    	
	    ld a, [playerY]
	    call ChangePlayerOAMY
	
	    ret
	
	
ChangePlayerOAMY:	
	    ld [$FE00], a ; Sprite 0 Y
	    ld [$FE04], a ; Sprite 1 Y
	    add 8
	    ld [$FE08], a ; Sprite 2 Y
	    ld [$FE0C], a ; Sprite 3 Y
	    ret
	
ChangePlayerOAMX:	
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    ret
	
ChangePlayerOAMXAdv:	
	    ld a, [FlipSpritesDir]
	    cp 4
	    jp z, MoveSpritesLeft
	
	    ld a, [FlipSpritesDir]
	    cp 3
	    jp z, MoveSpritesRight
	
	    ret
	
MoveSpritesLeft:	
	    ld a, [playerX]
	
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    add 8
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	
	    ld a, $20
	    ld [$FE03], a ; Sprite 0 X
	    ld [$FE07], a ; Sprite 1 X
	    ld [$FE0B], a ; Sprite 2 X
	    ld [$FE0F], a ; Sprite 3 X
	
	    ld a, 3
	    ld [CurrentFlipSpritesDir], a 
	
	    ret
	
MoveSpritesRight:	
	    ld a, [playerX]
	
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	
	    ld a, $00
	    ld [$FE03], a ; Sprite 0 X
	    ld [$FE07], a ; Sprite 1 X
	    ld [$FE0B], a ; Sprite 2 X
	    ld [$FE0F], a ; Sprite 3 X
	
	    ld a, 4
	    ld [CurrentFlipSpritesDir], a 
	
	    ret
	
	
;* END OF INCLUDE "func/movingCharacter/basicMovement.asm"	
;* INCLUDE "func/movingCharacter/flipCharacters.asm"	
flipLeftFacing:	
	    ld a, [playerX]
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    add 8
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    ret
	
flipRightFacing:	
	    ld a, [playerX]
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    ret
	
;* END OF INCLUDE "func/movingCharacter/flipCharacters.asm"	
;* INCLUDE "func/movingCharacter/collision.asm"	
DEF NoWalkTiles equ 9	
	
checkCollision:	
	    call getPlayerTileX
	    call getPlayerTileY
	    call getTileID
	    ret
	
getPlayerTileY:	
	    ld a, [rSCY]
	    ld b, a
	    ld a, [playerY]
	    add b
	    srl a
	    srl a
	    srl a
	    ld [playerTileY], a
	    ret
	
getPlayerTileX:	
	    ld a, [rSCX]
	    ld b, a
	    ld a, [playerX]
	    add b
	    srl a
	    srl a
	    srl a
	    ld [playerTileX], a
	    ret
	
getTileID:	
	    ;Formula to get the tile ID:    $9800 + (tileY * 32) + tileX
	    ld h, 0
	    ld a, [playerTileY]
	    ld l, a
	
	    ;multiply by 32 (shift left 5 times)
	    add hl, hl
	    add hl, hl
	    add hl, hl
	    add hl, hl
	    add hl, hl
	
	    ;Add tile x
	    ld d, 0
	    ld a, [playerTileX]
	    ld e, a
	    add hl, de              ; HL = (tileY * 32) + tileX
	
	    ld de, $9800
	    add hl, de
	
	    ld a, [hl]
	    ld [currentTileStandingOn], a
    ;call PrintA	
	
	    ret
;* END OF INCLUDE "func/movingCharacter/collision.asm"	
;* INCLUDE "func/movingCharacter/hoppingMovement.asm"	
GoLeft:	
	    ld a, 4
	    ld [FlipSpritesDir], a
	
	
	    ld a, [playerX]
	    cp 20
	    jr z, GoLeft.MoveBackgroundLeft
	    jr nz, GoLeft.MovePlayerLeft
	
	    ret
	
.MovePlayerLeft:	
	    ld a, [playerX]
	    dec a
	    ld [playerX], a
	    ret
	
.MoveBackgroundLeft:	
	    ld a, [rSCX]
	    dec a
	    ld [rSCX], a
	    ret
	
GoRight:	
	    ld a, 3
	    ld [FlipSpritesDir], a
	
	    ld a, [playerX]
	    cp 140
	    jr z, GoRight.MoveBackgroundRight
	    jr nz, GoRight.MovePlayerRight
    	
	    ret
	
.MovePlayerRight:	
	    ld a, [playerX]
	    inc a
	    ld [playerX], a
	    ret
	
.MoveBackgroundRight:	
	    ld a, [rSCX]
	    inc a
	    ld [rSCX], a
	    ret
	
	
CharacterJump:	
	    ;Set jump height to 70 pixels
	    ld a, [hoppingHeight]
	    ld [pixelsLeftHopping], a
	
	    ld a, [playerY]
	    dec a 
	    ld [playerY], a
	
	    ret
	
	
ContinueCharacterJump:	
	    ld a, [pixelsLeftHopping]
	    dec a
	    ld [pixelsLeftHopping], a
	
	    ld a, [playerY]
	    dec a
	    ld [playerY], a
	
	    ret
	
ReadyFallingDown:	
	    ld a, [pixelsLeftHopping]
	    cp 0
	    call z, CheckCollisionFallingDown
	    ret
	
CheckCollisionFallingDown:	
	    ld a, [currentTileStandingOn]
	    cp NoWalkTiles
	    call nc, FallingDown
	    ret
	
FallingDown:	
	    ld a, [playerY]
	    inc a
	    ld [playerY], a
	    ret
;* END OF INCLUDE "func/movingCharacter/hoppingMovement.asm"	
;* INCLUDE "func/movingCharacter/flyingMovement.asm"	
MoveUp:	
	    ld a, [playerY]
	    dec a
	    ld [playerY], a
	
	    ret
	
MoveDown:	
	    ld a, [currentTileStandingOn]
	    cp NoWalkTiles
	    ret z
	    ld a, [playerY]
	    inc a
	    ld [playerY], a
	
	    ret
MoveLeft:	
	    ld a, [playerX]
	    inc a
	    ld [playerX], a
	
	    ld a, 3
	    ld [FlipSpritesDir], a
	
	    ret
	
MoveRight:	
	    ld a, 4
	    ld [FlipSpritesDir], a
	
	    ld a, [playerX]
	    cp 140
	    jr z, GoRight.MoveBackgroundRight
	    jr nz, GoRight.MovePlayerRight
	
	    ret
	
.MoveBackgroundRight:	
	    ld a, [rSCX]
	    inc a
	    ld [rSCX], a
	
	    ret
	
.MovePlayerRight:	
	    ld a, [playerX]
	    inc a 
;* END OF INCLUDE "func/movingCharacter/flyingMovement.asm"	
	
;------------------------------------------------------------------------	
;DEFINITIONS OF THE CHARACTERS	
	
SECTION "CharacterDefs", ROM0	
;* INCLUDE "libs/SpriteDEF/Types.asm"	
DEF MOVE_ATTACK equ 1	
DEF MOVE_DEFEND equ 2	
DEF MOVE_FREEZE equ 3	
DEF MOVE_HEAL   equ 4	
	
DEF WALKING     equ 0	
DEF FLYING      equ 1	
DEF HOPPING     equ 2	
	
CharacterMovementTable:	
	    db 0                ; ID 0 - NONE (No characters on id 0)
	    db FLYING           ; ID 1 - Wizard
	    db HOPPING          ; ID 2 - 
	    db HOPPING          ; ID 3 - 
;* END OF INCLUDE "libs/SpriteDEF/Types.asm"	
	
;* INCLUDE "libs/SpriteDEF/Wizard.asm"	
wizardSpriteData:	
wizardHead:	
	    ; Y, X, Tile ID
	    db 0, 0, 0            ; Left top
	    db 0, 8, 1            ; Right top
wizardBottom:	
	    db 8, 0, 2            ; Left
	    db 8, 8, 3            ; Right
	
DEF WizardNumSprites equ 16 * 4	
	
wizardAbilities:	
	    ;Moving Type, hp, etc
	    db FLYING   ;MovingStyle
	    db 160      ;HP
	
	
wizardMoves:	
    ;Move id, Name, damage,speed px, durration (frames), type flags	
wizardFireball:	
	    db 0
	    db "FireBall"
	    db 40
	    db 5
	    db 60
	    db MOVE_ATTACK
wizardDefence:	
	    db 1
	    db "Sheild"
	    db 0 
	    db 0
	    db 30
	    db MOVE_DEFEND
wizardIceBlast:	
	    db 2
	    db "Ice Blast"
	    db 20
	    db 10
	    db 30
	    db MOVE_ATTACK
	; Loaded sources do not match the ROM from 38 to FF
	; Data from 38 to 39 (2 bytes)
	db $00, $00
	db $00, $00, $00, $00, $00, $00
	
_LABEL_40_:	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
_LABEL_48_:	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
_LABEL_50_:	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
_LABEL_58_:	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
_LABEL_60_:	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
;* END OF INCLUDE "libs/SpriteDEF/Wizard.asm"	
	
;------------------------------------------------------------------------	
;TEXTURES	
	
SECTION "TileData", ROM0	
	
;* INCLUDE "tex/Tilemap/First.z80"	
; World.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : WorldMap	
;   Bank          : 0	
;   Map size      : 32 x 32	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\GameASM\tempTiles&Map\Tiles\World.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF WorldTileMapWidth  EQU 32	
DEF WorldTileMapHeight EQU 32	
DEF WorldTileMapBank   EQU 0	
	
;SECTION "WorldMap", HOME	
	
WorldTileMap::	
	DB $00,$00,$00,$00,$01,$01,$01,$00,$00,$00
	DB $03,$03,$03,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$01,$02,$02,$01,$00
	DB $00,$00,$00,$03,$03,$03,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$01
	DB $01,$01,$00,$00,$00,$00,$01,$02,$02,$02
	DB $02,$00,$00,$00,$00,$03,$03,$03,$00,$01
	DB $01,$00,$01,$01,$01,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$02
	DB $02,$02,$02,$00,$00,$00,$00,$00,$03,$03
	DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$02
	DB $02,$02,$02,$02,$02,$00,$00,$00,$00,$00
	DB $01,$01,$01,$01,$02,$00,$00,$01,$01,$00
	DB $03,$03,$01,$02,$01,$01,$02,$02,$02,$01
	DB $01,$02,$02,$02,$02,$02,$02,$00,$00,$00
	DB $00,$00,$02,$02,$02,$02,$02,$00,$01,$01
	DB $00,$00,$03,$03,$01,$01,$02,$01,$01,$01
	DB $01,$01,$01,$02,$02,$02,$02,$02,$00,$00
	DB $00,$00,$01,$01,$01,$02,$02,$02,$01,$01
	DB $00,$01,$00,$00,$03,$03,$00,$01,$01,$01
	DB $01,$00,$00,$00,$00,$00,$00,$02,$02,$02
	DB $02,$02,$00,$00,$01,$00,$02,$02,$02,$02
	DB $01,$00,$01,$01,$00,$00,$03,$03,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $02,$02,$02,$02,$00,$00,$01,$00,$02,$02
	DB $02,$02,$01,$01,$00,$00,$00,$00,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $02,$02,$02,$00,$00,$00,$00,$00,$00,$01
	DB $00,$02,$02,$02,$00,$01,$01,$01,$00,$00
	DB $03,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$01,$01,$02,$02,$02,$01,$01,$01,$01
	DB $01,$00,$03,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$02,$02,$02,$02,$00,$00
	DB $00,$00,$00,$00,$03,$03,$01,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$01,$01,$00,$02,$02,$00
	DB $00,$00,$00,$00,$00,$01,$03,$03,$03,$01
	DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$01,$01,$00,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$00,$00,$01,$00,$03
	DB $03,$03,$03,$03,$01,$01,$01,$01,$00,$01
	DB $01,$01,$01,$01,$01,$01,$00,$00,$00,$00
	DB $01,$01,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$03,$03,$03,$03,$03,$03,$00,$00,$00
	DB $01,$01,$01,$01,$01,$00,$00,$00,$00,$00
	DB $03,$03,$00,$01,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$01,$01,$01,$00,$03,$03
	DB $00,$01,$01,$01,$00,$00,$00,$00,$00,$03
	DB $03,$03,$03,$03,$03,$03,$01,$01,$01,$00
	DB $00,$00,$01,$00,$00,$00,$00,$00,$01,$00
	DB $03,$00,$00,$00,$00,$00,$03,$03,$03,$03
	DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$00
	DB $00,$00,$00,$00,$01,$01,$00,$00,$00,$00
	DB $01,$01,$03,$03,$03,$03,$03,$03,$03,$03
	DB $03,$03,$02,$02,$00,$00,$00,$00,$03,$03
	DB $03,$03,$03,$03,$01,$00,$00,$01,$01,$00
	DB $00,$00,$00,$01,$01,$03,$03,$03,$00,$01
	DB $01,$00,$02,$02,$00,$01,$02,$00,$00,$01
	DB $00,$03,$03,$03,$03,$03,$03,$03,$00,$01
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $01,$00,$00,$00,$02,$00,$00,$01,$01,$02
	DB $00,$01,$01,$00,$00,$01,$01,$03,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$02,$00,$00,$00
	DB $00,$01,$00,$00,$00,$01,$01,$01,$01,$03
	DB $03,$03,$03,$00,$00,$00,$01,$01,$01,$00
	DB $00,$00,$01,$01,$01,$00,$00,$00,$00,$00
	DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$01
	DB $01,$00,$03,$03,$03,$00,$00,$00,$01,$01
	DB $01,$00,$00,$00,$01,$01,$01,$00,$00,$00
	DB $00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$03,$03,$03,$00,$00
	DB $01,$01,$01,$00,$02,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$01,$01,$02,$00,$00
	DB $00,$00,$01,$00,$00,$00,$00,$00,$03,$03
	DB $00,$00,$00,$00,$00,$00,$02,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$01,$02,$00
	DB $00,$00,$00,$01,$01,$00,$00,$00,$00,$00
	DB $03,$03,$03,$01,$01,$00,$00,$00,$02,$00
	DB $00,$00,$01,$00,$00,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$01,$00,$00,$00,$00
	DB $00,$00,$03,$03,$03,$01,$01,$00,$00,$00
	DB $00,$00,$00,$00,$01,$00,$00,$00,$00,$02
	DB $02,$00,$00,$00,$00,$00,$00,$01,$00,$01
	DB $01,$00,$00,$01,$03,$03,$03,$03,$01,$01
	DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
	DB $02,$02,$00,$00,$00,$00,$00,$00,$00,$01
	DB $01,$01,$00,$00,$01,$00,$03,$03,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$02,$02,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$01,$03,$03
	DB $03,$03,$00,$01,$01,$01,$01,$01,$01,$01
	DB $00,$00,$00,$02,$02,$02,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	DB $01,$03,$03,$03,$01,$00,$00,$00,$00,$00
	DB $01,$00,$00,$00,$00,$02,$02,$02,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$03,$03,$03,$01,$01,$01,$01
	DB $01,$01,$01,$01,$02,$02,$02,$00,$00,$00
	DB $00,$00,$00,$00
	
; End of World.Z80	
;* END OF INCLUDE "tex/Tilemap/First.z80"	
;* INCLUDE "tex/Tilemap/hello_world.asm"	
section "HelloWorld", ROM0	
	
HelloWorldmap:	
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $01, $02, $03, $01, $04, $03, $01, $05, $00, $01, $05, $00, $06, $04, $07, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $08, $09, $0a, $0b, $0c, $0d, $0b, $0e, $0f, $08, $0e, $0f, $10, $11, $12, $13, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $14, $15, $16, $17, $18, $19, $1a, $1b, $0f, $14, $1b, $0f, $14, $1c, $16, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $1e, $1f, $20, $21, $22, $23, $24, $22, $25, $1e, $22, $25, $26, $22, $27, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $01, $28, $29, $2a, $2b, $2c, $2d, $2b, $2e, $2d, $2f, $30, $2d, $31, $32, $33, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $08, $34, $0a, $0b, $11, $0a, $0b, $35, $36, $0b, $0e, $0f, $08, $37, $0a, $38, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $14, $39, $16, $17, $1c, $16, $17, $3a, $3b, $17, $1b, $0f, $14, $3c, $16, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $1e, $3d, $3e, $3f, $22, $27, $21, $1f, $20, $21, $22, $25, $1e, $22, $40, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $41, $42, $43, $44, $30, $33, $41, $45, $43, $41, $30, $43, $41, $30, $33, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
HelloWorldmapEnd:	
;* END OF INCLUDE "tex/Tilemap/hello_world.asm"	
;* INCLUDE "tex/Tilemap/BattleArena1.z80"	
; BATTLEARENA1.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : Arena	
;   Bank          : 0	
;   Map size      : 32 x 32	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\SmashBro_GB\src\tex\Tiles\First.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF BattleArenaWidth  EQU 32	
DEF BattleArenaHeight EQU 32	
DEF BattleArenaBank   EQU 0	
	
;SECTION "Arena", HOME	
	
BattleArena::	
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $02,$02,$02,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$02,$02,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00
	
; End of BATTLEARENA1.Z80	
;* END OF INCLUDE "tex/Tilemap/BattleArena1.z80"	
;* INCLUDE "tex/Tilemap/ChineseStadium.z80"	
; CHINESESTADIUM.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : ChineseStadium	
;   Bank          : 0	
;   Map size      : 32 x 32	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\SmashBro_GB\src\tex\Tiles\ChineseBattleStadium.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF ChineseStadiumWidth  EQU 32	
DEF ChineseStadiumHeight EQU 32	
DEF ChineseStadiumBank   EQU 0	
	
;SECTION "ChineseStadium", HOME	
	
ChineseStadium::	
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$04,$05,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$07,$08,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$06,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$09,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $06,$00,$00,$01,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$00,$01,$07,$09
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$02,$02,$03,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$02,$03
	DB $09,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A
	
; End of CHINESESTADIUM.Z80	
;* END OF INCLUDE "tex/Tilemap/ChineseStadium.z80"	
;* INCLUDE "tex/Tilemap/StartScreen/CharacterSelectScreen.z80"	
; CHARACTERSELECTSCREEN.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : CharacterSelectScreen	
;   Bank          : 0	
;   Map size      : 32 x 18	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\SmashBro_GB\src\tex\Tiles\Letters.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF CharacterSelectScreenWidth  EQU 32	
DEF CharacterSelectScreenHeight EQU 18	
DEF CharacterSelectScreenBank   EQU 0	
	
; SECTION "CharacterSelectScreen", HOME	
	
CharacterSelectScreen::	
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$03,$08,$01,$12,$01,$03,$14
	DB $05,$12,$13,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$17,$09
	DB $19,$01,$12,$04,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$17,$01,$12,$12,$09,$0F,$12,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$0F,$0B,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00
	
; End of CHARACTERSELECTSCREEN.Z80	
;* END OF INCLUDE "tex/Tilemap/StartScreen/CharacterSelectScreen.z80"	
;* INCLUDE "tex/Tilemap/StartScreen/StartScreen.z80"	
; STARTSCREENMAP.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : StartScreenMap	
;   Bank          : 0	
;   Map size      : 32 x 18	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\SmashBro_GB\src\tex\Tiles\LettersV2.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF StartScreenWidth  EQU 32	
DEF StartScreenHeight EQU 18	
DEF StartScreenBank   EQU 0	
	
;SECTION "StartScreen", HOME	
	
StartScreenMap::	
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$13,$0D,$01,$13,$08,$00,$07,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$03,$08,$01,$12,$13,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$0D,$01,$10,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$13,$14,$01,$12,$14
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00
	
; End of STARTSCREENMAP.Z80	
;* END OF INCLUDE "tex/Tilemap/StartScreen/StartScreen.z80"	
;* INCLUDE "tex/Tilemap/StartScreen/MapSelectScreen.z80"	
; MAPSELECTSCREEN.Z80	
;	
; Map Source File.	
;	
; Info:	
;   Section       : StartScreen	
;   Bank          : 0	
;   Map size      : 32 x 18	
;   Tile set      : Z:\Users\sebastian\Repositories\Github\SmashBro_GB\src\tex\Tiles\Letters.gbr	
;   Plane count   : 1 plane (8 bits)	
;   Plane order   : Tiles are continues	
;   Tile offset   : 0	
;   Split data    : No	
;	
; This file was generated by GBMB v1.8	
	
DEF MapSelectScreenWidth  EQU 32	
DEF MapSelectScreenHeight EQU 18	
DEF MapSelectScreenBank   EQU 0	
	
;SECTION "StartScreen", HOME	
	
MapSelectScreen::	
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$0D
	DB $01,$10,$13,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$03,$08,$09
	DB $0E,$01,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$06,$09,$12,$13,$14,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$0F,$0B,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A
	
; End of MAPSELECTSCREEN.Z80	
;* END OF INCLUDE "tex/Tilemap/StartScreen/MapSelectScreen.z80"	
	
;* INCLUDE "tex/Tiles/ChineseBattleStadionTiles.z80"	
; CHINESEBATTLESTADIONTILES.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : ChineseStadionTiles	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 10	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
; SECTION "ChineseStadionTiles", HOME	
	
; Start of tile array.	
ChineseStadionTiles::	
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FF,$FF,$21,$FF,$56,$FF,$89,$FF
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FF,$FF,$84,$FF,$6A,$FF,$91,$FF
	DB $6A,$FF,$94,$FF,$94,$FF,$94,$FF
	DB $6A,$FF,$91,$FF,$6A,$FF,$84,$FF
	DB $56,$FF,$29,$FF,$29,$FF,$29,$FF
	DB $56,$FF,$89,$FF,$56,$FF,$21,$FF
	DB $4C,$FF,$B3,$FF,$6C,$FF,$9B,$FF
	DB $64,$7F,$1B,$1F,$0C,$0F,$03,$03
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FC,$FF,$03,$FF,$CC,$FF,$33,$FF
	DB $B4,$FF,$B4,$FF,$75,$7F,$73,$7F
	DB $4C,$7F,$23,$3F,$14,$1F,$0F,$0F
	DB $33,$FF,$CC,$FF,$33,$FF,$CC,$FF
	DB $3F,$FF,$C0,$FF,$33,$FF,$CC,$FF
	DB $32,$FF,$CD,$FF,$36,$FF,$D9,$FF
	DB $26,$FE,$D8,$F8,$30,$F0,$C0,$C0
	DB $2D,$FF,$2D,$FF,$AE,$FE,$CE,$FE
	DB $32,$FE,$C4,$FC,$28,$F8,$F0,$F0
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	
; End of CHINESEBATTLESTADIONTILES.Z80	
;* END OF INCLUDE "tex/Tiles/ChineseBattleStadionTiles.z80"	
;* INCLUDE "tex/Tiles/Letters.z80"	
; LETTERSV2.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : LettersV2	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 26	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
;SECTION "LettersV2", HOME	
	
; Start of tile array.	
Letters::	
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$18,$18,$24,$24,$42,$42
	DB $7E,$7E,$42,$42,$42,$42,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$7C,$7C
	DB $42,$42,$42,$42,$7C,$7C,$00,$00
	DB $00,$00,$3E,$3E,$40,$40,$40,$40
	DB $40,$40,$40,$40,$3E,$3E,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$42,$42
	DB $42,$42,$42,$42,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$78,$78
	DB $40,$40,$40,$40,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$40,$40
	DB $7C,$7C,$40,$40,$40,$40,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$5E,$5E
	DB $42,$42,$42,$42,$7E,$7E,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $7E,$7E,$42,$42,$42,$42,$00,$00
	DB $00,$00,$7E,$7E,$18,$18,$18,$18
	DB $18,$18,$18,$18,$7E,$7E,$00,$00
	DB $00,$00,$7E,$7E,$02,$02,$02,$02
	DB $02,$02,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$42,$42,$44,$44,$58,$58
	DB $60,$60,$58,$58,$44,$44,$00,$00
	DB $00,$00,$40,$40,$40,$40,$40,$40
	DB $40,$40,$40,$40,$7C,$7C,$00,$00
	DB $00,$00,$42,$42,$66,$66,$5A,$5A
	DB $42,$42,$42,$42,$42,$42,$00,$00
	DB $00,$00,$62,$62,$52,$52,$52,$52
	DB $4A,$4A,$4A,$4A,$46,$46,$00,$00
	DB $00,$00,$3C,$3C,$42,$42,$42,$42
	DB $42,$42,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$7C,$7C
	DB $40,$40,$40,$40,$40,$40,$00,$00
	DB $00,$00,$38,$38,$44,$44,$44,$44
	DB $44,$44,$44,$44,$3E,$3E,$00,$00
	DB $00,$00,$7E,$7E,$42,$42,$7E,$7E
	DB $58,$58,$44,$44,$44,$44,$00,$00
	DB $00,$00,$3E,$3E,$40,$40,$3C,$3C
	DB $02,$02,$02,$02,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$18,$18,$18,$18
	DB $18,$18,$18,$18,$18,$18,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $42,$42,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $24,$24,$24,$24,$18,$18,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $42,$42,$5A,$5A,$24,$24,$00,$00
	DB $00,$00,$42,$42,$46,$46,$34,$34
	DB $18,$18,$28,$28,$66,$66,$00,$00
	DB $00,$00,$7E,$7E,$02,$02,$0C,$0C
	DB $30,$30,$40,$40,$7E,$7E,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	
; End of LETTERSV2.Z80	
;* END OF INCLUDE "tex/Tiles/Letters.z80"	
;* INCLUDE "tex/Tiles/First.z80"	
; EXPORT.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : remove	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 3	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
;SECTION "remove", HOME	
	
; Start of tile array.	
First::	
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $01,$02,$00,$05,$06,$C9,$05,$AA
	DB $20,$9E,$12,$4C,$D0,$2C,$64,$18
	DB $B9,$00,$7D,$00,$AF,$00,$C5,$00
	DB $8F,$00,$99,$00,$DE,$00,$6D,$00
	DB $44,$00,$44,$00,$21,$00,$25,$00
	DB $29,$00,$48,$00,$42,$00,$02,$00
	
; End of EXPORT.Z80	
;* END OF INCLUDE "tex/Tiles/First.z80"	
;* INCLUDE "tex/Tiles/hello_world.asm"	
section "HelloWorld_Tiles", ROM0	
	
HelloWorld_Tiles:	
	    db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	    db $00, $ff, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	    db $00, $ff, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e
	    db $00, $ff, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
	    db $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $00, $ff, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f
	    db $00, $ff, $03, $fc, $00, $f8, $00, $f0, $00, $e0, $20, $c0, $00, $c0, $40, $80
	    db $00, $ff, $c0, $3f, $00, $1f, $00, $0f, $00, $07, $04, $03, $00, $03, $02, $01
	    db $00, $80, $00, $80, $7f, $80, $00, $80, $00, $80, $7f, $80, $7f, $80, $00, $80
	    db $00, $7e, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ff, $00, $ff, $00, $00, $00
	    db $00, $01, $00, $01, $ff, $01, $00, $01, $01, $01, $fe, $01, $ff, $01, $00, $01
	    db $00, $80, $80, $80, $7f, $80, $80, $80, $00, $80, $ff, $80, $7f, $80, $80, $80
	    db $00, $7f, $2a, $7f, $d5, $7f, $2a, $7f, $55, $7f, $ff, $00, $ff, $00, $00, $00
	    db $00, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $fa, $07, $fd, $07, $02, $07
	    db $00, $7f, $2a, $7f, $d5, $7f, $2a, $7f, $55, $7f, $aa, $7f, $d5, $7f, $2a, $7f
	    db $00, $ff, $80, $ff, $00, $ff, $80, $ff, $00, $ff, $80, $ff, $00, $ff, $80, $ff
	    db $40, $80, $00, $80, $7f, $80, $00, $80, $00, $80, $7f, $80, $7f, $80, $00, $80
	    db $00, $3c, $02, $7e, $85, $7e, $0a, $7e, $14, $7e, $ab, $7e, $95, $7e, $2a, $7e
	    db $02, $01, $00, $01, $ff, $01, $00, $01, $01, $01, $fe, $01, $ff, $01, $00, $01
	    db $00, $ff, $80, $ff, $50, $ff, $a8, $ff, $50, $ff, $a8, $ff, $54, $ff, $a8, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	    db $ff, $00, $ff, $00, $ff, $00, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01
	    db $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80
	    db $ff, $00, $ff, $00, $ff, $00, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f
	    db $f8, $07, $f8, $07, $f8, $07, $80, $ff, $00, $ff, $aa, $ff, $55, $ff, $aa, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80
	    db $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $eb, $3c
	    db $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $80, $ff
	    db $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $aa, $ff
	    db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $80, $ff
	    db $7f, $80, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff
	    db $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $80, $ff
	    db $3f, $c0, $3f, $c0, $3f, $c0, $1f, $e0, $1f, $e0, $0f, $f0, $03, $fc, $00, $ff
	    db $fd, $03, $fc, $03, $fd, $03, $f8, $07, $f9, $07, $f0, $0f, $c1, $3f, $82, $ff
	    db $55, $ff, $2a, $7e, $54, $7e, $2a, $7e, $54, $7e, $2a, $7e, $54, $7e, $00, $7e
	    db $01, $ff, $00, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01, $01, $00, $01
	    db $54, $ff, $ae, $f8, $50, $f0, $a0, $e0, $60, $c0, $80, $c0, $40, $80, $40, $80
	    db $55, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $55, $ff, $6a, $1f, $05, $0f, $02, $07, $05, $07, $02, $03, $03, $01, $02, $01
	    db $54, $ff, $80, $80, $00, $80, $80, $80, $00, $80, $80, $80, $00, $80, $00, $80
	    db $55, $ff, $2a, $1f, $0d, $07, $06, $03, $01, $03, $02, $01, $01, $01, $00, $01
	    db $55, $ff, $2a, $7f, $55, $7f, $2a, $7f, $55, $7f, $2a, $7f, $55, $7f, $00, $7f
	    db $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $00, $ff
	    db $15, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $55, $ff, $6a, $1f, $0d, $07, $06, $03, $01, $03, $02, $01, $03, $01, $00, $01
	    db $54, $ff, $a8, $ff, $54, $ff, $a8, $ff, $50, $ff, $a0, $ff, $40, $ff, $00, $ff
	    db $00, $7e, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ab, $76, $dd, $66, $22, $66
	    db $00, $7c, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7c, $ff, $00, $ff, $00, $00, $00
	    db $00, $01, $00, $01, $ff, $01, $02, $01, $07, $01, $fe, $03, $fd, $07, $0a, $0f
	    db $00, $7c, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ab, $7e, $d5, $7e, $2a, $7e
	    db $00, $ff, $a0, $ff, $50, $ff, $a8, $ff, $54, $ff, $a8, $ff, $54, $ff, $aa, $ff
	    db $dd, $62, $bf, $42, $fd, $42, $bf, $40, $ff, $00, $ff, $00, $f7, $08, $ef, $18
	    db $ff, $00, $ff, $00, $ff, $00, $ab, $7c, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e
	    db $f9, $07, $fc, $03, $fd, $03, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7c
	    db $f7, $18, $eb, $1c, $d7, $3c, $eb, $3c, $d5, $3e, $ab, $7e, $d5, $7e, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $a2, $ff
	    db $7f, $c0, $bf, $c0, $7f, $c0, $bf, $e0, $5f, $e0, $af, $f0, $57, $fc, $aa, $ff
	    db $ff, $01, $fc, $03, $fd, $03, $fc, $03, $f9, $07, $f0, $0f, $c1, $3f, $82, $ff
	    db $55, $ff, $2a, $ff, $55, $ff, $2a, $ff, $55, $ff, $2a, $ff, $55, $ff, $00, $ff
	    db $45, $ff, $a2, $ff, $41, $ff, $82, $ff, $41, $ff, $80, $ff, $01, $ff, $00, $ff
	    db $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $00, $ff
	    db $15, $ff, $2a, $ff, $15, $ff, $0a, $ff, $15, $ff, $0a, $ff, $01, $ff, $00, $ff
	    db $01, $ff, $80, $ff, $01, $ff, $80, $ff, $01, $ff, $80, $ff, $01, $ff, $00, $ff
HelloWorld_TilesEnd:	
;* END OF INCLUDE "tex/Tiles/hello_world.asm"	
;* INCLUDE "tex/Tiles/SelectArrow.z80"	
; SELECTARROW.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : SelectArrow	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 1	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
;SECTION "SelectArrow", HOME	
	
; Start of tile array.	
SelectArrow::	
	DB $C0,$C0,$F8,$F8,$8E,$8E,$83,$83
	DB $81,$81,$8E,$8E,$F8,$F8,$C0,$C0
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	
; End of SELECTARROW.Z80	
;* END OF INCLUDE "tex/Tiles/SelectArrow.z80"	
	
;* INCLUDE "tex/Sprites/CharacterV2.z80"	
; EXPORT.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : Sprite	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 9	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
;SECTION "Sprite", HOME	
	
; Start of tile array.	
CharacterV2::	
	DB $08,$08,$1C,$1C,$38,$28,$38,$28
	DB $38,$28,$38,$28,$38,$28,$7F,$67
	DB $40,$40,$E0,$E0,$70,$50,$70,$50
	DB $70,$50,$70,$50,$70,$50,$F0,$D0
	DB $FF,$A0,$FF,$90,$FF,$80,$FF,$8E
	DB $FF,$8E,$FF,$8E,$FF,$8E,$FF,$80
	DB $F8,$08,$F8,$08,$F8,$08,$F8,$38
	DB $F8,$38,$F8,$38,$F8,$38,$F8,$08
	DB $7F,$40,$FF,$BF,$75,$5F,$2A,$3F
	DB $35,$3F,$4A,$7F,$75,$7F,$4B,$7F
	DB $F0,$10,$E0,$E0,$50,$F0,$B0,$F0
	DB $50,$F0,$D0,$F0,$F0,$F0,$F0,$F0
	DB $E7,$FF,$9F,$FF,$FF,$FF,$99,$99
	DB $09,$09,$00,$00,$00,$00,$00,$00
	DB $E0,$E0,$A0,$E0,$C0,$C0,$80,$80
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $E7,$FF,$9F,$FF,$FF,$FF,$99,$99
	DB $10,$10,$00,$00,$00,$00,$00,$00
	DB $E0,$E0,$A0,$E0,$C0,$C0,$80,$80
	DB $80,$80,$00,$00,$00,$00,$00,$00
	
; End of EXPORT.Z80	
;* END OF INCLUDE "tex/Sprites/CharacterV2.z80"	
	
;Wizard Character	
;* INCLUDE "tex/Sprites/Wizard/Wizard.z80"	
; WIZARD.Z80	
;	
; Tile Source File.	
;	
; Info:	
;   Section              : Tiles	
;   Bank                 : 0	
;   Form                 : All tiles as one unit.	
;   Format               : Gameboy 4 color.	
;   Compression          : None.	
;   Counter              : None.	
;   Tile size            : 8 x 8	
;   Tiles                : 0 to 3	
;	
;   Palette colors       : None.	
;   SGB Palette          : None.	
;   CGB Palette          : None.	
;	
;   Convert to metatiles : No.	
;	
; This file was generated by GBTD v2.2	
	
;SECTION "Tiles", HOME	
	
; Start of tile array.	
Wizard::	
	DB $FE,$FE,$81,$FF,$40,$7F,$40,$7F
	DB $23,$3F,$2F,$3C,$7F,$72,$DF,$AD
	DB $00,$00,$F8,$F8,$7C,$E4,$FE,$82
	DB $FE,$12,$FE,$12,$FC,$04,$F8,$C8
	DB $DF,$B2,$DF,$B2,$7E,$73,$1D,$1E
	DB $1A,$15,$1C,$14,$12,$1E,$1E,$1E
	DB $F8,$38,$50,$B0,$BC,$5C,$50,$B0
	DB $B0,$50,$E0,$A0,$90,$F0,$F0,$F0
	
; End of WIZARD.Z80	
;* END OF INCLUDE "tex/Sprites/Wizard/Wizard.z80"	
;* END OF INCLUDE "include.asm"	
	
section "Header", ROM0[$100]	
	
	    jp Entrypoint
; Loaded sources do not match the ROM from 103 to 14F	
	
	; Data from 103 to 103 (1 bytes)
	db $00
	
GBcartridgeHeader:	
	; Nintendo Logo: OK
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
	db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
	db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E
	
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Title
	db $00, $00, $00, $00 ; Manufacturer Code / End of Title
	db $00      ; CGB Flag: Game does not support CGB functions.
	db $00, $00 ; New Licensee Code
	db $00      ; SGB Flag: No SGB functions (Normal Gameboy or CGB only game)
	db $00      ; Cartridge Type: ROM ONLY
	db $00      ; ROM Size: 32 KByte 	no ROM banking
	db $00      ; RAM Size: None
	db $00      ; Destination Code: Japanese
	db $00      ; Old Licensee Code
	db $00      ; Mask ROM Version number
	db $E7      ; Header Checksum: OK
	dw $213F    ; Global Checksum: OK
	
    ds $150 - @, 0 ; Make room for the header	
	
Entrypoint: 	
	    ; Turn off audio
	    ld a, 0
	    ld [rNR52], a
	
	    ld a, 0
	    ld [gameState], a               ;Sets the game state to the start screen
	    ld [readyLoadSprites], a
	    ld [wFramesCounter], a
	
	    ;Gameplay vars
	    ld [playerTileX], a
	    ld [playerTileY], a
	    ld [currentTileStandingOn], a
	    ld [currentlyJumping], a
	    ld [pixelsLeftHopping], a
	
	    ;Startscreen vars
	    ld [startScreenMenuSelection], a
	    ld [startScreenState], a
	    ld [currentPositionStartArrowX], a
	    ld [currentPositionStartArrowY], a
	
	    ld a, 1
	    ld [selectedBattleMap], a
	    ld a, 4
	    ld [FlipSpritesDir], a
	    ld [CurrentFlipSpritesDir], a
	
	    ld a, 1                         ;Selects the wizard as the playable character
	    ld [playerSelectedCharacter], a
	
	    ;Init of the player
	    ld a, 50
	    ld [playerX], a
	    ld [playerY], a
	
	    ld a, 32
	    ld [hoppingHeight], a
    	
	    call WaitVBlank
	
;My main loop of the game. Basically a main(){} in c	
MainLoop:	
	    ;Wait for vblank
	    ld a, [rLY]
	    cp 144
	    jp c, MainLoop
	
	    ld a, [wFramesCounter]
	    inc a
	    ld [wFramesCounter], a
	    cp 60
	    call z, ResetCounter
	
	    ld a,[currentInput]
	    ld [lastInput], a
	
	    call InputButton        ;Takes the input
	
	    ld a, [gameState]
	    cp 0
	    call z, StartScreen_State
	    cp 1
	    call z, Playing_State
	
   	
	
.waitVBlankEnd:	
	    ld a, [rLY]
	    cp 144
	    jp nc, .waitVBlankEnd
	
	    jp MainLoop 
	
	
PrintA:	
	;   deb_msg A_msg
	            ld      d,d
	            jr      :+
	            dw      $6464           ; Two ASCII characters: "dd"
	            dw      $0001           ; Identifier for this debug message type
	            dw      A_msg
	            dw      bank(A_msg)
    :	
	;   END OF deb_msg
	    ret
	
A_msg:	
	    db "A=%A%", 0
	
ResetCounter:	
	    ld a, 0
	    ld [wFramesCounter], a
	    ret
;* BEGINNING OF Warrior.asm	
warriorSpriteData:	
warriorHead:	
    ; Y, X, Tile ID	
    db 0, 0, 0            ; Left top	
    db 0, 8, 1            ; Right top	
warriorBottom:	
    db 8, 0, 2            ; Left	
    db 8, 8, 3            ; Right	
	
DEF warriorNumSprites equ 16 * 4	
	
warriorAbilities:	
    ;Moving Type, hp, etc	
    db HOPPING   ;MovingStyle	
    db 200       ;HP	
	
	
warriorMoves:	
    ;Move id, Name, damage,speed px, durration (frames), type flags	
warriorSword:	
    db 0	
    db "Sword"	
    db 60	
    db 0	
    db 10	
    db MOVE_ATTACK	
warriorDefence:	
    db 1	
    db "Sheild"	
    db 0 	
    db 0	
    db 30	
    db MOVE_DEFEND	
warriorIceBlast:	
    db 2	
    db "Ice Blast"	
    db 20	
    db 10	
    db 30	
    db MOVE_ATTACK	
	
; This disassembly was created using Emulicious (https://www.emulicious.net)	
; If you want to reassemble this disassembly make sure to disable RGBDS optimizations.	
; To disable them use the -h and -L commandline flags when invoking rgbasm.	
	
SECTION "wram_c000", WRAM0[$C000]	
VariableExample: db	
wFramesCounter: db	
currentInput: db	
lastInput: db	
gameState: db	
selectedBattleMap: db	
readyLoadSprites: db	
FlipSpritesDir: db	
CurrentFlipSpritesDir: db	
playerX: db	
playerTileX: db	
playerY: db	
playerTileY: db	
currentTileStandingOn: db	
playerSelectedCharacter: db	
currentlyJumping: db	
pixelsLeftHopping: db	
hoppingHeight: db	
currentPositionStartArrowX: db	
currentPositionStartArrowY: db	
startScreenState: db	
startScreenMenuSelection: db	
	
; Ports	
rP1 EQU $00	
rAUDENA EQU $26	
rLCDC EQU $40	
rSCY EQU $42	
rSCX EQU $43	
rLY EQU $44	
rBGP EQU $47	
rOBP0 EQU $48	
rOBP1 EQU $49	
	    db 0                ; ID 0 - NONE (No characters on id 0)
	    db FLYING           ; ID 1 - Wizard
	    db HOPPING          ; ID 2 - 
	    db HOPPING          ; ID 3 - 
	    db 0, 0, 0            ; Left top
	    db 0, 8, 1            ; Right top
	    db 8, 0, 2            ; Left
	    db 8, 8, 3            ; Right
	    db FLYING   ;MovingStyle
	    db 160      ;HP
	    db 0
	    db "FireBall"
	    db 40
	    db 5
	    db 60
	    db MOVE_ATTACK
	    db 1
	    db "Sheild"
	    db 0 
	    db 0
	    db 30
	    db MOVE_DEFEND
	    db 2
	    db "Ice Blast"
	    db 20
	    db 10
	    db 30
	    db MOVE_ATTACK
	db $00, $00
	db $00, $00, $00, $00, $00, $00
	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
	    jp Entrypoint
	
	db $00
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
	db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
	db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Title
	db $00, $00, $00, $00 ; Manufacturer Code / End of Title
	db $00      ; CGB Flag: Game does not support CGB functions.
	db $00, $00 ; New Licensee Code
	db $00      ; SGB Flag: No SGB functions (Normal Gameboy or CGB only game)
	db $00      ; Cartridge Type: ROM ONLY
	db $00      ; ROM Size: 32 KByte 	no ROM banking
	db $00      ; RAM Size: None
	db $00      ; Destination Code: Japanese
	db $00      ; Old Licensee Code
	db $00      ; Mask ROM Version number
	db $E7      ; Header Checksum: OK
	dw $213F    ; Global Checksum: OK
	
	    ld a, 0
	    ld [rNR52], a
	    ld a, 0
	    ld [gameState], a               ;Sets the game state to the start screen
	    ld [readyLoadSprites], a
	    ld [wFramesCounter], a
	    ld [playerTileX], a
	    ld [playerTileY], a
	    ld [currentTileStandingOn], a
	    ld [currentlyJumping], a
	    ld [pixelsLeftHopping], a
	    ld [startScreenMenuSelection], a
	    ld [startScreenState], a
	    ld [currentPositionStartArrowX], a
	    ld [currentPositionStartArrowY], a
	    ld a, 1
	    ld [selectedBattleMap], a
	    ld a, 4
	    ld [FlipSpritesDir], a
	    ld [CurrentFlipSpritesDir], a
	    ld a, 1                         ;Selects the wizard as the playable character
	    ld [playerSelectedCharacter], a
	    ld a, 50
	    ld [playerX], a
	    ld [playerY], a
	    ld a, 32
	    ld [hoppingHeight], a
	    call WaitVBlank
	    ld a, [rLY]
	    cp 144
	    jp c, MainLoop
	    ld a, [wFramesCounter]
	    inc a
	    ld [wFramesCounter], a
	    cp 60
	    call z, ResetCounter
	    ld a,[currentInput]
	    ld [lastInput], a
	    call InputButton        ;Takes the input
	    ld a, [gameState]
	    cp 0
	    call z, StartScreen_State
	    cp 1
	    call z, Playing_State
	    ld a, [rLY]
	    cp 144
	    jp nc, .waitVBlankEnd
	    jp MainLoop 
	
	            ld      d,d
	            jr      :+
	
	            dw      $6464           ; Two ASCII characters: "dd"
	            dw      $0001           ; Identifier for this debug message type
	            dw      A_msg
	            dw      bank(A_msg)
	
	    ret
	
	    db "A=%A%", 0
	
	    ld a, 0
	    ld [wFramesCounter], a
	    ret
	
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $01, $02, $03, $01, $04, $03, $01, $05, $00, $01, $05, $00, $06, $04, $07, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $08, $09, $0a, $0b, $0c, $0d, $0b, $0e, $0f, $08, $0e, $0f, $10, $11, $12, $13, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $14, $15, $16, $17, $18, $19, $1a, $1b, $0f, $14, $1b, $0f, $14, $1c, $16, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $1e, $1f, $20, $21, $22, $23, $24, $22, $25, $1e, $22, $25, $26, $22, $27, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $01, $28, $29, $2a, $2b, $2c, $2d, $2b, $2e, $2d, $2f, $30, $2d, $31, $32, $33, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $08, $34, $0a, $0b, $11, $0a, $0b, $35, $36, $0b, $0e, $0f, $08, $37, $0a, $38, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $14, $39, $16, $17, $1c, $16, $17, $3a, $3b, $17, $1b, $0f, $14, $3c, $16, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $1e, $3d, $3e, $3f, $22, $27, $21, $1f, $20, $21, $22, $25, $1e, $22, $40, $1d, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $41, $42, $43, $44, $30, $33, $41, $45, $43, $41, $30, $43, $41, $30, $33, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $02,$02,$02,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$02,$02,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$04,$05,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$07,$08,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$06,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$09,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $06,$00,$00,$01,$00,$01,$00,$01,$00,$01
	DB $00,$01,$00,$01,$00,$01,$00,$01,$07,$09
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$02,$02,$03,$02,$03,$02,$03
	DB $02,$03,$02,$03,$02,$03,$02,$03,$02,$03
	DB $09,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	DB $0A,$0A,$0A,$0A
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$03,$08,$01,$12,$01,$03,$14
	DB $05,$12,$13,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$17,$09
	DB $19,$01,$12,$04,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$17,$01,$12,$12,$09,$0F,$12,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$0F,$0B,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$13,$0D,$01,$13,$08,$00,$07,$02
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$03,$08,$01,$12,$13,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$0D,$01,$10,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$13,$14,$01,$12,$14
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$0D
	DB $01,$10,$13,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$03,$08,$09
	DB $0E,$01,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$06,$09,$12,$13,$14,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$0F,$0B,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DB $1A,$1A,$1A,$1A,$1A,$1A
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FF,$FF,$21,$FF,$56,$FF,$89,$FF
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FF,$FF,$84,$FF,$6A,$FF,$91,$FF
	DB $6A,$FF,$94,$FF,$94,$FF,$94,$FF
	DB $6A,$FF,$91,$FF,$6A,$FF,$84,$FF
	DB $56,$FF,$29,$FF,$29,$FF,$29,$FF
	DB $56,$FF,$89,$FF,$56,$FF,$21,$FF
	DB $4C,$FF,$B3,$FF,$6C,$FF,$9B,$FF
	DB $64,$7F,$1B,$1F,$0C,$0F,$03,$03
	DB $CC,$FF,$33,$FF,$CC,$FF,$33,$FF
	DB $FC,$FF,$03,$FF,$CC,$FF,$33,$FF
	DB $B4,$FF,$B4,$FF,$75,$7F,$73,$7F
	DB $4C,$7F,$23,$3F,$14,$1F,$0F,$0F
	DB $33,$FF,$CC,$FF,$33,$FF,$CC,$FF
	DB $3F,$FF,$C0,$FF,$33,$FF,$CC,$FF
	DB $32,$FF,$CD,$FF,$36,$FF,$D9,$FF
	DB $26,$FE,$D8,$F8,$30,$F0,$C0,$C0
	DB $2D,$FF,$2D,$FF,$AE,$FE,$CE,$FE
	DB $32,$FE,$C4,$FC,$28,$F8,$F0,$F0
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$18,$18,$24,$24,$42,$42
	DB $7E,$7E,$42,$42,$42,$42,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$7C,$7C
	DB $42,$42,$42,$42,$7C,$7C,$00,$00
	DB $00,$00,$3E,$3E,$40,$40,$40,$40
	DB $40,$40,$40,$40,$3E,$3E,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$42,$42
	DB $42,$42,$42,$42,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$78,$78
	DB $40,$40,$40,$40,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$40,$40
	DB $7C,$7C,$40,$40,$40,$40,$00,$00
	DB $00,$00,$7E,$7E,$40,$40,$5E,$5E
	DB $42,$42,$42,$42,$7E,$7E,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $7E,$7E,$42,$42,$42,$42,$00,$00
	DB $00,$00,$7E,$7E,$18,$18,$18,$18
	DB $18,$18,$18,$18,$7E,$7E,$00,$00
	DB $00,$00,$7E,$7E,$02,$02,$02,$02
	DB $02,$02,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$42,$42,$44,$44,$58,$58
	DB $60,$60,$58,$58,$44,$44,$00,$00
	DB $00,$00,$40,$40,$40,$40,$40,$40
	DB $40,$40,$40,$40,$7C,$7C,$00,$00
	DB $00,$00,$42,$42,$66,$66,$5A,$5A
	DB $42,$42,$42,$42,$42,$42,$00,$00
	DB $00,$00,$62,$62,$52,$52,$52,$52
	DB $4A,$4A,$4A,$4A,$46,$46,$00,$00
	DB $00,$00,$3C,$3C,$42,$42,$42,$42
	DB $42,$42,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$7C,$7C,$42,$42,$7C,$7C
	DB $40,$40,$40,$40,$40,$40,$00,$00
	DB $00,$00,$38,$38,$44,$44,$44,$44
	DB $44,$44,$44,$44,$3E,$3E,$00,$00
	DB $00,$00,$7E,$7E,$42,$42,$7E,$7E
	DB $58,$58,$44,$44,$44,$44,$00,$00
	DB $00,$00,$3E,$3E,$40,$40,$3C,$3C
	DB $02,$02,$02,$02,$7C,$7C,$00,$00
	DB $00,$00,$7E,$7E,$18,$18,$18,$18
	DB $18,$18,$18,$18,$18,$18,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $42,$42,$42,$42,$3C,$3C,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $24,$24,$24,$24,$18,$18,$00,$00
	DB $00,$00,$42,$42,$42,$42,$42,$42
	DB $42,$42,$5A,$5A,$24,$24,$00,$00
	DB $00,$00,$42,$42,$46,$46,$34,$34
	DB $18,$18,$28,$28,$66,$66,$00,$00
	DB $00,$00,$7E,$7E,$02,$02,$0C,$0C
	DB $30,$30,$40,$40,$7E,$7E,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $01,$02,$00,$05,$06,$C9,$05,$AA
	DB $20,$9E,$12,$4C,$D0,$2C,$64,$18
	DB $B9,$00,$7D,$00,$AF,$00,$C5,$00
	DB $8F,$00,$99,$00,$DE,$00,$6D,$00
	DB $44,$00,$44,$00,$21,$00,$25,$00
	DB $29,$00,$48,$00,$42,$00,$02,$00
	    db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	    db $00, $ff, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	    db $00, $ff, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $7e
	    db $00, $ff, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
	    db $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $00, $ff, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00, $7f
	    db $00, $ff, $03, $fc, $00, $f8, $00, $f0, $00, $e0, $20, $c0, $00, $c0, $40, $80
	    db $00, $ff, $c0, $3f, $00, $1f, $00, $0f, $00, $07, $04, $03, $00, $03, $02, $01
	    db $00, $80, $00, $80, $7f, $80, $00, $80, $00, $80, $7f, $80, $7f, $80, $00, $80
	    db $00, $7e, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ff, $00, $ff, $00, $00, $00
	    db $00, $01, $00, $01, $ff, $01, $00, $01, $01, $01, $fe, $01, $ff, $01, $00, $01
	    db $00, $80, $80, $80, $7f, $80, $80, $80, $00, $80, $ff, $80, $7f, $80, $80, $80
	    db $00, $7f, $2a, $7f, $d5, $7f, $2a, $7f, $55, $7f, $ff, $00, $ff, $00, $00, $00
	    db $00, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $fa, $07, $fd, $07, $02, $07
	    db $00, $7f, $2a, $7f, $d5, $7f, $2a, $7f, $55, $7f, $aa, $7f, $d5, $7f, $2a, $7f
	    db $00, $ff, $80, $ff, $00, $ff, $80, $ff, $00, $ff, $80, $ff, $00, $ff, $80, $ff
	    db $40, $80, $00, $80, $7f, $80, $00, $80, $00, $80, $7f, $80, $7f, $80, $00, $80
	    db $00, $3c, $02, $7e, $85, $7e, $0a, $7e, $14, $7e, $ab, $7e, $95, $7e, $2a, $7e
	    db $02, $01, $00, $01, $ff, $01, $00, $01, $01, $01, $fe, $01, $ff, $01, $00, $01
	    db $00, $ff, $80, $ff, $50, $ff, $a8, $ff, $50, $ff, $a8, $ff, $54, $ff, $a8, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	    db $ff, $00, $ff, $00, $ff, $00, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01
	    db $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80
	    db $ff, $00, $ff, $00, $ff, $00, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f
	    db $f8, $07, $f8, $07, $f8, $07, $80, $ff, $00, $ff, $aa, $ff, $55, $ff, $aa, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80
	    db $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f, $d5, $7f, $aa, $7f
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $eb, $3c
	    db $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff
	    db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $80, $ff
	    db $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $ff, $80, $7f, $80, $aa, $ff
	    db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $80, $ff
	    db $7f, $80, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff
	    db $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $80, $ff
	    db $3f, $c0, $3f, $c0, $3f, $c0, $1f, $e0, $1f, $e0, $0f, $f0, $03, $fc, $00, $ff
	    db $fd, $03, $fc, $03, $fd, $03, $f8, $07, $f9, $07, $f0, $0f, $c1, $3f, $82, $ff
	    db $55, $ff, $2a, $7e, $54, $7e, $2a, $7e, $54, $7e, $2a, $7e, $54, $7e, $00, $7e
	    db $01, $ff, $00, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01, $01, $00, $01
	    db $54, $ff, $ae, $f8, $50, $f0, $a0, $e0, $60, $c0, $80, $c0, $40, $80, $40, $80
	    db $55, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $55, $ff, $6a, $1f, $05, $0f, $02, $07, $05, $07, $02, $03, $03, $01, $02, $01
	    db $54, $ff, $80, $80, $00, $80, $80, $80, $00, $80, $80, $80, $00, $80, $00, $80
	    db $55, $ff, $2a, $1f, $0d, $07, $06, $03, $01, $03, $02, $01, $01, $01, $00, $01
	    db $55, $ff, $2a, $7f, $55, $7f, $2a, $7f, $55, $7f, $2a, $7f, $55, $7f, $00, $7f
	    db $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $00, $ff
	    db $15, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	    db $55, $ff, $6a, $1f, $0d, $07, $06, $03, $01, $03, $02, $01, $03, $01, $00, $01
	    db $54, $ff, $a8, $ff, $54, $ff, $a8, $ff, $50, $ff, $a0, $ff, $40, $ff, $00, $ff
	    db $00, $7e, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ab, $76, $dd, $66, $22, $66
	    db $00, $7c, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7c, $ff, $00, $ff, $00, $00, $00
	    db $00, $01, $00, $01, $ff, $01, $02, $01, $07, $01, $fe, $03, $fd, $07, $0a, $0f
	    db $00, $7c, $2a, $7e, $d5, $7e, $2a, $7e, $54, $7e, $ab, $7e, $d5, $7e, $2a, $7e
	    db $00, $ff, $a0, $ff, $50, $ff, $a8, $ff, $54, $ff, $a8, $ff, $54, $ff, $aa, $ff
	    db $dd, $62, $bf, $42, $fd, $42, $bf, $40, $ff, $00, $ff, $00, $f7, $08, $ef, $18
	    db $ff, $00, $ff, $00, $ff, $00, $ab, $7c, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e
	    db $f9, $07, $fc, $03, $fd, $03, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01
	    db $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7e, $d5, $7e, $ab, $7c
	    db $f7, $18, $eb, $1c, $d7, $3c, $eb, $3c, $d5, $3e, $ab, $7e, $d5, $7e, $2a, $ff
	    db $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $fe, $01, $ff, $01, $a2, $ff
	    db $7f, $c0, $bf, $c0, $7f, $c0, $bf, $e0, $5f, $e0, $af, $f0, $57, $fc, $aa, $ff
	    db $ff, $01, $fc, $03, $fd, $03, $fc, $03, $f9, $07, $f0, $0f, $c1, $3f, $82, $ff
	    db $55, $ff, $2a, $ff, $55, $ff, $2a, $ff, $55, $ff, $2a, $ff, $55, $ff, $00, $ff
	    db $45, $ff, $a2, $ff, $41, $ff, $82, $ff, $41, $ff, $80, $ff, $01, $ff, $00, $ff
	    db $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $aa, $ff, $54, $ff, $00, $ff
	    db $15, $ff, $2a, $ff, $15, $ff, $0a, $ff, $15, $ff, $0a, $ff, $01, $ff, $00, $ff
	    db $01, $ff, $80, $ff, $01, $ff, $80, $ff, $01, $ff, $80, $ff, $01, $ff, $00, $ff
	DB $C0,$C0,$F8,$F8,$8E,$8E,$83,$83
	DB $81,$81,$8E,$8E,$F8,$F8,$C0,$C0
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $08,$08,$1C,$1C,$38,$28,$38,$28
	DB $38,$28,$38,$28,$38,$28,$7F,$67
	DB $40,$40,$E0,$E0,$70,$50,$70,$50
	DB $70,$50,$70,$50,$70,$50,$F0,$D0
	DB $FF,$A0,$FF,$90,$FF,$80,$FF,$8E
	DB $FF,$8E,$FF,$8E,$FF,$8E,$FF,$80
	DB $F8,$08,$F8,$08,$F8,$08,$F8,$38
	DB $F8,$38,$F8,$38,$F8,$38,$F8,$08
	DB $7F,$40,$FF,$BF,$75,$5F,$2A,$3F
	DB $35,$3F,$4A,$7F,$75,$7F,$4B,$7F
	DB $F0,$10,$E0,$E0,$50,$F0,$B0,$F0
	DB $50,$F0,$D0,$F0,$F0,$F0,$F0,$F0
	DB $E7,$FF,$9F,$FF,$FF,$FF,$99,$99
	DB $09,$09,$00,$00,$00,$00,$00,$00
	DB $E0,$E0,$A0,$E0,$C0,$C0,$80,$80
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $E7,$FF,$9F,$FF,$FF,$FF,$99,$99
	DB $10,$10,$00,$00,$00,$00,$00,$00
	DB $E0,$E0,$A0,$E0,$C0,$C0,$80,$80
	DB $80,$80,$00,$00,$00,$00,$00,$00
	DB $FE,$FE,$81,$FF,$40,$7F,$40,$7F
	DB $23,$3F,$2F,$3C,$7F,$72,$DF,$AD
	DB $00,$00,$F8,$F8,$7C,$E4,$FE,$82
	DB $FE,$12,$FE,$12,$FC,$04,$F8,$C8
	DB $DF,$B2,$DF,$B2,$7E,$73,$1D,$1E
	DB $1A,$15,$1C,$14,$12,$1E,$1E,$1E
	DB $F8,$38,$50,$B0,$BC,$5C,$50,$B0
	DB $B0,$50,$E0,$A0,$90,$F0,$F0,$F0
	DB $00,$00,$00,$00,$01,$01,$01,$00,$00,$00
	DB $03,$03,$03,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$01,$02,$02,$01,$00
	DB $00,$00,$00,$03,$03,$03,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$01
	DB $01,$01,$00,$00,$00,$00,$01,$02,$02,$02
	DB $02,$00,$00,$00,$00,$03,$03,$03,$00,$01
	DB $01,$00,$01,$01,$01,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$02
	DB $02,$02,$02,$00,$00,$00,$00,$00,$03,$03
	DB $01,$01,$01,$01,$01,$01,$01,$01,$01,$02
	DB $02,$02,$02,$02,$02,$00,$00,$00,$00,$00
	DB $01,$01,$01,$01,$02,$00,$00,$01,$01,$00
	DB $03,$03,$01,$02,$01,$01,$02,$02,$02,$01
	DB $01,$02,$02,$02,$02,$02,$02,$00,$00,$00
	DB $00,$00,$02,$02,$02,$02,$02,$00,$01,$01
	DB $00,$00,$03,$03,$01,$01,$02,$01,$01,$01
	DB $01,$01,$01,$02,$02,$02,$02,$02,$00,$00
	DB $00,$00,$01,$01,$01,$02,$02,$02,$01,$01
	DB $00,$01,$00,$00,$03,$03,$00,$01,$01,$01
	DB $01,$00,$00,$00,$00,$00,$00,$02,$02,$02
	DB $02,$02,$00,$00,$01,$00,$02,$02,$02,$02
	DB $01,$00,$01,$01,$00,$00,$03,$03,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $02,$02,$02,$02,$00,$00,$01,$00,$02,$02
	DB $02,$02,$01,$01,$00,$00,$00,$00,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $02,$02,$02,$00,$00,$00,$00,$00,$00,$01
	DB $00,$02,$02,$02,$00,$01,$01,$01,$00,$00
	DB $03,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$01,$01,$02,$02,$02,$01,$01,$01,$01
	DB $01,$00,$03,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$02,$02,$02,$02,$00,$00
	DB $00,$00,$00,$00,$03,$03,$01,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$01,$01,$00,$02,$02,$00
	DB $00,$00,$00,$00,$00,$01,$03,$03,$03,$01
	DB $00,$01,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$01,$01,$00,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$00,$00,$01,$00,$03
	DB $03,$03,$03,$03,$01,$01,$01,$01,$00,$01
	DB $01,$01,$01,$01,$01,$01,$00,$00,$00,$00
	DB $01,$01,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$03,$03,$03,$03,$03,$03,$00,$00,$00
	DB $01,$01,$01,$01,$01,$00,$00,$00,$00,$00
	DB $03,$03,$00,$01,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$01,$01,$01,$00,$03,$03
	DB $00,$01,$01,$01,$00,$00,$00,$00,$00,$03
	DB $03,$03,$03,$03,$03,$03,$01,$01,$01,$00
	DB $00,$00,$01,$00,$00,$00,$00,$00,$01,$00
	DB $03,$00,$00,$00,$00,$00,$03,$03,$03,$03
	DB $03,$03,$03,$03,$03,$03,$03,$03,$03,$00
	DB $00,$00,$00,$00,$01,$01,$00,$00,$00,$00
	DB $01,$01,$03,$03,$03,$03,$03,$03,$03,$03
	DB $03,$03,$02,$02,$00,$00,$00,$00,$03,$03
	DB $03,$03,$03,$03,$01,$00,$00,$01,$01,$00
	DB $00,$00,$00,$01,$01,$03,$03,$03,$00,$01
	DB $01,$00,$02,$02,$00,$01,$02,$00,$00,$01
	DB $00,$03,$03,$03,$03,$03,$03,$03,$00,$01
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $01,$00,$00,$00,$02,$00,$00,$01,$01,$02
	DB $00,$01,$01,$00,$00,$01,$01,$03,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$02,$00,$00,$00
	DB $00,$01,$00,$00,$00,$01,$01,$01,$01,$03
	DB $03,$03,$03,$00,$00,$00,$01,$01,$01,$00
	DB $00,$00,$01,$01,$01,$00,$00,$00,$00,$00
	DB $00,$00,$01,$01,$00,$00,$00,$00,$00,$01
	DB $01,$00,$03,$03,$03,$00,$00,$00,$01,$01
	DB $01,$00,$00,$00,$01,$01,$01,$00,$00,$00
	DB $00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$03,$03,$03,$00,$00
	DB $01,$01,$01,$00,$02,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$01,$01,$02,$00,$00
	DB $00,$00,$01,$00,$00,$00,$00,$00,$03,$03
	DB $00,$00,$00,$00,$00,$00,$02,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$01,$02,$00
	DB $00,$00,$00,$01,$01,$00,$00,$00,$00,$00
	DB $03,$03,$03,$01,$01,$00,$00,$00,$02,$00
	DB $00,$00,$01,$00,$00,$00,$01,$01,$01,$00
	DB $00,$00,$00,$00,$00,$01,$00,$00,$00,$00
	DB $00,$00,$03,$03,$03,$01,$01,$00,$00,$00
	DB $00,$00,$00,$00,$01,$00,$00,$00,$00,$02
	DB $02,$00,$00,$00,$00,$00,$00,$01,$00,$01
	DB $01,$00,$00,$01,$03,$03,$03,$03,$01,$01
	DB $01,$01,$01,$01,$01,$01,$01,$00,$00,$00
	DB $02,$02,$00,$00,$00,$00,$00,$00,$00,$01
	DB $01,$01,$00,$00,$01,$00,$03,$03,$03,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$02,$02,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$01,$03,$03
	DB $03,$03,$00,$01,$01,$01,$01,$01,$01,$01
	DB $00,$00,$00,$02,$02,$02,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	DB $01,$03,$03,$03,$01,$00,$00,$00,$00,$00
	DB $01,$00,$00,$00,$00,$02,$02,$02,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$03,$03,$03,$01,$01,$01,$01
	DB $01,$01,$01,$01,$02,$02,$02,$00,$00,$00
	DB $00,$00,$00,$00
	
	    ld a, JOYP_GET_CTRL_PAD     ;Loads the number that we send to the joypad register to ask for dpad
	    call .onenibble
	    swap a                      ;Swaps the lower 4 bits with the higher bits so we can have the whole input in one byte
	    ld b, a                     ;Store the input in b so we can accesess the other buttons
	    ld a, JOYP_GET_BUTTONS      ;Loads the number that we send to the joypad register to ask for buttons
	    call .onenibble
	    or b                        ;Combines the inputs into one single byte to have everything 
	    cpl                         ; Invert the bits so 1 is pressed
	    ld [currentInput], a    ;Stores the current input
	    ret
	
	    ldh [rJOYP], a              ;sends a request to the joypad register with either the value for the dpad or buttons, this will give a return
	    call .knownRet              ;a function that just take time so that the output stabalize, takes 10 cycles
	    ldh a, [rJOYP]              ;fetch the joypad multible times until it gets stable
	    ldh a, [rJOYP]
	    ldh a, [rJOYP]
	    and $0F                     ;0F = 00001111, The "and" masks the bits. Will only return 1 in the byte if both bits are 1. This will make it only keep the button inputs and remove the command we used to specify the buttons or dpad
	    ret
	
	    ret
	
	    ld a, [rLY]
	    cp 144
	    jp c, WaitVBlank
	    ld a, 0
	    ld [rLCDC], a
	    ld a, [gameState]
	    cp 0
	    call z, SetupChosenStartScreen
	    cp 1
	    call z, SetupChosenMap
	    call ClearOAM
	    ld a, [gameState]
	    cp 0
	    call z, WaitVBlank.loadStartStateSprites
	    cp 1
	    call z,  WaitVBlank.loadGameStateSprites
	    ld a, LCDC_ON | LCDC_BG_ON |LCDC_OBJ_ON
	    ld [rLCDC], a
	    ld a, %11100100
	    ld [rBGP], a
	    ld a, %11100100
	    ld [rOBP0], a
	    ld [rOBP1], a
	    ret
	
	    ld de, SelectArrow
	    ld bc, 1 * 16
	    ld hl, $8000
	    call CopyTiles
	    ret
	
	    ld b, 1
	    ld de, selectArrowData
	    call z, SetupSpriteData
	    ret
	
	    ld a, [readyLoadSprites]
	    cp 1
	    ld de, Wizard
	    ld bc, WizardNumSprites
	    call z, loadPlayerSprites
	    ld de, Wizard
	    ld bc, WizardNumSprites
	    call z, loadCPUSprites
	    ld b, 4
	    ld de, wizardSpriteData
	    call z, SetupSpriteData
	    ret
	
	    db 100, 100, 0            ; Left top
	
	    ld a, [selectedBattleMap]
	    cp 0
	    call z, LoadBattleArena1
	    cp 1
	    call z, LoadChineseStadium
	    ret
	
	    ld de, First
	    ld hl, $9000
	    ld bc, 4 * 16
	    call CopyTiles
	    ld de, WorldTileMap
	    ld hl, $9800
	    ld bc, WorldTileMapWidth * WorldTileMapHeight
	    call CopyTilemap
	    ret
	
	    ld de, First
	    ld hl, $9000
	    ld bc, 4 * 16
	    call CopyTiles
	    ld de, BattleArena
	    ld hl, $9800
	    ld bc, BattleArenaWidth * BattleArenaHeight
	    call CopyTilemap
	    ret
	
	    ld de, ChineseStadionTiles
	    ld hl, $9000
	    ld bc, 11 * 16
	    call CopyTiles
	    ld de, ChineseStadium
	    ld hl, $9800
	    ld bc, ChineseStadiumWidth * ChineseStadiumHeight
	    call CopyTilemap
	    ret
	
	    ld a, [startScreenState]
	    cp 0
	    jp z, LoadStartScreen
	    cp 1
	    jp z, LoadCharacterSelectScreen
	    ret
	
	    ld de, Letters
	    ld hl, $9000
	    ld bc, 26 * 16
	    call CopyTiles
	    ld de, StartScreenMap
	    ld hl, $9800
	    ld bc, StartScreenWidth * StartScreenHeight
	    call CopyTilemap
		jr nz, @ - 53
	    ld de, Letters
	    ld hl, $9000
	    ld bc, 26 * 16
	    call CopyTiles
	    ld de, CharacterSelectScreen
	    ld hl, $9800
	    ld bc, CharacterSelectScreenWidth * CharacterSelectScreenHeight
	    call CopyTilemap
	    ret
	
	    ld a, [de]
	    ld [hli], a
	    inc de
	    dec bc
	    ld a, b
	    or a, c
	    jp nz, CopyTiles
	    ret ;Returns to the initial caller of the function
	
	    ld a, [de]
	    ld [hli], a
	    inc de
	    dec bc
	    ld a, b
	    or a, c
	    jp nz, CopyTilemap
	    ret
	
	    ld hl, $8000        ;This is the memory location for the player. Never write over this
	    call CopyTiles
	    ret
	
	    ld hl, $8040
	    call CopyTiles
	    ret
	
	    ld hl, _OAMRAM
	    jp LoadSpriteLoop
	
	    ld a, [de]
	    ld c, a
	    ld a, [playerY]
	    add c
	    inc de
	    ld [hli], a
	    ld a, [de]
	    ld c, a
	    ld a, [playerX]
	    add c
	    inc de
	    ld [hli], a
	    ld a, [de]
	    inc de
	    ld [hli], a
	    ld a, [FlipSpritesDir]
	    cp 3
	    call z, flipSprites
	    call nz, notFlipSprites
	    dec b
	    jr nz, LoadSpriteLoop
	    ret
	
	    ld a, [B_OAM_YFLIP]
	    ld [hli], a
	    ret
	
	    xor a
	    ld [hli], a
	    ret
	
	    ld a, 0
	    ld b, 160
	    ld hl, STARTOF(OAM)
	    ld [hli], a
	    dec b
	    jp nz, ClearOAMLoop
	    ret
	
	    call MovingType
	    cp FLYING
	    jp z, FlyingMovement
	    cp WALKING
	    cp HOPPING
	    jp z, HoppingMovement
	    jp FlyingMovement
	
	    ld a, [playerSelectedCharacter]
	    ld hl, CharacterMovementTable
	    ld d, 0
	    ld e, a
	    add hl, de
	    ld a, [hl]
	    ret
	
	    ld a, [pixelsLeftHopping]
	    cp 0
	    call nz, ContinueCharacterJump
	    ld a, [currentInput]
	    and %01000000
	    ld b, a
	    ld a, [lastInput]
	    and %01000000
	    cp b
	    call nz, CharacterJump
	    call z, ReadyFallingDown
	    ld a, [currentInput]
	    bit 7, a
	    ld a, [currentInput]
	    bit 4, a
	    call nz, GoRight
	    ld a, [currentInput]
	    bit 5, a
	    call nz, GoLeft
	    ld a, [playerX]
	    call ChangePlayerOAMXAdv
	    ld a, [playerY]
	    call ChangePlayerOAMY
	    ret
	
	    ld a, [currentInput]
	    bit 6, a
	    call nz, MoveUp
	    ld a, [currentInput]
	    bit 7, a
	    call nz, MoveDown
	    ld a, [currentInput]
	    bit 4, a
	    call nz, GoRight
	    ld a, [currentInput]
	    bit 5, a
	    call nz, GoLeft
	    ld a, [playerX]
	    call ChangePlayerOAMXAdv
	    ld a, [playerY]
	    call ChangePlayerOAMY
	    ret
	
	    ld [$FE00], a ; Sprite 0 Y
	    ld [$FE04], a ; Sprite 1 Y
	    add 8
	    ld [$FE08], a ; Sprite 2 Y
	    ld [$FE0C], a ; Sprite 3 Y
	    ret
	
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    ret
	
	    ld a, [FlipSpritesDir]
	    cp 4
	    jp z, MoveSpritesLeft
	    ld a, [FlipSpritesDir]
	    cp 3
	    jp z, MoveSpritesRight
	    ret
	
	    ld a, [playerX]
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    add 8
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    ld a, $20
	    ld [$FE03], a ; Sprite 0 X
	    ld [$FE07], a ; Sprite 1 X
	    ld [$FE0B], a ; Sprite 2 X
	    ld [$FE0F], a ; Sprite 3 X
	    ld a, 3
	    ld [CurrentFlipSpritesDir], a 
	    ret
	
	    ld a, [playerX]
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    ld a, $00
	    ld [$FE03], a ; Sprite 0 X
	    ld [$FE07], a ; Sprite 1 X
	    ld [$FE0B], a ; Sprite 2 X
	    ld [$FE0F], a ; Sprite 3 X
	    ld a, 4
	    ld [CurrentFlipSpritesDir], a 
	    ret
	
	    ld a, [playerX]
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    add 8
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    ret
	
	    ld a, [playerX]
	    ld [$FE01], a ; Sprite 0 X
	    ld [$FE09], a ; Sprite 2 X
	    add 8
	    ld [$FE05], a ; Sprite 1 X
	    ld [$FE0D], a ; Sprite 3 X
	    ret
	
	    call getPlayerTileX
	    call getPlayerTileY
	    call getTileID
	    ret
	
	    ld a, [rSCY]
	    ld b, a
	    ld a, [playerY]
	    add b
	    srl a
	    srl a
	    srl a
	    ld [playerTileY], a
	    ret
	
	    ld a, [rSCX]
	    ld b, a
	    ld a, [playerX]
	    add b
	    srl a
	    srl a
	    srl a
	    ld [playerTileX], a
	    ret
	
	    ld h, 0
	    ld a, [playerTileY]
	    ld l, a
	    add hl, hl
	    add hl, hl
	    add hl, hl
	    add hl, hl
	    add hl, hl
	    ld d, 0
	    ld a, [playerTileX]
	    ld e, a
	    add hl, de              ; HL = (tileY * 32) + tileX
	    ld de, $9800
	    add hl, de
	    ld a, [hl]
	    ld [currentTileStandingOn], a
	    ret
	
	    ld a, 4
	    ld [FlipSpritesDir], a
	    ld a, [playerX]
	    cp 20
	    jr z, GoLeft.MoveBackgroundLeft
	    jr nz, GoLeft.MovePlayerLeft
	    ret
	
	    ld a, [playerX]
	    dec a
	    ld [playerX], a
	    ret
	
	    ld a, [rSCX]
	    dec a
	    ld [rSCX], a
	    ret
	
	    ld a, 3
	    ld [FlipSpritesDir], a
	    ld a, [playerX]
	    cp 140
	    jr z, GoRight.MoveBackgroundRight
	    jr nz, GoRight.MovePlayerRight
	    ret
	
	    ld a, [playerX]
	    inc a
	    ld [playerX], a
	    ret
	
	    ld a, [rSCX]
	    inc a
	    ld [rSCX], a
	    ret
	
	    ld a, [hoppingHeight]
	    ld [pixelsLeftHopping], a
	    ld a, [playerY]
	    dec a 
	    ld [playerY], a
	    ret
	
	    ld a, [pixelsLeftHopping]
	    dec a
	    ld [pixelsLeftHopping], a
	    ld a, [playerY]
	    dec a
	    ld [playerY], a
	    ret
	
	    ld a, [pixelsLeftHopping]
	    cp 0
	    call z, CheckCollisionFallingDown
	    ret
	
	    ld a, [currentTileStandingOn]
	    cp NoWalkTiles
	    call nc, FallingDown
	    ret
	
	    ld a, [playerY]
	    inc a
	    ld [playerY], a
	    ret
	
	    ld a, [playerY]
	    dec a
	    ld [playerY], a
	    ret
	
	    ld a, [currentTileStandingOn]
	    cp NoWalkTiles
	    ret z
	    ld a, [playerY]
	    inc a
	    ld [playerY], a
	    ret
	
	    ld a, [playerX]
	    inc a
	    ld [playerX], a
	    ld a, 3
	    ld [FlipSpritesDir], a
	    ret
	
	    ld a, 4
	    ld [FlipSpritesDir], a
	    ld a, [playerX]
	    cp 140
	    jr z, GoRight.MoveBackgroundRight
	    jr nz, GoRight.MovePlayerRight
	    ret
	
	    ld a, [rSCX]
	    inc a
	    ld [rSCX], a
	    ret
	
	    ld a, [playerX]
	    inc a 
	    ld a, [startScreenState]
	    cp 0
	    jr z, StartScreen_State.viewStartScreen
	    cp 1
	    jr z, StartScreen_State.viewCharacterSelectScreen
	    cp 2
	    jr z, StartScreen_State.viewMapSelectScreen
	    jr StartScreen_State.viewStartScreen
	
	    ret
	
	    ld a, [currentInput]
	    bit 7, a
	    call nz, StartScreen_State.incStartScreenSelection
	    ld a, [currentInput]
	    bit 6, a
	    call nz, StartScreen_State.decStartScreenSelection
	    ld a, [currentInput]
	    bit 0, a
	    call nz, StartScreen_State.passToCorrectState
	    call StartScreen_State.changeArrowLocation
	    ret
	
	    ld a, [currentInput]
	    bit 7, a
	    call nz, StartScreen_State.incStartScreenSelection
	    ld a, [currentInput]
	    bit 6, a
	    call nz, StartScreen_State.decStartScreenSelection
	    ld a, [currentInput]
	    bit 0, a
	    call nz, StartScreen_State.characterSelectionSet
	    ld a, [currentInput]
	    bit 1, a
	    call nz, GoToGame_State
	    call StartScreen_State.changeArrowLocation
	    ret
	
	    ld a, [startScreenMenuSelection]
	    ld b, a
	    cp 0
	    call z, StartScreen_State.setCharacter0
	    ld a, b
	    cp 1
	    call z, StartScreen_State.setCharacter1
	    ret
	
	    ld a, WizardID
	    ld [playerSelectedCharacter], a 
	    ret
	
	    ld a, WarriorID
	    ld [playerSelectedCharacter], a 
	    ret
	
	    ret
	
	    ld a, [startScreenMenuSelection]
	    ld b, a
	    cp 0
	    jp z, GoToSelectCharacter_State
	    ld a, b
	    cp 1
	    jp z, GoToSelectMap_State
	    ld a, b
	    cp 2
	    jp z, GoToGame_State
	    ret
	
	    ld a, [startScreenMenuSelection]
	    cp 2
	    ret z
	    ld a, [lastInput]
	    bit 7, a
	    ret nz
	    ld a, [startScreenMenuSelection]
	    inc a
	    ld [startScreenMenuSelection], a
	    ret
	
	    ld a, [startScreenMenuSelection]
	    cp 0
	    ret z
	    ld a, [lastInput]
	    bit 6, a
	    ret nz
	    ld a, [startScreenMenuSelection]
	    dec a
	    ld [startScreenMenuSelection], a
	    ret
	
	    ld a, [startScreenState]
	    ld b, a
	    cp 0
	    call z, StartScreen_State.setStartScreenLocation
	    ld a, b
	    cp 1
	    call z, StartScreen_State.setCharacterSelectLocation
	    ld b, 1
	    ld hl, _OAMRAM
	    jp StartScreen_State.LoadArrowLoop
	
	    ret
	
	    ld de, StartScreen_State.startScreenArrowLocations
	    call StartScreen_State.setSelection
	    ret
	
	    ld de, StartScreen_State.characterSelectArrowLocations
	    call StartScreen_State.setSelection
	    ret
	
	    ld a, [de]
	    inc de
	    ld [hli], a
	    ld a, [de]
	    inc de
	    ld [hli], a
	    ld a, 0
	    ld [hli], a
	    ret
	
	    db 9 * 8, 6 * 8
	    db 11 * 8, 6 * 8
	    db 16 * 8, 6 * 8
	    db 6 * 8, 8 * 8
	    db 8 * 8, 8 * 8
	    db 16 * 8, 2 * 8
	
	    ld a, [startScreenMenuSelection]
	    cp 0
	    ret z
	    inc de
	    inc de
	    dec a
	    jr StartScreen_State.setSelectionLoop
	
	    ld a, 0
	    ld [gameState], a
	    ld [startScreenState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	    call WaitVBlank
	    ret
	
	    ld a, 0
	    ld [gameState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	    ld a, 1
	    ld [startScreenState], a
	    call WaitVBlank
	    ret
	
	    ld a, 0
	    ld [gameState], a
	    ld [readyLoadSprites], a
	    ld [rSCY], a
	    ld [rSCX], a
	    ld a, 2
	    ld [startScreenState], a
	    call WaitVBlank
	    ret
	
	    call checkCollision
	    ld a, [currentInput]
	    bit 3, a
	    jp nz, GoToStart_State
	    call MovingCharacterTypes
	    ret
	
	    ld a, 1
	    ld [gameState], a
	    ld [readyLoadSprites], a
	    call WaitVBlank
	    ret
	
	ds 7188, $00
	ds 16384, $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
		ld d, b
VariableExample:	
		xor a
wFramesCounter:	
		ld a, h
currentInput:	
		adc a
lastInput:	
		reti
	
gameState:	
		dec l
selectedBattleMap:	
		ld l, d
readyLoadSprites:	
		ld e, l
FlipSpritesDir:	
		dec c
CurrentFlipSpritesDir:	
		sbc a, a
playerX:	
		call nz, $0C9A	; Possibly invalid
playerTileY:	
		pop bc
currentTileStandingOn:	
		and d
playerSelectedCharacter:	
		ret z
currentlyJumping:	
		jp $5146	; Possibly invalid
	
	db $FD
currentPositionStartArrowY:	
		rst $18
	db $FC
startScreenMenuSelection:	
		dec de
		cp $18
		ld d, $C7
		di
		adc b
		or a
		sub h
		xor l
		dec e
		dec d
		ld de, $95FC
		jr c, @ + 72
		add [hl]
		add sp, -35
		ld b, l
		rst $18
		ld l, h
		ld l, $06
		sbc a, d
		xor [hl]
		inc b
		rst $08
		ld e, e
		ld [hl], l
		ld e, b
		adc $06
		stop
		inc bc
		adc e
		dec hl
		and $97
		xor l
		sbc a, b
		or h
		ld a, e
		ld a, $3E
		sbc a, d
		sub a
	db $FD
		ld l, $3E
		inc c
		cp a
		inc c
		ld d, l
		sub d
		ld [$02B3], sp
		adc l
		ld [hl], h
		ld c, h
		ld e, e
		nop
		rst $00	; CharacterMovementTable
		xor a
		ret nz
		xor c
		ld e, b
		or e
		inc a
		dec d
		ld b, e
		dec bc
		cp $34
		adc b
		jr nc, @ + 71
		jr nz, @ + 39
		ld c, $B5
		and l
		ld l, h
		and c
		cpl
		cp e
		ld [hl], l
		ld l, h
		ld e, a
		dec sp
		add hl, de
		ldi a, [hl]
		jr z, @ - 80
		inc hl
		dec c
		adc b
		scf
		ei
		ccf
		adc c
		ld l, $F1
		ld e, d
		ld a, e
		sub d
		ld [bc], a
		call nc, $CA38	; Possibly invalid
		ld [hl], a
		rst $38
		reti
	
		ld h, $AB
		ld l, d
		ldh a, [c]
		ld sp, hl
		xor b
		ld h, [hl]
		ld c, l
		ld sp, $6EC1
		ld e, c
		cp e
		cp h
		push bc
		ld a, [$956E]
		call c, $2D1B	; Possibly invalid
		push de
		inc a
		sub c
		or a
		ld h, d
		dec sp
		dec e
		dec [hl]
		and a
		ld b, [hl]
		sub h
		ld c, [hl]
		inc c
		cp l
		inc h
		xor e
		ld h, l
		sub $9C
		ld [hl], h
		ldh a, [c]
	db $DB
		add hl, de
		sub [hl]
		sub $88
		dec h
		ldh a, [c]
		adc a
		cp l
		and b
		or $DC
		sbc a, c
		rst $00	; CharacterMovementTable
		adc [hl]
		push bc
		sub a
		adc c
		xor a
		rlca
	db $DD
		ld l, c
		inc h
		ld b, e
		ld [hl], a
		ld hl, $ABE6
		ld [hl], e
		sbc a, l
		ld h, e
		inc d
		add hl, de
		ld l, e
		pop af
	db $DD
		cp a
	db $DB
		and a
		xor d
		inc d
		jp $329F	; Possibly invalid
	
		dec l
		inc e
		ld l, c
		jp $91FF
	
		ldi a, [hl]
		ld a, [hl]
		ld [hl], $E5
		ld b, c
		ld a, b
		ld d, b
		ldi a, [hl]
		and l
	db $EC
		ld a, d
		or [hl]
		ld a, [de]
		ld d, b
		ccf
		ld b, h
		ld e, $B4
		rlca
		ld l, d
		add a
		or c
		ld a, c
		jp nc, $6DE6	; Possibly invalid
		sub d
	db $F4
		jp $593A	; Possibly invalid
	
		add [hl]
		and a
		ld d, e
		ld hl, sp+-62
	db $E3
		ld a, h
		push af
		pop bc
		rra
		ld b, h
		ld d, b
		call $6B32	; Possibly invalid
		ret nz
		ld [$172C], sp
		reti
	
		ld d, d
		adc c
		ld c, [hl]
		ld h, c
		rst $20
		rst $30
	db $E3
		ld hl, $A524
		ld h, b
		ld sp, hl
		ld e, c
		sbc a, d
		ld b, b
		ld a, $52
		add hl, sp
		ld e, l
		ld [hl], h
		rst $00	; CharacterMovementTable
		and e
		ld d, $46
		add hl, bc
		ld l, [hl]
		dec l
		ld d, [hl]
		push af
		ld l, $8B
		ld sp, hl
		ld [hl], a
		ld b, $7D
		rla
		dec h
		ld [$30B8], sp
		adc a
		dec [hl]
		sub e
		ld h, e
		ld h, $BA
		ld h, e
		call nc, $8791
		ret c
		ld [hl], d
	db $EC
		sub e
		and c
		push af
		ld [hl], h
		jp z, $47BC	; Possibly invalid
		ldh a, [_PORT_3A_]
		ld h, c
		inc e
		ld b, [hl]
		daa
		ld hl, $74D1
		ld c, a
		inc de
		cpl
		pop hl
		add sp, 104
		add $6A
	db $D3
		ld [hl], d
	db $EC
		add c
		ld a, h
		inc sp
		xor a
		ldh [$EE], a
		ld bc, $F1B8
		ld l, l
		add d
		and a
		ld b, [hl]
		and h
		ld b, [hl]
		ld d, h
		ld d, e
		jp nc, $453E	; Possibly invalid
		ld c, b
		jp $200E	; Possibly invalid
	
		ldh [c], a
		call nc, $9B83
		ld h, [hl]
		rst $38
		call $33D1	; Possibly invalid
		ld e, d
		ldh a, [c]
		ld e, d
		pop de
		rst $28
		ld hl, $07C5
		ld bc, $FD0E
		ret
	
	db $E4
		rst $28
		xor d
		ei
		and l
		ld c, e
		ld d, l
		ld sp, hl
		jr c, @ - 44
		rst $28
	db $E3
		xor [hl]
		and [hl]
		di
		ldi [hl], a
		pop hl
		call nc, $0D1D	; Possibly invalid
		ld e, [hl]
	db $EC
		xor e
		or e
		ld c, c
		daa
		ld h, b
		ld c, $F6
		ld a, c
		reti
	
		ldh [c], a
		or h
		ld b, [hl]
		add a
		ld l, h
		ld l, l
		ld l, $3F
		jr @ + 88
	
		ld h, b
		ld h, $C2
	db $EB
		adc c
	db $F4
		sbc a, a
		ld c, c
		dec de
	db $E3
		ret
	
	db $EC
		ld c, d
		ld c, [hl]
		call z, $C16C	; Possibly invalid
		or b
		cpl
		dec e
		call z, $02D7	; Possibly invalid
	db $EB
		or h
		ld c, e
		cp d
		and [hl]
		ld d, l
		push hl
		ld d, l
		rst $10	; wizardAbilities
		sub [hl]
		ld a, b
		dec b
		add e
		xor $00
		or l
		ret c
		rst $20
		ld e, h
		or c
		ld bc, $1FDE
		ld c, $6B
	db $F4
		xor d
		cp l
		ld [hl], $E4
		adc h
		inc bc
		ld a, a
		ld sp, hl
		xor b
		ld e, [hl]
		add l
		ld [hl], c
		sub e
		ld l, h
		and l
		call c, $97B3
		sbc $76
		rrca
		ld [de], a
		ld [de], a
		ld a, d
		sub b
		adc e
		ld l, [hl]
		ld e, d
		xor h
		cp e
		jp hl
	
		rst $08
		sbc a, l
		ld l, c
		reti
	
		ld e, [hl]
		rst $20
		ldh a, [rBGP]
		dec d
		ldd a, [hl]
		or h
		ei
		ld c, a
		ldh [c], a
		sbc a, c
		ld c, e
		ld bc, $938C
		ld h, c
		cp l
		xor h
		and $63
		cp e
		ld a, c
		rst $00	; CharacterMovementTable
		ld d, d
		di
		rlca
		ret z
		xor [hl]
		sbc a, b
		rst $18
		pop de
		ld c, d
		rst $30
		ld [hl], l
		or h
		xor $BD
		jp c, $48F4	; Possibly invalid
		ld d, a
		inc e
		ld a, [de]
		dec [hl]
		jp nc, $AFBD
		ld hl, $2A2F
		cp d
		and l
		and d
		dec hl
		ld e, a
		ld e, c
		jp c, $9A66
		ldd a, [hl]
		ldh [c], a
		inc c
		pop hl
		xor a
		cp $19
		ldd [hl], a
		sbc a, e
		jp hl
	
		ldd [hl], a
		ld hl, $2890
		or h
		inc [hl]
		ld c, a
		call c, $BC15
		ld b, b
		ldi [hl], a
		ld a, l
		xor $8C
		ei
		ld l, l
		or $48
		dec de
		stop
		ld a, b
		inc b
		ld a, [de]
		ld l, l
		sub l
		ldi a, [hl]
		scf
		or e
		ld c, l
		ret nc
		rst $28
		ld b, $71
		pop af
		rst $10	; wizardAbilities
		ld c, c
		ld b, d
		ld [hl], b
		jp c, $C4CF	; Possibly invalid
		ld l, c
		or l
		ld b, a
		ld e, [hl]
		adc [hl]
		cp $59
		xor d
		ld b, l
		ld e, d
		inc d
		ld e, c
		cp e
		dec b
		ld sp, hl
		adc [hl]
		ld e, l
		adc $28
		ld c, a
		ld hl, sp+-81
		ret nz
		xor l
		and c
		ld c, a
		or c
		ld d, a
		jr nz, @ + 99
		sub $3A
	db $F4
		push hl
		adc h
		or e
		push bc
		jr nc, @ + 117
		ld h, $67
		push af
		ld c, a
		ld l, l
		dec hl
		xor b
		ld l, l
		dec b
		adc $B9
		ld l, d
		dec sp
		inc [hl]
		ld d, b
		cp e
		stop
		sub l
		ld d, c
		sbc a, h
		push de
		dec l
		jr nc, @ + 98
		sra h
		ld l, a
		sub a
	db $DD
		dec a
		ld a, [de]
		jp $0D65	; Possibly invalid
	
		ld b, $41
		rst $30
		daa
		dec l
		ld [$AF90], sp
		ld l, $DA
		sub h
		jp nc, $C60D	; Possibly invalid
		dec d
		inc h
		sub e
		jr c, @ - 91
		sbc a, l
		cp d
		ld h, e
		ld b, b
		ccf
	db $EB
		adc e
		inc [hl]
		dec sp
		ld d, d
		ld h, [hl]
		or a
		ld a, c
		pop bc
		inc l
		jp hl
	
		dec e
		dec hl
		ld h, h
		ld c, d
		sub l
		adc a
		and b
		ld sp, hl
		ld [bc], a
		sub [hl]
		ld h, [hl]
		jp z, $8737
		ld l, d
		ld e, h
		ld l, [hl]
		ld e, d
		ld l, h
		rst $38
		ld d, b
		xor h
		ld hl, $F9C4
		ld c, [hl]
		ld e, $74
		ld l, $BA
		ld bc, $A7D5
	db $EB
		push hl
		ret
	
		add h
		ld d, [hl]
		halt
		dec sp
		dec a
		add e
		ld d, l
		rrca
		ld a, d
		inc a
		inc d
		ld c, $AD
		ret nz
		ld d, c
		and l
		inc l
		sbc $10
		dec a
		ld e, c
		sub b
		ld h, c
		push af
		sub l
		adc d
		sbc a, b
		sub a
		ret z
		rla
		ld c, h
		ld a, b
		ldh a, [$87]
		ld d, b
		ld d, e
		call c, $BB4F
		ld e, e
		inc de
		pop hl
		ldh [rSC], a
		ld h, l
		ld [$3043], sp
		add hl, hl
		ld l, c
		xor e
		rla
		ld [$61A2], sp
		scf
		ld h, [hl]
		ld d, b
		cp l
		ld d, h
		jr z, @ + 95
		add sp, -66
		ld d, $24
		add d
		call nz, $6E6D	; Possibly invalid
		xor [hl]
		ld l, l
		ld e, a
		ld l, a
		ld hl, $DE0A
		inc b
		or e
		ld d, e
		and h
		ld [de], a
		ld e, $53
		sbc a, c
		ld e, e
		sub a
		ret z
		ld d, a
		sbc a, d
		ld a, h
		ld b, d
	db $FC
		add d
		jp c, $4489	; Possibly invalid
		dec de
		add $E6
		inc sp
		ldh a, [c]
		ld h, c
		add h
		jr nc, @ - 22
		ld a, $DC
		cp b
		add hl, sp
		and e
		ld c, l
		xor e
		ld e, h
		and $6A
		jr @ + 1
	
		ld b, h
		ld e, a
		sub b
		inc l
		ld c, c
		xor e
	db $ED
		ld h, e
		ld bc, $80AD
		inc a
		cp b
		sbc a, d
		ld l, b
		dec sp
		sbc a, c
		add c
		rla
		rst $00	; CharacterMovementTable
		add hl, hl
		pop af
		ld c, a
		dec bc
		ret z
		ldh a, [rDMA]
		xor l
	db $ED
		rst $20
		adc h
		xor h
		ld [hl], l
		or b
		ld h, e
		inc h
		ld l, d
		ret nc
		and h
		ld [hl], c
		rst $38
		sbc a, d
		dec d
		xor e
		ldd a, [hl]
		ldh [c], a
		and l
		ld b, c
		rst $18
		sub d
		inc l
		inc bc
		ld h, c
		ld [hl], d
		inc b
		sbc a, e
		dec c
		cpl
		and $34
		sub $28
		ldh a, [$96]
		nop
		inc bc
		jp z, $330A	; Possibly invalid
		cp $62
		ld c, $D7
		rst $28
		adc b
		ld d, a
		ld b, h
		ldh a, [_PORT_0A_]
		and $EC
		jp $39E1	; Possibly invalid
	
		rlca
		xor d
		call $F6D5	; Possibly invalid
		adc $7E
		dec bc
		or $C6
		dec h
		sub [hl]
		cp $F2
		dec h
		inc sp
		sub b
		ld a, e
		inc sp
		ld l, h
		or b
		ld h, l
		ld l, h
		rst $28
		and a
		ld [$E098], sp
		ret nc
		rra
		ld d, c
		ld a, c
		ld a, d
		add l
		and b
		cpl
		ld e, b
		xor c
		cp d
		inc hl
		ld a, d
		ldi a, [hl]
		ld d, l
		adc d
		ld c, b
	db $F4
		call z, $5610	; Possibly invalid
		or a
		jr nc, @ + 85
		ld l, $92
		and e
		call c, $E437	; Possibly invalid
		inc a
		or c
		ld e, h
		or e
		and e
		dec l
		ld b, $92
		jr c, @ - 98
		ld a, [$DE13]
		ld h, a
		add hl, sp
		ret z
		ld c, c
		add hl, bc
		ld h, a
		rrca
		adc $D8
		add sp, 69
		ld e, l
		ld d, h
	db $EC
		inc bc
		ld a, l
		or h
		push hl
		ld [$2F16], a
		ld b, [hl]
		dec de
		sbc $AB
		add hl, de
		rla
		and c
		ldi a, [hl]
		add [hl]
		ret nc
		call $B6A6
		add l
		ldd a, [hl]
	db $DD
		adc e
		ld d, c
		adc [hl]
		jr @ - 87
	
		rra
		sub d
		cp $90
		inc [hl]
		ld b, b
		cp b
		ld b, l
		sbc $6F
		jr nz, @ - 119
		cp $D9
		rst $18
		adc c
		and l
		add hl, hl
		rst $10	; wizardAbilities
		ld h, c
		jr z, @ - 77
		cp [hl]
		ret
	
		call nz, $E094	; Possibly invalid
		or $79
		sub e
		sbc a, h
		xor d
		or h
		ld b, $6F
		nop
		rst $18
		sub d
		rlc c
		ld l, l
		add sp, 100
		ld a, [hl]
		ld a, [bc]
		sbc a, d
		sbc a, b
		ld h, a
		cp c
		ld a, [de]
		ld d, $DC
		adc h
		rst $00	; CharacterMovementTable
		add l
		ld a, [hl]
		sbc a, e
		add hl, hl
		sub [hl]
		ld l, h
		ld e, l
		dec h
		ld b, d
		ld c, d
		scf
	db $E4
		and $2F
		ld hl, $704B
		cp h
		jr nc, @ + 92
		ldd [hl], a
		ld b, l
	db $E3
		ret z
	db $FC
		ldh [c], a
		and $D1
		ld a, [hl]
		ld a, $63
		rst $10	; wizardAbilities
		rst $30
		sub h
		cp c
		ld h, a
		dec hl
		inc e
		add a
		ld l, $28
		ei
		rst $00	; CharacterMovementTable
		ld a, b
		cp [hl]
		dec bc
		ei
		dec l
		ld b, h
		jp c, $F089	; Possibly invalid
		rst $20
		call $A18E
		sub l
		xor h
		ld a, [bc]
		and h
		scf
		dec [hl]
		ld e, a
		add $20
		dec sp
		ld l, b
		rst $28
		jr nc, @ - 122
		adc a
		ldh [$BE], a
		and $CD
		ld a, b
		ld e, e
		ld a, [bc]
		xor [hl]
		ld sp, hl
		ld a, e
		cp a
		rst $30
		ldh a, [c]
		rst $18
		ldd [hl], a
		sub $EA
		add d
		ld a, e
		rlca
		ld hl, $1A8A
		rst $30
		reti
	
		ld c, e
		ld l, h
		ld b, [hl]
		inc [hl]
		cp b
		rst $10	; wizardAbilities
		xor b
		sbc a, [hl]
		jr c, @ - 29
		inc sp
		push de
		adc l
		ret z
		ld l, d
		ld [hl], e
		pop hl
		push af
		ld c, b
		add $EC
		sra b
		ld [hl], l
		ld c, [hl]
		inc c
		adc c
		rra
		dec l
		sbc a, c
		ld [hl], l
		dec d
		pop af
		ld a, e
		jr @ - 121
	
		ld a, $5C
		ld [$DFAC], a
		inc l
		ret c
		xor l
		call c, $D955	; Possibly invalid
		ret
	
		rst $10	; wizardAbilities
		cp [hl]
		dec sp
		and a
		call $677C	; Possibly invalid
		sbc a, l
	db $DD
		scf
		ld d, d
		jr z, @ - 70
		jr nc, @ + 31
		ld b, h
		add sp, 80
		ld d, [hl]
		ld a, [bc]
		sbc $4C
		rst $10	; wizardAbilities
		inc h
		rst $00	; CharacterMovementTable
		ld [hl], l
		sub $CB
		ld c, e
		adc l
		rlca
		call nc, $9AD1
		rlca
		sub c
		ld c, d
		ret nz
		dec a
		ld c, [hl]
		ld b, $8E
		sub h
		or h
	db $D3
		ld de, $24EF
		ld d, e
		jp nc, $3FD1	; Possibly invalid
		ld e, [hl]
		xor h
		sub c
		xor a
		ld h, l
		or l
		dec c
		dec a
		ld [$1D1B], sp
		jp nc, $2FDD	; Possibly invalid
		ld c, [hl]
		rst $18
		ld c, l
		ldh a, [c]
		ld h, c
		inc d
		ld b, l
		dec c
		rst $08
		cp e
		adc h
		call c, $3981	; Possibly invalid
		ret c
		rst $30
		stop
		ld e, h
		adc b
		and h
		ld d, e
		add d
		add b
		ld d, c
		ld [hl], h
		add h
		sub e
		sub e
		ld a, b
		rst $28
		and c
		inc l
		or $24
		sbc a, d
		ld d, e
		ld e, d
		and a
		inc de
		ld d, l
		cp b
		ld a, [de]
		ld h, [hl]
		cp e
		ld [hl], c
		pop bc
		adc e
		ld a, [bc]
		ret
	
		ld [hl], $5A
		rst $10	; wizardAbilities
		sbc a, d
		daa
		dec c
		ld a, [bc]
		cp d
		pop de
		adc $26
		sbc a, b
		ld b, [hl]
		ld e, l
		adc c
		ld l, [hl]
		or d
		sub h
		ld c, a
		dec [hl]
		add l
		ld e, h
		pop af
		xor a
		ld d, h
		sub d
		ld d, h
		ldh a, [_PORT_4E_]
		add hl, hl
		sub a
		dec bc
		ld [de], a
		ld a, [hl]
		dec l
		adc a
		ld a, l
		ld h, [hl]
		ld b, b
		xor e
		rst $18
		add [hl]
		ld a, l
		ld l, c
		cp d
		ld [hl], l
		jp $5AD9	; Possibly invalid
	
		adc a
		ld a, b
		cp e
		dec c
		sbc a, d
		dec hl
		ld [hl], $1A
		ldh [c], a
		ldi [hl], a
		ld [$098B], a
		adc c
		sub c
		ldh a, [$99]
		xor c
		ldi [hl], a
		adc [hl]
		ld h, c
		ld sp, hl
	db $DD
		reti
	
	db $E4
		inc hl
		ld h, c
		ldd a, [hl]
		xor $7B
		and l
	db $E3
		jr c, @ - 53
		sbc a, c
		sbc a, d
		ld c, $EF
	db $F4
		jr c, @ - 28
		sbc a, [hl]
		ld b, b
		sbc a, l
		ld d, e
		ldh a, [$B9]
		call $B1EE
		ld h, a
		sbc a, d
		swap a
		dec l
		sbc $5A
		inc e
		ld [bc], a
		ld [$047D], a
		ld [$8EAF], sp
		sbc a, d
		add hl, bc
		jr nc, @ - 105
		ldd a, [hl]
		ret z
		ld c, [hl]
		xor e
	db $D3
		and h
		xor [hl]
		push af
		ei
		xor c
		ld d, d
		rst $00	; CharacterMovementTable
		ld d, l
		and d
		push af
		jp $7C25	; Possibly invalid
	
		sbc a, b
		halt
		rlca
		ld h, $AF
		add a
		ld h, l
		add sp, 30
		add sp, -36
		ld l, h
		rra
		xor l
		sub d
		ld d, a
		call c, $C2E0	; Possibly invalid
		add d
		rra
		call c, $1B95	; Possibly invalid
		ld a, h
		dec sp
		add hl, de
		sub [hl]
		dec e
		halt
		ld a, a
		ldd a, [hl]
		ld e, a
		dec l
		ld [hl], d
		xor [hl]
		sbc a, [hl]
		xor [hl]
		dec sp
		xor l
		dec e
		adc l
		dec bc
		ld h, l
		inc [hl]
		add hl, bc
		ld [de], a
		or b
		dec hl
		ld h, [hl]
		cpl
		adc a
		ret c
	db $ED
		dec sp
		ld d, b
		jp nz, $B1BD
		add l
		and e
		cp l
		reti
	
		dec a
		ld a, [hl]
		ld d, $B5
		rlca
		sub $56
		ld d, $79
		ld [hl], c
		ld h, l
		ld e, h
		pop hl
		ldh a, [_PORT_52_]
		ld a, a
		ld [hl], d
		add e
		ld b, b
		ld b, c
		ld l, c
		ld b, h
		ccf
		ld [hl], l
		or b
		ld e, $02
		ld c, b
		ld l, e
		ld c, e
		jr @ + 41
	
		ld d, a
		rlca
		ld d, $FB
		inc c
		dec a
		or h
		or l
		ld c, d
		dec [hl]
		ldi a, [hl]
		or b
		xor b
		dec sp
		add a
		add sp, -5
		dec a
		dec h
		add l
		rst $08
		ld l, a
		inc d
		ld a, [hl]
		sub c
		sbc a, e
		or b
		or h
		rst $30
		ld sp, hl
		sub c
		jr @ + 66
	
		cp b
		or $E1
		or [hl]
		sbc a, e
		call nc, $86BE
		add hl, bc
		cp a
		cp e
		reti
	
		ldi a, [hl]
		ld a, b
		ld e, e
		daa
		dec h
		ld b, a
		set 7, c
		rst $00	; CharacterMovementTable
		ld d, $A1
		and [hl]
		jp nc, $3767	; Possibly invalid
		or a
		push hl
		or $B9
		ld b, e
		ld a, l
		ld a, b
		jr nc, @ + 54
		and [hl]
		dec hl
		ld d, [hl]
		ld [hl], c
		ld a, [hl]
		ld b, $EE
		jp hl
	
		add hl, sp
	db $EC
		ld a, [de]
		inc c
		or b
		call nz, $8463
		ld a, [bc]
		ld d, d
		cp b
		sbc a, b
		push de
		sub l
		ld sp, $8CFF
		ld [bc], a
	db $ED
		dec [hl]
		ld bc, $3951
		adc $69
		rra
		ld l, $09
		dec l
		ret nc
		sbc a, l
		sub c
		sbc a, d
	db $DD
	db $EB
		ld c, e
		sub c
		ld c, a
		ldd [hl], a
		ld [hl], l
		jp z, $5D79	; Possibly invalid
		ld c, b
		jr nz, @ - 96
		ld d, l
		ld a, [bc]
	db $EC
		ret c
		jr z, @ + 55
		reti
	
		sub a
		ld c, e
		ld l, $95
		rla
		ld a, b
		call z, $5E0D	; Possibly invalid
	db $DB
		ld b, c
		rst $38
		ld e, a
	db $EB
		ld h, d
		ld [de], a
		adc c
		dec l
		jp c, $DC28	; Possibly invalid
		ld c, d
		dec a
		xor $D3
		reti
	
		jp nc, $6985	; Possibly invalid
		rst $38
		or [hl]
		cp h
		inc h
		ret z
		ld [hl], l
		inc [hl]
		adc e
		ld c, l
		jp hl
	
		ld [hl], a
		ldh a, [$A0]
		add c
		ld l, h
		and b
		ld [hl], h
		adc e
		jp nc, $A388
		add l
		daa
		xor h
		ld h, d
		or e
		adc c
		cp c
		inc hl
		ldi [hl], a
		sbc a, h
		scf
		ld [bc], a
		ld d, b
		ld e, c
		ld h, l
		ld d, d
		or d
		ld b, [hl]
		sub l
		cp $58
		ld h, c
		add sp, -93
		ret nc
		sub b
		adc l
		adc d
		and d
		ld d, c
		ld c, $F2
		ld d, l
		jr z, @ - 3
		jp hl
	
		jp c, $2617	; Possibly invalid
		ld [hl], h
		ld h, e
		ld b, h
	db $FD
		ld h, c
		sbc $3F
		dec e
		sbc a, h
		ld sp, $7EBD
	db $D3
		ld e, e
		ld d, d
		ld hl, sp+112
		ld a, a
		inc e
		sbc a, d
		ld e, [hl]
		sub l
		ret nc
		ld sp, hl
		dec d
		xor c
		ld c, $00
		ld l, c
		cp a
		ld c, h
		xor e
		rrca
		sbc a, a
		xor [hl]
		xor a
		ldh [c], a
		ld e, [hl]
		ld d, h
		sbc a, b
		ld d, e
		jr nz, @ + 100
		push de
		or d
		add sp, -127
	db $EB
		ccf
		cp $AA
		jr z, @ + 83
		rst $18
		rlca
		ld e, d
		add l
		ld e, h
		ld a, a
		inc de
		add $57
		and c
		adc $5F
		dec a
		dec sp
		ld h, [hl]
		and d
		ldi [hl], a
		ld l, h
		rst $08
		xor c
		dec c
		dec e
		add c
		ld b, b
		add b
		or h
		ld [hl], l
		ld a, [bc]
		daa
		and b
		rlca
		inc de
		add h
		inc sp
		push bc
		ld b, $E3
		sub $FB
		ld hl, sp+56
		ld [hl], l
		sbc a, b
		sub l
		ld a, [$A6D7]
		ldi [hl], a
		add $6B
	db $FC
		di
		ret nz
		inc hl
		ld d, c
		call c, $51E6	; Possibly invalid
		sbc a, d
		ld e, e
		inc bc
		sbc a, d
		and a
		ld b, h
		ldi [hl], a
		or $4B
		ret
	
		inc bc
		dec l
		rst $20
		ei
		ld a, d
		and [hl]
		or $4B
		sub h
		ld de, $2188
		ld l, d
		add e
		ld hl, $EEF2
		adc c
		sbc a, c
		add hl, de
		ld c, b
		dec de
		ld h, $55
		add b
	db $DD
		ld e, c
		dec h
		add c
		adc d
		xor e
		ld l, e
		and b
		add hl, de
		cp [hl]
		ld h, l
		ld b, l
		ld h, $60
		sbc a, e
		or [hl]
		add h
		ld b, d
		rst $00	; CharacterMovementTable
		call nz, $0201	; Possibly invalid
		inc l
		dec a
		cp e
		ld b, b
		ld a, [de]
		ld c, a
		inc sp
		or b
		add [hl]
		xor d
		ld c, d
		ld b, d
		rst $10	; wizardAbilities
		ldd [hl], a
		ret nc
		inc sp
		ld d, c
		rra
		ld a, e
		rra
		cpl
		ld a, e
		push af
		ld h, c
		add hl, sp
		sbc a, b
	db $FC
		sub h
		sbc a, d
		ld h, a
		dec [hl]
		ld b, $EC
		ld sp, $DE5B
		ld e, a
		sub b
		jp $E6B6	; Possibly invalid
	
		jp c, $5E55	; Possibly invalid
		xor b
		or e
		xor d
		set 4, l
		ld [$AC09], a
		dec h
		jr nz, @ + 38
		ld h, e
		dec bc
		reti
	
		ldh [$92], a
		cp e
		push hl
		ld [$5697], a
		ld h, c
		rst $38
		ld c, a
		ld a, [hl]
		rst $30
		ldh [c], a
		ld b, [hl]
		and c
		ld d, [hl]
		adc h
		ldd [hl], a
		ld [$369D], a
		cp l
		dec l
		adc b
	db $EB
		ld [de], a
		add [hl]
		jp nc, $533D	; Possibly invalid
		or a
		rrca
		ld h, [hl]
		ld d, e
	db $FC
		dec l
		or $69
		ldi [hl], a
		adc h
		ld e, e
		ld c, a
		ld c, c
		add h
		add hl, hl
		or [hl]
		ld [de], a
		ld hl, sp+20
		sbc a, b
		reti
	
		ld h, b
		ld d, d
		and h
		inc a
		rst $08
		ld [$5251], sp
		ld [bc], a
		and l
		sub d
		or [hl]
		sbc a, d
		dec bc
		cp $37
		cp e
		ld e, a
		inc [hl]
		ld l, e
		rrca
		ld c, d
		sub l
		pop hl
		ld [$F188], sp
		adc b
		ld b, e
		or d
		ld l, $0E
		rst $38
		rst $38
		stop
		dec b
		xor [hl]
		ld [hl], h
		ret z
		call nz, $7745	; Possibly invalid
		cp e
		ld e, a
		ldi [hl], a
		jp z, $79B8	; Possibly invalid
		ld a, [bc]
		sub d
		ld h, h
		ld e, $24
		ld b, b
	db $EB
		ldd a, [hl]
		inc a
		pop bc
		call nc, $7439	; Possibly invalid
		rst $18
	db $E3
		cp $5C
		ld de, $0B5B
		ld de, $837F
		halt
		ld d, l
		ld d, d
		or l
		ld l, [hl]
		ld e, d
		and b
		or $77
		rst $10	; wizardAbilities
		inc sp
		cpl
		adc e
		add l
		and e
		call z, $C482	; Possibly invalid
		ld hl, $021A
		ld c, $55
		dec hl
		ld b, $8B
		cp d
		ld l, $69
		ld e, a
		or $43
		cp b
		inc a
		sub [hl]
		sbc a, l
		sub b
		halt
		pop de
		xor h
	db $D3
		and c
		nop
		xor [hl]
		adc e
		ld [$0380], a
		ld bc, $F0A1
		ld e, h
		ld d, [hl]
		ld e, a
		xor b
		ld c, h
		add l
		xor l
		ld h, [hl]
		jr c, @ - 64
		stop
		push af
		ret nc
		sub b
		inc h
		sbc a, a
		ld sp, hl
		ld h, c
		ret c
		ld [hl], c
		rst $18
		xor d
		ld [bc], a
		ld b, [hl]
		ld d, b
		add $D3
		dec l
		add $DB
		add d
		ld c, $9C
		ldh a, [_PORT_78_]
		ld h, a
		ld d, a
		add l
		push de
		ld l, a
		sub a
		ld l, l
		reti
	
	db $F4
		inc b
		add sp, 81
		ld l, l
		cp a
		ld [hl], c
		ld a, a
		or l
		ld a, [de]
	db $F4
		ccf
		ld [hl], d
		ld d, d
		sbc a, e
		inc a
		ld c, [hl]
		push de
		ld c, e
		adc c
		ld c, l
	db $EB
		ret z
		add hl, hl
		jr c, @ + 53
		ld l, c
		ld [hl], h
		dec h
		ld l, [hl]
		jp $66F8	; Possibly invalid
	
		ld e, $66
		ret
	
		ld c, c
		or h
		cp l
		and e
		add [hl]
		ld b, c
		daa
		or e
		inc [hl]
		sbc a, a
		dec de
		sbc a, d
		jp nz, $BD20
		pop af
		ld hl, sp+-105
		or a
		ld l, d
		add h
		ld e, e
		inc [hl]
		push de
		xor b
		jr nc, @ + 119
		stop
		adc d
		pop de
		ld [hl], a
		dec e
		jp c, $2B8E	; Possibly invalid
		inc d
	db $DD
		ld b, h
		cp c
		ld [hl], l
		or b
		sbc a, [hl]
		xor l
		cp l
	db $EB
		ld h, b
		ld h, c
		inc e
		jr @ + 113
	
		ld h, h
		push bc
		ld hl, $D0A9
		ld d, $1B
		ld a, [de]
		cp $2A
	db $DB
		sub [hl]
		inc b
		pop hl
		dec l
		halt
		add h
		adc $5F
		jr c, @ - 36
		bit 2, b
		ld a, e
		jp nz, $E505	; Possibly invalid
		ld a, $A7
		sub l
		push hl
		sub e
	db $EB
		jr c, @ - 125
		sub $EE
		ld [hl], $AD
		ld e, [hl]
		ld d, l
		ccf
		and l
		cp l
		ld d, c
		ld c, e
		jr c, @ + 80
		ld h, l
		ld b, h
		ret nz
		ld c, d
		add hl, bc
		xor $A2
		ld d, [hl]
		ldd [hl], a
		ld [hl], d
		ldi [hl], a
		ld a, b
		ld hl, $F56E
		ld e, [hl]
		cp a
		dec c
	db $EB
		dec bc
	db $EC
		and h
		rst $28
		add d
		add h
	db $ED
		ld b, d
		push bc
		adc l
		ld a, c
		ld c, e
		ld d, c
		or d
		rst $20
		ld l, [hl]
		dec e
	db $F4
		adc c
		ret nc
	db $EB
		xor [hl]
		dec bc
	db $E3
		ld a, a
		ld h, b
		adc l
		sub [hl]
		call nc, $2A46	; Possibly invalid
		scf
		ld e, $48
		jp c, $6D0B	; Possibly invalid
		sbc a, h
		or e
		ld a, b
		ld l, l
		adc a
		rst $20
		ld bc, $057F
		ld l, b
		cp $FC
		ld hl, $298C
		daa
		jp nc, $1C20	; Possibly invalid
		ldi [hl], a
		inc sp
		ld h, h
		jp hl
	
		ld sp, $62BC
		adc c
		rst $20
		ldi [hl], a
		add d
		ld b, [hl]
		and c
		add a
		ld d, [hl]
		add d
		add hl, bc
		ccf
		add d
		rla
		ld h, b
		sub [hl]
		ldi a, [hl]
		sbc $7A
		push hl
		call nz, $2E44	; Possibly invalid
		ld d, h
		push hl
		inc a
		or b
		call nc, $258E	; Possibly invalid
		rst $30
		ret
	
		jr c, @ - 101
		dec a
		ld c, e
		and d
		ld e, d
		ld sp, $D532
		dec [hl]
		sbc a, h
		add hl, hl
		pop af
		jp nz, $298D	; Possibly invalid
		ld a, d
		ret
	
		add sp, 42
		cp h
		ldd [hl], a
		ld d, [hl]
		pop de
		push hl
		ld e, e
		inc h
		add a
		call nc, $1E97	; Possibly invalid
		ld e, d
		sbc a, c
		rst $38
		ld [de], a
		ld h, c
		ld d, d
		daa
		rst $18
		sub [hl]
		ld a, b
		sub $2E
		jp nz, $FD7D	; Possibly invalid
		sub [hl]
		ld l, a
	db $F4
		adc d
		dec [hl]
		add c
		ld h, l
		ld c, d
		adc a
		or d
		adc $4B
		ret z
		dec h
		inc hl
		reti
	
		ret
	
		inc sp
		rla
	db $FD
		ld l, $79
		ld a, d
		add hl, sp
		ld [$7A25], a
		ld b, $E6
		rst $10	; wizardAbilities
		jr z, @ + 66
		or e
		ld l, c
		xor c
		ld a, c
		xor b
		inc b
		ld c, $06
		cp c
		or l
		jr @ + 13
	
		ldh [_PORT_0E_], a
		pop hl
		or [hl]
		inc d
		pop bc
		rla
		ld e, c
		ld c, $CF
		ld a, [de]
		sbc a, a
		rla
		add hl, bc
		bit 4, e
		ld h, b
		xor d
		ld l, h
		ld [hl], $C6
		ld c, d
		ld a, d
		ld b, d
		rst $38
		ld a, l
		dec e
		ld a, l
		halt
		adc a
		nop
		dec hl
		ret c
		ld c, $32
		ld c, c
		ld l, c
		xor b
		ld a, c
		xor a
		ld e, a
		rrca
		sbc a, h
		sbc a, d
		ld h, c
		rst $00	; CharacterMovementTable
		ld l, h
		ld b, b
		srl l
		rra
	db $E4
		ld l, $50
		inc l
		ld [hl], e
		ld l, a
		ld h, b
		ld [de], a
		ldh [c], a
		ldh [c], a
		ldi a, [hl]
		ld h, e
		add e
		ld l, b
		xor [hl]
		and d
		ret nc
		ldh a, [c]
		adc l
		ldd a, [hl]
		rst $10	; wizardAbilities
		and d
		and b
		xor h
		and c
		call c, $E0BD	; Possibly invalid
		ld c, $45
		ld b, a
		ld b, $CA
	db $ED
		rra
		cp c
		ld c, c
		inc bc
		dec d
		ld e, h
		xor h
		cp [hl]
		dec b
	db $EC
		pop hl
		ld b, a
		ld [hl], e
		cp d
		or e
		sub a
		and c
		adc a
		ret nz
		ld l, c
		add l
		dec e
		inc a
		ld d, b
	db $FD
		ldd a, [hl]
		sbc $F6
		ld e, b
		adc e
		ld l, h
		sbc a, [hl]
		ld a, [de]
		ld d, l
		ld b, a
		jp c, $6B08	; Possibly invalid
		call nz, $2995	; Possibly invalid
		rra
		rrca
		call nc, $FC83	; Possibly invalid
		ld a, $06
		ld h, c
		ld a, [$BC5D]
		ccf
		ld d, c
		ld l, $F9
		inc b
		ld b, h
		sub l
		ld l, [hl]
		xor d
		inc hl
		ldh [c], a
		cp l
		ld sp, $12AE
		pop de
		add hl, bc
		adc a
		ld c, l
		ld b, d
		ld b, l
		cp c
		jp $4246	; Possibly invalid
	
		rst $08
		sub [hl]
		ld e, b
		dec de
		jp nc, $1612	; Possibly invalid
		ld c, l
		or d
		ld a, b
		ld [bc], a
	db $D3
		ld a, $37
		call nz, $D520	; Possibly invalid
		call $B5B9
		add sp, 13
	db $FC
		ld a, c
		add hl, hl
		add l
		ld a, d
		ld e, l
		pop af
		or $D9
		ld d, d
		add $5E
		ret nz
		xor h
		ret nc
		ldi [hl], a
		adc [hl]
		xor c
		xor l
		or e
		jr nc, @ - 32
		or l
	db $E4
		or $EF
		ld l, a
		ld c, [hl]
		ld h, l
		and l
		bit 0, c
		sub c
		call nz, $3092	; Possibly invalid
		or e
		sbc a, h
		inc bc
		inc e
		add e
		adc b
		pop hl
		sub e
		call z, $06FF	; Possibly invalid
		xor h
		sbc a, c
	db $DB
		cp e
		dec sp
		ld [hl], $5A
		ldh a, [c]
		di
		add hl, bc
		ld [hl], a
		rst $20
		ld h, a
		dec l
		ld hl, sp+-80
		dec b
		xor e
		xor e
		ld h, d
		daa
		rrca
		push bc
		and a
		jp nz, $46A0	; Possibly invalid
		jr z, @ + 26
		or l
		cp a
		jp c, $EDA0	; Possibly invalid
		inc d
	db $EC
		or c
		ld b, e
		ld l, h
		add a
		or b
		ld l, d
		ret z
		ld e, c
		ld d, a
		and c
		ld h, l
		and l
	db $EC
		ld l, [hl]
	db $D3
		ld l, d
		ld l, a
		xor b
		cp b
		pop de
		ld d, $26
		jp z, $8138
		ld c, b
		call nc, $467A	; Possibly invalid
		ld c, $DD
		adc b
		ld d, b
		ld a, $B2
		ld [hl], e
		ld b, a
		dec d
		ld d, d
		ccf
		ld l, d
		jp nc, $4E27	; Possibly invalid
		ld a, c
		ld [de], a
		ldi a, [hl]
		ld a, [bc]
		ld l, e
		reti
	
		sbc a, [hl]
		ld d, e
		ret
	
		reti
	
		push hl
		ldd a, [hl]
		adc l
	db $D3
		ld [de], a
		ld a, $C0
		xor $CB
		daa
		sbc a, h
		ld sp, $57A8
		ld c, e
		ldh a, [c]
		ld b, [hl]
		ld b, d
		ret nz
		cp $3D
		ldh a, [c]
		rla
		ld b, [hl]
		sub h
		ld b, b
		and l
		pop af
		dec l
		push de
	db $E3
		nop
		and b
		or a
		rst $08
		or c
		xor e
		sub d
		add hl, de
		dec sp
		call nz, $E0E3	; Possibly invalid
		ld h, a
		ld l, c
		ld d, e
		ld l, b
		rst $38
		rra
		ccf
		add l
		ld c, $AB
		ld d, e
		rst $10	; wizardAbilities
		ld a, l
		ld h, l
		inc c
		and l
		reti
	
		add [hl]
		xor b
		ldh a, [rAUD2ENV]
		ld c, a
		rst $20
		inc e
		call c, $CED9	; Possibly invalid
		ld c, a
		push bc
		ld d, e
		dec bc
		inc bc
		cp d
		ld d, l
		ldh a, [$BA]
		or h
		sbc $F0
		dec e
		ld h, [hl]
		inc sp
		or d
		ld [hl], e
		sub a
		add hl, hl
		sub [hl]
		ld h, e
		dec hl
		ldd a, [hl]
	db $EB
		rra
		ld [$D98E], sp
		ld a, [de]
		ld d, $4B
		adc c
		rst $28
		adc d
		add d
	db $DB
		dec [hl]
		sub l
		ld a, [bc]
		and [hl]
		ld b, l
		jr z, @ + 113
		cp l
		rst $08
		add e
		ld de, $1591
		ld l, c
		dec a
		and b
		call z, $E13C	; Possibly invalid
		sub l
		or [hl]
		ld h, b
		or d
		dec c
		sbc a, b
		inc hl
		set 5, l
		xor b
		ldh [c], a
		jp z, $EEC6	; Possibly invalid
		ld hl, $7D3C
		inc de
		ld a, e
		cp c
		inc a
		ld d, l
	db $ED
		dec hl
		xor l
		ld h, d
		xor l
		xor c
		ret nz
		call c, $D290	; Possibly invalid
		call $0B7C	; Possibly invalid
		ld e, $F4
		dec bc
		adc l
		sbc a, a
		ld [hl], l
		ld [hl], c
		ld c, d
		adc d
		add $C1
		add hl, hl
		di
		ld c, c
		ld a, e
		cp $E2
		jp nc, $F8F3	; Possibly invalid
		ld c, b
		or d
		ld c, [hl]
		call $E4D8	; Possibly invalid
		rst $08
		ld c, h
		ld a, l
		inc hl
		ld a, c
		ld [$D909], sp
		ret z
		add h
		ld sp, $A6B4
		ld d, d
		adc e
		dec l
		add [hl]
		ld l, $99
	db $F4
		dec bc
		sbc a, [hl]
		jr c, @ + 6
		ld [hl], e
		ret c
		cp [hl]
		inc hl
		ldd [hl], a
		ld de, $9E8E
		ldh [_PORT_0A_], a
		jp c, $A71A
		and a
		dec [hl]
		or [hl]
		ld [hl], d
		ld b, a
		ld h, l
		adc d
		cp b
		dec l
		dec d
		adc [hl]
		ld e, e
		ld h, $6F
		ld [hl], e
		sub c
		dec bc
		ld c, [hl]
	db $ED
		sbc a, [hl]
		add e
		ld e, $07
		and e
		xor a
		or e
		or a
		add hl, hl
		and a
		ld a, e
		sub c
		rst $38
		call nz, $6D0D	; Possibly invalid
		inc e
		and b
		scf
		ld d, [hl]
	db $D3
		ld e, h
		inc c
		ld hl, $73F5
		rst $10	; wizardAbilities
		ret nz
		push de
		daa
		ret nz
		ld e, e
		xor h
		add sp, 94
		cp a
		sbc a, e
		add hl, sp
		ld l, d
		sub c
		ld a, [bc]
		add h
		or [hl]
		add a
		ld [hl], c
		add b
		or d
	db $EB
		and b
		pop af
		ld d, $A1
		ld a, [de]
		inc b
		sbc a, a
		add hl, sp
		ret
	
		adc d
		inc b
		add b
		ld l, e
		inc sp
		add hl, hl
		ld e, $24
		di
	db $FD
		and d
		ld d, a
		ldh a, [$F2]
		call $ADB3
		ld [hl], d
		xor a
		dec a
		ld [bc], a
		ld [hl], a
		cp e
		xor h
		ld d, h
		ld [hl], l
		jp nz, $5DD6	; Possibly invalid
		nop
		ld a, $8A
		ret z
		add b
		or b
		dec [hl]
		jr c, @ - 60
		rst $30
		or b
		push hl
		xor h
		call $7385	; Possibly invalid
		rst $10	; wizardAbilities
		cp b
		scf
		ld a, a
		add hl, bc
		ld h, l
		inc sp
		or h
		ld b, l
		ld a, b
		inc bc
		ld c, c
		inc e
		ld sp, hl
		dec sp
		jp nz, $B0AC
		ld a, [hl]
		ld a, [$FC0F]
		ld [bc], a
		inc a
		ld sp, $70AF
		ld a, h
		rst $20
		xor b
		ld sp, $F157
		ld a, [bc]
		cp d
		inc sp
		jp nc, $5A7A	; Possibly invalid
		add b
		ld [hl], e
		xor h
		ld [hl], h
		ld [hl], a
		cp e
		adc c
		inc hl
		ld [$BABB], a
		rra
		dec d
		halt
		jr nz, @ - 38
		xor a
		inc b
	db $E3
		inc sp
		ld l, c
		ld a, [de]
		xor [hl]
		rst $38
		dec d
		xor c
		ld h, e
		dec [hl]
	db $E3
		cp h
		ld d, [hl]
		ld a, b
		sub h
		add [hl]
		sbc a, e
		inc bc
	db $FD
		dec [hl]
		ld b, c
		ld e, e
		or l
		add $C6
		sbc a, a
		and b
		sub l
		ldh a, [_PORT_5F_]
		sbc a, c
		ld d, a
		ld [$9F31], a
		or [hl]
		push hl
		inc e
	db $E3
		rla
		ld a, [de]
		ld c, l
		ld [hl], a
		adc [hl]
		ld a, [$2000]
		ld e, l
		ld [hl], a
		call $25D3	; Possibly invalid
		dec b
	db $EB
		ldi a, [hl]
		ret nc
		sbc a, c
		or [hl]
		ld c, a
		ld h, a
		ld l, d
		rst $28
		ld de, $702C
		or l
		jp hl
	
		ret
	
		adc a
		add e
		ld [$CF5E], a
		cp h
		rrca
		ld b, e
		ld d, b
		push hl
		sbc a, c
		ld d, c
		ld [hl], c
		ld a, [de]
		cp a
		jr z, @ - 42
		add sp, 7
		pop bc
		add e
		ld c, b
		ld c, h
		ld e, c
		ld [hl], b
		call z, $E86A	; Possibly invalid
		ldd [hl], a
		ld a, $57
		sub l
		sbc a, a
		ld bc, $E559
		ld c, b
		push de
		ld d, b
		rst $38
		ld e, a
		rst $10	; wizardAbilities
		cp $B8
		ld c, c
		ldi a, [hl]
		ld e, h
		ld h, b
		cp b
		ld c, d
		ld a, d
		ldh a, [c]
		ld a, [bc]
		ld h, e
		cp d
		add c
		adc [hl]
	db $FD
		xor l
		add [hl]
		ld h, [hl]
		sub d
	db $FD
		and c
		ld d, a
		ld [hl], a
	db $E3
		rst $08
		dec de
		sbc a, d
		cpl
		inc h
		jp nc, $9B5C
		ld e, [hl]
		or b
		ldd [hl], a
		xor b
		or c
		ld b, e
		ld c, b
		ld a, h
		inc a
		xor d
		ld c, $D9
		ldd [hl], a
		ld h, e
		ld d, b
		rst $00	; CharacterMovementTable
		di
		ld c, l
		ld c, c
		ld a, a
		call nz, $EEAD	; Possibly invalid
		ld de, $9849
		and $A3
		rlca
		ld e, c
		ld d, [hl]
		bit 4, a
		inc h
		ld de, $3EB0
		di
		or a
		ld b, [hl]
		ld a, [de]
		ld d, $6C
		ld l, a
		ld l, d
		ld e, $FA
		dec b
		inc de
		ld l, [hl]
		ld c, e
		ldh a, [$B4]
		ldh [$E6], a
		ld [bc], a
		inc hl
		add l
		ld l, $CC
		cp c
		ld h, l
		ld l, b
		ld b, l
		dec e
		xor d
		dec a
		ret z
		xor c
		ld a, [de]
		xor $6F
		ld e, [hl]
		add h
		cp a
		adc $A1
		sub h
		ld h, [hl]
		ld b, h
		ld sp, hl
		ld hl, sp+-59
		add d
		adc l
		jp z, $0270	; Possibly invalid
		jr nc, @ + 32
		ld d, h
		stop
		ld a, c
		cp c
		add $5D
		ldi a, [hl]
		ei
		ld e, d
		rst $08
		add b
		cp d
		or e
		jr z, @ - 27
		add [hl]
		xor l
		inc e
		ld [hl], e
		ld [hl], b
		and c
		ld l, a
		set 1, h
		ld de, $D785
		ld l, d
		add [hl]
		adc d
		cp $DE
		inc d
		sbc a, a
		jr c, @ + 91
	db $E3
		ret nc
		ret z
		adc [hl]
		inc d
		ld a, [bc]
		ld a, d
		rst $18
		and [hl]
		inc d
	db $DD
		push hl
		ld l, e
		ccf
		and l
	db $FC
		ldh a, [c]
		or l
		rst $08
		or l
		dec d
		ld a, $88
		add hl, hl
		ldd [hl], a
		rla
		ld d, d
		sub l
		add e
	db $ED
		cp a
		ld c, e
		adc d
		adc d
		ld d, d
		rla
		and l
		ld de, $E9E2
		cp c
		ld c, c
		inc l
		inc c
		jr c, @ + 7
		dec c
		inc b
		dec c
		ld [bc], a
		inc l
		ld b, [hl]
		sub d
		inc b
		add e
		ld d, c
		ldh a, [_PORT_6E_]
		push af
		ld b, e
		rra
		and d
		push af
		cp e
		jp c, $C7F3	; Possibly invalid
		push hl
		sub d
		ld b, a
		ret
	
		ld e, e
		inc h
		rst $28
		ld a, $76
		and l
		ldh a, [c]
		ret nc
		ld c, [hl]
		ld a, b
		dec sp
		call $F2DE	; Possibly invalid
		scf
		ld d, $48
		rst $18
		or [hl]
		ld c, e
		inc a
	db $FD
		ld l, a
		cp h
		ldh a, [$A5]
		ldd a, [hl]
		cp l
		or h
		inc e
		ld h, a
		ld l, h
		sub a
		ld l, e
		cp $FD
		xor e
		ccf
		ld c, c
		add b
		ld sp, $B78B
		rst $38
		ld e, h
		ld bc, $EF83
	db $FC
		jr z, @ - 1
		inc a
		rla
		add [hl]
		ld h, e
		xor $9A
		cp b
		rra
		ld a, $58
		ld [$63A4], a
		inc e
		sub $9C
		ld d, c
		ld a, $04
		cp [hl]
		sbc a, h
		jp nz, $8297
		ld sp, $1FF3
		ld hl, sp+27
		ld [$9340], sp
		and $E8
		ld b, a
		inc hl
		push af
		nop
		add e
		jp $E311	; Possibly invalid
	
		ld h, [hl]
		jp nc, $BAFD
		inc b
		and h
		and h
		ld e, [hl]
		ld sp, $E062
		rla
		or a
		jp nc, $B266
		ld h, [hl]
		ld [hl], b
		ld l, a
		jr @ + 88
	
		jp nc, $3A9C	; Possibly invalid
		ld e, h
		sbc a, c
		add [hl]
		ld a, l
		xor l
		ldh a, [c]
		pop af
		xor b
		ld c, d
		dec hl
		ld l, d
		dec sp
		rst $28
		call nz, $67FB	; Possibly invalid
		add sp, 51
		ld [bc], a
		ld h, $BD
		ld c, [hl]
		ret nc
		add hl, hl
		ld c, d
		add $01
		cp $9B
		cp h
		or e
		ld h, b
		xor $9B
		ldh a, [c]
		pop hl
		ld bc, $3178
		xor e
	db $EB
		dec de
		ld d, $0D
		dec b
		jp nz, $0318	; Possibly invalid
		ld hl, $40E9
		jp nz, $87CF
		jr nz, @ - 59
		inc h
		ld e, [hl]
		ld de, $C407
		ld bc, $819E
		ld b, d
		ldh a, [c]
		sub l
		ld hl, $EC52
		ld d, d
		ld hl, sp+-80
		and l
		add $5E
		cp e
		ld h, c
		ld l, $4B
		ld a, l
		ld [hl], e
		ld c, a
		dec h
		ld e, $3D
		ld a, [$3E3F]
		add d
		ldh a, [c]
		rlca
		ld d, e
		and $D3
		rst $30
		pop hl
		ld h, h
		rst $20
		and $B2
		add [hl]
		ei
		ld h, a
		ld c, b
		jp nc, $34EE	; Possibly invalid
		jr z, @ + 103
		sbc a, e
		add b
		ld h, [hl]
		sbc a, b
		add hl, hl
		sbc a, [hl]
		ld c, h
		ldh [rAUD2LOW], a
		call nc, $0BC8	; Possibly invalid
		ld a, b
		sbc a, c
		inc h
		add a
		nop
		ld l, a
		ld d, a
		dec h
		and l
		ld [hl], l
		sub [hl]
		ld l, e
		and $44
		add hl, bc
		or [hl]
		call z, $2AFD	; Possibly invalid
		dec sp
		inc sp
		cp c
		ld [bc], a
		ld e, h
		scf
		push de
		xor $D1
		and d
		add a
		ld c, h
	db $DB
		ld d, l
		rra
		push bc
		ld bc, $5E0E
		rst $38
		add hl, sp
		sbc a, c
		ld l, d
		ld h, l
		ld b, $3B
		ld h, [hl]
		rrca
		add l
		or a
		dec e
		adc c
		cp [hl]
		sbc a, d
		ld l, $82
		adc c
		ld d, d
		ldi [hl], a
		cp d
		and $28
		ld e, $12
		xor [hl]
		rst $38
		ld sp, hl
		ld a, [bc]
		rst $30
		ld l, c
		dec l
		ld [hl], b
		ld c, d
		ld a, h
		sub $DE
		jp c, $29D4	; Possibly invalid
		adc c
		ld [hl], $30
		jp hl
	
		and e
		and e
		dec h
		ld a, h
		ld b, e
		ld [$852C], a
		push de
		or c
		call $F940	; Possibly invalid
		or d
		adc e
		ld [hl], e
		ld l, h
		rst $38
		ld hl, $EFC3
		ld [hl], b
		ld a, a
		dec l
		ldh a, [c]
		ld d, l
	db $ED
		pop de
		cp a
		dec sp
		ld sp, $1BA8
		ld bc, $7FCE
		ld b, e
		cp l
		adc a
		or a
		call z, $2604	; Possibly invalid
		ld b, e
		ld b, h
		ld a, [hl]
		rrca
	db $EB
		xor l
		ld l, b
		ld d, d
		jp nz, $6689	; Possibly invalid
		rst $18
		adc a
		ld [hl], e
		inc l
		push bc
		sbc $4A
		ret
	
		ldd [hl], a
		add hl, bc
		stop
		ld a, b
		or h
		add hl, hl
		ld l, b
	db $D3
		push af
		ret
	
		xor c
		dec [hl]
		scf
		dec e
	db $E3
		ret
	
		ldh a, [$B5]
		dec sp
		rst $20
		ld d, e
		inc h
		jr nc, @ - 76
		inc l
		rst $28
		ldd a, [hl]
		xor e
		xor h
		pop bc
		ld [bc], a
		ld l, $76
		adc h
		ld d, l
		add e
		and b
		jp hl
	
		dec h
	db $DD
		ld a, [bc]
	db $EB
		or a
		xor h
		ld l, $FE
		xor b
		add b
		pop bc
		ld [hl], $E4
		and e
		ld b, b
		adc h
		ld a, c
		ld b, b
		sbc a, b
		adc [hl]
		inc h
		sub d
		ld a, [$247B]
		cp [hl]
		add hl, bc
		ld l, c
		jr nc, @ + 97
		ld h, $1F
	db $ED
		ld [hl], b
		ld a, [hl]
		pop bc
		ld h, h
		jr z, @ + 62
		add hl, de
	db $F4
		xor b
		ld [de], a
		or h
		ccf
		ld hl, $ED42
		ld l, e
		ld [$50F4], a
		halt
		xor $75
		xor c
		ld h, $C7
		ld b, $75
		rra
		ld a, [de]
		push bc
		inc c
		ld a, [$BB39]
		ret c
		ret
	
		ld b, l
		jr z, @ + 18
		ld e, l
		adc [hl]
		cp h
		ld h, d
		ld l, c
		sub h
		jr nc, @ - 8
		ldh [c], a
		ld [hl], h
		cp h
		ld l, b
		jr nc, @ + 114
		and [hl]
		halt
		jp z, $9125
		ld [hl], h
		ldi [hl], a
		ld b, e
		sbc a, h
		ret c
		xor $DC
	db $F4
		xor [hl]
		ld e, d
		rst $08
		inc b
		adc c
		add $CD
		inc [hl]
		ldi a, [hl]
		ld a, l
		rlca
		or $C8
		ld a, [bc]
		ld a, c
		call $B7E5
		res 3, c
		di
	db $DB
		sub $15
		ld [hl], b
		rlca
		cp b
		ld h, $1A
		rst $00	; CharacterMovementTable
		dec c
		ld d, $D6
		dec sp
		ld b, a
		sub l
		ld [hl], e
		ld h, a
		and d
		ld c, [hl]
		and l
		ld d, l
	db $F4
		ld c, e
		ld [hl], h
		ld l, e
		call nz, $8E2D
		ld l, a
		sub c
		adc c
		ld h, c
		ld h, $2D
		add hl, sp
		ld a, a
		inc a
		dec d
		adc h
		ld l, e
		and l
		ld d, l
		inc de
		or [hl]
		or h
		inc sp
		ld [$546A], a
		ld [de], a
		add hl, bc
		sub $13
		xor a
		inc sp
		cp a
		dec bc
		and l
		ld a, c
		sbc a, l
		or d
		dec c
		ld a, [$2ADB]
		dec c
		jr @ - 116
	
		xor d
		ld c, d
		ei
		add c
	db $EC
		ld b, $08
		ld e, a
		ld d, b
		xor c
		sub [hl]
		call z, $62F1	; Possibly invalid
		call z, $E419	; Possibly invalid
		dec sp
	db $D3
		cp b
		inc l
		xor c
		ld h, [hl]
		rst $08
		or h
		and h
		push bc
		rst $28
		ldh a, [c]
		cp d
		jr nc, @ - 116
		ld de, $8AC8
		ld d, l
		ld sp, $C2E3
		rst $30
		ldi [hl], a
		and c
		dec h
		pop af
		pop hl
		ld e, e
		xor a
		call z, $FD96	; Possibly invalid
		ld a, [bc]
		adc e
		stop
		ld c, a
		jp hl
	
		ld d, [hl]
		call nz, $8431
		sbc a, c
		or e
		cp d
		sub e
		cp b
		ld l, b
		jp c, $D12F	; Possibly invalid
		add l
	db $FD
		dec h
		ld b, h
		and a
		add d
		inc sp
		dec d
	db $E3
		rst $20
		cpl
		inc sp
		ld l, e
		call $2B5B	; Possibly invalid
		ld h, l
		jr z, @ + 121
		inc de
		ld a, b
		jp hl
	
	db $FC
		ld sp, $4494
		jp nc, $C744	; Possibly invalid
		sub d
		ld b, d
		add l
		sub h
		dec [hl]
		push hl
		call $76D7	; Possibly invalid
		or l
		ld e, l
		jr z, @ + 125
		pop af
		ld c, $B2
		rst $28
		xor b
		inc [hl]
		or h
		and $E2
		cp l
		inc a
		dec sp
	db $E4
		cp c
		dec hl
		jp $F626	; Possibly invalid
	
		ld d, c
		add sp, 4
		add sp, 15
		rst $38
		dec h
		inc de
	db $D3
		or $EB
		sub h
		and e
		call z, $74F1	; Possibly invalid
		and e
		ld h, [hl]
		ldd [hl], a
		xor b
		ld [hl], d
	db $E3
		ld d, h
		ld d, e
		jp $A630
	
		jr @ + 59
	
	db $EC
		ld d, l
		ld d, d
		and h
		ld h, a
		cp a
		and c
	db $FC
		rst $00	; CharacterMovementTable
		ld [hl], b
		ld h, h
		cp [hl]
		ldi [hl], a
		add [hl]
		ld b, $C2
		ld h, e
		cp a
		ld e, d
		ld [$6C2C], sp
	db $E4
		rra
		sub e
	db $E4
		ld l, e
		ldh [c], a
		jp nc, $BF83
		ld de, $D9DE
		or b
		ld d, d
		dec bc
	db $ED
		ld d, [hl]
		ld c, c
		sub b
		sub c
		rst $00	; CharacterMovementTable
		dec [hl]
		ld d, d
		ld [hl], l
		ld [$7428], sp
		ldi a, [hl]
		ld e, a
		rra
		rr b
		ld l, a
	db $FC
		ld l, e
		ld d, c
		call c, $0B4D	; Possibly invalid
		xor h
		inc [hl]
		inc [hl]
		jp c, $D1B8	; Possibly invalid
	db $DB
		cp b
	db $EB
		adc l
		ld b, h
		ld b, d
		jp nz, $F181	; Possibly invalid
		ld l, [hl]
		ldh [$AD], a
		push de
		adc h
		ldh a, [c]
		ld b, l
		ld c, [hl]
		call nc, $0133	; Possibly invalid
		ret c
		or e
		ld c, l
		ld a, $BB
		sub b
		pop bc
		ld [$0BAD], sp
		xor d
		ld h, a
		xor e
		pop de
		cp c
		ld [$2759], sp
		cp a
		or d
		rrca
		ld a, l
		ret nc
		add hl, de
		ld b, d
		sub h
		rst $28
		xor l
		rrca
		cp c
		dec l
		ld h, c
		ld l, l
		jp nc, $C6EF	; Possibly invalid
	db $EC
		ld b, e
		ld b, d
		or h
		sub e
		ret c
	db $ED
		inc e
		and b
		ld [hl], h
		ld c, h
		jr c, @ - 73
		ld e, $35
		adc l
		ld [hl], e
		dec b
		ld a, [bc]
		inc c
	db $FC
		sbc a, l
		ld b, b
		adc b
		xor [hl]
		adc e
	db $ED
		add l
		reti
	
		add e
		cp a
		rst $30
		ld d, $9D
		ld l, d
		and $4C
		ld d, d
		ld e, h
		adc a
		sub [hl]
		ret c
		ld [$2E2F], a
		rst $30
		dec b
		xor c
		sbc $98
		adc d
		add hl, bc
		inc h
		ld bc, $C1EB
		ld b, b
		stop
		inc h
		ld a, d
		and h
		ld a, [hl]
	db $DD
		or d
		scf
		sub d
		ei
		xor b
		cp $29
		ld c, b
		call z, $4473	; Possibly invalid
		inc c
		and b
		inc c
		adc b
		push af
		and $21
		scf
		jr c, @ - 84
		halt
		ld e, c
		add d
		sbc a, l
		ld h, a
		ret z
		ld l, h
		sbc a, c
	db $E3
		ld d, $C7
		rla
		call z, $7280	; Possibly invalid
		dec b
		cp c
		cp b
		add e
		cp d
		dec a
		ld sp, $685D
		inc h
	db $ED
		dec l
		ld [hl], e
		ldh a, [c]
		push hl
		ld b, [hl]
		and h
		inc sp
		cp c
		ld b, d
		ld e, h
		ld e, c
		ld b, h
		or e
		add e
		rst $20
		dec a
		dec a
		rst $00	; CharacterMovementTable
		ld l, [hl]
		sub l
		dec hl
		add c
	db $D3
		and e
		cpl
		inc bc
		or d
		ld [$1D35], sp
		cp a
		ld a, a
		jr @ + 105
	
		pop af
		ld [bc], a
		or e
		and $8F
		ret
	
		ld l, $8A
		xor c
		ld h, a
		halt
		ld l, b
		ld c, $86
		cp a
		ld sp, hl
		rst $08
		inc a
		rst $28
		ld a, [bc]
		ld a, [$CE7E]
		ld hl, sp+-25
		cp $2C
		daa
		rst $20
	db $F4
		add hl, hl
		ld [hl], e
		ld b, e
	db $ED
		adc d
		ld [hl], b
		inc c
		add hl, hl
		xor c
		sub c
		ld e, e
		ld [$1146], sp
		add hl, de
		sub b
		dec hl
	db $ED
		and e
		rlca
		ld [hl], a
		call $0F7D	; Possibly invalid
		ld [bc], a
	db $EB
		ld h, a
		sbc a, b
		inc [hl]
		push hl
		ld a, d
		add hl, sp
		xor $34
		ld h, e
		ld e, b
		ld b, b
		ld c, c
		ld c, e
		and [hl]
		stop
	db $FD
		or [hl]
		ld [hl], d
		jr @ + 61
	
		and d
		ld h, [hl]
		rst $30
		ldd [hl], a
		ld [$50A0], a
		ld [hl], c
		ld c, c
		sbc a, b
		sbc a, d
		ld a, a
		ld h, e
		ld c, e
		ret z
		ld e, d
		sbc a, b
		ld [hl], a
		ld c, $94
		adc c
		ld [$20C7], a
		push de
		cp a
		ret z
	db $FC
		ld h, d
		ld b, d
	db $EC
		or [hl]
		daa
		ld c, c
		add h
		ld c, e
		rra
		inc sp
		or [hl]
		ld a, $16
		cp e
		ld c, h
		ld a, d
		ld d, a
		ret nz
		sbc a, e
	db $DB
		rst $20
		ret z
		sbc a, d
		call z, $A03E
		call z, $5419	; Possibly invalid
		nop
		ld d, b
		sbc a, d
		ld b, e
		ld sp, $D034
		inc h
		ld [hl], l
		rla
		ldi a, [hl]
		adc $E0
		rst $10	; wizardAbilities
		xor a
		ld d, d
		ld l, b
		cp h
		adc c
		cp a
		dec [hl]
		ld h, e
		ld d, [hl]
		inc l
		inc hl
		ld b, h
		ld [hl], a
		sub h
		ld l, c
		and b
		ld b, b
		push bc
		xor h
		pop de
		ld sp, $33A3
		adc a
		add e
		call nz, $E552	; Possibly invalid
		ld bc, $AC0C
		inc b
		rst $20
		dec sp
		ld e, l
		cpl
		ld a, h
		ld d, c
		add d
		ldi [hl], a
		sub d
		or e
		push af
		rst $20
		ld c, h
		add c
		add [hl]
		ld d, e
		dec h
		jr nz, @ + 49
		and a
		sub l
		dec d
		ld a, h
		ld d, h
	db $F4
		xor l
		sub c
		add $F7
		ld d, [hl]
		ld l, l
		ld d, e
		sub e
		xor [hl]
		cp c
		adc l
		add b
		inc sp
		ccf
		adc d
		rst $38
		dec d
		ld [$DEFC], a
		pop hl
		jr nc, @ + 120
		ld h, $EF
	db $F4
		ld h, [hl]
		halt
		xor c
		jp hl
	
		ld h, b
		or a
		ld d, l
		push bc
		ld hl, sp+37
		ld d, a
		ld b, h
		ldi [hl], a
		cp c
		inc l
		inc h
		ld de, $C0D0
		adc l
		push hl
		sub l
		bit 5, d
		ld e, h
		dec b
		sbc a, [hl]
		ld hl, sp+13
		ret c
		ld h, c
		rst $30
		pop hl
		add b
		sbc $43
		cp e
		ld e, c
		ld a, h
		push hl
		adc a
		ld a, [hl]
		rrca
		ld [$E618], sp
		sbc a, c
		ld a, [$5C3C]
		ld c, l
		ld hl, sp+12
		dec l
		ld e, $44
		add sp, 88
		ld [hl], a
		ld l, c
		cpl
		dec h
		ld c, [hl]
		cp b
		xor l
		or d
		ret c
	db $EB
		adc b
		cp d
		jr z, @ + 65
		di
		ld bc, $42DF
		rlca
		ld c, e
		ld h, $1A
		adc d
		pop af
		ld [hl], l
		inc b
	db $EC
		di
	db $E4
		ld c, $90
		ld b, c
		di
		ld [hl], c
		jp nc, $B089
	db $F4
		sbc a, d
		ld h, a
		ld h, d
		ld h, c
		cp c
		xor l
		jp z, $0661	; Possibly invalid
		call $1A00	; Possibly invalid
		inc a
		ld b, a
		rst $30
		or [hl]
		ld d, [hl]
		ld c, h
		ld l, b
		call nc, $5617	; Possibly invalid
		sub a
		or d
		ld l, $2D
		push af
		inc bc
		ld b, d
	db $FD
		ld [de], a
		cp e
		or e
		and l
		inc l
		dec hl
		dec e
		ld e, e
		and $6E
		ld h, b
		adc h
		sub $D5
		pop bc
		jp nc, $BCFE
		sub b
		cp c
		cp [hl]
		ld [hl], l
		push hl
		ld b, $3E
		xor h
		push bc
		ld d, d
		ld a, d
		ld a, a
		ret z
		ld a, [bc]
		ld [hl], h
		ld b, a
		scf
		inc e
	db $D3
		and a
		dec [hl]
		ld hl, sp+-35
		ld l, b
		inc l
		or l
		or b
		ld c, c
		add hl, bc
		ld d, h
		add [hl]
		ld c, a
		sub [hl]
		sub a
		ld d, h
		ld c, h
		sbc a, h
		ld a, b
		or b
		add b
		sbc a, h
		adc [hl]
		di
		ld e, e
	db $FD
		add [hl]
		daa
		inc sp
		ld a, [bc]
		ld e, l
		inc sp
		cpl
		ld d, c
		ld a, $45
		add sp, 34
		add hl, hl
		ld l, b
		pop de
		adc c
		ld h, a
		ei
		pop de
		and $65
		xor h
		dec e
		dec hl
		ld a, b
		and l
		call nc, $E0B5	; Possibly invalid
		res 1, c
		ld c, c
		ld a, c
		inc de
		ld a, h
		ldi a, [hl]
		pop de
		ld [hl], b
		dec l
		add [hl]
		ld l, $5A
		add $19
		xor c
		ld l, l
		ld c, a
		cp [hl]
		ld bc, $FA5E
		ldh a, [c]
		cp a
		ld c, e
		ld a, $EF
		ld a, $22
		ret z
		jr nz, @ - 3
		sub d
		inc hl
		stop
		xor c
		inc b
		ret nc
		sbc a, a
		push hl
		ld d, e
		add h
	db $E3
		sbc a, l
		nop
		add hl, sp
		cp h
		and e
		xor d
		sbc a, a
		rra
		add h
		push af
		add a
		ret z
		ret c
		xor d
		ld h, c
		inc b
		sub b
		or [hl]
		ld sp, hl
		xor [hl]
		ld [hl], c
		ld c, c
	db $D3
		dec c
		ld d, d
		ld e, c
		or a
		ld l, c
	db $EB
		ld h, e
		ldh [$81], a
		ld a, [bc]
		call c, $DADE	; Possibly invalid
	db $DB
		ret c
		inc de
		add d
		dec a
		xor h
		push af
		add sp, -21
		inc e
		adc b
		xor b
		ld l, d
		rrca
		or e
		ld a, l
		push af
		ld d, [hl]
		add h
		ld d, a
		add a
		or [hl]
		inc b
		ldh [c], a
		ld a, $46
		ld l, c
		jp nc, $033B	; Possibly invalid
		jr c, @ - 44
		ld l, b
		or [hl]
		ld [hl], h
		ld h, e
		add $AC
		rst $08
		jp c, $4724	; Possibly invalid
		sub b
		inc hl
		or [hl]
		ld h, d
		jp c, $39E5	; Possibly invalid
		sbc a, [hl]
		rst $00	; CharacterMovementTable
		sub l
		cp d
		inc h
		ld e, $2F
		inc d
		push hl
		ld c, [hl]
		jp z, $C027	; Possibly invalid
		ld e, $9C
		sub e
		and e
		ld a, [$D4A3]
		xor e
		add hl, bc
		add hl, bc
		add [hl]
		sbc a, d
		jp hl
	
		call nz, $277F	; Possibly invalid
	db $FD
		ld a, $E6
		ccf
		adc c
		ldh [c], a
		rst $28
		add hl, hl
		sub d
		ld a, [de]
		sub d
		ret c
		cp [hl]
		ld c, e
		and c
		and $9A
		ldh a, [c]
		dec b
		inc e
		call z, $ED2C	; Possibly invalid
		ld h, [hl]
	db $F4
		ld d, c
		ld b, [hl]
		ld c, d
		pop hl
		ld h, a
		ld a, $AF
		jr nz, @ + 10
		dec h
		ld [hl], h
		ld a, e
		call nc, $5117	; Possibly invalid
		add d
		ld sp, hl
		sub e
		sbc a, b
		or l
		ld h, h
		ld d, a
		ld b, c
		or l
		rrca
	db $D3
		and d
		add b
		add hl, bc
		adc d
		pop hl
		dec sp
		call $5224	; Possibly invalid
		dec e
		add hl, bc
		and l
		ld a, [bc]
		or l
	db $ED
		ld c, a
		dec e
		call nz, $103E	; Possibly invalid
		or h
		ld d, [hl]
		ld b, $A8
	db $EC
		inc [hl]
		call c, $9890
		cp a
		sub a
	db $E4
		add e
		ld a, [de]
		ld h, h
		dec de
		ret
	
		halt
		ld h, [hl]
		inc [hl]
	db $FC
		xor l
	db $E4
		ld [hl], d
		pop bc
		ld b, d
		dec de
		daa
		ld l, c
		ld [hl], l
		inc de
		ret c
		rst $20
		ld c, h
		ret nz
	db $DB
		add hl, hl
		ld d, e
		add a
		dec sp
		push bc
		ld a, l
		inc c
		dec l
		dec bc
		ld c, $F5
		ld a, a
		sbc a, e
		call z, $AA99
		ld [hl], b
		ld a, $A3
		call nc, $40ED	; Possibly invalid
		adc b
		ld [hl], $29
		inc sp
		rst $38
		ld h, c
		rst $20
		ld c, [hl]
		cp h
		sbc a, b
		or c
		cp c
		jp hl
	
		cp a
		ld e, h
		call z, $4870	; Possibly invalid
		sub l
		jp $575F	; Possibly invalid
	
		or $26
		cp $19
		cp h
	db $F4
		add hl, de
	db $D3
		rla
		and h
		add l
		ret nz
		ld b, [hl]
		or e
		inc hl
		adc l
		ld a, [hl]
		and d
		ld a, h
		ld h, l
		ld sp, $ACF2
		dec e
		ld [hl], e
		ld [hl], $79
		ldh [c], a
		inc bc
		inc d
		rst $30
		ret nc
		and a
		ld [hl], e
		dec c
		xor l
		or $5F
		add hl, bc
		ld a, $7A
		sbc a, l
		scf
		rst $08
		call c, $8A67
		jp c, $E592	; Possibly invalid
		jp nz, $2DC0	; Possibly invalid
		jr z, @ + 89
		ret nc
		di
		rst $30
		and $86
		jr nz, @ + 85
		ld a, b
		ld c, d
		and $7E
		sbc a, e
		sbc $CC
		ld d, $7A
		xor c
		stop
		nop
		ld l, d
	db $D3
		ld a, d
	db $F4
		ret nz
		ld sp, $D8F2
	db $DB
		jp nz, $BA4E
		ldh [rTIMA], a
		dec b
		di
		ld [hl], b
		dec a
		ld e, a
		ld d, l
		jr z, @ + 117
		ld c, a
		call nc, $1A98	; Possibly invalid
		ldi a, [hl]
		ld l, l
		dec de
		ldh a, [c]
		ld hl, sp+-26
		ccf
		ld l, c
		rlca
		jp hl
	
		dec e
		ld h, b
		inc d
		ld a, a
		ld l, a
		rst $30
		di
		scf
		add b
		adc d
		inc d
		inc e
	db $DB
		add a
		add l
		pop af
		push hl
		ld b, c
		inc b
		inc a
		adc b
	db $EC
		ld e, [hl]
	db $D3
		cpl
		ret
	
		or d
		nop
		dec a
		xor d
		call $3B37	; Possibly invalid
		cp [hl]
		ld b, a
		inc d
		ld b, e
	db $ED
		adc c
		add hl, sp
		ld d, a
		ld d, $DD
		call z, $31A2	; Possibly invalid
		or d
		adc e
		and e
		ld e, e
		sub h
		ccf
		inc a
		jr @ + 67
	
		ld c, h
		adc b
		jp z, $11AB	; Possibly invalid
		add hl, sp
		sbc a, a
		jr z, @ - 27
		jr @ + 119
	
		ldh [c], a
		ld b, d
		add [hl]
		ld [bc], a
		daa
		and d
		ld h, h
		ld c, a
		rra
		adc [hl]
		cp d
		ld a, a
		ld e, b
		jr @ - 42
	
		ld l, h
		rlca
		ccf
		ld b, l
		ldd [hl], a
		add sp, -117
		inc de
		sbc a, d
		and a
		ld h, $9C
		ld b, [hl]
		ld e, d
		adc b
		ld h, l
		ld a, [$3DD9]
		inc c
		ldh [c], a
		pop af
		or a
		inc a
		ld hl, $D656
		rst $38
		inc [hl]
		adc a
		jr nc, @ + 66
		ret c
		xor h
		and l
		and e
		ld l, $55
		inc [hl]
		ld l, c
		adc a
		halt
	db $F4
		adc b
		cp d
		inc bc
		dec b
		add [hl]
		add hl, hl
		ld d, a
		jr nz, @ + 23
		ld c, c
		cp l
		sbc a, a
		inc e
		rst $10	; wizardAbilities
		ld de, $B12C
	db $EC
		ld c, [hl]
		adc h
		call nz, $1161	; Possibly invalid
		sbc a, d
		ld [hl], $68
		or c
		cp b
		rst $30
		ld h, d
		add l
	db $ED
		ld e, e
		jp hl
	
		call nz, $B803
		adc l
		jp $0023	; Possibly invalid
	
		ld [hl], d
		ld a, [hl]
		pop bc
		ret nz
		add c
		ld e, c
		ld c, h
		sbc a, c
		ld e, d
		ld de, $899E
		inc [hl]
		cp c
		sub $67
		and a
		adc h
		ld d, e
		daa
		ld h, h
		jp nz, $0B86	; Possibly invalid
		ld l, d
		ld a, e
		xor c
		ld [$BD4D], a
		jr nz, @ - 110
		set 6, [hl]
		add a
		adc c
		ld h, $B2
		xor [hl]
		ccf
		jp nc, $915C
		dec de
	db $DB
		inc b
		ld hl, sp+-112
		sub h
		sbc a, a
		or b
		inc hl
		ret
	
		ld d, c
		ldi a, [hl]
		ldh [c], a
		and $B0
		inc e
		cp a
		ld c, c
		adc a
		add sp, 22
		ld d, [hl]
		inc l
		ld a, [$3370]
		ld l, $09
		jp z, $A6B5
		ld h, b
		ld hl, sp+-103
		ret
	
		ei
		and d
		inc sp
		sub c
		and a
		sbc a, d
		ld l, h
		sbc a, a
		ld h, e
		ld d, $A6
		and e
		inc a
		ld b, e
		call c, $EC96	; Possibly invalid
		jr nc, @ + 82
		ldi [hl], a
		ret z
		ld b, [hl]
		push bc
		ld de, $F33E
		dec [hl]
		jr z, @ + 97
		inc b
		or [hl]
		ld h, $2F
		add l
		call $A248
		add hl, de
		xor b
		ccf
		or b
		cp a
		xor c
		ld a, e
		inc h
		pop bc
		jp $AF1E
	
		ld [hl], c
		add h
		ld e, e
		ld h, $C1
		inc l
		sub d
		add hl, sp
		sbc a, d
	db $ED
		inc de
		call z, $2A6E	; Possibly invalid
		dec bc
		ld c, [hl]
		cp d
		jp nc, $203A	; Possibly invalid
		ld l, h
		or l
		ld h, $8D
		and [hl]
	db $E3
		rra
		push hl
		ld d, a
		or l
		dec l
		sub [hl]
		sub d
		pop hl
		sbc a, h
		ld de, $3DD9
		ld l, $44
		halt
		reti
	
		xor c
	db $DD
		add h
		scf
		di
		inc e
		or e
		ld b, b
		ld b, d
		push de
		sub c
		inc c
		or a
		jr nc, @ + 124
		rlca
		jr nc, @ + 16
		and a
		dec e
	db $D3
		ld a, a
		sbc a, e
		jp $7974	; Possibly invalid
	
		rst $20
		ldh a, [c]
		ld a, [bc]
		ld b, a
		ld h, h
		jr nz, @ - 67
		call nc, $6AED	; Possibly invalid
		ld d, e
		rla
		ld [hl], b
		ldh a, [c]
		ld a, l
		ld sp, hl
		or a
		ld e, e
		ldi [hl], a
		ld l, [hl]
		push de
		ld [hl], a
		or b
		ld h, a
		ld b, b
		add e
		ld e, h
		xor c
		adc l
		ld a, c
		dec c
		jp nz, $C924	; Possibly invalid
		push af
		ld a, l
		adc $3C
		rrca
		sub c
		rst $10	; wizardAbilities
		add [hl]
		ld b, b
		cp [hl]
		ret nc
		halt
		xor l
		dec h
		jp nz, $9B7E
		ld e, h
		xor h
		push bc
		jp nz, $2A79	; Possibly invalid
		jr @ + 4
	
		ld [hl], h
		dec b
		add c
		cp a
		ldi a, [hl]
		pop hl
		halt
		ld [hl], l
		inc d
		cp b
		ei
		daa
		ldi [hl], a
		sub b
		ret c
		set 4, e
		ldi a, [hl]
		call nc, $5E9D	; Possibly invalid
	db $EB
		ld sp, hl
		ld [$8F1A], a
		ld c, l
		ld d, $4C
		ld l, $F0
		sub a
		ld l, h
		ld e, d
	db $FC
		rst $20
		sub [hl]
		add hl, de
		ld d, h
		ld l, l
		ld c, c
		pop hl
		jp nc, $DBEF	; Possibly invalid
		rlca
		ld [hl], c
		sub b
		sub c
		sub a
		call nc, playerY	; Possibly invalid
	db $DD
		adc [hl]
		add $4D
		ld d, e
		ld l, h
		ld a, [hl]
		ldh a, [c]
		add hl, sp
		ld h, h
		sub a
		ld h, $C2
		ldh [c], a
		adc c
		jr c, @ - 50
		dec hl
	db $DD
		ld h, [hl]
		add a
		rla
		adc $69
		push bc
		ret nc
		rst $30
		ld [bc], a
		add e
		ld [hl], $9B
		ld b, e
	db $EC
		ld c, c
		adc l
		jp nc, $CC8C	; Possibly invalid
		rra
		ld c, c
		ld a, b
		jr @ + 63
	
		ld [hl], d
		add sp, 103
		dec hl
		sbc a, b
		and [hl]
		or b
		inc l
		ld b, c
		ld b, c
		add e
		and h
		ld l, d
		push bc
		ld l, h
		or e
		ld h, $F6
		ld h, l
		ld b, a
		jr z, @ - 47
		sbc a, l
		ret nc
		ld e, $6B
		ld c, l
		bit 7, a
		and c
		inc sp
		inc bc
		ld d, l
		add a
		inc e
		add d
		add d
		halt
		ld e, [hl]
		sub b
		sbc a, l
		add c
		sbc a, c
		dec e
		ld [bc], a
		add $AE
	db $EC
		dec a
		add hl, de
		ld l, $E1
		add l
		ld [hl], d
		rrca
		jr nc, @ - 53
		ld a, l
		inc b
		ld [bc], a
		ldh [c], a
		ldh [_PORT_36_], a
		ld e, $60
		ld a, [hl]
		ld c, d
		ld e, [hl]
		ld c, l
	db $EC
		dec bc
		add hl, bc
		ld [$6329], sp
		ei
		ldh a, [c]
		add d
		pop de
		and d
		nop
		ld a, l
		reti
	
		ld a, [bc]
		ld [hl], b
		ld b, [hl]
		sbc $15
		push de
		cp l
		call nc, $6017	; Possibly invalid
		ld a, [$6705]
		rst $08
	db $E3
		dec b
		ld e, d
		ld c, $2C
		adc $6E
		and e
		ret nz
		ld [$B9B9], sp
		ld d, h
		ldi a, [hl]
		set 2, a
		sub a
		ld d, [hl]
		add hl, sp
		ld c, e
		xor a
		ld b, d
		or h
		jr nz, @ - 117
		ld e, $F7
		ld d, [hl]
		inc e
		sub h
		ld b, [hl]
		ei
		sub [hl]
		ld [hl], a
	db $D3
		ld hl, $ABAB
		inc de
		ld e, h
		ret z
		or l
		add hl, de
		ldi [hl], a
		bit 3, a
		sub a
		xor e
		ld b, $CC
		ld b, l
		or a
		rst $28
		and a
		di
		add d
		ld hl, sp+15
		rla
		jr @ - 46
	
		cp h
		ld bc, $C4A0
		jp hl
	
		and e
		sbc a, h
		pop de
		add [hl]
		add b
		ld e, $AA
		ld l, [hl]
		rrca
	db $EC
		xor l
	db $FC
		ld a, l
		cp [hl]
		dec b
		ld l, $F3
		sbc a, a
		dec hl
		ld [hl], a
		sub a
		inc l
		rst $38
		inc bc
		dec bc
		cp a
		and [hl]
		cp [hl]
		dec c
		ld l, a
	db $FC
		ei
		ldi [hl], a
		ld a, [de]
		rst $30
		push hl
		pop bc
		ld l, d
		push bc
		ldi [hl], a
		and b
	db $DB
		ldh [$FD], a
		ld l, d
		add hl, de
		xor c
		ld c, b
		rlca
		ld [$F0F7], a
		ld d, c
		and d
		ld b, $80
		add hl, sp
		or l
		ld [$D2E9], sp
		ld a, b
		inc l
		and c
		xor $71
		daa
	db $F4
		ret
	
		and $16
		or d
		inc de
		call c, $B9C8
		or d
		inc c
		ld d, d
		cp a
		ld e, h
		ld c, a
	db $EB
		add c
		add hl, de
		ld a, [$4D4A]
		dec sp
		ld a, a
		cp d
		rst $28
		ld e, [hl]
		call c, $4E2B	; Possibly invalid
		xor $C1
		add hl, hl
		ld d, [hl]
		ld h, a
		ld e, [hl]
		ld bc, $1937
		and e
		adc l
		cp b
		dec l
		dec sp
	db $E3
		adc [hl]
		add h
		jp $26CE	; Possibly invalid
	
		ld h, c
		cp a
		and h
		ld hl, $525D
		adc h
		ld e, [hl]
		sub c
		ld e, c
		dec [hl]
		ldh [c], a
		dec hl
		ld l, b
		ld h, [hl]
		ccf
		ld e, b
		or e
		or h
		ld [hl], $4C
		ld b, [hl]
		adc $F5
		inc de
		pop bc
		daa
		ld a, a
		ld l, b
		ld c, $CA
		ld h, c
		sbc a, [hl]
		dec c
		add hl, hl
		ld l, [hl]
		ret z
		sbc $AC
		call nz, $1E42	; Possibly invalid
		ld [$DEC9], a
		ld d, h
		dec c
		ld e, b
		and $39
		and e
		ld hl, $629B
		ld b, l
		inc b
		inc b
	db $DD
		ld [$6E15], sp
		ld bc, $2928
		and e
		ld d, a
		cpl
		cp d
		call z, $36E1	; Possibly invalid
		cp $D1
		ld a, h
		ld c, c
		sub $4B
		inc a
		dec c
		push hl
		sbc a, a
		stop
		xor [hl]
		or d
		jr @ + 57
	
		pop de
		and l
		ret z
		cp c
		rst $28
		ld [hl], a
		and l
		sla e
		ld l, l
		ld d, e
		ld h, h
		ldi [hl], a
		ldi [hl], a
		pop de
		ld hl, sp+101
		dec hl
		or b
		reti
	
		jr z, @ + 92
		ldh [_PORT_33_], a
		ld e, b
		cp a
		and h
		rst $18
		ld d, [hl]
		xor b
		xor a
		ld d, c
		ld a, b
		dec a
		ld b, l
		cp e
		xor $D0
		ld a, c
		xor $3E
		sbc a, e
		jr z, @ - 4
		jp nz, $6F66	; Possibly invalid
		jr nc, @ - 7
		adc $6B
		add c
		and h
		rst $28
		add hl, de
		dec e
		ldh a, [c]
		adc l
		ld b, $90
		sub h
		ld c, a
		add hl, sp
		dec h
		rst $00	; CharacterMovementTable
		cp e
		dec hl
		ld [$A724], a
		ld h, a
		ld e, b
		xor a
		or h
		rrca
		cp c
		jr c, @ + 26
		add hl, hl
	db $DD
		scf
		sub h
		sub e
		pop bc
		ld a, [de]
		ld a, e
		and a
		adc l
		ld d, h
		adc $BD
		ld l, l
	db $D3
		ld l, a
		ld a, [hl]
		ld [hl], $30
		ld h, h
		pop de
	db $E3
		jp c, $36B3	; Possibly invalid
		add hl, de
		ld c, a
		ld h, l
		rla
		xor [hl]
		add a
		ld h, c
		ld c, c
		ld l, $3F
		ld b, l
		cpl
		push de
		ld c, $F8
		ld e, a
		ld a, b
		sub d
		inc h
		or a
		dec a
		ld a, d
		ld b, $95
		ld b, b
		push bc
		ld a, [bc]
		ret
	
		rst $18
		ldh [c], a
		xor b
		add hl, sp
		ld b, b
		and c
		xor e
		ld a, b
		ld [$DDE1], sp
		ld l, h
		cp $DE
		ld h, b
		rla
		ld h, $9A
		ld h, c
		ld l, h
		ld d, c
		sub $70
		ld [hl], l
		rst $00	; CharacterMovementTable
		and e
		ld l, h
		jr nc, @ - 39
		jp hl
	
		dec h
		xor l
		ld c, d
		xor a
		ld a, c
		rla
		ld d, h
		ld e, a
		add c
		ld l, [hl]
		sub c
		ld c, [hl]
		ld d, $28
		ld [hl], d
		xor e
		jp c, $5ECA	; Possibly invalid
		ret c
		ld l, [hl]
		ld b, h
		ld b, $A4
		ldd [hl], a
		cp l
		ld c, h
		ld h, c
		inc a
		ld b, d
		ld de, $6472
		sbc a, b
		ld l, h
		xor l
		sub l
		adc [hl]
	db $ED
		ld [de], a
		inc de
		ld h, [hl]
		ld c, c
		ldd a, [hl]
		dec c
		ld e, e
		set 1, [hl]
		sub b
		dec [hl]
		pop bc
		jp nz, $EA75	; Possibly invalid
		ld e, d
		ld l, l
		or d
	db $EC
		ld l, a
		add hl, hl
		and a
		sbc a, b
		xor a
		xor d
		ld [de], a
		ldh [$A5], a
		ld e, b
		and d
		ret z
	db $F4
		dec a
		ld bc, $BC06
		ld e, [hl]
		ld l, d
		and d
		inc bc
		jp hl
	
		rst $10	; wizardAbilities
		di
		ld h, [hl]
		dec de
		inc de
		ld [$EB20], a
		ld [hl], h
		ld c, [hl]
		stop
		jp c, $CB99	; Possibly invalid
		ld b, [hl]
		jp z, $78FB	; Possibly invalid
		or c
		add l
		add hl, hl
		xor h
		rst $38
		sub a
		ld hl, $7D85
		ld a, a
		cp c
		ld [hl], b
		and d
		cp d
		cp h
		ld a, a
		or [hl]
		jp z, $A104
		sbc $D3
		halt
		inc d
		sub h
		ldh [_PORT_35_], a
		dec e
		add sp, 93
		ld h, $90
		adc d
		ld a, c
		ret nz
		cp b
		ld c, a
		jp $D857	; Possibly invalid
	
		ld h, e
		sub d
		ld c, b
		ld c, h
		ld e, h
	db $E3
		ld l, c
		reti
	
		jp $BE37
	
		ld c, h
		ld b, [hl]
		ld b, [hl]
		or h
		ld h, b
		jr z, @ - 13
		ld l, $BA
		pop de
		ld c, $03
		add sp, 78
		ld l, $29
		sbc $F0
		ldi a, [hl]
		add sp, 57
		rst $20
		cp d
		add hl, de
		or l
	db $ED
		ld h, b
		add hl, sp
		daa
		add sp, 37
		jr c, @ + 84
		inc e
		sbc a, [hl]
		ld [hl], h
		ldh [_PORT_66_], a
		jp hl
	
		halt
	db $DD
		sub c
		ld l, c
		add e
		ld e, b
		jp $F25B	; Possibly invalid
	
		jp hl
	
		ld a, b
		ld d, d
		ldh [_PORT_7D_], a
		inc a
		and l
		ld l, a
		inc l
		or h
		dec hl
		xor $C7
		ld b, e
		adc d
		ld [hl], a
		ld h, b
		pop af
		rst $38
		ldh [$81], a
		ld hl, sp+73
		ret z
		ld e, e
		ldd a, [hl]
		ld bc, $0890
		rst $18
		cp [hl]
		inc b
	db $E4
		xor $49
		rst $38
		jp $C193	; Possibly invalid
	
		ld [hl], h
		sbc $8F
		adc [hl]
		sub d
		ld d, c
		ld a, e
		ldh [rOBP1], a
		ret nz
		ld c, e
		inc [hl]
		ld l, b
		cp d
		and [hl]
		ret
	
		adc h
		dec d
		rrca
		adc l
		halt
		and $EB
		jr @ - 77
	
		inc b
		ld b, d
		sbc a, e
		xor c
	db $F4
		add hl, de
		pop de
		ld a, d
		ld [hl], a
		add c
		and b
		add a
		jr @ + 89
	
		ld [hl], l
		jp $A178
	
		ld h, c
		ld h, [hl]
		push hl
		ld d, l
		adc e
		sub b
		ret z
		inc [hl]
		ld h, l
		or h
		call $6FB5	; Possibly invalid
		cp d
		sbc a, a
	db $FC
		ld d, [hl]
		ld l, d
		and b
		jr @ + 101
	
		ld d, b
		sbc a, h
		add a
		ld l, a
		inc [hl]
		sbc a, b
		and [hl]
		inc a
		ldh a, [$AF]
		rst $00	; CharacterMovementTable
		ld sp, hl
		sub h
		dec [hl]
		ld a, d
		ld [hl], c
		rra
		set 3, d
		ld hl, sp+-78
		reti
	
		ld c, h
		add hl, bc
		call $79A1	; Possibly invalid
		sbc a, d
		ld a, b
		and l
		call nc, $339C	; Possibly invalid
		add h
		ld b, d
		ld e, c
		jp hl
	
		ld e, l
		ei
		sub d
		ld a, $D9
		dec hl
		add a
		add $BA
		ld a, e
		inc bc
		ld [$772B], a
		xor e
		and $82
		sub $A6
		cp $05
		ld d, c
		add hl, sp
		push bc
		ldd [hl], a
		sub a
	db $E3
		jp c, $D439	; Possibly invalid
		ld [de], a
		ld h, b
	db $DD
		or [hl]
		adc l
		ld hl, $8022
		pop bc
		ld [hl], b
		nop
		add c
		add e
		ld d, e
		or d
		ld [hl], b
		and c
		rst $10	; wizardAbilities
		ret c
		ldh a, [c]
		ld [hl], h
		or [hl]
	db $DB
		ld h, d
	db $DD
		ld d, $A1
		ld l, d
		ldh a, [rAUD2LOW]
		inc bc
		add l
		jp nc, $C96C	; Possibly invalid
		ldh [_PORT_38_], a
		ld l, a
		and l
		ld b, l
		ld l, h
		ld [hl], c
		cp [hl]
		ld a, $8B
		adc e
		ld c, h
	db $D3
		or $9C
		add d
		dec l
		ld b, e
		sbc a, l
		ld c, e
		ldh a, [c]
		ld b, d
		and a
		sbc a, [hl]
		ld [bc], a
		xor e
		sub a
		ld l, h
		and d
		dec [hl]
		ld d, a
		ld d, c
		ld e, e
		ld e, d
		ld sp, hl
		sbc $A9
		add h
		xor c
		inc e
		ld hl, $09D9
		ld d, l
		adc c
	db $E3
		inc l
	db $ED
		ld a, [bc]
		ld [hl], a
		cp $20
		ld a, e
		cp $D4
		ldi a, [hl]
		ld h, b
		ld [hl], e
		dec l
		ld [hl], a
		ldi a, [hl]
		ld c, h
		ld e, h
	db $DD
	db $DB
		ldd [hl], a
		rst $10	; wizardAbilities
		pop af
		ld e, c
		dec a
	db $DB
		stop
		ld a, h
		xor l
	db $DB
		ld d, b
		adc c
		ld c, a
		ld l, $31
		stop
		ld sp, $5920
		sub h
		ld c, d
		ld c, a
		pop af
		sbc a, h
		ld b, b
		ld c, e
		ld [hl], c
		xor d
		ld c, l
	db $D3
		cp [hl]
		ld [hl], $B3
		push af
		inc h
		and l
		ld c, c
		ld d, h
		ld c, h
		inc e
		ld c, b
		ld d, l
		ld a, d
		sub d
		ld d, d
		and c
		ld h, $7C
		ldd a, [hl]
		ld e, $3D
		ld a, c
		ld l, e
		ld e, b
		ld [hl], h
		ld h, [hl]
		ld a, [de]
		inc bc
	db $EC
	db $EC
		add c
		add a
		ld d, d
		adc b
		ret nz
		ld c, h
		inc l
		sub b
	db $EC
		reti
	
		ld b, h
		ret nc
		ld a, [bc]
		adc [hl]
		ret
	
		rst $18
		ld e, $F7
		add hl, sp
		ldh a, [_PORT_2C_]
		or c
		ld [hl], l
		cp c
		inc d
		adc c
		add [hl]
		cp b
		ld a, c
		ldi a, [hl]
		ld h, c
		jp c, $AECF
		jr @ - 96
	
		ret c
		ld h, [hl]
		or h
		ld [hl], $60
		ld l, b
		ret
	
		ld h, d
		and [hl]
		ld b, d
		call $DA61	; Possibly invalid
		ld [de], a
		ld l, c
		call nz, $7A55	; Possibly invalid
		xor l
		add e
		ld h, h
		and c
		and [hl]
		scf
		ei
		dec bc
		xor $27
		add l
		stop
		ld b, [hl]
		dec sp
		call nc, $B689
		jr nz, @ + 2
		ld [hl], $B6
		add e
	db $FD
		add d
		or $F7
		rst $20
		or d
		dec b
		ld e, d
		rst $10	; wizardAbilities
		ccf
		dec [hl]
		rrca
	db $EB
		jp c, $C4A4	; Possibly invalid
		or $41
		rst $00	; CharacterMovementTable
		inc a
		cp e
		rst $10	; wizardAbilities
		ld b, e
		xor e
		ld c, $27
		dec bc
		ld [$7ACA], a
		ld [hl], $23
		dec c
		ret z
		jp nz, $132A	; Possibly invalid
		call nz, $0E95	; Possibly invalid
		add l
		and l
		dec l
		or e
		dec a
		ld c, a
		inc hl
		cp a
		ld l, d
		dec de
		cp a
		sbc $F5
		add b
		and [hl]
		ld h, $8F
		inc bc
		ret
	
		jp c, $89A4
		inc e
		ret nz
		add h
		reti
	
		ld c, l
		rst $20
		ld a, $1F
		ld a, [hl]
		ld l, $02
		ldh [c], a
		xor a
		ld c, $8C
	db $E3
		ld h, a
		ld a, a
		pop de
		dec h
		ld a, l
		dec e
		ld h, e
		add c
		jr nz, @ - 123
		cp [hl]
		adc [hl]
	db $E3
		set 6, d
		xor a
	db $D3
		ldi [hl], a
		ld h, a
		dec bc
		push bc
		cp b
		sbc $27
		reti
	
		adc h
		sub h
		rst $20
		add [hl]
		rst $10	; wizardAbilities
		sbc $31
		ld b, $77
		ld b, a
		ld b, b
		jp nc, $5BFF	; Possibly invalid
		ld de, $C4DB
		cp $FE
		adc [hl]
	db $FD
	db $FC
		ld d, l
		ld e, l
		ld b, $62
		ld e, b
		ld b, l
		ld a, [bc]
		inc b
		sbc $01
		add hl, de
		dec a
		add e
		push hl
	db $D3
		dec a
		ld c, $DE
		adc b
		sub l
		call c, $71BA	; Possibly invalid
		halt
		sub [hl]
		ret c
	db $E3
		rst $10	; wizardAbilities
		and c
		rst $28
		ld c, h
		sbc a, e
		rst $30
		pop af
		ld b, h
		ldi a, [hl]
		rst $10	; wizardAbilities
		sbc a, b
		pop hl
		dec sp
		sub $52
		ld d, $88
		rst $38
		and c
		ld h, [hl]
		add [hl]
		ld b, $EC
		ld c, $96
		add $7D
		rst $28
	db $DD
		ld b, l
		or e
		add l
		dec d
		pop hl
		add l
		ld a, $B5
		ld e, b
		and c
		ret c
		add l
		ld [bc], a
		ld e, b
		sbc a, [hl]
		pop hl
		sub e
		and c
		ld d, e
		sbc a, a
		or a
		halt
		ld b, l
		ld [hl], $73
		ld [hl], d
		dec d
		halt
		dec c
		ld [hl], e
		ld a, d
		ld b, a
		ld h, d
		ld l, c
		add sp, 101
		adc l
		pop hl
		ld a, c
		ld c, $87
		and e
		ld h, a
		ld h, [hl]
		ld e, l
		rst $38
		inc a
		ld h, l
		push de
		push hl
		ld bc, $2710
		rst $08
		jp z, $8ACD
		di
		ld b, a
		ld d, l
		add a
		push af
		ld c, b
		jr nz, @ - 77
		adc h
		or [hl]
		pop af
		rr [hl]
		jr @ - 41
	
		ldi a, [hl]
		and h
		or c
		xor l
		di
		ld c, a
		sub e
		ld sp, hl
		ld b, [hl]
		sbc a, h
		sub l
		jp c, $8FF0
		ld l, l
		dec a
		inc bc
		add [hl]
		rst $38
		pop bc
		ld l, c
	db $EB
		or c
		ld e, e
		adc b
		ld l, a
		ld a, [de]
		ld [hl], e
		ld d, a
		and c
		ld h, c
		sub c
		sub b
		or h
		ld [hl], d
		ld [bc], a
		inc l
		xor b
		add hl, de
		add hl, hl
		ld d, $5B
		add hl, sp
		ld sp, $625B
		push de
		pop hl
		cp h
		cp $1D
		sub c
		ld [hl], a
		add e
		rst $20
		ld a, b
		stop
		jp nz, $50AE	; Possibly invalid
		ld h, [hl]
		sbc a, h
		ld e, l
		call $4A11	; Possibly invalid
		scf
		ld c, l
		ld a, [hl]
		call nz, $E9A6	; Possibly invalid
		nop
		inc e
		ld d, h
		add d
		push de
		rla
		rla
		adc d
		xor $60
	db $FC
		sub a
		ld d, a
		adc l
		add sp, 45
		cpl
		ld l, $B8
		dec h
		jp nc, $CCD4	; Possibly invalid
		rla
		dec [hl]
		ret c
		and l
		ld c, c
		ld [hl], d
		ld d, b
		cp b
		add e
		inc [hl]
		cp h
		sbc a, h
		inc [hl]
	db $DB
		ld [hl], l
		add l
		dec c
		ld h, [hl]
		ldd a, [hl]
		dec h
		cp c
		ld l, a
		ei
		jr nc, @ + 75
		sub h
		ld e, b
		dec [hl]
		ld d, l
		ld sp, hl
		inc sp
		ld bc, $1ECB
		halt
		xor h
		or a
		adc c
		ldh a, [$B6]
		rst $38
		xor a
		cpl
		ld a, $A1
		xor $20
		or b
		jp hl
	
		ld c, h
		ld b, h
		daa
	db $DD
		and $05
		or d
		add hl, sp
		ld [hl], l
	db $E3
		ld a, $17
	db $D3
		sub l
		rra
		dec l
		add $21
		jr nc, @ - 83
		ld [hl], h
		ldi a, [hl]
		cp e
		ld [hl], c
		ld a, b
		jp hl
	
		sub l
		call nc, $FCF0	; Possibly invalid
		cp $74
		ld [$2FDF], a
		jr c, @ + 60
		ld [hl], l
		adc a
		cp e
		ld [hl], c
	db $E4
		ld sp, $C37D
		ld h, [hl]
		dec hl
		ld c, d
		ld a, [hl]
		dec d
		and c
		ld a, d
		add hl, hl
		xor l
		ld e, b
		or e
		ld b, a
		nop
		ldh a, [c]
		ld a, l
		add [hl]
		sub a
		ld h, l
		jr @ + 8
	
		rst $18
		ret nz
		ld [hl], l
		ldh a, [$94]
		ld a, [bc]
		ld b, [hl]
		dec e
		ld c, d
		dec [hl]
		ld a, [$78A4]
		sub e
		jr nc, @ + 58
		or c
		ld [bc], a
		pop bc
		ld c, [hl]
		adc b
		ldh [rAUD1LOW], a
		dec d
		ld a, d
		or $A8
		rst $28
		rla
		rr c
		ld b, d
		dec [hl]
		dec hl
		ld b, e
		ldh [rSTAT], a
		ld b, [hl]
		sub a
		or l
		cp e
		adc h
	db $E3
		adc c
		xor c
		add c
		push hl
		ld a, [de]
		ld a, c
		rst $20
		inc c
		ld a, a
		cp [hl]
		or b
		ld h, d
		dec de
		ld e, b
		ld a, [$D0AB]
		ld sp, $6C80
		cp $E4
		dec l
		or d
		sub b
		xor c
		add hl, sp
		rst $28
		add b
		ld l, c
		scf
		ld [hl], b
		cp e
		rst $00	; CharacterMovementTable
		and b
		cp e
		call c, $DBAC	; Possibly invalid
		sub a
	db $EB
		jp $FFF8	; Possibly invalid
	
		xor h
		push de
		rrca
		call nc, $9E80
		ld e, l
		ld a, [de]
		ld d, b
		push de
		ld b, a
		rst $30
		dec [hl]
		inc hl
		ld l, a
		ld a, e
		ld d, d
		ld e, c
		ld h, a
		cp c
		ld l, l
		ld a, $B6
		ld h, l
		ld l, e
		ld [$AEC2], a
		ret nc
		ld e, c
		adc b
		ld b, e
		add [hl]
		ld d, [hl]
		ld b, $57
		ld c, c
		sbc a, l
		dec b
		xor a
		halt
		push af
		ccf
		dec bc
		add $B8
	db $FC
		ld l, l
		cp [hl]
		sbc a, a
		ld b, c
		dec l
		xor e
		dec b
		xor d
		ld e, l
		ld e, b
		ld [hl], c
		and b
		inc l
		ld b, [hl]
		ld e, [hl]
		ld a, [de]
		rst $18
		ld [$0F90], sp
	db $F4
		jr nz, @ - 12
		push bc
		ld [hl], $60
		jr nc, @ + 89
		and a
		and h
		add $42
		ld a, $71
		ld de, $0878
		ld bc, $5C55
		rla
		sub d
		halt
		ld e, h
		sub b
		ld [$A1EC], a
		and l
		ret z
		ld l, b
		ld h, [hl]
		reti
	
		ld e, l
		ldh a, [$94]
		ld b, h
		cp c
		pop bc
		or e
		ld d, $67
		ld d, c
		jp hl
	
		sbc a, [hl]
		cpl
	db $ED
		inc sp
		ld c, l
		ld e, e
		and a
		ldh a, [$84]
		ldh [rTMA], a
	db $EC
		ldd a, [hl]
		pop hl
		ld [hl], d
		add hl, de
		ld b, h
		inc hl
		inc b
		sub [hl]
		ld c, c
		push hl
		add hl, bc
		or a
		adc e
		rst $30
		ld c, a
		ld [hl], c
		ld [hl], h
		add hl, sp
		ld [hl], h
		sbc a, a
		sub a
		ld [bc], a
		or $C0
		xor l
		sbc a, l
		ld l, h
	db $ED
		ld e, c
		or d
		ld [$3977], sp
		or [hl]
		inc hl
		ld d, c
		ld h, [hl]
		inc h
		adc h
		push bc
		ld a, b
		ld d, b
		ld e, b
		add h
		add h
		inc bc
		ld l, d
		ldh a, [c]
		or a
		ld c, h
		ld a, b
		jr @ + 83
	
		ld c, $82
		and h
		ld a, [$1A77]
		cp [hl]
		or c
		xor l
		adc $E4
		dec a
		add a
		ld d, d
		ld b, b
		add $63
		ld l, $97
		add hl, hl
		add l
		jp nz, $9AC7
		push de
		sub $D4
		inc h
		ldh a, [rAUD1LEN]
		adc $0D
		adc h
		inc b
		ld l, [hl]
		sub d
		pop af
	db $ED
		inc e
		ld l, l
		adc c
		cp e
		ld e, [hl]
		add hl, hl
		dec de
		ldd [hl], a
		ld d, d
		xor h
		ld b, e
		add $21
		add d
		ld e, b
		ld [$6744], sp
		xor e
		dec hl
		add hl, de
		sbc a, b
		cp b
		inc a
		ld b, $CB
		ld [hl], c
		add h
		rst $20
		ld b, h
		ldi a, [hl]
	db $FD
	db $D3
	db $EC
		or l
		add b
		ld b, [hl]
		or l
		ld b, e
		halt
		ld b, b
		ld e, c
		inc e
		ret
	
		ld l, l
		xor b
		sub [hl]
		ld [hl], c
	db $E3
		add l
		ccf
		ld c, e
		ld [$4133], sp
		ld c, e
		adc h
		ld a, [de]
		dec a
		adc a
		dec bc
		inc sp
		jp c, $650C	; Possibly invalid
		adc d
		ld b, l
		ld l, h
		jr @ - 62
	
		dec de
		ld e, h
	db $DD
		ldh [$D2], a
	db $DD
		ld a, [bc]
		sub b
		ld c, $69
		push af
		ld e, l
		adc c
		inc sp
		dec [hl]
		rst $18
		add hl, bc
		adc l
		cp [hl]
		sub [hl]
		ld [hl], h
		ld e, $56
		dec a
		add hl, bc
		and e
		jr @ + 114
	
		and l
		ld d, e
		cp a
		xor e
		and c
		sbc a, l
		ld l, [hl]
		add sp, 78
		xor b
		scf
		adc e
		rla
		or b
		add hl, de
		sub e
		adc e
		sub l
		ld b, d
		cpl
		ld [$4B1B], a
		sub a
		inc a
	db $ED
	db $E4
		ld d, h
		ld a, d
	db $EC
		reti
	
		ld l, $9D
		adc e
		call c, $2864	; Possibly invalid
		cp c
		cp $E3
		ld h, l
		ld d, a
		ld d, $19
		rlca
		adc c
		ld c, h
		ld [hl], e
		and b
		pop de
		ret
	
		ldi [hl], a
		and e
		ld d, e
		ld a, $87
		xor d
		call z, $5CDE	; Possibly invalid
		ld d, e
	db $D3
		adc c
		and d
		rla
		ld a, c
		ld a, e
		ld a, d
		inc h
		scf
		inc [hl]
		inc l
		and a
		ld d, e
		ld [hl], e
		ld l, [hl]
		cpl
		ld l, l
		adc [hl]
		pop af
		ldh [c], a
		ret nz
		ld [bc], a
		ld b, e
		nop
		xor a
		ld a, h
		adc a
		reti
	
		dec l
		ld l, d
		ld e, l
		dec c
		sbc a, a
		call nz, $0C9A	; Possibly invalid
		pop bc
		and d
		ret z
		jp $5146	; Possibly invalid
	
	db $FD
		rst $18
	db $FC
		dec de
		cp $18
		ld d, $C7
		di
		adc b
		or a
		sub h
		xor l
		dec e
		dec d
		ld de, $95FC
		jr c, @ + 72
		add [hl]
		add sp, -35
		ld b, l
		rst $18
		ld l, h
		ld l, $06
		sbc a, d
		xor [hl]
		inc b
		rst $08
		ld e, e
		ld [hl], l
		ld e, b
		adc $06
		stop
		inc bc
		adc e
		dec hl
		and $97
		xor l
		sbc a, b
		or h
		ld a, e
		ld a, $3E
		sbc a, d
		sub a
	db $FD
		ld l, $3E
		inc c
		cp a
		inc c
		ld d, l
		sub d
		ld [$02B3], sp
		adc l
		ld [hl], h
		ld c, h
		ld e, e
		nop
		rst $00	; CharacterMovementTable
		xor a
		ret nz
		xor c
		ld e, b
		or e
		inc a
		dec d
		ld b, e
		dec bc
		cp $34
		adc b
		jr nc, @ + 71
		jr nz, @ + 39
		ld c, $B5
		and l
		ld l, h
		and c
		cpl
		cp e
		ld [hl], l
		ld l, h
		ld e, a
		dec sp
		add hl, de
		ldi a, [hl]
		jr z, @ - 80
		inc hl
		dec c
		adc b
		scf
		ei
		ccf
		adc c
		ld l, $F1
		ld e, d
		ld a, e
		sub d
		ld [bc], a
		call nc, $CA38	; Possibly invalid
		ld [hl], a
		rst $38
		reti
	
		ld h, $AB
		ld l, d
		ldh a, [c]
		ld sp, hl
		xor b
		ld h, [hl]
		ld c, l
		ld sp, $6EC1
		ld e, c
		cp e
		cp h
		push bc
		ld a, [$956E]
		call c, $2D1B	; Possibly invalid
		push de
		inc a
		sub c
		or a
		ld h, d
		dec sp
		dec e
		dec [hl]
		and a
		ld b, [hl]
		sub h
		ld c, [hl]
		inc c
		cp l
		inc h
		xor e
		ld h, l
		sub $9C
		ld [hl], h
		ldh a, [c]
	db $DB
		add hl, de
		sub [hl]
		sub $88
		dec h
		ldh a, [c]
		adc a
		cp l
		and b
		or $DC
		sbc a, c
		rst $00	; CharacterMovementTable
		adc [hl]
		push bc
		sub a
		adc c
		xor a
		rlca
	db $DD
		ld l, c
		inc h
		ld b, e
		ld [hl], a
		ld hl, $ABE6
		ld [hl], e
		sbc a, l
		ld h, e
		inc d
		add hl, de
		ld l, e
		pop af
	db $DD
		cp a
	db $DB
		and a
		xor d
		inc d
		jp $329F	; Possibly invalid
	
		dec l
		inc e
		ld l, c
		jp $91FF
	
		ldi a, [hl]
		ld a, [hl]
		ld [hl], $E5
		ld b, c
		ld a, b
		ld d, b
		ldi a, [hl]
		and l
	db $EC
		ld a, d
		or [hl]
		ld a, [de]
		ld d, b
		ccf
		ld b, h
		ld e, $B4
		rlca
		ld l, d
		add a
		or c
		ld a, c
		jp nc, $6DE6	; Possibly invalid
		sub d
	db $F4
		jp $593A	; Possibly invalid
	
		add [hl]
		and a
		ld d, e
		ld hl, sp+-62
	db $E3
		ld a, h
		push af
		pop bc
		rra
		ld b, h
		ld d, b
		call $6B32	; Possibly invalid
		ret nz
		ld [$172C], sp
		reti
	
		ld d, d
		adc c
		ld c, [hl]
		ld h, c
		rst $20
		rst $30
	db $E3
		ld hl, $A524
		ld h, b
		ld sp, hl
		ld e, c
		sbc a, d
		ld b, b
		ld a, $52
		add hl, sp
		ld e, l
		ld [hl], h
		rst $00	; CharacterMovementTable
		and e
		ld d, $46
		add hl, bc
		ld l, [hl]
		dec l
		ld d, [hl]
		push af
		ld l, $8B
		ld sp, hl
		ld [hl], a
		ld b, $7D
		rla
		dec h
		ld [$30B8], sp
		adc a
		dec [hl]
		sub e
		ld h, e
		ld h, $BA
		ld h, e
		call nc, $8791
		ret c
		ld [hl], d
	db $EC
		sub e
		and c
		push af
		ld [hl], h
		jp z, $47BC	; Possibly invalid
		ldh a, [_PORT_3A_]
		ld h, c
		inc e
		ld b, [hl]
		daa
		ld hl, $74D1
		ld c, a
		inc de
		cpl
		pop hl
		add sp, 104
		add $6A
	db $D3
		ld [hl], d
	db $EC
		add c
		ld a, h
		inc sp
		xor a
		ldh [$EE], a
		ld bc, $F1B8
		ld l, l
		add d
		and a
		ld b, [hl]
		and h
		ld b, [hl]
		ld d, h
		ld d, e
		jp nc, $453E	; Possibly invalid
		ld c, b
		jp $200E	; Possibly invalid
	
		ldh [c], a
		call nc, $9B83
		ld h, [hl]
		rst $38
		call $33D1	; Possibly invalid
		ld e, d
		ldh a, [c]
		ld e, d
		pop de
		rst $28
		ld hl, $07C5
		ld bc, $FD0E
		ret
	
	db $E4
		rst $28
		xor d
		ei
		and l
		ld c, e
		ld d, l
		ld sp, hl
		jr c, @ - 44
		rst $28
	db $E3
		xor [hl]
		and [hl]
		di
		ldi [hl], a
		pop hl
		call nc, $0D1D	; Possibly invalid
		ld e, [hl]
	db $EC
		xor e
		or e
		ld c, c
		daa
		ld h, b
		ld c, $F6
		ld a, c
		reti
	
		ldh [c], a
		or h
		ld b, [hl]
		add a
		ld l, h
		ld l, l
		ld l, $3F
		jr @ + 88
	
		ld h, b
		ld h, $C2
	db $EB
		adc c
	db $F4
		sbc a, a
		ld c, c
		dec de
	db $E3
		ret
	
	db $EC
		ld c, d
		ld c, [hl]
		call z, $C16C	; Possibly invalid
		or b
		cpl
		dec e
		call z, $02D7	; Possibly invalid
	db $EB
		or h
		ld c, e
		cp d
		and [hl]
		ld d, l
		push hl
		ld d, l
		rst $10	; wizardAbilities
		sub [hl]
		ld a, b
		dec b
		add e
		xor $00
		or l
		ret c
		rst $20
		ld e, h
		or c
		ld bc, $1FDE
		ld c, $6B
	db $F4
		xor d
		cp l
		ld [hl], $E4
		adc h
		inc bc
		ld a, a
		ld sp, hl
		xor b
		ld e, [hl]
		add l
		ld [hl], c
		sub e
		ld l, h
		and l
		call c, $97B3
		sbc $76
		rrca
		ld [de], a
		ld [de], a
		ld a, d
		sub b
		adc e
		ld l, [hl]
		ld e, d
		xor h
		cp e
		jp hl
	
		rst $08
		sbc a, l
		ld l, c
		reti
	
		ld e, [hl]
		rst $20
		ldh a, [rBGP]
		dec d
		ldd a, [hl]
		or h
		ei
		ld c, a
		ldh [c], a
		sbc a, c
		ld c, e
		ld bc, $938C
		ld h, c
		cp l
		xor h
		and $63
		cp e
		ld a, c
		rst $00	; CharacterMovementTable
		ld d, d
		di
		rlca
		ret z
		xor [hl]
		sbc a, b
		rst $18
		pop de
		ld c, d
		rst $30
		ld [hl], l
		or h
		xor $BD
		jp c, $48F4	; Possibly invalid
		ld d, a
		inc e
		ld a, [de]
		dec [hl]
		jp nc, $AFBD
		ld hl, $2A2F
		cp d
		and l
		and d
		dec hl
		ld e, a
		ld e, c
		jp c, $9A66
		ldd a, [hl]
		ldh [c], a
		inc c
		pop hl
		xor a
		cp $19
		ldd [hl], a
		sbc a, e
		jp hl
	
		ldd [hl], a
		ld hl, $2890
		or h
		inc [hl]
		ld c, a
		call c, $BC15
		ld b, b
		ldi [hl], a
		ld a, l
		xor $8C
		ei
		ld l, l
		or $48
		dec de
		stop
		ld a, b
		inc b
		ld a, [de]
		ld l, l
		sub l
		ldi a, [hl]
		scf
		or e
		ld c, l
		ret nc
		rst $28
		ld b, $71
		pop af
		rst $10	; wizardAbilities
		ld c, c
		ld b, d
		ld [hl], b
		jp c, $C4CF	; Possibly invalid
		ld l, c
		or l
		ld b, a
		ld e, [hl]
		adc [hl]
		cp $59
		xor d
		ld b, l
		ld e, d
		inc d
		ld e, c
		cp e
		dec b
		ld sp, hl
		adc [hl]
		ld e, l
		adc $28
		ld c, a
		ld hl, sp+-81
		ret nz
		xor l
		and c
		ld c, a
		or c
		ld d, a
		jr nz, @ + 99
		sub $3A
	db $F4
		push hl
		adc h
		or e
		push bc
		jr nc, @ + 117
		ld h, $67
		push af
		ld c, a
		ld l, l
		dec hl
		xor b
		ld l, l
		dec b
		adc $B9
		ld l, d
		dec sp
		inc [hl]
		ld d, b
		cp e
		stop
		sub l
		ld d, c
		sbc a, h
		push de
		dec l
		jr nc, @ + 98
		sra h
		ld l, a
		sub a
	db $DD
		dec a
		ld a, [de]
		jp $0D65	; Possibly invalid
	
		ld b, $41
		rst $30
		daa
		dec l
		ld [$AF90], sp
		ld l, $DA
		sub h
		jp nc, $C60D	; Possibly invalid
		dec d
		inc h
		sub e
		jr c, @ - 91
		sbc a, l
		cp d
		ld h, e
		ld b, b
		ccf
	db $EB
		adc e
		inc [hl]
		dec sp
		ld d, d
		ld h, [hl]
		or a
		ld a, c
		pop bc
		inc l
		jp hl
	
		dec e
		dec hl
		ld h, h
		ld c, d
		sub l
		adc a
		and b
		ld sp, hl
		ld [bc], a
		sub [hl]
		ld h, [hl]
		jp z, $8737
		ld l, d
		ld e, h
		ld l, [hl]
		ld e, d
		ld l, h
		rst $38
		ld d, b
		xor h
		ld hl, $F9C4
		ld c, [hl]
		ld e, $74
		ld l, $BA
		ld bc, $A7D5
	db $EB
		push hl
		ret
	
		add h
		ld d, [hl]
		halt
		dec sp
		dec a
		add e
		ld d, l
		rrca
		ld a, d
		inc a
		inc d
		ld c, $AD
		ret nz
		ld d, c
		and l
		inc l
		sbc $10
		dec a
		ld e, c
		sub b
		ld h, c
		push af
		sub l
		adc d
		sbc a, b
		sub a
		ret z
		rla
		ld c, h
		ld a, b
		ldh a, [$87]
		ld d, b
		ld d, e
		call c, $BB4F
		ld e, e
		inc de
		pop hl
		ldh [rSC], a
		ld h, l
		ld [$3043], sp
		add hl, hl
		ld l, c
		xor e
		rla
		ld [$61A2], sp
		scf
		ld h, [hl]
		ld d, b
		cp l
		ld d, h
		jr z, @ + 95
		add sp, -66
		ld d, $24
		add d
		call nz, $6E6D	; Possibly invalid
		xor [hl]
		ld l, l
		ld e, a
		ld l, a
		ld hl, $DE0A
		inc b
		or e
		ld d, e
		and h
		ld [de], a
		ld e, $53
		sbc a, c
		ld e, e
		sub a
		ret z
		ld d, a
		sbc a, d
		ld a, h
		ld b, d
	db $FC
		add d
		jp c, $4489	; Possibly invalid
		dec de
		add $E6
		inc sp
		ldh a, [c]
		ld h, c
		add h
		jr nc, @ - 22
		ld a, $DC
		cp b
		add hl, sp
		and e
		ld c, l
		xor e
		ld e, h
		and $6A
		jr @ + 1
	
		ld b, h
		ld e, a
		sub b
		inc l
		ld c, c
		xor e
	db $ED
		ld h, e
		ld bc, $80AD
		inc a
		cp b
		sbc a, d
		ld l, b
		dec sp
		sbc a, c
		add c
		rla
		rst $00	; CharacterMovementTable
		add hl, hl
		pop af
		ld c, a
		dec bc
		ret z
		ldh a, [rDMA]
		xor l
	db $ED
		rst $20
		adc h
		xor h
		ld [hl], l
		or b
		ld h, e
		inc h
		ld l, d
		ret nc
		and h
		ld [hl], c
		rst $38
		sbc a, d
		dec d
		xor e
		ldd a, [hl]
		ldh [c], a
		and l
		ld b, c
		rst $18
		sub d
		inc l
		inc bc
		ld h, c
		ld [hl], d
		inc b
		sbc a, e
		dec c
		cpl
		and $34
		sub $28
		ldh a, [$96]
		nop
		inc bc
		jp z, $330A	; Possibly invalid
		cp $62
		ld c, $D7
		rst $28
		adc b
		ld d, a
		ld b, h
		ldh a, [_PORT_0A_]
		and $EC
		jp $39E1	; Possibly invalid
	
		rlca
		xor d
		call $F6D5	; Possibly invalid
		adc $7E
		dec bc
		or $C6
		dec h
		sub [hl]
		cp $F2
		dec h
		inc sp
		sub b
		ld a, e
		inc sp
		ld l, h
		or b
		ld h, l
		ld l, h
		rst $28
		and a
		ld [$E098], sp
		ret nc
		rra
		ld d, c
		ld a, c
		ld a, d
		add l
		and b
		cpl
		ld e, b
		xor c
		cp d
		inc hl
		ld a, d
		ldi a, [hl]
		ld d, l
		adc d
		ld c, b
	db $F4
		call z, $5610	; Possibly invalid
		or a
		jr nc, @ + 85
		ld l, $92
		and e
		call c, $E437	; Possibly invalid
		inc a
		or c
		ld e, h
		or e
		and e
		dec l
		ld b, $92
		jr c, @ - 98
		ld a, [$DE13]
		ld h, a
		add hl, sp
		ret z
		ld c, c
		add hl, bc
		ld h, a
		rrca
		adc $D8
		add sp, 69
		ld e, l
		ld d, h
	db $EC
		inc bc
		ld a, l
		or h
		push hl
		ld [$2F16], a
		ld b, [hl]
		dec de
		sbc $AB
		add hl, de
		rla
		and c
		ldi a, [hl]
		add [hl]
		ret nc
		call $B6A6
		add l
		ldd a, [hl]
	db $DD
		adc e
		ld d, c
		adc [hl]
		jr @ - 87
	
		rra
		sub d
		cp $90
		inc [hl]
		ld b, b
		cp b
		ld b, l
		sbc $6F
		jr nz, @ - 119
		cp $D9
		rst $18
		adc c
		and l
		add hl, hl
		rst $10	; wizardAbilities
		ld h, c
		jr z, @ - 77
		cp [hl]
		ret
	
		call nz, $E094	; Possibly invalid
		or $79
		sub e
		sbc a, h
		xor d
		or h
		ld b, $6F
		nop
		rst $18
		sub d
		rlc c
		ld l, l
		add sp, 100
		ld a, [hl]
		ld a, [bc]
		sbc a, d
		sbc a, b
		ld h, a
		cp c
		ld a, [de]
		ld d, $DC
		adc h
		rst $00	; CharacterMovementTable
		add l
		ld a, [hl]
		sbc a, e
		add hl, hl
		sub [hl]
		ld l, h
		ld e, l
		dec h
		ld b, d
		ld c, d
		scf
	db $E4
		and $2F
		ld hl, $704B
		cp h
		jr nc, @ + 92
		ldd [hl], a
		ld b, l
	db $E3
		ret z
	db $FC
		ldh [c], a
		and $D1
		ld a, [hl]
		ld a, $63
		rst $10	; wizardAbilities
		rst $30
		sub h
		cp c
		ld h, a
		dec hl
		inc e
		add a
		ld l, $28
		ei
		rst $00	; CharacterMovementTable
		ld a, b
		cp [hl]
		dec bc
		ei
		dec l
		ld b, h
		jp c, $F089	; Possibly invalid
		rst $20
		call $A18E
		sub l
		xor h
		ld a, [bc]
		and h
		scf
		dec [hl]
		ld e, a
		add $20
		dec sp
		ld l, b
		rst $28
		jr nc, @ - 122
		adc a
		ldh [$BE], a
		and $CD
		ld a, b
		ld e, e
		ld a, [bc]
		xor [hl]
		ld sp, hl
		ld a, e
		cp a
		rst $30
		ldh a, [c]
		rst $18
		ldd [hl], a
		sub $EA
		add d
		ld a, e
		rlca
		ld hl, $1A8A
		rst $30
		reti
	
		ld c, e
		ld l, h
		ld b, [hl]
		inc [hl]
		cp b
		rst $10	; wizardAbilities
		xor b
		sbc a, [hl]
		jr c, @ - 29
		inc sp
		push de
		adc l
		ret z
		ld l, d
		ld [hl], e
		pop hl
		push af
		ld c, b
		add $EC
		sra b
		ld [hl], l
		ld c, [hl]
		inc c
		adc c
		rra
		dec l
		sbc a, c
		ld [hl], l
		dec d
		pop af
		ld a, e
		jr @ - 121
	
		ld a, $5C
		ld [$DFAC], a
		inc l
		ret c
		xor l
		call c, $D955	; Possibly invalid
		ret
	
		rst $10	; wizardAbilities
		cp [hl]
		dec sp
		and a
		call $677C	; Possibly invalid
		sbc a, l
	db $DD
		scf
		ld d, d
		jr z, @ - 70
		jr nc, @ + 31
		ld b, h
		add sp, 80
		ld d, [hl]
		ld a, [bc]
		sbc $4C
		rst $10	; wizardAbilities
		inc h
		rst $00	; CharacterMovementTable
		ld [hl], l
		sub $CB
		ld c, e
		adc l
		rlca
		call nc, $9AD1
		rlca
		sub c
		ld c, d
		ret nz
		dec a
		ld c, [hl]
		ld b, $8E
		sub h
		or h
	db $D3
		ld de, $24EF
		ld d, e
		jp nc, $3FD1	; Possibly invalid
		ld e, [hl]
		xor h
		sub c
		xor a
		ld h, l
		or l
		dec c
		dec a
		ld [$1D1B], sp
		jp nc, $2FDD	; Possibly invalid
		ld c, [hl]
		rst $18
		ld c, l
		ldh a, [c]
		ld h, c
		inc d
		ld b, l
		dec c
		rst $08
		cp e
		adc h
		call c, $3981	; Possibly invalid
		ret c
		rst $30
		stop
		ld e, h
		adc b
		and h
		ld d, e
		add d
		add b
		ld d, c
		ld [hl], h
		add h
		sub e
		sub e
		ld a, b
		rst $28
		and c
		inc l
		or $24
		sbc a, d
		ld d, e
		ld e, d
		and a
		inc de
		ld d, l
		cp b
		ld a, [de]
		ld h, [hl]
		cp e
		ld [hl], c
		pop bc
		adc e
		ld a, [bc]
		ret
	
		ld [hl], $5A
		rst $10	; wizardAbilities
		sbc a, d
		daa
		dec c
		ld a, [bc]
		cp d
		pop de
		adc $26
		sbc a, b
		ld b, [hl]
		ld e, l
		adc c
		ld l, [hl]
		or d
		sub h
		ld c, a
		dec [hl]
		add l
		ld e, h
		pop af
		xor a
		ld d, h
		sub d
		ld d, h
		ldh a, [_PORT_4E_]
		add hl, hl
		sub a
		dec bc
		ld [de], a
		ld a, [hl]
		dec l
		adc a
		ld a, l
		ld h, [hl]
		ld b, b
		xor e
		rst $18
		add [hl]
		ld a, l
		ld l, c
		cp d
		ld [hl], l
		jp $5AD9	; Possibly invalid
	
		adc a
		ld a, b
		cp e
		dec c
		sbc a, d
		dec hl
		ld [hl], $1A
		ldh [c], a
		ldi [hl], a
		ld [$098B], a
		adc c
		sub c
		ldh a, [$99]
		xor c
		ldi [hl], a
		adc [hl]
		ld h, c
		ld sp, hl
	db $DD
		reti
	
	db $E4
		inc hl
		ld h, c
		ldd a, [hl]
		xor $7B
		and l
	db $E3
		jr c, @ - 53
		sbc a, c
		sbc a, d
		ld c, $EF
	db $F4
		jr c, @ - 28
		sbc a, [hl]
		ld b, b
		sbc a, l
		ld d, e
		ldh a, [$B9]
		call $B1EE
		ld h, a
		sbc a, d
		swap a
		dec l
		sbc $5A
		inc e
		ld [bc], a
		ld [$047D], a
		ld [$8EAF], sp
		sbc a, d
		add hl, bc
		jr nc, @ - 105
		ldd a, [hl]
		ret z
		ld c, [hl]
		xor e
	db $D3
		and h
		xor [hl]
		push af
		ei
		xor c
		ld d, d
		rst $00	; CharacterMovementTable
		ld d, l
		and d
		push af
		jp $7C25	; Possibly invalid
	
		sbc a, b
		halt
		rlca
		ld h, $AF
		add a
		ld h, l
		add sp, 30
		add sp, -36
		ld l, h
		rra
		xor l
		sub d
		ld d, a
		call c, $C2E0	; Possibly invalid
		add d
		rra
		call c, $1B95	; Possibly invalid
		ld a, h
		dec sp
		add hl, de
		sub [hl]
		dec e
		halt
		ld a, a
		ldd a, [hl]
		ld e, a
		dec l
		ld [hl], d
		xor [hl]
		sbc a, [hl]
		xor [hl]
		dec sp
		xor l
		dec e
		adc l
		dec bc
		ld h, l
		inc [hl]
		add hl, bc
		ld [de], a
		or b
		dec hl
		ld h, [hl]
		cpl
		adc a
		ret c
	db $ED
		dec sp
		ld d, b
		jp nz, $B1BD
		add l
		and e
		cp l
		reti
	
		dec a
		ld a, [hl]
		ld d, $B5
		rlca
		sub $56
		ld d, $79
		ld [hl], c
		ld h, l
		ld e, h
		pop hl
		ldh a, [_PORT_52_]
		ld a, a
		ld [hl], d
		add e
		ld b, b
		ld b, c
		ld l, c
		ld b, h
		ccf
		ld [hl], l
		or b
		ld e, $02
		ld c, b
		ld l, e
		ld c, e
		jr @ + 41
	
		ld d, a
		rlca
		ld d, $FB
		inc c
		dec a
		or h
		or l
		ld c, d
		dec [hl]
		ldi a, [hl]
		or b
		xor b
		dec sp
		add a
		add sp, -5
		dec a
		dec h
		add l
		rst $08
		ld l, a
		inc d
		ld a, [hl]
		sub c
		sbc a, e
		or b
		or h
		rst $30
		ld sp, hl
		sub c
		jr @ + 66
	
		cp b
		or $E1
		or [hl]
		sbc a, e
		call nc, $86BE
		add hl, bc
		cp a
		cp e
		reti
	
		ldi a, [hl]
		ld a, b
		ld e, e
		daa
		dec h
		ld b, a
		set 7, c
		rst $00	; CharacterMovementTable
		ld d, $A1
		and [hl]
		jp nc, $3767	; Possibly invalid
		or a
		push hl
		or $B9
		ld b, e
		ld a, l
		ld a, b
		jr nc, @ + 54
		and [hl]
		dec hl
		ld d, [hl]
		ld [hl], c
		ld a, [hl]
		ld b, $EE
		jp hl
	
		add hl, sp
	db $EC
		ld a, [de]
		inc c
		or b
		call nz, $8463
		ld a, [bc]
		ld d, d
		cp b
		sbc a, b
		push de
		sub l
		ld sp, $8CFF
		ld [bc], a
	db $ED
		dec [hl]
		ld bc, $3951
		adc $69
		rra
		ld l, $09
		dec l
		ret nc
		sbc a, l
		sub c
		sbc a, d
	db $DD
	db $EB
		ld c, e
		sub c
		ld c, a
		ldd [hl], a
		ld [hl], l
		jp z, $5D79	; Possibly invalid
		ld c, b
		jr nz, @ - 96
		ld d, l
		ld a, [bc]
	db $EC
		ret c
		jr z, @ + 55
		reti
	
		sub a
		ld c, e
		ld l, $95
		rla
		ld a, b
		call z, $5E0D	; Possibly invalid
	db $DB
		ld b, c
		rst $38
		ld e, a
	db $EB
		ld h, d
		ld [de], a
		adc c
		dec l
		jp c, $DC28	; Possibly invalid
		ld c, d
		dec a
		xor $D3
		reti
	
		jp nc, $6985	; Possibly invalid
		rst $38
		or [hl]
		cp h
		inc h
		ret z
		ld [hl], l
		inc [hl]
		adc e
		ld c, l
		jp hl
	
		ld [hl], a
		ldh a, [$A0]
		add c
		ld l, h
		and b
		ld [hl], h
		adc e
		jp nc, $A388
		add l
		daa
		xor h
		ld h, d
		or e
		adc c
		cp c
		inc hl
		ldi [hl], a
		sbc a, h
		scf
		ld [bc], a
		ld d, b
		ld e, c
		ld h, l
		ld d, d
		or d
		ld b, [hl]
		sub l
		cp $58
		ld h, c
		add sp, -93
		ret nc
		sub b
		adc l
		adc d
		and d
		ld d, c
		ld c, $F2
		ld d, l
		jr z, @ - 3
		jp hl
	
		jp c, $2617	; Possibly invalid
		ld [hl], h
		ld h, e
		ld b, h
	db $FD
		ld h, c
		sbc $3F
		dec e
		sbc a, h
		ld sp, $7EBD
	db $D3
		ld e, e
		ld d, d
		ld hl, sp+112
		ld a, a
		inc e
		sbc a, d
		ld e, [hl]
		sub l
		ret nc
		ld sp, hl
		dec d
		xor c
		ld c, $00
		ld l, c
		cp a
		ld c, h
		xor e
		rrca
		sbc a, a
		xor [hl]
		xor a
		ldh [c], a
		ld e, [hl]
		ld d, h
		sbc a, b
		ld d, e
		jr nz, @ + 100
		push de
		or d
		add sp, -127
	db $EB
		ccf
		cp $AA
		jr z, @ + 83
		rst $18
		rlca
		ld e, d
		add l
		ld e, h
		ld a, a
		inc de
		add $57
		and c
		adc $5F
		dec a
		dec sp
		ld h, [hl]
		and d
		ldi [hl], a
		ld l, h
		rst $08
		xor c
		dec c
		dec e
		add c
		ld b, b
		add b
		or h
		ld [hl], l
		ld a, [bc]
		daa
		and b
		rlca
		inc de
		add h
		inc sp
		push bc
		ld b, $E3
		sub $FB
		ld hl, sp+56
		ld [hl], l
		sbc a, b
		sub l
		ld a, [$A6D7]
		ldi [hl], a
		add $6B
	db $FC
		di
		ret nz
		inc hl
		ld d, c
		call c, $51E6	; Possibly invalid
		sbc a, d
		ld e, e
		inc bc
		sbc a, d
		and a
		ld b, h
		ldi [hl], a
		or $4B
		ret
	
		inc bc
		dec l
		rst $20
		ei
		ld a, d
		and [hl]
		or $4B
		sub h
		ld de, $2188
		ld l, d
		add e
		ld hl, $EEF2
		adc c
		sbc a, c
		add hl, de
		ld c, b
		dec de
		ld h, $55
		add b
	db $DD
		ld e, c
		dec h
		add c
		adc d
		xor e
		ld l, e
		and b
		add hl, de
		cp [hl]
		ld h, l
		ld b, l
		ld h, $60
		sbc a, e
		or [hl]
		add h
		ld b, d
		rst $00	; CharacterMovementTable
		call nz, $0201	; Possibly invalid
		inc l
		dec a
		cp e
		ld b, b
		ld a, [de]
		ld c, a
		inc sp
		or b
		add [hl]
		xor d
		ld c, d
		ld b, d
		rst $10	; wizardAbilities
		ldd [hl], a
		ret nc
		inc sp
		ld d, c
		rra
		ld a, e
		rra
		cpl
		ld a, e
		push af
		ld h, c
		add hl, sp
		sbc a, b
	db $FC
		sub h
		sbc a, d
		ld h, a
		dec [hl]
		ld b, $EC
		ld sp, $DE5B
		ld e, a
		sub b
		jp $E6B6	; Possibly invalid
	
		jp c, $5E55	; Possibly invalid
		xor b
		or e
		xor d
		set 4, l
		ld [$AC09], a
		dec h
		jr nz, @ + 38
		ld h, e
		dec bc
		reti
	
		ldh [$92], a
		cp e
		push hl
		ld [$5697], a
		ld h, c
		rst $38
		ld c, a
		ld a, [hl]
		rst $30
		ldh [c], a
		ld b, [hl]
		and c
		ld d, [hl]
		adc h
		ldd [hl], a
		ld [$369D], a
		cp l
		dec l
		adc b
	db $EB
		ld [de], a
		add [hl]
		jp nc, $533D	; Possibly invalid
		or a
		rrca
		ld h, [hl]
		ld d, e
	db $FC
		dec l
		or $69
		ldi [hl], a
		adc h
		ld e, e
		ld c, a
		ld c, c
		add h
		add hl, hl
		or [hl]
		ld [de], a
		ld hl, sp+20
		sbc a, b
		reti
	
		ld h, b
		ld d, d
		and h
		inc a
		rst $08
		ld [$5251], sp
		ld [bc], a
		and l
		sub d
		or [hl]
		sbc a, d
		dec bc
		cp $37
		cp e
		ld e, a
		inc [hl]
		ld l, e
		rrca
		ld c, d
		sub l
		pop hl
		ld [$F188], sp
		adc b
		ld b, e
		or d
		ld l, $0E
		rst $38
		rst $38
		stop
		dec b
		xor [hl]
		ld [hl], h
		ret z
		call nz, $7745	; Possibly invalid
		cp e
		ld e, a
		ldi [hl], a
		jp z, $79B8	; Possibly invalid
		ld a, [bc]
		sub d
		ld h, h
		ld e, $24
		ld b, b
	db $EB
		ldd a, [hl]
		inc a
		pop bc
		call nc, $7439	; Possibly invalid
		rst $18
	db $E3
		cp $5C
		ld de, $0B5B
		ld de, $837F
		halt
		ld d, l
		ld d, d
		or l
		ld l, [hl]
		ld e, d
		and b
		or $77
		rst $10	; wizardAbilities
		inc sp
		cpl
		adc e
		add l
		and e
		call z, $C482	; Possibly invalid
		ld hl, $021A
		ld c, $55
		dec hl
		ld b, $8B
		cp d
		ld l, $69
		ld e, a
		or $43
		cp b
		inc a
		sub [hl]
		sbc a, l
		sub b
		halt
		pop de
		xor h
	db $D3
		and c
		nop
		xor [hl]
		adc e
		ld [$0380], a
		ld bc, $F0A1
		ld e, h
		ld d, [hl]
		ld e, a
		xor b
		ld c, h
		add l
		xor l
		ld h, [hl]
		jr c, @ - 64
		stop
		push af
		ret nc
		sub b
		inc h
		sbc a, a
		ld sp, hl
		ld h, c
		ret c
		ld [hl], c
		rst $18
		xor d
		ld [bc], a
		ld b, [hl]
		ld d, b
		add $D3
		dec l
		add $DB
		add d
		ld c, $9C
		ldh a, [_PORT_78_]
		ld h, a
		ld d, a
		add l
		push de
		ld l, a
		sub a
		ld l, l
		reti
	
	db $F4
		inc b
		add sp, 81
		ld l, l
		cp a
		ld [hl], c
		ld a, a
		or l
		ld a, [de]
	db $F4
		ccf
		ld [hl], d
		ld d, d
		sbc a, e
		inc a
		ld c, [hl]
		push de
		ld c, e
		adc c
		ld c, l
	db $EB
		ret z
		add hl, hl
		jr c, @ + 53
		ld l, c
		ld [hl], h
		dec h
		ld l, [hl]
		jp $66F8	; Possibly invalid
	
		ld e, $66
		ret
	
		ld c, c
		or h
		cp l
		and e
		add [hl]
		ld b, c
		daa
		or e
		inc [hl]
		sbc a, a
		dec de
		sbc a, d
		jp nz, $BD20
		pop af
		ld hl, sp+-105
		or a
		ld l, d
		add h
		ld e, e
		inc [hl]
		push de
		xor b
		jr nc, @ + 119
		stop
		adc d
		pop de
		ld [hl], a
		dec e
		jp c, $2B8E	; Possibly invalid
		inc d
	db $DD
		ld b, h
		cp c
		ld [hl], l
		or b
		sbc a, [hl]
		xor l
		cp l
	db $EB
		ld h, b
		ld h, c
		inc e
		jr @ + 113
	
		ld h, h
		push bc
		ld hl, $D0A9
		ld d, $1B
		ld a, [de]
		cp $2A
	db $DB
		sub [hl]
		inc b
		pop hl
		dec l
		halt
		add h
		adc $5F
		jr c, @ - 36
		bit 2, b
		ld a, e
		jp nz, $E505	; Possibly invalid
		ld a, $A7
		sub l
		push hl
		sub e
	db $EB
		jr c, @ - 125
		sub $EE
		ld [hl], $AD
		ld e, [hl]
		ld d, l
		ccf
		and l
		cp l
		ld d, c
		ld c, e
		jr c, @ + 80
		ld h, l
		ld b, h
		ret nz
		ld c, d
		add hl, bc
		xor $A2
		ld d, [hl]
		ldd [hl], a
		ld [hl], d
		ldi [hl], a
		ld a, b
		ld hl, $F56E
		ld e, [hl]
		cp a
		dec c
	db $EB
		dec bc
	db $EC
		and h
		rst $28
		add d
		add h
	db $ED
		ld b, d
		push bc
		adc l
		ld a, c
		ld c, e
		ld d, c
		or d
		rst $20
		ld l, [hl]
		dec e
	db $F4
		adc c
		ret nc
	db $EB
		xor [hl]
		dec bc
	db $E3
		ld a, a
		ld h, b
		adc l
		sub [hl]
		call nc, $2A46	; Possibly invalid
		scf
		ld e, $48
		jp c, $6D0B	; Possibly invalid
		sbc a, h
		or e
		ld a, b
		ld l, l
		adc a
		rst $20
		ld bc, $057F
		ld l, b
		cp $FC
		ld hl, $298C
		daa
		jp nc, $1C20	; Possibly invalid
		ldi [hl], a
		inc sp
		ld h, h
		jp hl
	
		ld sp, $62BC
		adc c
		rst $20
		ldi [hl], a
		add d
		ld b, [hl]
		and c
		add a
		ld d, [hl]
		add d
		add hl, bc
		ccf
		add d
		rla
		ld h, b
		sub [hl]
		ldi a, [hl]
		sbc $7A
		push hl
		call nz, $2E44	; Possibly invalid
		ld d, h
		push hl
		inc a
		or b
		call nc, $258E	; Possibly invalid
		rst $30
		ret
	
		jr c, @ - 101
		dec a
		ld c, e
		and d
		ld e, d
		ld sp, $D532
		dec [hl]
		sbc a, h
		add hl, hl
		pop af
		jp nz, $298D	; Possibly invalid
		ld a, d
		ret
	
		add sp, 42
		cp h
		ldd [hl], a
		ld d, [hl]
		pop de
		push hl
		ld e, e
		inc h
		add a
		call nc, $1E97	; Possibly invalid
		ld e, d
		sbc a, c
		rst $38
		ld [de], a
		ld h, c
		ld d, d
		daa
		rst $18
		sub [hl]
		ld a, b
		sub $2E
		jp nz, $FD7D	; Possibly invalid
		sub [hl]
		ld l, a
	db $F4
		adc d
		dec [hl]
		add c
		ld h, l
		ld c, d
		adc a
		or d
		adc $4B
		ret z
		dec h
		inc hl
		reti
	
		ret
	
		inc sp
		rla
	db $FD
		ld l, $79
		ld a, d
		add hl, sp
		ld [$7A25], a
		ld b, $E6
		rst $10	; wizardAbilities
		jr z, @ + 66
		or e
		ld l, c
		xor c
		ld a, c
		xor b
		inc b
		ld c, $06
		cp c
		or l
		jr @ + 13
	
		ldh [_PORT_0E_], a
		pop hl
		or [hl]
		inc d
		pop bc
		rla
		ld e, c
		ld c, $CF
		ld a, [de]
		sbc a, a
		rla
		add hl, bc
		bit 4, e
		ld h, b
		xor d
		ld l, h
		ld [hl], $C6
		ld c, d
		ld a, d
		ld b, d
		rst $38
		ld a, l
		dec e
		ld a, l
		halt
		adc a
		nop
		dec hl
		ret c
		ld c, $32
		ld c, c
		ld l, c
		xor b
		ld a, c
		xor a
		ld e, a
		rrca
		sbc a, h
		sbc a, d
		ld h, c
		rst $00	; CharacterMovementTable
		ld l, h
		ld b, b
		srl l
		rra
	db $E4
		ld l, $50
		inc l
		ld [hl], e
		ld l, a
		ld h, b
		ld [de], a
		ldh [c], a
		ldh [c], a
		ldi a, [hl]
		ld h, e
		add e
		ld l, b
		xor [hl]
		and d
		ret nc
		ldh a, [c]
		adc l
		ldd a, [hl]
		rst $10	; wizardAbilities
		and d
		and b
		xor h
		and c
		call c, $E0BD	; Possibly invalid
		ld c, $45
		ld b, a
		ld b, $CA
	db $ED
		rra
		cp c
		ld c, c
		inc bc
		dec d
		ld e, h
		xor h
		cp [hl]
		dec b
	db $EC
		pop hl
		ld b, a
		ld [hl], e
		cp d
		or e
		sub a
		and c
		adc a
		ret nz
		ld l, c
		add l
		dec e
		inc a
		ld d, b
	db $FD
		ldd a, [hl]
		sbc $F6
		ld e, b
		adc e
		ld l, h
		sbc a, [hl]
		ld a, [de]
		ld d, l
		ld b, a
		jp c, $6B08	; Possibly invalid
		call nz, $2995	; Possibly invalid
		rra
		rrca
		call nc, $FC83	; Possibly invalid
		ld a, $06
		ld h, c
		ld a, [$BC5D]
		ccf
		ld d, c
		ld l, $F9
		inc b
		ld b, h
		sub l
		ld l, [hl]
		xor d
		inc hl
		ldh [c], a
		cp l
		ld sp, $12AE
		pop de
		add hl, bc
		adc a
		ld c, l
		ld b, d
		ld b, l
		cp c
		jp $4246	; Possibly invalid
	
		rst $08
		sub [hl]
		ld e, b
		dec de
		jp nc, $1612	; Possibly invalid
		ld c, l
		or d
		ld a, b
		ld [bc], a
	db $D3
		ld a, $37
		call nz, $D520	; Possibly invalid
		call $B5B9
		add sp, 13
	db $FC
		ld a, c
		add hl, hl
		add l
		ld a, d
		ld e, l
		pop af
		or $D9
		ld d, d
		add $5E
		ret nz
		xor h
		ret nc
		ldi [hl], a
		adc [hl]
		xor c
		xor l
		or e
		jr nc, @ - 32
		or l
	db $E4
		or $EF
		ld l, a
		ld c, [hl]
		ld h, l
		and l
		bit 0, c
		sub c
		call nz, $3092	; Possibly invalid
		or e
		sbc a, h
		inc bc
		inc e
		add e
		adc b
		pop hl
		sub e
		call z, $06FF	; Possibly invalid
		xor h
		sbc a, c
	db $DB
		cp e
		dec sp
		ld [hl], $5A
		ldh a, [c]
		di
		add hl, bc
		ld [hl], a
		rst $20
		ld h, a
		dec l
		ld hl, sp+-80
		dec b
		xor e
		xor e
		ld h, d
		daa
		rrca
		push bc
		and a
		jp nz, $46A0	; Possibly invalid
		jr z, @ + 26
		or l
		cp a
		jp c, $EDA0	; Possibly invalid
		inc d
	db $EC
		or c
		ld b, e
		ld l, h
		add a
		or b
		ld l, d
		ret z
		ld e, c
		ld d, a
		and c
		ld h, l
		and l
	db $EC
		ld l, [hl]
	db $D3
		ld l, d
		ld l, a
		xor b
		cp b
		pop de
		ld d, $26
		jp z, $8138
		ld c, b
		call nc, $467A	; Possibly invalid
		ld c, $DD
		adc b
		ld d, b
		ld a, $B2
		ld [hl], e
		ld b, a
		dec d
		ld d, d
		ccf
		ld l, d
		jp nc, $4E27	; Possibly invalid
		ld a, c
		ld [de], a
		ldi a, [hl]
		ld a, [bc]
		ld l, e
		reti
	
		sbc a, [hl]
		ld d, e
		ret
	
		reti
	
		push hl
		ldd a, [hl]
		adc l
	db $D3
		ld [de], a
		ld a, $C0
		xor $CB
		daa
		sbc a, h
		ld sp, $57A8
		ld c, e
		ldh a, [c]
		ld b, [hl]
		ld b, d
		ret nz
		cp $3D
		ldh a, [c]
		rla
		ld b, [hl]
		sub h
		ld b, b
		and l
		pop af
		dec l
		push de
	db $E3
		nop
		and b
		or a
		rst $08
		or c
		xor e
		sub d
		add hl, de
		dec sp
		call nz, $E0E3	; Possibly invalid
		ld h, a
		ld l, c
		ld d, e
		ld l, b
		rst $38
		rra
		ccf
		add l
		ld c, $AB
		ld d, e
		rst $10	; wizardAbilities
		ld a, l
		ld h, l
		inc c
		and l
		reti
	
		add [hl]
		xor b
		ldh a, [rAUD2ENV]
		ld c, a
		rst $20
		inc e
		call c, $CED9	; Possibly invalid
		ld c, a
		push bc
		ld d, e
		dec bc
		inc bc
		cp d
		ld d, l
		ldh a, [$BA]
		or h
		sbc $F0
		dec e
		ld h, [hl]
		inc sp
		or d
		ld [hl], e
		sub a
		add hl, hl
		sub [hl]
		ld h, e
		dec hl
		ldd a, [hl]
	db $EB
		rra
		ld [$D98E], sp
		ld a, [de]
		ld d, $4B
		adc c
		rst $28
		adc d
		add d
	db $DB
		dec [hl]
		sub l
		ld a, [bc]
		and [hl]
		ld b, l
		jr z, @ + 113
		cp l
		rst $08
		add e
		ld de, $1591
		ld l, c
		dec a
		and b
		call z, $E13C	; Possibly invalid
		sub l
		or [hl]
		ld h, b
		or d
		dec c
		sbc a, b
		inc hl
		set 5, l
		xor b
		ldh [c], a
		jp z, $EEC6	; Possibly invalid
		ld hl, $7D3C
		inc de
		ld a, e
		cp c
		inc a
		ld d, l
	db $ED
		dec hl
		xor l
		ld h, d
		xor l
		xor c
		ret nz
		call c, $D290	; Possibly invalid
		call $0B7C	; Possibly invalid
		ld e, $F4
		dec bc
		adc l
		sbc a, a
		ld [hl], l
		ld [hl], c
		ld c, d
		adc d
		add $C1
		add hl, hl
		di
		ld c, c
		ld a, e
		cp $E2
		jp nc, $F8F3	; Possibly invalid
		ld c, b
		or d
		ld c, [hl]
		call $E4D8	; Possibly invalid
		rst $08
		ld c, h
		ld a, l
		inc hl
		ld a, c
		ld [$D909], sp
		ret z
		add h
		ld sp, $A6B4
		ld d, d
		adc e
		dec l
		add [hl]
		ld l, $99
	db $F4
		dec bc
		sbc a, [hl]
		jr c, @ + 6
		ld [hl], e
		ret c
		cp [hl]
		inc hl
		ldd [hl], a
		ld de, $9E8E
		ldh [_PORT_0A_], a
		jp c, $A71A
		and a
		dec [hl]
		or [hl]
		ld [hl], d
		ld b, a
		ld h, l
		adc d
		cp b
		dec l
		dec d
		adc [hl]
		ld e, e
		ld h, $6F
		ld [hl], e
		sub c
		dec bc
		ld c, [hl]
	db $ED
		sbc a, [hl]
		add e
		ld e, $07
		and e
		xor a
		or e
		or a
		add hl, hl
		and a
		ld a, e
		sub c
		rst $38
		call nz, $6D0D	; Possibly invalid
		inc e
		and b
		scf
		ld d, [hl]
	db $D3
		ld e, h
		inc c
		ld hl, $73F5
		rst $10	; wizardAbilities
		ret nz
		push de
		daa
		ret nz
		ld e, e
		xor h
		add sp, 94
		cp a
		sbc a, e
		add hl, sp
		ld l, d
		sub c
		ld a, [bc]
		add h
		or [hl]
		add a
		ld [hl], c
		add b
		or d
	db $EB
		and b
		pop af
		ld d, $A1
		ld a, [de]
		inc b
		sbc a, a
		add hl, sp
		ret
	
		adc d
		inc b
		add b
		ld l, e
		inc sp
		add hl, hl
		ld e, $24
		di
	db $FD
		and d
		ld d, a
		ldh a, [$F2]
		call $ADB3
		ld [hl], d
		xor a
		dec a
		ld [bc], a
		ld [hl], a
		cp e
		xor h
		ld d, h
		ld [hl], l
		jp nz, $5DD6	; Possibly invalid
		nop
		ld a, $8A
		ret z
		add b
		or b
		dec [hl]
		jr c, @ - 60
		rst $30
		or b
		push hl
		xor h
		call $7385	; Possibly invalid
		rst $10	; wizardAbilities
		cp b
		scf
		ld a, a
		add hl, bc
		ld h, l
		inc sp
		or h
		ld b, l
		ld a, b
		inc bc
		ld c, c
		inc e
		ld sp, hl
		dec sp
		jp nz, $B0AC
		ld a, [hl]
		ld a, [$FC0F]
		ld [bc], a
		inc a
		ld sp, $70AF
		ld a, h
		rst $20
		xor b
		ld sp, $F157
		ld a, [bc]
		cp d
		inc sp
		jp nc, $5A7A	; Possibly invalid
		add b
		ld [hl], e
		xor h
		ld [hl], h
		ld [hl], a
		cp e
		adc c
		inc hl
		ld [$BABB], a
		rra
		dec d
		halt
		jr nz, @ - 38
		xor a
		inc b
	db $E3
		inc sp
		ld l, c
		ld a, [de]
		xor [hl]
		rst $38
		dec d
		xor c
		ld h, e
		dec [hl]
	db $E3
		cp h
		ld d, [hl]
		ld a, b
		sub h
		add [hl]
		sbc a, e
		inc bc
	db $FD
		dec [hl]
		ld b, c
		ld e, e
		or l
		add $C6
		sbc a, a
		and b
		sub l
		ldh a, [_PORT_5F_]
		sbc a, c
		ld d, a
		ld [$9F31], a
		or [hl]
		push hl
		inc e
	db $E3
		rla
		ld a, [de]
		ld c, l
		ld [hl], a
		adc [hl]
		ld a, [$2000]
		ld e, l
		ld [hl], a
		call $25D3	; Possibly invalid
		dec b
	db $EB
		ldi a, [hl]
		ret nc
		sbc a, c
		or [hl]
		ld c, a
		ld h, a
		ld l, d
		rst $28
		ld de, $702C
		or l
		jp hl
	
		ret
	
		adc a
		add e
		ld [$CF5E], a
		cp h
		rrca
		ld b, e
		ld d, b
		push hl
		sbc a, c
		ld d, c
		ld [hl], c
		ld a, [de]
		cp a
		jr z, @ - 42
		add sp, 7
		pop bc
		add e
		ld c, b
		ld c, h
		ld e, c
		ld [hl], b
		call z, $E86A	; Possibly invalid
		ldd [hl], a
		ld a, $57
		sub l
		sbc a, a
		ld bc, $E559
		ld c, b
		push de
		ld d, b
		rst $38
		ld e, a
		rst $10	; wizardAbilities
		cp $B8
		ld c, c
		ldi a, [hl]
		ld e, h
		ld h, b
		cp b
		ld c, d
		ld a, d
		ldh a, [c]
		ld a, [bc]
		ld h, e
		cp d
		add c
		adc [hl]
	db $FD
		xor l
		add [hl]
		ld h, [hl]
		sub d
	db $FD
		and c
		ld d, a
		ld [hl], a
	db $E3
		rst $08
		dec de
		sbc a, d
		cpl
		inc h
		jp nc, $9B5C
		ld e, [hl]
		or b
		ldd [hl], a
		xor b
		or c
		ld b, e
		ld c, b
		ld a, h
		inc a
		xor d
		ld c, $D9
		ldd [hl], a
		ld h, e
		ld d, b
		rst $00	; CharacterMovementTable
		di
		ld c, l
		ld c, c
		ld a, a
		call nz, $EEAD	; Possibly invalid
		ld de, $9849
		and $A3
		rlca
		ld e, c
		ld d, [hl]
		bit 4, a
		inc h
		ld de, $3EB0
		di
		or a
		ld b, [hl]
		ld a, [de]
		ld d, $6C
		ld l, a
		ld l, d
		ld e, $FA
		dec b
		inc de
		ld l, [hl]
		ld c, e
		ldh a, [$B4]
		ldh [$E6], a
		ld [bc], a
		inc hl
		add l
		ld l, $CC
		cp c
		ld h, l
		ld l, b
		ld b, l
		dec e
		xor d
		dec a
		ret z
		xor c
		ld a, [de]
		xor $6F
		ld e, [hl]
		add h
		cp a
		adc $A1
		sub h
		ld h, [hl]
		ld b, h
		ld sp, hl
		ld hl, sp+-59
		add d
		adc l
		jp z, $0270	; Possibly invalid
		jr nc, @ + 32
		ld d, h
		stop
		ld a, c
		cp c
		add $5D
		ldi a, [hl]
		ei
		ld e, d
		rst $08
		add b
		cp d
		or e
		jr z, @ - 27
		add [hl]
		xor l
		inc e
		ld [hl], e
		ld [hl], b
		and c
		ld l, a
		set 1, h
		ld de, $D785
		ld l, d
		add [hl]
		adc d
		cp $DE
		inc d
		sbc a, a
		jr c, @ + 91
	db $E3
		ret nc
		ret z
		adc [hl]
		inc d
		ld a, [bc]
		ld a, d
		rst $18
		and [hl]
		inc d
	db $DD
		push hl
		ld l, e
		ccf
		and l
	db $FC
		ldh a, [c]
		or l
		rst $08
		or l
		dec d
		ld a, $88
		add hl, hl
		ldd [hl], a
		rla
		ld d, d
		sub l
		add e
	db $ED
		cp a
		ld c, e
		adc d
		adc d
		ld d, d
		rla
		and l
		ld de, $E9E2
		cp c
		ld c, c
		inc l
		inc c
		jr c, @ + 7
		dec c
		inc b
		dec c
		ld [bc], a
		inc l
		ld b, [hl]
		sub d
		inc b
		add e
		ld d, c
		ldh a, [_PORT_6E_]
		push af
		ld b, e
		rra
		and d
		push af
		cp e
		jp c, $C7F3	; Possibly invalid
		push hl
		sub d
		ld b, a
		ret
	
		ld e, e
		inc h
		rst $28
		ld a, $76
		and l
		ldh a, [c]
		ret nc
		ld c, [hl]
		ld a, b
		dec sp
		call $F2DE	; Possibly invalid
		scf
		ld d, $48
		rst $18
		or [hl]
		ld c, e
		inc a
	db $FD
		ld l, a
		cp h
		ldh a, [$A5]
		ldd a, [hl]
		cp l
		or h
		inc e
		ld h, a
		ld l, h
		sub a
		ld l, e
		cp $FD
		xor e
		ccf
		ld c, c
		add b
		ld sp, $B78B
		rst $38
		ld e, h
		ld bc, $EF83
	db $FC
		jr z, @ - 1
		inc a
		rla
		add [hl]
		ld h, e
		xor $9A
		cp b
		rra
		ld a, $58
		ld [$63A4], a
		inc e
		sub $9C
		ld d, c
		ld a, $04
		cp [hl]
		sbc a, h
		jp nz, $8297
		ld sp, $1FF3
		ld hl, sp+27
		ld [$9340], sp
		and $E8
		ld b, a
		inc hl
		push af
		nop
		add e
		jp $E311	; Possibly invalid
	
		ld h, [hl]
		jp nc, $BAFD
		inc b
		and h
		and h
		ld e, [hl]
		ld sp, $E062
		rla
		or a
		jp nc, $B266
		ld h, [hl]
		ld [hl], b
		ld l, a
		jr @ + 88
	
		jp nc, $3A9C	; Possibly invalid
		ld e, h
		sbc a, c
		add [hl]
		ld a, l
		xor l
		ldh a, [c]
		pop af
		xor b
		ld c, d
		dec hl
		ld l, d
		dec sp
		rst $28
		call nz, $67FB	; Possibly invalid
		add sp, 51
		ld [bc], a
		ld h, $BD
		ld c, [hl]
		ret nc
		add hl, hl
		ld c, d
		add $01
		cp $9B
		cp h
		or e
		ld h, b
		xor $9B
		ldh a, [c]
		pop hl
		ld bc, $3178
		xor e
	db $EB
		dec de
		ld d, $0D
		dec b
		jp nz, $0318	; Possibly invalid
		ld hl, $40E9
		jp nz, $87CF
		jr nz, @ - 59
		inc h
		ld e, [hl]
		ld de, $C407
		ld bc, $819E
		ld b, d
		ldh a, [c]
		sub l
		ld hl, $EC52
		ld d, d
		ld hl, sp+-80
		and l
		add $5E
		cp e
		ld h, c
		ld l, $4B
		ld a, l
		ld [hl], e
		ld c, a
		dec h
		ld e, $3D
		ld a, [$3E3F]
		add d
		ldh a, [c]
		rlca
		ld d, e
		and $D3
		rst $30
		pop hl
		ld h, h
		rst $20
		and $B2
		add [hl]
		ei
		ld h, a
		ld c, b
		jp nc, $34EE	; Possibly invalid
		jr z, @ + 103
		sbc a, e
		add b
		ld h, [hl]
		sbc a, b
		add hl, hl
		sbc a, [hl]
		ld c, h
		ldh [rAUD2LOW], a
		call nc, $0BC8	; Possibly invalid
		ld a, b
		sbc a, c
		inc h
		add a
		nop
		ld l, a
		ld d, a
		dec h
		and l
		ld [hl], l
		sub [hl]
		ld l, e
		and $44
		add hl, bc
		or [hl]
		call z, $2AFD	; Possibly invalid
		dec sp
		inc sp
		cp c
		ld [bc], a
		ld e, h
		scf
		push de
		xor $D1
		and d
		add a
		ld c, h
	db $DB
		ld d, l
		rra
		push bc
		ld bc, $5E0E
		rst $38
		add hl, sp
		sbc a, c
		ld l, d
		ld h, l
		ld b, $3B
		ld h, [hl]
		rrca
		add l
		or a
		dec e
		adc c
		cp [hl]
		sbc a, d
		ld l, $82
		adc c
		ld d, d
		ldi [hl], a
		cp d
		and $28
		ld e, $12
		xor [hl]
		rst $38
		ld sp, hl
		ld a, [bc]
		rst $30
		ld l, c
		dec l
		ld [hl], b
		ld c, d
		ld a, h
		sub $DE
		jp c, $29D4	; Possibly invalid
		adc c
		ld [hl], $30
		jp hl
	
		and e
		and e
		dec h
		ld a, h
		ld b, e
		ld [$852C], a
		push de
		or c
		call $F940	; Possibly invalid
		or d
		adc e
		ld [hl], e
		ld l, h
		rst $38
		ld hl, $EFC3
		ld [hl], b
		ld a, a
		dec l
		ldh a, [c]
		ld d, l
	db $ED
		pop de
		cp a
		dec sp
		ld sp, $1BA8
		ld bc, $7FCE
		ld b, e
		cp l
		adc a
		or a
		call z, $2604	; Possibly invalid
		ld b, e
		ld b, h
		ld a, [hl]
		rrca
	db $EB
		xor l
		ld l, b
		ld d, d
		jp nz, $6689	; Possibly invalid
		rst $18
		adc a
		ld [hl], e
		inc l
		push bc
		sbc $4A
		ret
	
		ldd [hl], a
		add hl, bc
		stop
		ld a, b
		or h
		add hl, hl
		ld l, b
	db $D3
		push af
		ret
	
		xor c
		dec [hl]
		scf
		dec e
	db $E3
		ret
	
		ldh a, [$B5]
		dec sp
		rst $20
		ld d, e
		inc h
		jr nc, @ - 76
		inc l
		rst $28
		ldd a, [hl]
		xor e
		xor h
		pop bc
		ld [bc], a
		ld l, $76
		adc h
		ld d, l
		add e
		and b
		jp hl
	
		dec h
	db $DD
		ld a, [bc]
	db $EB
		or a
		xor h
		ld l, $FE
		xor b
		add b
		pop bc
		ld [hl], $E4
		and e
		ld b, b
		adc h
		ld a, c
		ld b, b
		sbc a, b
		adc [hl]
		inc h
		sub d
		ld a, [$247B]
		cp [hl]
		add hl, bc
		ld l, c
		jr nc, @ + 97
		ld h, $1F
	db $ED
		ld [hl], b
		ld a, [hl]
		pop bc
		ld h, h
		jr z, @ + 62
		add hl, de
	db $F4
		xor b
		ld [de], a
		or h
		ccf
		ld hl, $ED42
		ld l, e
		ld [$50F4], a
		halt
		xor $75
		xor c
		ld h, $C7
		ld b, $75
		rra
		ld a, [de]
		push bc
		inc c
		ld a, [$BB39]
		ret c
		ret
	
		ld b, l
		jr z, @ + 18
		ld e, l
		adc [hl]
		cp h
		ld h, d
		ld l, c
		sub h
		jr nc, @ - 8
		ldh [c], a
		ld [hl], h
		cp h
		ld l, b
		jr nc, @ + 114
		and [hl]
		halt
		jp z, $9125
		ld [hl], h
		ldi [hl], a
		ld b, e
		sbc a, h
		ret c
		xor $DC
	db $F4
		xor [hl]
		ld e, d
		rst $08
		inc b
		adc c
		add $CD
		inc [hl]
		ldi a, [hl]
		ld a, l
		rlca
		or $C8
		ld a, [bc]
		ld a, c
		call $B7E5
		res 3, c
		di
	db $DB
		sub $15
		ld [hl], b
		rlca
		cp b
		ld h, $1A
		rst $00	; CharacterMovementTable
		dec c
		ld d, $D6
		dec sp
		ld b, a
		sub l
		ld [hl], e
		ld h, a
		and d
		ld c, [hl]
		and l
		ld d, l
	db $F4
		ld c, e
		ld [hl], h
		ld l, e
		call nz, $8E2D
		ld l, a
		sub c
		adc c
		ld h, c
		ld h, $2D
		add hl, sp
		ld a, a
		inc a
		dec d
		adc h
		ld l, e
		and l
		ld d, l
		inc de
		or [hl]
		or h
		inc sp
		ld [$546A], a
		ld [de], a
		add hl, bc
		sub $13
		xor a
		inc sp
		cp a
		dec bc
		and l
		ld a, c
		sbc a, l
		or d
		dec c
		ld a, [$2ADB]
		dec c
		jr @ - 116
	
		xor d
		ld c, d
		ei
		add c
	db $EC
		ld b, $08
		ld e, a
		ld d, b
		xor c
		sub [hl]
		call z, $62F1	; Possibly invalid
		call z, $E419	; Possibly invalid
		dec sp
	db $D3
		cp b
		inc l
		xor c
		ld h, [hl]
		rst $08
		or h
		and h
		push bc
		rst $28
		ldh a, [c]
		cp d
		jr nc, @ - 116
		ld de, $8AC8
		ld d, l
		ld sp, $C2E3
		rst $30
		ldi [hl], a
		and c
		dec h
		pop af
		pop hl
		ld e, e
		xor a
		call z, $FD96	; Possibly invalid
		ld a, [bc]
		adc e
		stop
		ld c, a
		jp hl
	
		ld d, [hl]
		call nz, $8431
		sbc a, c
		or e
		cp d
		sub e
		cp b
		ld l, b
		jp c, $D12F	; Possibly invalid
		add l
	db $FD
		dec h
		ld b, h
		and a
		add d
		inc sp
		dec d
	db $E3
		rst $20
		cpl
		inc sp
		ld l, e
		call $2B5B	; Possibly invalid
		ld h, l
		jr z, @ + 121
		inc de
		ld a, b
		jp hl
	
	db $FC
		ld sp, $4494
		jp nc, $C744	; Possibly invalid
		sub d
		ld b, d
		add l
		sub h
		dec [hl]
		push hl
		call $76D7	; Possibly invalid
		or l
		ld e, l
		jr z, @ + 125
		pop af
		ld c, $B2
		rst $28
		xor b
		inc [hl]
		or h
		and $E2
		cp l
		inc a
		dec sp
	db $E4
		cp c
		dec hl
		jp $F626	; Possibly invalid
	
		ld d, c
		add sp, 4
		add sp, 15
		rst $38
		dec h
		inc de
	db $D3
		or $EB
		sub h
		and e
		call z, $74F1	; Possibly invalid
		and e
		ld h, [hl]
		ldd [hl], a
		xor b
		ld [hl], d
	db $E3
		ld d, h
		ld d, e
		jp $A630
	
		jr @ + 59
	
	db $EC
		ld d, l
		ld d, d
		and h
		ld h, a
		cp a
		and c
	db $FC
		rst $00	; CharacterMovementTable
		ld [hl], b
		ld h, h
		cp [hl]
		ldi [hl], a
		add [hl]
		ld b, $C2
		ld h, e
		cp a
		ld e, d
		ld [$6C2C], sp
	db $E4
		rra
		sub e
	db $E4
		ld l, e
		ldh [c], a
		jp nc, $BF83
		ld de, $D9DE
		or b
		ld d, d
		dec bc
	db $ED
		ld d, [hl]
		ld c, c
		sub b
		sub c
		rst $00	; CharacterMovementTable
		dec [hl]
		ld d, d
		ld [hl], l
		ld [$7428], sp
		ldi a, [hl]
		ld e, a
		rra
		rr b
		ld l, a
	db $FC
		ld l, e
		ld d, c
		call c, $0B4D	; Possibly invalid
		xor h
		inc [hl]
		inc [hl]
		jp c, $D1B8	; Possibly invalid
	db $DB
		cp b
	db $EB
		adc l
		ld b, h
		ld b, d
		jp nz, $F181	; Possibly invalid
		ld l, [hl]
		ldh [$AD], a
		push de
		adc h
		ldh a, [c]
		ld b, l
		ld c, [hl]
		call nc, $0133	; Possibly invalid
		ret c
		or e
		ld c, l
		ld a, $BB
		sub b
		pop bc
		ld [$0BAD], sp
		xor d
		ld h, a
		xor e
		pop de
		cp c
		ld [$2759], sp
		cp a
		or d
		rrca
		ld a, l
		ret nc
		add hl, de
		ld b, d
		sub h
		rst $28
		xor l
		rrca
		cp c
		dec l
		ld h, c
		ld l, l
		jp nc, $C6EF	; Possibly invalid
	db $EC
		ld b, e
		ld b, d
		or h
		sub e
		ret c
	db $ED
		inc e
		and b
		ld [hl], h
		ld c, h
		jr c, @ - 73
		ld e, $35
		adc l
		ld [hl], e
		dec b
		ld a, [bc]
		inc c
	db $FC
		sbc a, l
		ld b, b
		adc b
		xor [hl]
		adc e
	db $ED
		add l
		reti
	
		add e
		cp a
		rst $30
		ld d, $9D
		ld l, d
		and $4C
		ld d, d
		ld e, h
		adc a
		sub [hl]
		ret c
		ld [$2E2F], a
		rst $30
		dec b
		xor c
		sbc $98
		adc d
		add hl, bc
		inc h
		ld bc, $C1EB
		ld b, b
		stop
		inc h
		ld a, d
		and h
		ld a, [hl]
	db $DD
		or d
		scf
		sub d
		ei
		xor b
		cp $29
		ld c, b
		call z, $4473	; Possibly invalid
		inc c
		and b
		inc c
		adc b
		push af
		and $21
		scf
		jr c, @ - 84
		halt
		ld e, c
		add d
		sbc a, l
		ld h, a
		ret z
		ld l, h
		sbc a, c
	db $E3
		ld d, $C7
		rla
		call z, $7280	; Possibly invalid
		dec b
		cp c
		cp b
		add e
		cp d
		dec a
		ld sp, $685D
		inc h
	db $ED
		dec l
		ld [hl], e
		ldh a, [c]
		push hl
		ld b, [hl]
		and h
		inc sp
		cp c
		ld b, d
		ld e, h
		ld e, c
		ld b, h
		or e
		add e
		rst $20
		dec a
		dec a
		rst $00	; CharacterMovementTable
		ld l, [hl]
		sub l
		dec hl
		add c
	db $D3
		and e
		cpl
		inc bc
		or d
		ld [$1D35], sp
		cp a
		ld a, a
		jr @ + 105
	
		pop af
		ld [bc], a
		or e
		and $8F
		ret
	
		ld l, $8A
		xor c
		ld h, a
		halt
		ld l, b
		ld c, $86
		cp a
		ld sp, hl
		rst $08
		inc a
		rst $28
		ld a, [bc]
		ld a, [$CE7E]
		ld hl, sp+-25
		cp $2C
		daa
		rst $20
	db $F4
		add hl, hl
		ld [hl], e
		ld b, e
	db $ED
		adc d
		ld [hl], b
		inc c
		add hl, hl
		xor c
		sub c
		ld e, e
		ld [$1146], sp
		add hl, de
		sub b
		dec hl
	db $ED
		and e
		rlca
		ld [hl], a
		call $0F7D	; Possibly invalid
		ld [bc], a
	db $EB
		ld h, a
		sbc a, b
		inc [hl]
		push hl
		ld a, d
		add hl, sp
		xor $34
		ld h, e
		ld e, b
		ld b, b
		ld c, c
		ld c, e
		and [hl]
		stop
	db $FD
		or [hl]
		ld [hl], d
		jr @ + 61
	
		and d
		ld h, [hl]
		rst $30
		ldd [hl], a
		ld [$50A0], a
		ld [hl], c
		ld c, c
		sbc a, b
		sbc a, d
		ld a, a
		ld h, e
		ld c, e
		ret z
		ld e, d
		sbc a, b
		ld [hl], a
		ld c, $94
		adc c
		ld [$20C7], a
		push de
		cp a
		ret z
	db $FC
		ld h, d
		ld b, d
	db $EC
		or [hl]
		daa
		ld c, c
		add h
		ld c, e
		rra
		inc sp
		or [hl]
		ld a, $16
		cp e
		ld c, h
		ld a, d
		ld d, a
		ret nz
		sbc a, e
	db $DB
		rst $20
		ret z
		sbc a, d
		call z, $A03E
		call z, $5419	; Possibly invalid
		nop
		ld d, b
		sbc a, d
		ld b, e
		ld sp, $D034
		inc h
		ld [hl], l
		rla
		ldi a, [hl]
		adc $E0
		rst $10	; wizardAbilities
		xor a
		ld d, d
		ld l, b
		cp h
		adc c
		cp a
		dec [hl]
		ld h, e
		ld d, [hl]
		inc l
		inc hl
		ld b, h
		ld [hl], a
		sub h
		ld l, c
		and b
		ld b, b
		push bc
		xor h
		pop de
		ld sp, $33A3
		adc a
		add e
		call nz, $E552	; Possibly invalid
		ld bc, $AC0C
		inc b
		rst $20
		dec sp
		ld e, l
		cpl
		ld a, h
		ld d, c
		add d
		ldi [hl], a
		sub d
		or e
		push af
		rst $20
		ld c, h
		add c
		add [hl]
		ld d, e
		dec h
		jr nz, @ + 49
		and a
		sub l
		dec d
		ld a, h
		ld d, h
	db $F4
		xor l
		sub c
		add $F7
		ld d, [hl]
		ld l, l
		ld d, e
		sub e
		xor [hl]
		cp c
		adc l
		add b
		inc sp
		ccf
		adc d
		rst $38
		dec d
		ld [$DEFC], a
		pop hl
		jr nc, @ + 120
		ld h, $EF
	db $F4
		ld h, [hl]
		halt
		xor c
		jp hl
	
		ld h, b
		or a
		ld d, l
		push bc
		ld hl, sp+37
		ld d, a
		ld b, h
		ldi [hl], a
		cp c
		inc l
		inc h
		ld de, $C0D0
		adc l
		push hl
		sub l
		bit 5, d
		ld e, h
		dec b
		sbc a, [hl]
		ld hl, sp+13
		ret c
		ld h, c
		rst $30
		pop hl
		add b
		sbc $43
		cp e
		ld e, c
		ld a, h
		push hl
		adc a
		ld a, [hl]
		rrca
		ld [$E618], sp
		sbc a, c
		ld a, [$5C3C]
		ld c, l
		ld hl, sp+12
		dec l
		ld e, $44
		add sp, 88
		ld [hl], a
		ld l, c
		cpl
		dec h
		ld c, [hl]
		cp b
		xor l
		or d
		ret c
	db $EB
		adc b
		cp d
		jr z, @ + 65
		di
		ld bc, $42DF
		rlca
		ld c, e
		ld h, $1A
		adc d
		pop af
		ld [hl], l
		inc b
	db $EC
		di
	db $E4
		ld c, $90
		ld b, c
		di
		ld [hl], c
		jp nc, $B089
	db $F4
		sbc a, d
		ld h, a
		ld h, d
		ld h, c
		cp c
		xor l
		jp z, $0661	; Possibly invalid
		call $1A00	; Possibly invalid
		inc a
		ld b, a
		rst $30
		or [hl]
		ld d, [hl]
		ld c, h
		ld l, b
		call nc, $5617	; Possibly invalid
		sub a
		or d
		ld l, $2D
		push af
		inc bc
		ld b, d
	db $FD
		ld [de], a
		cp e
		or e
		and l
		inc l
		dec hl
		dec e
		ld e, e
		and $6E
		ld h, b
		adc h
		sub $D5
		pop bc
		jp nc, $BCFE
		sub b
		cp c
		cp [hl]
		ld [hl], l
		push hl
		ld b, $3E
		xor h
		push bc
		ld d, d
		ld a, d
		ld a, a
		ret z
		ld a, [bc]
		ld [hl], h
		ld b, a
		scf
		inc e
	db $D3
		and a
		dec [hl]
		ld hl, sp+-35
		ld l, b
		inc l
		or l
		or b
		ld c, c
		add hl, bc
		ld d, h
		add [hl]
		ld c, a
		sub [hl]
		sub a
		ld d, h
		ld c, h
		sbc a, h
		ld a, b
		or b
		add b
		sbc a, h
		adc [hl]
		di
		ld e, e
	db $FD
		add [hl]
		daa
		inc sp
		ld a, [bc]
		ld e, l
		inc sp
		cpl
		ld d, c
		ld a, $45
		add sp, 34
		add hl, hl
		ld l, b
		pop de
		adc c
		ld h, a
		ei
		pop de
		and $65
		xor h
		dec e
		dec hl
		ld a, b
		and l
		call nc, $E0B5	; Possibly invalid
		res 1, c
		ld c, c
		ld a, c
		inc de
		ld a, h
		ldi a, [hl]
		pop de
		ld [hl], b
		dec l
		add [hl]
		ld l, $5A
		add $19
		xor c
		ld l, l
		ld c, a
		cp [hl]
		ld bc, $FA5E
		ldh a, [c]
		cp a
		ld c, e
		ld a, $EF
		ld a, $22
		ret z
		jr nz, @ - 3
		sub d
		inc hl
		stop
		xor c
		inc b
		ret nc
		sbc a, a
		push hl
		ld d, e
		add h
	db $E3
		sbc a, l
		nop
		add hl, sp
		cp h
		and e
		xor d
		sbc a, a
		rra
		add h
		push af
		add a
		ret z
		ret c
		xor d
		ld h, c
		inc b
		sub b
		or [hl]
		ld sp, hl
		xor [hl]
		ld [hl], c
		ld c, c
	db $D3
		dec c
		ld d, d
		ld e, c
		or a
		ld l, c
	db $EB
		ld h, e
		ldh [$81], a
		ld a, [bc]
		call c, $DADE	; Possibly invalid
	db $DB
		ret c
		inc de
		add d
		dec a
		xor h
		push af
		add sp, -21
		inc e
		adc b
		xor b
		ld l, d
		rrca
		or e
		ld a, l
		push af
		ld d, [hl]
		add h
		ld d, a
		add a
		or [hl]
		inc b
		ldh [c], a
		ld a, $46
		ld l, c
		jp nc, $033B	; Possibly invalid
		jr c, @ - 44
		ld l, b
		or [hl]
		ld [hl], h
		ld h, e
		add $AC
		rst $08
		jp c, $4724	; Possibly invalid
		sub b
		inc hl
		or [hl]
		ld h, d
		jp c, $39E5	; Possibly invalid
		sbc a, [hl]
		rst $00	; CharacterMovementTable
		sub l
		cp d
		inc h
		ld e, $2F
		inc d
		push hl
		ld c, [hl]
		jp z, $C027	; Possibly invalid
		ld e, $9C
		sub e
		and e
		ld a, [$D4A3]
		xor e
		add hl, bc
		add hl, bc
		add [hl]
		sbc a, d
		jp hl
	
		call nz, $277F	; Possibly invalid
	db $FD
		ld a, $E6
		ccf
		adc c
		ldh [c], a
		rst $28
		add hl, hl
		sub d
		ld a, [de]
		sub d
		ret c
		cp [hl]
		ld c, e
		and c
		and $9A
		ldh a, [c]
		dec b
		inc e
		call z, $ED2C	; Possibly invalid
		ld h, [hl]
	db $F4
		ld d, c
		ld b, [hl]
		ld c, d
		pop hl
		ld h, a
		ld a, $AF
		jr nz, @ + 10
		dec h
		ld [hl], h
		ld a, e
		call nc, $5117	; Possibly invalid
		add d
		ld sp, hl
		sub e
		sbc a, b
		or l
		ld h, h
		ld d, a
		ld b, c
		or l
		rrca
	db $D3
		and d
		add b
		add hl, bc
		adc d
		pop hl
		dec sp
		call $5224	; Possibly invalid
		dec e
		add hl, bc
		and l
		ld a, [bc]
		or l
	db $ED
		ld c, a
		dec e
		call nz, $103E	; Possibly invalid
		or h
		ld d, [hl]
		ld b, $A8
	db $EC
		inc [hl]
		call c, $9890
		cp a
		sub a
	db $E4
		add e
		ld a, [de]
		ld h, h
		dec de
		ret
	
		halt
		ld h, [hl]
		inc [hl]
	db $FC
		xor l
	db $E4
		ld [hl], d
		pop bc
		ld b, d
		dec de
		daa
		ld l, c
		ld [hl], l
		inc de
		ret c
		rst $20
		ld c, h
		ret nz
	db $DB
		add hl, hl
		ld d, e
		add a
		dec sp
		push bc
		ld a, l
		inc c
		dec l
		dec bc
		ld c, $F5
		ld a, a
		sbc a, e
		call z, $AA99
		ld [hl], b
		ld a, $A3
		call nc, $40ED	; Possibly invalid
		adc b
		ld [hl], $29
		inc sp
		rst $38
		ld h, c
		rst $20
		ld c, [hl]
		cp h
		sbc a, b
		or c
		cp c
		jp hl
	
		cp a
		ld e, h
		call z, $4870	; Possibly invalid
		sub l
		jp $575F	; Possibly invalid
	
		or $26
		cp $19
		cp h
	db $F4
		add hl, de
	db $D3
		rla
		and h
		add l
		ret nz
		ld b, [hl]
		or e
		inc hl
		adc l
		ld a, [hl]
		and d
		ld a, h
		ld h, l
		ld sp, $ACF2
		dec e
		ld [hl], e
		ld [hl], $79
		ldh [c], a
		inc bc
		inc d
		rst $30
		ret nc
		and a
		ld [hl], e
		dec c
		xor l
		or $5F
		add hl, bc
		ld a, $7A
		sbc a, l
		scf
		rst $08
		call c, $8A67
		jp c, $E592	; Possibly invalid
		jp nz, $2DC0	; Possibly invalid
		jr z, @ + 89
		ret nc
		di
		rst $30
		and $86
		jr nz, @ + 85
		ld a, b
		ld c, d
		and $7E
		sbc a, e
		sbc $CC
		ld d, $7A
		xor c
		stop
		nop
		ld l, d
	db $D3
		ld a, d
	db $F4
		ret nz
		ld sp, $D8F2
	db $DB
		jp nz, $BA4E
		ldh [rTIMA], a
		dec b
		di
		ld [hl], b
		dec a
		ld e, a
		ld d, l
		jr z, @ + 117
		ld c, a
		call nc, $1A98	; Possibly invalid
		ldi a, [hl]
		ld l, l
		dec de
		ldh a, [c]
		ld hl, sp+-26
		ccf
		ld l, c
		rlca
		jp hl
	
		dec e
		ld h, b
		inc d
		ld a, a
		ld l, a
		rst $30
		di
		scf
		add b
		adc d
		inc d
		inc e
	db $DB
		add a
		add l
		pop af
		push hl
		ld b, c
		inc b
		inc a
		adc b
	db $EC
		ld e, [hl]
	db $D3
		cpl
		ret
	
		or d
		nop
		dec a
		xor d
		call $3B37	; Possibly invalid
		cp [hl]
		ld b, a
		inc d
		ld b, e
	db $ED
		adc c
		add hl, sp
		ld d, a
		ld d, $DD
		call z, $31A2	; Possibly invalid
		or d
		adc e
		and e
		ld e, e
		sub h
		ccf
		inc a
		jr @ + 67
	
		ld c, h
		adc b
		jp z, $11AB	; Possibly invalid
		add hl, sp
		sbc a, a
		jr z, @ - 27
		jr @ + 119
	
		ldh [c], a
		ld b, d
		add [hl]
		ld [bc], a
		daa
		and d
		ld h, h
		ld c, a
		rra
		adc [hl]
		cp d
		ld a, a
		ld e, b
		jr @ - 42
	
		ld l, h
		rlca
		ccf
		ld b, l
		ldd [hl], a
		add sp, -117
		inc de
		sbc a, d
		and a
		ld h, $9C
		ld b, [hl]
		ld e, d
		adc b
		ld h, l
		ld a, [$3DD9]
		inc c
		ldh [c], a
		pop af
		or a
		inc a
		ld hl, $D656
		rst $38
		inc [hl]
		adc a
		jr nc, @ + 66
		ret c
		xor h
		and l
		and e
		ld l, $55
		inc [hl]
		ld l, c
		adc a
		halt
	db $F4
		adc b
		cp d
		inc bc
		dec b
		add [hl]
		add hl, hl
		ld d, a
		jr nz, @ + 23
		ld c, c
		cp l
		sbc a, a
		inc e
		rst $10	; wizardAbilities
		ld de, $B12C
	db $EC
		ld c, [hl]
		adc h
		call nz, $1161	; Possibly invalid
		sbc a, d
		ld [hl], $68
		or c
		cp b
		rst $30
		ld h, d
		add l
	db $ED
		ld e, e
		jp hl
	
		call nz, $B803
		adc l
		jp $0023	; Possibly invalid
	
		ld [hl], d
		ld a, [hl]
		pop bc
		ret nz
		add c
		ld e, c
		ld c, h
		sbc a, c
		ld e, d
		ld de, $899E
		inc [hl]
		cp c
		sub $67
		and a
		adc h
		ld d, e
		daa
		ld h, h
		jp nz, $0B86	; Possibly invalid
		ld l, d
		ld a, e
		xor c
		ld [$BD4D], a
		jr nz, @ - 110
		set 6, [hl]
		add a
		adc c
		ld h, $B2
		xor [hl]
		ccf
		jp nc, $915C
		dec de
	db $DB
		inc b
		ld hl, sp+-112
		sub h
		sbc a, a
		or b
		inc hl
		ret
	
		ld d, c
		ldi a, [hl]
		ldh [c], a
		and $B0
		inc e
		cp a
		ld c, c
		adc a
		add sp, 22
		ld d, [hl]
		inc l
		ld a, [$3370]
		ld l, $09
		jp z, $A6B5
		ld h, b
		ld hl, sp+-103
		ret
	
		ei
		and d
		inc sp
		sub c
		and a
		sbc a, d
		ld l, h
		sbc a, a
		ld h, e
		ld d, $A6
		and e
		inc a
		ld b, e
		call c, $EC96	; Possibly invalid
		jr nc, @ + 82
		ldi [hl], a
		ret z
		ld b, [hl]
		push bc
		ld de, $F33E
		dec [hl]
		jr z, @ + 97
		inc b
		or [hl]
		ld h, $2F
		add l
		call $A248
		add hl, de
		xor b
		ccf
		or b
		cp a
		xor c
		ld a, e
		inc h
		pop bc
		jp $AF1E
	
		ld [hl], c
		add h
		ld e, e
		ld h, $C1
		inc l
		sub d
		add hl, sp
		sbc a, d
	db $ED
		inc de
		call z, $2A6E	; Possibly invalid
		dec bc
		ld c, [hl]
		cp d
		jp nc, $203A	; Possibly invalid
		ld l, h
		or l
		ld h, $8D
		and [hl]
	db $E3
		rra
		push hl
		ld d, a
		or l
		dec l
		sub [hl]
		sub d
		pop hl
		sbc a, h
		ld de, $3DD9
		ld l, $44
		halt
		reti
	
		xor c
	db $DD
		add h
		scf
		di
		inc e
		or e
		ld b, b
		ld b, d
		push de
		sub c
		inc c
		or a
		jr nc, @ + 124
		rlca
		jr nc, @ + 16
		and a
		dec e
	db $D3
		ld a, a
		sbc a, e
		jp $7974	; Possibly invalid
	
		rst $20
		ldh a, [c]
		ld a, [bc]
		ld b, a
		ld h, h
		jr nz, @ - 67
		call nc, $6AED	; Possibly invalid
		ld d, e
		rla
		ld [hl], b
		ldh a, [c]
		ld a, l
		ld sp, hl
		or a
		ld e, e
		ldi [hl], a
		ld l, [hl]
		push de
		ld [hl], a
		or b
		ld h, a
		ld b, b
		add e
		ld e, h
		xor c
		adc l
		ld a, c
		dec c
		jp nz, $C924	; Possibly invalid
		push af
		ld a, l
		adc $3C
		rrca
		sub c
		rst $10	; wizardAbilities
		add [hl]
		ld b, b
		cp [hl]
		ret nc
		halt
		xor l
		dec h
		jp nz, $9B7E
		ld e, h
		xor h
		push bc
		jp nz, $2A79	; Possibly invalid
		jr @ + 4
	
		ld [hl], h
		dec b
		add c
		cp a
		ldi a, [hl]
		pop hl
		halt
		ld [hl], l
		inc d
		cp b
		ei
		daa
		ldi [hl], a
		sub b
		ret c
		set 4, e
		ldi a, [hl]
		call nc, $5E9D	; Possibly invalid
	db $EB
		ld sp, hl
		ld [$8F1A], a
		ld c, l
		ld d, $4C
		ld l, $F0
		sub a
		ld l, h
		ld e, d
	db $FC
		rst $20
		sub [hl]
		add hl, de
		ld d, h
		ld l, l
		ld c, c
		pop hl
		jp nc, $DBEF	; Possibly invalid
		rlca
		ld [hl], c
		sub b
		sub c
		sub a
		call nc, playerY	; Possibly invalid
	db $DD
		adc [hl]
		add $4D
		ld d, e
		ld l, h
		ld a, [hl]
		ldh a, [c]
		add hl, sp
		ld h, h
		sub a
		ld h, $C2
		ldh [c], a
		adc c
		jr c, @ - 50
		dec hl
	db $DD
		ld h, [hl]
		add a
		rla
		adc $69
		push bc
		ret nc
		rst $30
		ld [bc], a
		add e
		ld [hl], $9B
		ld b, e
	db $EC
		ld c, c
		adc l
		jp nc, $CC8C	; Possibly invalid
		rra
		ld c, c
		ld a, b
		jr @ + 63
	
		ld [hl], d
		add sp, 103
		dec hl
		sbc a, b
		and [hl]
		or b
		inc l
		ld b, c
		ld b, c
		add e
		and h
		ld l, d
		push bc
		ld l, h
		or e
		ld h, $F6
		ld h, l
		ld b, a
		jr z, @ - 47
		sbc a, l
		ret nc
		ld e, $6B
		ld c, l
		bit 7, a
		and c
		inc sp
		inc bc
		ld d, l
		add a
		inc e
		add d
		add d
		halt
		ld e, [hl]
		sub b
		sbc a, l
		add c
		sbc a, c
		dec e
		ld [bc], a
		add $AE
	db $EC
		dec a
		add hl, de
		ld l, $E1
		add l
		ld [hl], d
		rrca
		jr nc, @ - 53
		ld a, l
		inc b
		ld [bc], a
		ldh [c], a
		ldh [_PORT_36_], a
		ld e, $60
		ld a, [hl]
		ld c, d
		ld e, [hl]
		ld c, l
	db $EC
		dec bc
		add hl, bc
		ld [$6329], sp
		ei
		ldh a, [c]
		add d
		pop de
		and d
		nop
		ld a, l
		reti
	
		ld a, [bc]
		ld [hl], b
		ld b, [hl]
		sbc $15
		push de
		cp l
		call nc, $6017	; Possibly invalid
		ld a, [$6705]
		rst $08
	db $E3
		dec b
		ld e, d
		ld c, $2C
		adc $6E
		and e
		ret nz
		ld [$B9B9], sp
		ld d, h
		ldi a, [hl]
		set 2, a
		sub a
		ld d, [hl]
		add hl, sp
		ld c, e
		xor a
		ld b, d
		or h
		jr nz, @ - 117
		ld e, $F7
		ld d, [hl]
		inc e
		sub h
		ld b, [hl]
		ei
		sub [hl]
		ld [hl], a
	db $D3
		ld hl, $ABAB
		inc de
		ld e, h
		ret z
		or l
		add hl, de
		ldi [hl], a
		bit 3, a
		sub a
		xor e
		ld b, $CC
		ld b, l
		or a
		rst $28
		and a
		di
		add d
		ld hl, sp+15
		rla
		jr @ - 46
	
		cp h
		ld bc, $C4A0
		jp hl
	
		and e
		sbc a, h
		pop de
		add [hl]
		add b
		ld e, $AA
		ld l, [hl]
		rrca
	db $EC
		xor l
	db $FC
		ld a, l
		cp [hl]
		dec b
		ld l, $F3
		sbc a, a
		dec hl
		ld [hl], a
		sub a
		inc l
		rst $38
		inc bc
		dec bc
		cp a
		and [hl]
		cp [hl]
		dec c
		ld l, a
	db $FC
		ei
		ldi [hl], a
		ld a, [de]
		rst $30
		push hl
		pop bc
		ld l, d
		push bc
		ldi [hl], a
		and b
	db $DB
		ldh [$FD], a
		ld l, d
		add hl, de
		xor c
		ld c, b
		rlca
		ld [$F0F7], a
		ld d, c
		and d
		ld b, $80
		add hl, sp
		or l
		ld [$D2E9], sp
		ld a, b
		inc l
		and c
		xor $71
		daa
	db $F4
		ret
	
		and $16
		or d
		inc de
		call c, $B9C8
		or d
		inc c
		ld d, d
		cp a
		ld e, h
		ld c, a
	db $EB
		add c
		add hl, de
		ld a, [$4D4A]
		dec sp
		ld a, a
		cp d
		rst $28
		ld e, [hl]
		call c, $4E2B	; Possibly invalid
		xor $C1
		add hl, hl
		ld d, [hl]
		ld h, a
		ld e, [hl]
		ld bc, $1937
		and e
		adc l
		cp b
		dec l
		dec sp
	db $E3
		adc [hl]
		add h
		jp $26CE	; Possibly invalid
	
		ld h, c
		cp a
		and h
		ld hl, $525D
		adc h
		ld e, [hl]
		sub c
		ld e, c
		dec [hl]
		ldh [c], a
		dec hl
		ld l, b
		ld h, [hl]
		ccf
		ld e, b
		or e
		or h
		ld [hl], $4C
		ld b, [hl]
		adc $F5
		inc de
		pop bc
		daa
		ld a, a
		ld l, b
		ld c, $CA
		ld h, c
		sbc a, [hl]
		dec c
		add hl, hl
		ld l, [hl]
		ret z
		sbc $AC
		call nz, $1E42	; Possibly invalid
		ld [$DEC9], a
		ld d, h
		dec c
		ld e, b
		and $39
		and e
		ld hl, $629B
		ld b, l
		inc b
		inc b
	db $DD
		ld [$6E15], sp
		ld bc, $2928
		and e
		ld d, a
		cpl
		cp d
		call z, $36E1	; Possibly invalid
		cp $D1
		ld a, h
		ld c, c
		sub $4B
		inc a
		dec c
		push hl
		sbc a, a
		stop
		xor [hl]
		or d
		jr @ + 57
	
		pop de
		and l
		ret z
		cp c
		rst $28
		ld [hl], a
		and l
		sla e
		ld l, l
		ld d, e
		ld h, h
		ldi [hl], a
		ldi [hl], a
		pop de
		ld hl, sp+101
		dec hl
		or b
		reti
	
		jr z, @ + 92
		ldh [_PORT_33_], a
		ld e, b
		cp a
		and h
		rst $18
		ld d, [hl]
		xor b
		xor a
		ld d, c
		ld a, b
		dec a
		ld b, l
		cp e
		xor $D0
		ld a, c
		xor $3E
		sbc a, e
		jr z, @ - 4
		jp nz, $6F66	; Possibly invalid
		jr nc, @ - 7
		adc $6B
		add c
		and h
		rst $28
		add hl, de
		dec e
		ldh a, [c]
		adc l
		ld b, $90
		sub h
		ld c, a
		add hl, sp
		dec h
		rst $00	; CharacterMovementTable
		cp e
		dec hl
		ld [$A724], a
		ld h, a
		ld e, b
		xor a
		or h
		rrca
		cp c
		jr c, @ + 26
		add hl, hl
	db $DD
		scf
		sub h
		sub e
		pop bc
		ld a, [de]
		ld a, e
		and a
		adc l
		ld d, h
		adc $BD
		ld l, l
	db $D3
		ld l, a
		ld a, [hl]
		ld [hl], $30
		ld h, h
		pop de
	db $E3
		jp c, $36B3	; Possibly invalid
		add hl, de
		ld c, a
		ld h, l
		rla
		xor [hl]
		add a
		ld h, c
		ld c, c
		ld l, $3F
		ld b, l
		cpl
		push de
		ld c, $F8
		ld e, a
		ld a, b
		sub d
		inc h
		or a
		dec a
		ld a, d
		ld b, $95
		ld b, b
		push bc
		ld a, [bc]
		ret
	
		rst $18
		ldh [c], a
		xor b
		add hl, sp
		ld b, b
		and c
		xor e
		ld a, b
		ld [$DDE1], sp
		ld l, h
		cp $DE
		ld h, b
		rla
		ld h, $9A
		ld h, c
		ld l, h
		ld d, c
		sub $70
		ld [hl], l
		rst $00	; CharacterMovementTable
		and e
		ld l, h
		jr nc, @ - 39
		jp hl
	
		dec h
		xor l
		ld c, d
		xor a
		ld a, c
		rla
		ld d, h
		ld e, a
		add c
		ld l, [hl]
		sub c
		ld c, [hl]
		ld d, $28
		ld [hl], d
		xor e
		jp c, $5ECA	; Possibly invalid
		ret c
		ld l, [hl]
		ld b, h
		ld b, $A4
		ldd [hl], a
		cp l
		ld c, h
		ld h, c
		inc a
		ld b, d
		ld de, $6472
		sbc a, b
		ld l, h
		xor l
		sub l
		adc [hl]
	db $ED
		ld [de], a
		inc de
		ld h, [hl]
		ld c, c
		ldd a, [hl]
		dec c
		ld e, e
		set 1, [hl]
		sub b
		dec [hl]
		pop bc
		jp nz, $EA75	; Possibly invalid
		ld e, d
		ld l, l
		or d
	db $EC
		ld l, a
		add hl, hl
		and a
		sbc a, b
		xor a
		xor d
		ld [de], a
		ldh [$A5], a
		ld e, b
		and d
		ret z
	db $F4
		dec a
		ld bc, $BC06
		ld e, [hl]
		ld l, d
		and d
		inc bc
		jp hl
	
		rst $10	; wizardAbilities
		di
		ld h, [hl]
		dec de
		inc de
		ld [$EB20], a
		ld [hl], h
		ld c, [hl]
		stop
		jp c, $CB99	; Possibly invalid
		ld b, [hl]
		jp z, $78FB	; Possibly invalid
		or c
		add l
		add hl, hl
		xor h
		rst $38
		sub a
		ld hl, $7D85
		ld a, a
		cp c
		ld [hl], b
		and d
		cp d
		cp h
		ld a, a
		or [hl]
		jp z, $A104
		sbc $D3
		halt
		inc d
		sub h
		ldh [_PORT_35_], a
		dec e
		add sp, 93
		ld h, $90
		adc d
		ld a, c
		ret nz
		cp b
		ld c, a
		jp $D857	; Possibly invalid
	
		ld h, e
		sub d
		ld c, b
		ld c, h
		ld e, h
	db $E3
		ld l, c
		reti
	
		jp $BE37
	
		ld c, h
		ld b, [hl]
		ld b, [hl]
		or h
		ld h, b
		jr z, @ - 13
		ld l, $BA
		pop de
		ld c, $03
		add sp, 78
		ld l, $29
		sbc $F0
		ldi a, [hl]
		add sp, 57
		rst $20
		cp d
		add hl, de
		or l
	db $ED
		ld h, b
		add hl, sp
		daa
		add sp, 37
		jr c, @ + 84
		inc e
		sbc a, [hl]
		ld [hl], h
		ldh [_PORT_66_], a
		jp hl
	
		halt
	db $DD
		sub c
		ld l, c
		add e
		ld e, b
		jp $F25B	; Possibly invalid
	
		jp hl
	
		ld a, b
		ld d, d
		ldh [_PORT_7D_], a
		inc a
		and l
		ld l, a
		inc l
		or h
		dec hl
		xor $C7
		ld b, e
		adc d
		ld [hl], a
		ld h, b
		pop af
		rst $38
		ldh [$81], a
		ld hl, sp+73
		ret z
		ld e, e
		ldd a, [hl]
		ld bc, $0890
		rst $18
		cp [hl]
		inc b
	db $E4
		xor $49
		rst $38
		jp $C193	; Possibly invalid
	
		ld [hl], h
		sbc $8F
		adc [hl]
		sub d
		ld d, c
		ld a, e
		ldh [rOBP1], a
		ret nz
		ld c, e
		inc [hl]
		ld l, b
		cp d
		and [hl]
		ret
	
		adc h
		dec d
		rrca
		adc l
		halt
		and $EB
		jr @ - 77
	
		inc b
		ld b, d
		sbc a, e
		xor c
	db $F4
		add hl, de
		pop de
		ld a, d
		ld [hl], a
		add c
		and b
		add a
		jr @ + 89
	
		ld [hl], l
		jp $A178
	
		ld h, c
		ld h, [hl]
		push hl
		ld d, l
		adc e
		sub b
		ret z
		inc [hl]
		ld h, l
		or h
		call $6FB5	; Possibly invalid
		cp d
		sbc a, a
	db $FC
		ld d, [hl]
		ld l, d
		and b
		jr @ + 101
	
		ld d, b
		sbc a, h
		add a
		ld l, a
		inc [hl]
		sbc a, b
		and [hl]
		inc a
		ldh a, [$AF]
		rst $00	; CharacterMovementTable
		ld sp, hl
		sub h
		dec [hl]
		ld a, d
		ld [hl], c
		rra
		set 3, d
		ld hl, sp+-78
		reti
	
		ld c, h
		add hl, bc
		call $79A1	; Possibly invalid
		sbc a, d
		ld a, b
		and l
		call nc, $339C	; Possibly invalid
		add h
		ld b, d
		ld e, c
		jp hl
	
		ld e, l
		ei
		sub d
		ld a, $D9
		dec hl
		add a
		add $BA
		ld a, e
		inc bc
		ld [$772B], a
		xor e
		and $82
		sub $A6
		cp $05
		ld d, c
		add hl, sp
		push bc
		ldd [hl], a
		sub a
	db $E3
		jp c, $D439	; Possibly invalid
		ld [de], a
		ld h, b
	db $DD
		or [hl]
		adc l
		ld hl, $8022
		pop bc
		ld [hl], b
		nop
		add c
		add e
		ld d, e
		or d
		ld [hl], b
		and c
		rst $10	; wizardAbilities
		ret c
		ldh a, [c]
		ld [hl], h
		or [hl]
	db $DB
		ld h, d
	db $DD
		ld d, $A1
		ld l, d
		ldh a, [rAUD2LOW]
		inc bc
		add l
		jp nc, $C96C	; Possibly invalid
		ldh [_PORT_38_], a
		ld l, a
		and l
		ld b, l
		ld l, h
		ld [hl], c
		cp [hl]
		ld a, $8B
		adc e
		ld c, h
	db $D3
		or $9C
		add d
		dec l
		ld b, e
		sbc a, l
		ld c, e
		ldh a, [c]
		ld b, d
		and a
		sbc a, [hl]
		ld [bc], a
		xor e
		sub a
		ld l, h
		and d
		dec [hl]
		ld d, a
		ld d, c
		ld e, e
		ld e, d
		ld sp, hl
		sbc $A9
		add h
		xor c
		inc e
		ld hl, $09D9
		ld d, l
		adc c
	db $E3
		inc l
	db $ED
		ld a, [bc]
		ld [hl], a
		cp $20
		ld a, e
		cp $D4
		ldi a, [hl]
		ld h, b
		ld [hl], e
		dec l
		ld [hl], a
		ldi a, [hl]
		ld c, h
		ld e, h
	db $DD
	db $DB
		ldd [hl], a
		rst $10	; wizardAbilities
		pop af
		ld e, c
		dec a
	db $DB
		stop
		ld a, h
		xor l
	db $DB
		ld d, b
		adc c
		ld c, a
		ld l, $31
		stop
		ld sp, $5920
		sub h
		ld c, d
		ld c, a
		pop af
		sbc a, h
		ld b, b
		ld c, e
		ld [hl], c
		xor d
		ld c, l
	db $D3
		cp [hl]
		ld [hl], $B3
		push af
		inc h
		and l
		ld c, c
		ld d, h
		ld c, h
		inc e
		ld c, b
		ld d, l
		ld a, d
		sub d
		ld d, d
		and c
		ld h, $7C
		ldd a, [hl]
		ld e, $3D
		ld a, c
		ld l, e
		ld e, b
		ld [hl], h
		ld h, [hl]
		ld a, [de]
		inc bc
	db $EC
	db $EC
		add c
		add a
		ld d, d
		adc b
		ret nz
		ld c, h
		inc l
		sub b
	db $EC
		reti
	
		ld b, h
		ret nc
		ld a, [bc]
		adc [hl]
		ret
	
		rst $18
		ld e, $F7
		add hl, sp
		ldh a, [_PORT_2C_]
		or c
		ld [hl], l
		cp c
		inc d
		adc c
		add [hl]
		cp b
		ld a, c
		ldi a, [hl]
		ld h, c
		jp c, $AECF
		jr @ - 96
	
		ret c
		ld h, [hl]
		or h
		ld [hl], $60
		ld l, b
		ret
	
		ld h, d
		and [hl]
		ld b, d
		call $DA61	; Possibly invalid
		ld [de], a
		ld l, c
		call nz, $7A55	; Possibly invalid
		xor l
		add e
		ld h, h
		and c
		and [hl]
		scf
		ei
		dec bc
		xor $27
		add l
		stop
		ld b, [hl]
		dec sp
		call nc, $B689
		jr nz, @ + 2
		ld [hl], $B6
		add e
	db $FD
		add d
		or $F7
		rst $20
		or d
		dec b
		ld e, d
		rst $10	; wizardAbilities
		ccf
		dec [hl]
		rrca
	db $EB
		jp c, $C4A4	; Possibly invalid
		or $41
		rst $00	; CharacterMovementTable
		inc a
		cp e
		rst $10	; wizardAbilities
		ld b, e
		xor e
		ld c, $27
		dec bc
		ld [$7ACA], a
		ld [hl], $23
		dec c
		ret z
		jp nz, $132A	; Possibly invalid
		call nz, $0E95	; Possibly invalid
		add l
		and l
		dec l
		or e
		dec a
		ld c, a
		inc hl
		cp a
		ld l, d
		dec de
		cp a
		sbc $F5
		add b
		and [hl]
		ld h, $8F
		inc bc
		ret
	
		jp c, $89A4
		inc e
		ret nz
		add h
		reti
	
		ld c, l
		rst $20
		ld a, $1F
		ld a, [hl]
		ld l, $02
		ldh [c], a
		xor a
		ld c, $8C
	db $E3
		ld h, a
		ld a, a
		pop de
		dec h
		ld a, l
		dec e
		ld h, e
		add c
		jr nz, @ - 123
		cp [hl]
		adc [hl]
	db $E3
		set 6, d
		xor a
	db $D3
		ldi [hl], a
		ld h, a
		dec bc
		push bc
		cp b
		sbc $27
		reti
	
		adc h
		sub h
		rst $20
		add [hl]
		rst $10	; wizardAbilities
		sbc $31
		ld b, $77
		ld b, a
		ld b, b
		jp nc, $5BFF	; Possibly invalid
		ld de, $C4DB
		cp $FE
		adc [hl]
	db $FD
	db $FC
		ld d, l
		ld e, l
		ld b, $62
		ld e, b
		ld b, l
		ld a, [bc]
		inc b
		sbc $01
		add hl, de
		dec a
		add e
		push hl
	db $D3
		dec a
		ld c, $DE
		adc b
		sub l
		call c, $71BA	; Possibly invalid
		halt
		sub [hl]
		ret c
	db $E3
		rst $10	; wizardAbilities
		and c
		rst $28
		ld c, h
		sbc a, e
		rst $30
		pop af
		ld b, h
		ldi a, [hl]
		rst $10	; wizardAbilities
		sbc a, b
		pop hl
		dec sp
		sub $52
		ld d, $88
		rst $38
		and c
		ld h, [hl]
		add [hl]
		ld b, $EC
		ld c, $96
		add $7D
		rst $28
	db $DD
		ld b, l
		or e
		add l
		dec d
		pop hl
		add l
		ld a, $B5
		ld e, b
		and c
		ret c
		add l
		ld [bc], a
		ld e, b
		sbc a, [hl]
		pop hl
		sub e
		and c
		ld d, e
		sbc a, a
		or a
		halt
		ld b, l
		ld [hl], $73
		ld [hl], d
		dec d
		halt
		dec c
		ld [hl], e
		ld a, d
		ld b, a
		ld h, d
		ld l, c
		add sp, 101
		adc l
		pop hl
		ld a, c
		ld c, $87
		and e
		ld h, a
		ld h, [hl]
		ld e, l
		rst $38
		inc a
		ld h, l
		push de
		push hl
		ld bc, $2710
		rst $08
		jp z, $8ACD
		di
		ld b, a
		ld d, l
		add a
		push af
		ld c, b
		jr nz, @ - 77
		adc h
		or [hl]
		pop af
		rr [hl]
		jr @ - 41
	
		ldi a, [hl]
		and h
		or c
		xor l
		di
		ld c, a
		sub e
		ld sp, hl
		ld b, [hl]
		sbc a, h
		sub l
		jp c, $8FF0
		ld l, l
		dec a
		inc bc
		add [hl]
		rst $38
		pop bc
		ld l, c
	db $EB
		or c
		ld e, e
		adc b
		ld l, a
		ld a, [de]
		ld [hl], e
		ld d, a
		and c
		ld h, c
		sub c
		sub b
		or h
		ld [hl], d
		ld [bc], a
		inc l
		xor b
		add hl, de
		add hl, hl
		ld d, $5B
		add hl, sp
		ld sp, $625B
		push de
		pop hl
		cp h
		cp $1D
		sub c
		ld [hl], a
		add e
		rst $20
		ld a, b
		stop
		jp nz, $50AE	; Possibly invalid
		ld h, [hl]
		sbc a, h
		ld e, l
		call $4A11	; Possibly invalid
		scf
		ld c, l
		ld a, [hl]
		call nz, $E9A6	; Possibly invalid
		nop
		inc e
		ld d, h
		add d
		push de
		rla
		rla
		adc d
		xor $60
	db $FC
		sub a
		ld d, a
		adc l
		add sp, 45
		cpl
		ld l, $B8
		dec h
		jp nc, $CCD4	; Possibly invalid
		rla
		dec [hl]
		ret c
		and l
		ld c, c
		ld [hl], d
		ld d, b
		cp b
		add e
		inc [hl]
		cp h
		sbc a, h
		inc [hl]
	db $DB
		ld [hl], l
		add l
		dec c
		ld h, [hl]
		ldd a, [hl]
		dec h
		cp c
		ld l, a
		ei
		jr nc, @ + 75
		sub h
		ld e, b
		dec [hl]
		ld d, l
		ld sp, hl
		inc sp
		ld bc, $1ECB
		halt
		xor h
		or a
		adc c
		ldh a, [$B6]
		rst $38
		xor a
		cpl
		ld a, $A1
		xor $20
		or b
		jp hl
	
		ld c, h
		ld b, h
		daa
	db $DD
		and $05
		or d
		add hl, sp
		ld [hl], l
	db $E3
		ld a, $17
	db $D3
		sub l
		rra
		dec l
		add $21
		jr nc, @ - 83
		ld [hl], h
		ldi a, [hl]
		cp e
		ld [hl], c
		ld a, b
		jp hl
	
		sub l
		call nc, $FCF0	; Possibly invalid
		cp $74
		ld [$2FDF], a
		jr c, @ + 60
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $08
		nop
		ld a, [hl]
		rst $38
		xor e
		nop
		nop
		ld hl, sp+-1
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		pop hl
		add b
		cp a
		di
		rst $38
		cp a
		rst $38
		ccf
		nop
		rst $38
		cp a
		ld a, a
		rst $38
		sbc a, a
		rst $38
		cp a
		rst $38
		rst $38
		nop
		nop
		cp a
		ld [hl], a
		di
		pop af
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		xor h
	db $DD
		jp c, $3648	; Possibly invalid
		ld [bc], a
		rst $08
		ld d, $2C
		inc b
		push hl
		inc l
		xor h
	db $DD
		jp c, $9148
		add a
		nop
		nop
		nop
		nop
		rst $38
	db $FC
		rst $38
		rst $38
		nop
		nop
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		rst $38
		ldi [hl], a
		cp a
		call c, $3650	; Possibly invalid
		ret c
		ld e, [hl]
		ld h, e
		dec sp
	db $D3
		jr nc, @ - 20
		dec de
		jr nz, @ + 50
		add a
		ld d, h
		adc c
		ld a, [$C826]
		scf
		ld hl, sp+52
		ld d, e
		dec l
		ld bc, $365B
		dec c
		adc e
	db $EC
		ret z
		ld hl, sp+20
		halt
		and d
		xor c
		adc d
		push af
		rla
		ld c, $05
		or e
		ld [hl], b
		sub a
		cp [hl]
		and h
		ld [hl], c
		add hl, hl
		xor h
		dec de
		and e
		inc [hl]
		ld a, [de]
		call nc, $AC13
		inc d
		ld c, l
		add $9F
		add hl, sp
		or c
		sub l
		ldh a, [c]
		ld h, [hl]
		cp h
		inc [hl]
		ld e, l
		sbc a, h
		xor l
		ldh a, [_PORT_2E_]
		cp e
		jr z, @ + 91
		and h
		adc c
	db $DD
		ld a, [$070B]
		add hl, de
		ld [hl], a
		add hl, hl
		inc h
		call c, $1FB4	; Possibly invalid
		ld hl, sp+-115
	db $FC
		cp h
		ld e, a
		jp $C6C4	; Possibly invalid
	
		inc c
		ld [hl], $25
		ld [hl], h
		ld d, a
		and c
		call c, $2772	; Possibly invalid
		ldi a, [hl]
		dec b
		ld l, $00
		add d
		sub e
		ld l, l
		or d
		stop
		adc h
		ld sp, $D955
		halt
		ld b, a
		add hl, sp
		ld bc, $002E
	db $ED
		nop