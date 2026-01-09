;Liberaries and global variables
INCLUDE "libs/hardware.inc"
INCLUDE "libs/variables.asm"

;------------------------------------------------------------------------

;The game states
SECTION "GameState", ROM0

INCLUDE "states/start.asm"
INCLUDE "states/game.asm"




;------------------------------------------------------------------------

;The functions and code assosiated with the game, like walking
SECTION "GameCode", ROM0

INCLUDE "func/printConsole.asm"
INCLUDE "func/input.asm"
INCLUDE "func/vblank.asm"


;------------------------------------------------------------------------

;textures
SECTION "TileData", ROM0

INCLUDE "tex/Tilemap/First.z80"
INCLUDE "tex/Tilemap/hello_world.asm"

INCLUDE "tex/Tiles/First.z80"
INCLUDE "tex/Tiles/hello_world.asm"