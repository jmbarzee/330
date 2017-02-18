#lang racket

(require test-engine/racket-tests)
(require "lab2.rkt")

(check-expect
  (check-temps1 (list 3 4 5)) #f)
(check-expect
  (check-temps1 (list 4 5 6)) #f)
(check-expect
  (check-temps1 (list 5 6 7)) #t)
(check-expect
  (check-temps1 (list 93 94 95)) #t)
(check-expect
  (check-temps1 (list 94 95 96)) #f)
(check-expect
  (check-temps1 (list 95 96 97)) #f)
(check-expect
  (check-temps1 (list -1 0 1)) #f)
(check-expect
  (check-temps1 (list -100 0 100)) #f)
(check-expect
  (check-temps1 (list 5 6 7 8 9 10 90 91 92 93 94 95)) #t)
(check-expect
  (check-temps1 empty) #t)


(check-expect
  (convert (list 1)) 1)
(check-expect
  (convert (list 1 2 3)) 321)
(check-expect
  (convert (list 1 2 3 4 5)) 54321)
(check-expect
  (convert (list 5 4 3 2 1)) 12345)
(check-expect
  (convert (list 5 4 3)) 345)
(check-expect
  (convert (list 5)) 5)
(check-expect
  (convert empty) 0)
(check-expect
  (convert (list 1 0 1)) 101)
(check-expect
  (convert (list 1 0 1 0 1)) 10101)
(check-expect
  (convert (list 1 0 0 0 1)) 10001)
(check-expect
  (convert (list 1 0 1 0 1 0 1 0 1)) 101010101)


(check-expect
  (duple (list 1 2 3)) (list (list 3 3) (list 2 2) (list 1 1)))
(check-expect
  (duple (list 1 2)) (list (list 2 2) (list 1 1)))
(check-expect
  (duple (list 1)) (list (list 1 1)))
(check-expect
  (duple empty) empty)


(check-expect
  (average empty) 0)
(check-expect
  (average (list 1 2 3)) (/ 6 3))
(check-expect
  (average (list 1 2 3 4)) (/ 10 4))
(check-expect
  (average (list 1 2 3 4 5)) (/ 15 5))
(check-expect
  (average (list 0 1 2 3 4 5 6 7 8 9 10 11)) (/ 66 12))


(check-expect
  (convertFC empty) empty)
(check-expect
  (convertFC (list 32 212)) (list 0 100))


(check-expect
  (eliminate-larger empty) empty)
(check-expect
  (eliminate-larger (list 1)) (list 1))
(check-expect
  (eliminate-larger (list 1 2 3 4 5)) (list 1 2 3 4 5))
(check-expect
  (eliminate-larger (list 5 1 2 3 4)) (list 1 2 3 4))
(check-expect
  (eliminate-larger (list 2 3 4 5 1)) (list 1))


(check-expect
  (get-nth (list 1 2 3 4 5) 0) 1)
(check-expect
  (get-nth (list 1 2 3 4 5) 1) 2)
(check-expect
  (get-nth (list 1 2 3 4 5) 2) 3)
(check-expect
  (get-nth (list 1 2 3 4 5) 3) 4)
(check-expect
  (get-nth (list 1 2 3 4 5) 4) 5)


(check-expect
  (find-item empty 1) -1)
(check-expect
  (find-item (list 1 2 3 4 5) 1) 0)
(check-expect
  (find-item (list 1 2 3 4 5) 2) 1)
(check-expect
  (find-item (list 1 2 3 4 5) 3) 2)
(check-expect
  (find-item (list 1 2 3 4 5) 4) 3)
(check-expect
  (find-item (list 1 2 3 4 5) 5) 4)
(check-expect
  (find-item (list 1 2 3 4 5) 0) -1)


(test)