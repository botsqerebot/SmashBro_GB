;Liberaries and global variables
INCLUDE "libs/hardware.inc"
INCLUDE "libs/variables.asm"
INCLUDE "libs/CharacterID.asm"


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
INCLUDE "func/viewSprites.asm"
INCLUDE "func/movingCharacter/basicMovement.asm"
INCLUDE "func/movingCharacter/flipCharacters.asm"
INCLUDE "func/movingCharacter/collision.asm"
INCLUDE "func/movingCharacter/hoppingMovement.asm"
INCLUDE "func/movingCharacter/flyingMovement.asm"

;------------------------------------------------------------------------
;DEFINITIONS OF THE CHARACTERS

SECTION "CharacterDefs", ROM0
INCLUDE "libs/SpriteDEF/Types.asm"

INCLUDE "libs/SpriteDEF/Wizard.asm"

;------------------------------------------------------------------------
;TEXTURES

SECTION "TileData", ROM0

INCLUDE "tex/Tilemap/First.z80"
INCLUDE "tex/Tilemap/hello_world.asm"
INCLUDE "tex/Tilemap/BattleArena1.z80"
INCLUDE "tex/Tilemap/ChineseStadium.z80"

INCLUDE "tex/Tiles/ChineseBattleStadionTiles.z80"
INCLUDE "tex/Tiles/First.z80"
INCLUDE "tex/Tiles/hello_world.asm"

INCLUDE "tex/Sprites/CharacterV2.z80"

;Wizard Character
INCLUDE "tex/Sprites/Wizard/Wizard.z80"