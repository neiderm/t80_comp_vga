;;
;; This program operates in an endless loop, and increments the
;; value stored at a particular address.
;; Modified for use as benchtest of t80 core.
org 0
   di
   ld  sp, top_of_stack
   call ctestc

   jp  entry


ds  0x0038-$
org 0x0038
RST_38:
    ei   ; apparentely must be re-enabled
    ret


ds 0x0100-$
org 0x0100
entry:

   ;; Set HL to the address we're going to modify.
   ld  hl, output

   ;; start count
   ld  c, 0x10

   im  1 
   ei

loop:
   ;; Store counter
   ld  (hl), c

   ;; Note: don't try to read from uninitialized array in simulation!
   ld  b, (hl)

   ;; Increment Address then mask in $8000 so that it can wrap around but stay in RAM segment
;   inc hl
   inc l        ; only write to "page 0", adequate for test (don't overwrite stack!_
;   ld  a, h
;   or  0x80
;   ld  h, a

   ;; Increment counter
   inc c

   ;; Repeat.  Forever.
   jr  loop

db 0xFF, 0xFF

ctestc:
   xor a
    ret

org 0x8000
output:
   db 00

org 0x8400
top_of_stack:  ; SP is pre-incremented i.e. 87FF is first address push'd


gfx_ram:
