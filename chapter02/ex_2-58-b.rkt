#lang sicp
(#%require "utils_symdiff.rkt")
(#%require "ex_2-58-b-utils.rkt")

; TODO
; * add: transformation (`x +`x + 5) => ((2 * `x) + 5)
; * fix: works for book example, but addition does not commute

(define (sum? x)
  (and (pair? x) (eq? (cadr x) `+)))

(define (addend s) (car s))
(define (augend s)
  (let ((out (cddr s)))
    (if (= (length out) 1)
        (car out)
        out)))

(define (make-sum . ax)
  (define (sum-iter terms symbols num-tally)
    (cond ((null? terms)
           (if (= num-tally 0)
             (if (null? symbols)
               (list 0)
               (popped symbols))
             (append symbols (list num-tally))))
          ((is-sum-operator? (car terms))
           (sum-iter (cdr terms)
                     symbols
                     num-tally))
          ((number? (car terms))
           (sum-iter (cdr terms)
                     symbols
                     (+ (car terms) num-tally)))
          ((pair? (car terms))
           (if (sum? (car terms))
               (sum-iter (cdr (append terms (car terms)))
                         symbols
                         num-tally)
               (sum-iter (cdr terms)
                         (append symbols (list (car terms) `+))
                         num-tally)))
          ((variable? (car terms))
           (sum-iter (cdr terms)
                     (append symbols (list (car terms) `+))
                     num-tally))))
  (let ((out (sum-iter ax `() 0)))
    (if (= (length out) 1)
      (car out)
      out)))

(define (product? x)
  (and (pair? x) (eq? (cadr x) `*)))

(define (multiplier m) (car m))
(define (multiplicand m)
  (let ((out (cddr m)))
    (if (= (length out) 1)
        (car out)
        out)))

(define (make-product . mx)
  (define (prod-iter terms symbols num-tally)
    (cond ((null? terms)
           (cond ((= num-tally 1)
                  (if (null? symbols)
                      (list 1)
                      (popped symbols)))
                 ((= num-tally 0) (list 0))
                 (else (append symbols (list num-tally)))))
          ((is-prod-operator? (car terms))
           (prod-iter (cdr terms)
                      symbols
                      num-tally))
          ((number? (car terms))
           (prod-iter (cdr terms)
                      symbols
                      (* (car terms) num-tally)))
          ((pair? (car terms))
           (if (product? (car terms))
               (prod-iter (cdr (append terms (car terms)))
                          symbols
                          num-tally)
               (prod-iter (cdr terms)
                          (append symbols (list (car terms) `*))
                          num-tally)))
          ((variable? (car terms))
           (prod-iter (cdr terms)
                      (append symbols (list (car terms) `*))
                      num-tally))))
  (let ((out (prod-iter mx `() 1)))
    (if (= (length out) 1)
      (car out)
      out)))

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product 
           (multiplier exp)
           (deriv (multiplicand exp) var))
          (make-product 
           (deriv (multiplier exp) var)
           (multiplicand exp))))
        (else (error "unknown expression 
                      type: DERIV" exp))))

(deriv `(x + 3 * (x + y + 2)) `x)
