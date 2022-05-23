#lang racket
;; returns a list for diff output between TCP and UDP
(define (if-TCP-template tcp udp)
  (cons 'if (cons '% (cons tcp (cons udp '())))))

;; compares two things as if they are constants
;; other than the first equal?, it does not recursively check between x and y
;; used as a fallback if we can't match it to a list or special form
(define (compare-constants x y)
  (if (equal? x y)
      x
      (if (and (eq? x #t) (eq? y #f))
	  '%
	  (if (and (eq? x #f) (eq? y #t))
	      '(not %)
	      (if-TCP-template x y)))))

;; compares lists one element at a time
;; only works if x and y are same length
(define (compare-lists x y)
  (if (equal? x '())
      '()
      (if (equal? y '())
	  '()
	  (cons (expr-compare (car x) (car y)) (compare-lists (cdr x) (cdr y))))))

;; returns true if either x or y is a list of if, quote, lambda, let
(define (is-special-forms x y)
  (if (or (equal? (car x) 'if) (equal? (car y) 'if))
      #t
      (if (or (equal? (car x) 'quote) (equal? (car y) 'quote))
	  #t
	  (if (or (equal? (car x) 'lambda) (equal? (car y) 'lambda))
	      #t
	      (if (or (equal? (car x) 'let) (equal? (car y) 'let))
		  #t
		  #f)))))

;; quote is simple and treats the datum as a constant
(define (compare-quotes x y)
  (compare-constants x y))

;; for lambda, if the formals are the same we treat the body as a list
;; otherwise, the whole lambda expression is a constant
(define (compare-lambda x y)
  (if (equal? (car (cdr x)) (car (cdr y)))
      (compare-lists x y)
      (compare-constants x y)))

;; checks to see if two lets bind the same variables
;; values don't matter as they'll be checked elsewhere
(define (same-let-binding x y)
  (if (and (equal? x '()) (equal? y '()))
      #t
      (if (equal? (car (car x)) (car (car y)))
	  (same-let-binding (cdr x) (cdr y))
	  #f)))
	   

;; similar to lambda. if binding is same, compare as a list.
;; otherwise we treat the whole expression as a constant
(define (compare-let x y)
  (if (same-let-binding (car (cdr x)) (car (cdr y)))
      (compare-lists x y)
      (compare-constants x y)))



;; uses compare-constants to compare x and y unless they are lists of the same length
;; we also check for special cases for special forms that we define above
;; all it does it check when to apply compare-constants or compare-lists
(define (expr-compare x y)
  (if (and (list? x) (list? y))
      (if (eq? (length x) (length y))
	  (if (eq? (car x) (car y))
	      (case (car x)
		('quote (compare-quotes x y))
		('lambda (compare-lambda x y))
		('let (compare-let x y))
		(else (compare-lists x y)))
	      (if (is-special-forms x y)
		  (compare-constants x y)
		  (compare-lists x y)))
	  (compare-constants x y))
      (compare-constants x y)))


(define (myfunc x y)
  (cond
    [(and (equal? (caaadr x) (caddr x)) (equal? (caaadr y) (caddr y))) (string-join (map symbol->string (list (caaadr x)'!(caaadr y))))]
    ))