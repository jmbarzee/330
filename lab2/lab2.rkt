#lang racket
(provide check-temps1)
(provide check-temps)
(provide convert)
(provide duple)
(provide average)
(provide convertFC)
(provide eliminate-larger)
(provide get-nth)
(provide find-item)

(define (check-temps1 temps)
  (check-temps temps 5 95))

(define (check-temps temps low high)
  (cond
    [(empty? temps) #t]
    [(or (< (first temps) low) (> (first temps) high)) #f]
    [else (check-temps (rest temps) low high)]))

(define (convert digits [power 1])
  (if (empty? digits)
    0
    (+
      (* power (first digits))
      (convert (rest digits) (* power 10)))))

(define (duple lst)
  (if (empty? lst)
    empty
    (append
      (list (list (first lst) (first lst)))
      (duple (rest lst)))))

(define (average lst [rec #f])
  (cond
    [(empty? lst) 0]
    [else
      (define total (+
        (first lst)
        (average (rest lst) #t)))
      (if rec
        total
        (/ total (length lst)))]))

(define (convertFC temps)
  (cond
    [(empty? temps) empty]
    [else
      (append
        (list (convertOneFC (first temps)))
        (convertFC (rest temps)))]))

(define (convertOneFC temp)
  (*
    (- temp 32)
    (/ 5 9)))

(define (eliminate-larger lst)
  (if (empty? lst)
    empty
    (reverse
      (append
        (list (first (reverse lst)))
        (eliminate-largerR
          (rest (reverse lst))
          (first (reverse lst)))))))

(define (eliminate-largerR lst lwst)
  (cond
    [(empty? lst) empty]
    [else
      (cond
        [(> (first lst) lwst)
          (eliminate-largerR (rest lst) lwst)]
        [else
          (append
            (list (first lst))
            (eliminate-largerR (rest lst) (first lst)))])]))

(define (get-nth lst n)
  (if (zero? n)
    (first lst)
    (get-nth
      (rest lst)
      (- n 1))))

(define (find-item lst target)
  (cond
    [(empty? lst) -1]
    [(= target (first lst)) 0]
    [else
     (define rslt (find-item (rest lst) target))
     (if (= rslt -1)
       -1
       (+ rslt 1))]))