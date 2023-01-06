;;
;; This program operates in an endless loop, and increments the
;; value stored at a particular address.
;;
;; Since there is no output it is a tricky-program to test, but
;; if you're single-stepping through code, and can dump RAM then
;; it is a nice standalone example program.
;;

org 0

   ;; Set HL to the address we're going to modify.
   ld hl, output

   ;; A is zero.
   xor a,a

loop:

   ;; Increment the value of A
   inc a

   ;; Store it in the address
   ld (hl), a

   ;; Repeat.  Forever.
   jp loop

org 0x8000
output:
   db 00