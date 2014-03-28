;;; 2048 game for CHIP-8
;;;
;;; The board is stored as 16 consecutive bytes, each with a value between 0 and 11
;;; 0 is an empty tile
;;; 1..10 is a tile with values 2..1024
;;; 11 is the target tile: as soon as we get an 11 tile, the user has won
;;;
START:
        call NEWGAME
        call DRAW_GRID
        call PLACE_RANDOM_TILE
        call PLACE_RANDOM_TILE

        ;; call SLIDE_UP
        ;; call BLIT

        ;; call DRAW
LOOP:
        call DRAW
        load va, key
        call DRAW

        load vd, 0
        skip.ne va, 6
        call SLIDE_RIGHT
        skip.ne va, 4
        call SLIDE_LEFT
        skip.ne va, 8
        call SLIDE_DOWN
        skip.ne va, 2
        call SLIDE_UP

        skip.eq vd, 0
        call PLACE_RANDOM_TILE

        jump LOOP

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

BLIT:
        load v1, 0
BLIT_LOOP:
        skip.ne v1, 16
        ret
        load i, NEW_BOARD
        add i, v1
        restore v0
        load i, BOARD
        add i, v1
        save v0
        load v0, 0
        load i, NEW_BOARD
        add i, v1
        save v0
        add v1, 1
        jump BLIT_LOOP

;;; ROTATE
;;;
;;; Maps
;;;
;;; 0123
;;; 4567
;;; 89ab
;;; cdef
;;;
;;; to
;;;
;;; c840
;;; d951
;;; ea62
;;; fd73
;;;
;;; Use: V0: TMP
;;;      V1: K
;;;      V2: K'
;;;      V3: ROW
;;;      V4: NEW_ROW
ROTATE:
        call ROTATE_INT
        call BLIT
        ret
ROTATE_INT:
        load v1, 0
        load v2, 3
        load v3, 3
ROTATE_LOOP:
        skip.ne v1, 16
        ret

        load i, BOARD           ; TMP := BOARD[K]
        add i, v1
        restore v0

        load i, NEW_BOARD       ; NEW_BOARD[K'] := TMP
        add i, v2
        save v0

        add v1, 1                ; K += 1
        add v2, 4                ; K' += 4

        load v4, $11             ; New row?
        and v4, v1
        skip.eq v4, 0
        jump ROTATE_LOOP

        sub v3, 1               ; ROW -= 1
        load v2, v3             ; K' := ROW
        jump ROTATE_LOOP

;;; SLIDE_LEFT
;;; Vars: V0: TMP
;;;       V1: K
;;;       V2: K'
;;;       V3: LAST
;;;       V4: END_ROW
;;;       V5: ROW
;;;       V6: MATCH
SLIDE_LEFT:
        call SLIDE_LEFT_INT
        call BLIT
        ret

SLIDE_LEFT_INT:
        load v1, 0              ; K := 0
        load v2, 0              ; K' := 0
        load v3, 0              ; LAST := 0
        load vf, 0              ; WIN := 0
        load v5, 0              ; ROW := 0

SLIDE_LEFT_ROW:
        skip.ne v1, 16
        ret

        load i, BOARD           ; TMP := BOARD[K]
        add i, v1
        restore v0

        skip.ne v0, 0
        jump SLIDE_LEFT_NEXT

        load v6, 0
        skip.ne v0, v3
        load v6, 1

        skip.ne v6, 1          ; IF TMP == LAST then MERGE_LEFT
        call MERGE_LEFT
        skip.eq v6, 1
        load v3, v0

        load i, NEW_BOARD       ; NEW_BOARD[K'] := TMP'
        add i, v2
        save v0

        skip.eq v1, v2          ; vd |= v1 == v2
        load vd, 1

        add v2, 1               ; K' += 1

SLIDE_LEFT_NEXT:
        add v1, 1               ; K += 1

        load v4, $11            ; New row?
        and v4, v1
        skip.eq v4, 0
        jump SLIDE_LEFT_ROW

        add v5, 1               ; ROW += 1
        load v3, 0              ; LAST := 0
        load v2, 0              ; K' := ROW * 4
        skip.ne v5, 1
        load v2, 4
        skip.ne v5, 2
        load v2, 8
        skip.ne v5, 3
        load v2, 12
        jump SLIDE_LEFT_ROW

SLIDE_DOWN:
        call ROTATE
        call SLIDE_LEFT
        call ROTATE
        call ROTATE
        call ROTATE
        ret

SLIDE_RIGHT:
        call ROTATE
        call ROTATE
        call SLIDE_LEFT
        call ROTATE
        call ROTATE
        ret

SLIDE_UP:
        call ROTATE
        call ROTATE
        call ROTATE
        call SLIDE_LEFT
        call ROTATE
        ret

;;; MERGE
;;; InOut: V0: TMP
;;;        V2: K'
;;;        V3: LAST
MERGE_LEFT:
        add v0, 1
        load v3, 0
        sub v2, 1
        ret

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

        sub v0, 1               ; Draw digit for TMP-1 at (X, Y)
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
        add v2, 8               ; X += 8
        skip.eq v2, (3*16-1)+3  ; Start new row?
        jump DRAW_LOOP
        load v2, 15+3           ; X := 15+3
        add v3, 8               ; Y += 8
        jump DRAW_LOOP

;;; PLACE_RANDOM_TILE
PLACE_RANDOM_TILE:
        rnd v2, 7               ; Place a 1 tile with prob 1/8 and a 0 tile with prob 7/8
        load vb, 1
        skip.ne v2, 0
        load vb, 2
        call PLACE_TILE
        ret

;;; PLACE_TILE
;;; Input: VB: TILE
;;; Use: V0: TMP
;;;      V1 : K
;;;      V2 : TARGET
PLACE_TILE:
        rnd v2, 15
        ;; Pick TARGET'th empty square
        load v1, -1
PLACE_TILE_SCAN:
        add v1, 1
        skip.ne v1, 16
        load v1, 0

        load i, BOARD           ; TMP := BOARD[K]
        add i, v1
        restore V0

        skip.eq V0, 0           ; If TMP == 0 then next
        jump PLACE_TILE_SCAN

        sub v2, 1               ; Is this the TARGET'th empty square?
        skip.eq v2, 0
        jump PLACE_TILE_SCAN

        load v0, vb             ; BOARD[K] := TILE
        save v0
        ret


;;; NEWGAME: fill BOARD with zeroes
NEWGAME:
        load v1, 0
        load v0, 0
NEWGAME_LOOP:
        skip.ne v1, 16
        ret
        load i, BOARD
        add i, v1
        save v0
        add v1, 1
        jump NEWGAME_LOOP

BOARD:
        .ds 16
NEW_BOARD:
        .ds 16

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
