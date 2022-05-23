
;;var!var not fully functional :(

(define (expr-compare x y)
  (expr-compare1 x y '())
  )



(define (test-expr-compare x y)
  (and (equal? (eval (list 'let '(('% #t)) (expr-compare x y))) (eval x))
       (equal? (eval (list 'let '(('% #f)) (expr-compare x y)))(eval y))))


(define test-expr-x 
 '(let ((a 4) (b 3))
    (list
      (- 9 3)
      '(#f #f #f)
      (cons (+ b a) (list 1 3 4))
      (if b a #f)
      (let ((h 10) (i 12)) (+ h y))
      (let ((j 1) (k 2)) (- j s))
      (quote (#t b))
      (quote (a))
      ((lambda (c d) (+ c d)) a 4)
      ((lambda (e f) (- e f)) b 4)
    )
  )
)

(define test-expr-y
 '(let ((a 4) (b 2))
    (list
      (list (- b a) (list 7 8 9))
      (if b a #f)
      ((lambda (x y) (+ x y)) b 4)
      ((lambda (z g) (- z g)) a 4)
    )
  )
)



(define (search s acc id)
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
         (and (or (keyword? (car x)) (keyword? (car y))) (not (equal? (car x) (car y)))))
     (list 'if '% x y)]
    
    [(and (list? x) (list? y)) (if (equal? (length x) 1) (list (expr-compare1 (car x) (car y) l))
                                       (append (list (expr-compare1 (car x) (car y) l)) (expr-compare1 (cdr x) (cdr y) l)))]

    [(or (not (and (list? x) (list? y)))
         (not (= (length x) (length y)))
         (and (or (keyword (car x)) (keyword? (car y))) (not (equal? (car x) (car y)))))
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
           (append (list (car a)) (cdr a))
           (
            list(list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))) (car (cdr a))))
           )
      (if (equal? (car a) (car b))
           (append (list (car a)) (list (list 'if '% (car (cdr a)) (car (cdr b)))))
            (append (list (string->symbol (string-append (string-append (symbol->string (car a)) "!") (symbol->string (car b)))))
                    (list (list 'if '% (car (cdr a)) (car (cdr b)))))
           )
      )
  )


(define (let_defn_handler x y l)
  (if (empty? x) '()
  (append (list (decl (car x) (car y) l)) (unwrap (let_defn_handler (cdr x) (cdr y) l)))
  )
)


(define (let_check x y l)
  (define acc (let_defn_handler (car (cdr x)) (car (cdr y)) l))
  (define output (expr-compare1 (cdr (cdr x)) (cdr (cdr y)) acc))
  (list acc (unwrap output))
)



(define (keyword? x)
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
