;;
;; benchtest of t80 core.
;;
org 0
   di
   ld  sp, top_of_stack
   call ctestc
   out (0x80), a    ; contents of A also appear on A8 through A15 at this time - UM008011 Z80 Manual OUT (n), A 
   jp  entry

ds  0x0038-$
org 0x0038
RST_38:
    di
    inc e
    ld  a, e        ; A is presently used for nothing, C is the genera
    out (0x80), a
    ei              ; apparently must be re-enabled
    ret


ds 0x0100-$
org 0x0100
entry:
   ; load data pointer and start count
   ld  hl, output
   ld  c, 0x10
   ; enable IRQ
   im  1 
   ei

loop:
   ;; Write to memory and then read back
   ld  (hl), c
   ;; Note: don't try to read from uninitialized array in simulation!
   ld  b, (hl)
;   inc hl
   inc l            ; only write to "page 0", adequate for test (don't overwrite stack!)
   inc c

   jr  loop

db 0xFF, 0xFF

ctestc:
   ld a, 0x5a
   ret

org 0x8000
output:
   db 00

org 0x8400
top_of_stack:  ; SP is pre-incremented i.e. 87FF is first address push'd


gfx_ram:
