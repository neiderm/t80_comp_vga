;;
;; This program operates in an endless loop, and increments the
;; value stored at a particular address.
;; Modified for use as benchtest of t80 core.
org 0

   ;; Set HL to the address we're going to modify.
   ld hl, output

   ;; A start count
   ld a, 0x10

loop:
   ;; Store counter
   ld (hl), a

   ;; Note: don't try to read from uninitialized array in simulation!
   ld b, (hl)

   ;; Increment Address
   inc hl
 
   ;; Increment counter
   inc a

   ;; Repeat.  Forever.
   jr loop

org 0x8000
output:
   db 00
