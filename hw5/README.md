# Homework 5. Scheme code difference analyzer
### Editor's note: This submission is incomplete, and does not perform to spec. 
## The problem
Your employer Litigious Data Analysts Inc. (LDA) is suing Software Verification Modules Inc. (SVM), claiming that SVM stole large bodies of LDA's code and incorporated it into their data mining product, while renaming identifiers to try to hide the fact that the code was stolen, and also making other minor changes. As part of the legal discovery process, LDA has obtained copies of SVM's data miner and wants to compare it to LDA's to find evidence of unauthorized copying. About 5% of both data miners are written in Scheme. Your team has been assigned the job of comparing the Scheme parts.

Your boss suggested that you prototype a procedure expr-compare that compares two Scheme expressions x and y, and produces a difference summary of where the two expressions are the same and where they differ. Your boss wants the difference summary to be easily checkable, in case there is a bug in expr-compare itself. So you decide to have the difference summary also be a Scheme expression which, if executed in an environment where the Scheme variable % is true, has the same behavior as x, and otherwise has the same behavior as y. You want the summary expression to use the same identifiers as the two input expressions where they agree, and that if x declares the bound variable X in the same place where y declares the bound variable Y, the summary expression should declare a bound variable X!Y and use it consistently thereafter wherever the input expressions use X and Y respectively. (A bound variable is one that is declared in an expression by a binding construct such as let or lambda.)

To keep things simple your prototype need not handle arbitrary Scheme expressions; it can be limited to the Scheme subset that consists of constant literals, variable references, procedure calls, the special form (quote datum), the special form (lambda formals body) where body consists of a single expression, the special form (let bindings body) where body consists of a single expression, and the special-form conditional (if expr expr). To avoid confusion the input Scheme expressions cannot contain any symbols which contain the % or ! characters. Your prototype need not check that its inputs are valid; it can have undefined behavior if given inputs outside the specified subset.

Assignment
First, write a Scheme procedure (expr-compare x y) that implements the specification described above. Your implementation must be free of side effects; for example you cannot use the set! special form. Returned values should share storage with arguments when possible; they should not copy their arguments.

The output expression should use if expressions and identifiers containing ! to represent differences whenever the two input expressions disagree, attempting to minimize the size of the subexpressions under the generated ifs. As a special case, it should use % to represent a subexpression that is #t in LDA's version and #f in SVM's version, and should use (not %) to represent the reverse situation. Here are some examples and what they should evaluate to.

(expr-compare 12 12)  ⇒  12
(expr-compare 12 20)  ⇒  (if % 12 20)
(expr-compare #t #t)  ⇒  #t
(expr-compare #f #f)  ⇒  #f
(expr-compare #t #f)  ⇒  %
(expr-compare #f #t)  ⇒  (not %)
(expr-compare 'a '(cons a b))  ⇒  (if % a (cons a b))
(expr-compare '(cons a b) '(cons a b))  ⇒  (cons a b)
(expr-compare '(cons a b) '(cons a c))  ⇒  (cons a (if % b c))
(expr-compare '(cons (cons a b) (cons b c))
              '(cons (cons a c) (cons a c)))
  ⇒ (cons (cons a (if % b c)) (cons (if % b a) c))
(expr-compare '(cons a b) '(list a b))  ⇒  ((if % cons list) a b)
(expr-compare '(list) '(list a))  ⇒  (if % (list) (list a))
(expr-compare ''(a b) ''(a c))  ⇒  (if % '(a b) '(a c))
(expr-compare '(quote (a b)) '(quote (a c)))  ⇒  (if % '(a b) '(a c))
(expr-compare '(quoth (a b)) '(quoth (a c)))  ⇒  (quoth (a (if % b c)))
(expr-compare '(if x y z) '(if x z z))  ⇒  (if x (if % y z) z)
(expr-compare '(if x y z) '(g x y z))
  ⇒ (if % (if x y z) (g x y z))
(expr-compare '(let ((a 1)) (f a)) '(let ((a 2)) (g a)))
  ⇒ (let ((a (if % 1 2))) ((if % f g) a))
(expr-compare '(let ((a c)) a) '(let ((b d)) b))
  ⇒ (let ((a!b (if % c d))) a!b)
(expr-compare ''(let ((a c)) a) ''(let ((b d)) b))
  ⇒ (if % '(let ((a c)) a) '(let ((b d)) b))
(expr-compare '(+ #f (let ((a 1) (b 2)) (f a b)))
              '(+ #t (let ((a 1) (c 2)) (f a c))))
  ⇒ (+
     (not %)
     (let ((a 1) (b!c 2)) (f a b!c)))
(expr-compare '((lambda (a) (f a)) 1) '((lambda (a) (g a)) 2))
  ⇒ ((lambda (a) ((if % f g) a)) (if % 1 2))
(expr-compare '((lambda (a b) (f a b)) 1 2)
              '((lambda (a b) (f b a)) 1 2))
  ⇒ ((lambda (a b) (f (if % a b) (if % b a))) 1 2)
(expr-compare '((lambda (a b) (f a b)) 1 2)
              '((lambda (a c) (f c a)) 1 2))
  ⇒ ((lambda (a b!c) (f (if % a b!c) (if % b!c a)))
     1 2)
(expr-compare '(let ((a (lambda (b a) (b a))))
                 (eq? a ((lambda (a b) (let ((a b) (b a)) (a b)))
                         a (lambda (a) a))))
              '(let ((a (lambda (a b) (a b))))
                 (eqv? a ((lambda (b a) (let ((a b) (b a)) (a b)))
                          a (lambda (b) a)))))
  ⇒ (let ((a (lambda (b!a a!b) (b!a a!b))))
      ((if % eq? eqv?)
       a
       ((lambda (a!b b!a) (let ((a (if % b!a a!b) (b (if % a!b b!a))) (a b)))
        a (lambda (a!b) (if % a!b a))))
(When testing your code, please note that Racket read–eval–print loop quotes its results unless they are self-quoting, so that, for example, although 12 prints as itself, (if % 12 20) prints as '(if % 12 20).)

Second, write a Scheme procedure (test-expr-compare x y) that tests your implementation of expr-compare by using eval to evaluate the expression x, and to evaluate the expression returned by (expr-compare x y) in the same context except with % bound to #t, and which checks that the two expressions yield the same value. Similarly, it should check that y evaluates to the same value that the output of expr-compare evaluates to with % bound to #f. The test-expr-compare function should return a true value if both tests succeed, and #f otherwise.

Third, define two Scheme variables test-expr-x and test-expr-y that contain data that can be interpreted as Scheme expressions that test expr-compare well. Your definitions should look like this:

(define test-expr-x '(+ 3 (let ((a 1) (b 2)) (list a b))))
(define test-expr-y '(+ 2 (let ((a 1) (c 2)) (list a c))))
except that your definitions should attempt to exercise all the specification in order to provide a single test case for this complete assignment.
