#lang racket

(define (expr-compare x y)
  (expr-compare1 x y '())
  )

(define (expr-compare1 x y l)
  (cond
    [(equal? x y) x] ;;i added 
    [(and (empty? x) (empty? y)) '()]

    [(and (boolean? x) (boolean? y))
                (if x '% '(not %))]
    [(and (number? x) (number? y)) (if (equal? x y) (list x) (list (list 'if '% x y)))]
    [(and (symbol? x) (symbol? y)) (if (equal? x y) (list x) (list (list 'if '% x y)))]
    [(or (symbol? x) (symbol? y)) (list 'if '% x y)]
        [(and (not (empty? x)) (equal? (car x) 'lambda) (equal? (car y) 'lambda)) (append '(lambda) (lambda_check x y l))]
        [(and (not (empty? x)) (equal? (car x) 'let) (equal? (car y) 'let)) (append '(let) (let_check x y l))]
        [(and (not (empty? x)) (list? (car x)) (list? (car y))) (append (expr-compare1 (car x) (car y) l) (expr-compare1 (cdr x) (cdr y) l))] 

       
        [(and (list? x) (list? y)) (if (equal? (length x) 1) (expr-compare1 (car x) (car y) l)
                                       (append (expr-compare1 (car x) (car y) l) (expr-compare1 (cdr x) (cdr y) l)))]
        )


  )
   


(define (defn_handler x y)
  (if (empty? x) '()
  (append (list ( string->symbol (if (equal? (car x) (car y)) (symbol->string (car x)) (string-append (string-append (symbol->string (car x)) "!") (symbol->string (car y)))))) (defn_handler (cdr x) (cdr y)))
  )
)

;;
(define (lambda_check x y l)
  (define acc (defn_handler (car (cdr x)) (car (cdr y))))
  (list acc)
  (define output (expr-compare1 (cdr (cdr x)) (cdr (cdr y)) acc))
  (display "Printing output:")
  (list output)
  (display output)
  (display "Finished output")
  (list acc output)
)

(define (decl a b l)
  (if (equal? (cdr a) (cdr b))
      (if (equal? (car a) (car b))
           (append (list (car a)) (cdr a))
           (;(append l (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b))))
            list(list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))) (cdr a)
           ))
           )
      (if (equal? (car a) (car b))
           (append (list (car a)) (list (list 'if '% (car (cdr a)) (car (cdr b)))))
           ((append l (list (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car a)))))
            (list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))) (cdr a))
           )
           )
      )
  )


(define (let_defn_handler x y l)
  (if (empty? x) '()
  (append (decl (car x) (car y) l) (let_defn_handler (cdr x) (cdr y) l))
  )
)


(define (let_check x y l)
  (define acc (let_defn_handler (car (cdr x)) (car (cdr y)) l))
  (display "what acc ")
  (display acc)
  (display "<== acc")
  (define output (expr-compare1 (cdr (cdr x)) (cdr (cdr y)) acc))
  (display "Printing output:")
  (display output)
  (display "Finished output")
  (list (list acc) output)
)




(define (keyword? x)
  (member x '(quote lambda let if)))

(define (let-vars x)
  (map car (car (cdr x))))











