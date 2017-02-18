#lang racket
(define (sum-coins pennies nickels dimes quarters)
  (+ pennies
     (* nickels 5)
     (* dimes 10)
     (* quarters 25)
   )
)   
(define (degrees-to-radians angle)
  (* angle (/ pi 180))
)
(define (sign x)
  (cond
    ((equal? x 0) 0)
    ((positive? x) 1)
    (else -1)
  )
)
(define (new-sin angle type)
  (cond
    ((symbol=? type 'degrees)
      (sin (degrees-to-radians angle)))
    (else
      (sin angle))
  )
)