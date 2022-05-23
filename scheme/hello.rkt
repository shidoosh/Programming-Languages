#lang racket

(define (expr-compare x y)
  (expr-compare1 x y '())
  )



(define (test-expr-compare x y)
  (define % #t) (equal? (eval (expr-compare x y)) x)

  )

(define (handle_binding x acc)
(cond
  [(list? x) (if (equal? (search (list-ref x 2) acc 1) (search (list-ref x 3) acc 2)) (search (list-ref x 3) acc 2) (list 'if '% (search (list-ref x 2) acc 1) (search (list-ref x 3) acc 2)))]
  [else x])
  )


(define (bind_it l acc)
(cond
  [(empty? l) '()]
  [else (append (handle_binding (car l) acc) (bind_it (cdr l) acc))])
  )

(define (search s acc id)
  (display acc)
  (cond
       [(empty? acc) s]
       
       [(and (equal? id 1) (equal? s (string->symbol (substring (car acc) 0 1)))) (car acc)]

       [(and (equal? id 2) (equal? s (string->symbol (substring (car acc) 2 3)))) (car acc)]

       [else (search s (cdr acc) id)]
       )
  )





(define (quote_handler x y l)
  (if (equal? (length x) 1)

      (if (equal? (car x) (car y))
      (list (quote quote) (car x))
      (list 'if '% (list (quote quote) (append (car x) '())) (list (quote quote) (append (car y) '())))
      )

      (if (equal? (car x) (car y))
      (list (quote quote) (car x))
      (append (list 'if '% (list (quote quote) (append (car x) '())) (list (quote quote) (append (car y) '()))) (quote_handler (cdr x) (cdr y) l))
      )
  )
)





(define (expr-compare1 x y l)
  (display "Printing l:")
  (display l)
  (cond
    [(and (empty? x) (empty? y)) '()]
    [(and (list? x) (equal? (car x) 'quote) (quote_handler (cdr x) (cdr y) l))] 
    [(and (boolean? x) (boolean? y) (equal? x y)) x ]
    [(and (boolean? x) (boolean? y) (not (equal? x y)))
                (if x '% '(not %))]
    [(and (number? x) (number? y)) (if (equal? x y) x (list 'if '% x y))]

   
    [(and (symbol? x) (symbol? y)) (if (equal? x y) x (list 'if '% x y))]
    [(or (symbol? x) (symbol? y)) (list 'if '% x y)]
    [(and (not (empty? x)) (equal? (car x) 'lambda) (equal? (car y) 'lambda)) (append '(lambda) (lambda_check x y l))]
    [(and (not (empty? x)) (equal? (car x) 'let) (equal? (car y) 'let)) (append '(let) (let_check x y l))]
    [(and (not (empty? x)) (list? (car x)) (list? (car y))) (append (list (expr-compare1 (car x) (car y) l)) (expr-compare1 (cdr x) (cdr y) l))] 

    [(equal? x y) x]

[(or (not (and (list? x) (list? y)))
         (not (= (length x) (length y)))
         (and (or (is-keyword (car x)) (is-keyword (car y))) (not (equal? (car x) (car y)))))
     (list 'if '% x y)]
    
    [(and (list? x) (list? y)) (if (equal? (length x) 1) (list (expr-compare1 (car x) (car y) l))
                                       (append (list (expr-compare1 (car x) (car y) l)) (expr-compare1 (cdr x) (cdr y) l)))]

    [(or (not (and (list? x) (list? y)))
         (not (= (length x) (length y)))
         (and (or (is-keyword (car x)) (is-keyword (car y))) (not (equal? (car x) (car y)))))
     (list 'if '% x y)]
        )
  )
   


(define (defn_handler x y)
  (if (empty? x) '()
  (append (list ( string->symbol (if (equal? (car x) (car y)) (symbol->string (car x))
                                     (string-append (string-append (symbol->string (car x)) "!") (symbol->string (car y)))))) (defn_handler (cdr x) (cdr y)))
  )
)


(define (lambda_check x y l)
  (define acc (defn_handler (car (cdr x)) (car (cdr y))))
  (define output (expr-compare1 (cdr (cdr x)) (cdr (cdr y)) acc))
  (list acc (unwrap output))
)


(define (decl a b l)
  (if (equal? (cdr a) (cdr b))
      (if (equal? (car a) (car b))
           (cons (append (list (car a)) (cdr a)) '())
           (
            cons (list(list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))) (car (cdr a))))
                 (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))) 
           )
      )
      (if (equal? (car a) (car b))
           (cons (append (list (car a)) (list (list 'if '% (car (cdr a)) (car (cdr b))))) '())
            (cons (append (list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))))
                    (list (list 'if '% (car (cdr a)) (car (cdr b))))) (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b))))
           )
      )
  )
)

(define (handle_concat x y)
  (if (empty? y) (cons '() '())
  (cons (append (car x) (car y)) (append (cdr x) (cdr y)))
  )
)
  

(define (let_defn_handler x y l)
  (if (empty? x) '()
  (handle_concat (list (decl (car x) (car y) l)) (unwrap (let_defn_handler (cdr x) (cdr y) l)))
  )
)


(define (let_check x y l)
  (define acc (let_defn_handler (car (cdr x)) (car (cdr y)) l))
  (display "Acc: ")
  (display acc)
  (display "\n")
  (define output (expr-compare1 (cdr (cdr x)) (cdr (cdr y)) l))
  (display "L: ")
  (display l)
  (display "\n")
  (define new_output (bind_it output l))
  (list acc (unwrap new_output))
)



(define (is-keyword x)
  (member x '(quote lambda let if)))


(define (unwrap lst)
  (if (null? lst)
      '()
      (my-append (car lst) (cdr lst))))

(define (my-append lhs rhs)
  (cond
    [(null? lhs)
     (unwrap rhs)]
    [(pair? lhs)
     (cons (car lhs)
           (my-append (cdr lhs) rhs))]
    [else
     (cons lhs (unwrap rhs))]))



