;;; lib-aux.sls --- Auxiliary code for library declarations

(library (lib-aux)
  (export check-arg
          define-aux-symbol
          define-aux-symbols)
  (import (rnrs))

  ;; `check-arg' is used by some SRFIs (e.g., 1 and 13)
  (define-syntax check-arg
    (syntax-rules ()
      ((_ pred val caller)
       val)))

  ;; These 2 syntax definitions originate from this commentary:
  ;; <https://github.com/cisco/ChezScheme/issues/41#issuecomment-218771556>.
  ;; They are also used by Federico Beffa:
  ;; <https://github.com/fedeinthemix/chez-srfi/blob/master/srfi/private/aux-keywords.sls>,
  ;; <https://github.com/fedeinthemix/chez-matchable/blob/master/matchable.sls>.
  (define-syntax define-aux-symbol
    (syntax-rules ()
      ((_ name)
       (define-syntax name
         (lambda (x)
           (syntax-violation #f "misplaced use of auxiliary symbol" x))))))

  (define-syntax define-aux-symbols
    (syntax-rules ()
      ((_ name ...)
       (begin (define-aux-symbol name) ...)))))

;;; lib-aux.sls ends here
