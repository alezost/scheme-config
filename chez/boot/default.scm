;;; default.scm --- Initialization file to modify SRFI libraries location

;; (compile-imported-libraries #f)  ; default
(generate-wpo-files #t)

(library-search-handler
 ;; I keep SRFI libraries in "srfi-N.sls" files, not in ":N.sls" files,
 ;; so make Chez find them.
 (lambda (who library directories extensions)
   (let ((lib (if (and (list? library)
                       (eq? (car library) 'srfi))
                ;; Convert ":N" symbol to "srfi-N" symbol.
                (let* ((name (symbol->string (cadr library)))
                       (num  (substring name 1 (string-length name)))
                       (new-name (string->symbol
                                  (string-append "srfi-" num))))
                  (list 'srfi new-name))
                library)))
     (default-library-search-handler who lib directories extensions))))

;;; default.scm ends here
