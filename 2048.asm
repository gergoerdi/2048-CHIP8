;;; 2048 game for CHIP-8
;;;
;;; The board is stored as 16 consecutive bytes, each with a value between 0 and 11
;;; 0 is an empty tile
;;; 1..10 is a tile with values 2..1024
;;; 11 is the target tile: as soon as we get an 11 tile, the user has won
;;;
;;;
START:
        ;; call NEWGAME
        call DRAW_GRID
        call DRAW

HALT:   jump HALT

DRAW_GRID:
        load i, GRID
        load v1, 0              ; K := 0
        load v2, 15             ; X := 15
        load v3, 0              ; Y := 0
DRAW_GRID_LOOP:
        skip.ne v1, 16          ; while (K != 16)
        ret
        draw v2, v3, 8

        add v1, 1               ; K += 1
        add v2, 8               ; X += 8
        skip.eq v2, 47
        jump DRAW_GRID_LOOP

        ;; Start new row
        load i, GRID_RIGHT
        draw v2, v3, 8
        load v2, 15             ; X := 15
        add v3, 8               ; Y += 8
        load i, GRID
        skip.ne v3, 24          ; for bottommost row, use special sprite
        load i, GRID_BOTTOM
        jump DRAW_GRID_LOOP

;;; DRAW_TILE
;;; In:  V1: K
;;;      V2: X
;;;      V3: Y
;;; Use: V0: TMP
DRAW_TILE:
        load i, BOARD           ; TMP := BOARD[K]
        add i, V1
        restore V0

        skip.ne v0, 0           ; if TMP == 0 then done
        ret

        sub v0, 1
        hex v0
        draw v2, v3, 5
        ret

DRAW:
        load v1, 0              ; K := 0
        load v2, 15+3           ; X := 15+3
        load v3, 0+2            ; Y := 0+2

DRAW_LOOP:
        skip.ne v1, 16          ; while (K /= 16)
        ret
        call DRAW_TILE
        add v1, 1               ; K += 1
        add v2, 8               ; X += 9
        skip.eq v2, (3*16-1)+3
        jump DRAW_LOOP
        load v2, 15+3           ; X := 15+3
        add v3, 8               ; Y += 8
        jump DRAW_LOOP


;;; NEWGAME: fill BOARD with zeroes
NEWGAME:
        load i, BOARD
        load v0, 0
        load v1, 1
        load v2, 16
NEWGAME_LOOP:
        skip.ne v2, 0
        ret
        save v0
        add i, v1
        jump NEWGAME_LOOP

BOARD:
        ;; .ds 16, 0x01
        .byte 1
        .byte 1
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0
        .byte 0

GRID:   .byte $11111111
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000

GRID_BOTTOM:
        .byte $11111111
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $11111111

GRID_RIGHT:
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
        .byte $10000000
