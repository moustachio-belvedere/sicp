#lang sicp

(define (make-vect x y)
  (cons x y))

(define (make-segment start end)
  (cons start end))

(define (start-segment segment)
  (car segment))

(define (stop-segment segment)
  (cdr segment))
