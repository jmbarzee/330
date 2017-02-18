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
  (if (empty? temps)
    #t
    (andmap
      (lambda (temp)
        (not (or
          (< temp low)
          (> temp high))))
      temps)))



(define (convert digits)
  (define power 1)
  (foldl
    (lambda (elem v)
      (set! power (* power 10))
      (+ v (* elem (/ power 10))))
    0
    digits))

(define (duple lst)
  (map
   (lambda (val)
     (list val val))
   lst))

(define (average lst)
  (if (zero? (length lst))
    0
    (/ (total lst) (length lst))))


(define (total lst)
  (foldl
    (lambda (elem v)
      (+ v elem))
    0
    lst))

(define (convertFC temps)
  (map
    convertOneFC
    temps))

(define (convertOneFC temp)
  (*
    (- temp 32)
    (/ 5 9)))

(define (eliminate-larger lst)
  (cond
    [(empty? lst) empty]
    [else
      (define lowest (first (reverse lst)))
      (reverse (foldl
        (lambda (elem val)
          (cond
            [(> elem lowest) val]
            [else
              (define lowest elem)
              (append val (list elem))]))
        (list (first (reverse lst)))
        (rest (reverse lst))))]))


(define (get-nth lst n)
  (cond
    [(empty? lst) -1]
    [else
      (foldl
        (lambda (elem v)
          (cond
            [(not (equal? -1 v)) v]
            [(zero? n) elem]
            [else (set! n (- n 1)) -1]))
        -1
        lst)]))

(define (find-item lst target)
  (define pos -1)
  (foldl
   (lambda (elem v)
     (set! pos (add1 pos))
     (cond
       [(not (equal? -1 v)) v]
       [(equal? elem target) pos]
       [else -1]))
   pos
   lst))

(define (curry2 f)
  (lambda (ar1)
    (lambda (ar2)
      (f ar1 ar2))))