#lang racket
(define (default-parms f values)
  (lambda args
    (if (eqv? (length args) (length values))
        (apply f args)
        (apply f (append args
                         (list-tail values
                                    (length args)))))))

(define (type-parms f types)
  (lambda args
    (apply f
           (map (lambda (pairing)
                  (if (not ((second pairing) (first pairing)))
                      (error "Types don't match! D:")
                      (first pairing)))
                (zip args types)))))

(define zip ;zup zoop
  (lambda (l1 l2)
    (map list l1 l2)))

(define (dToR angle)
  (* (/ angle 180) pi))

(define (newSin angle measure)
  (if (symbol=? measure 'degrees)
      (sin (dToR angle))
      (sin angle)))

(define new-sin2 (default-parms
                   (type-parms
                    newSin
                    (list number? symbol?))
                   (list 0 'radians)))