(asdf:defsystem #:bag-of-aserve
  :serial t
  :depends-on (#:alexandria
               #:closer-mop
               #:aserve
               #:cl-who)
  :components (;; (:module "pratical-common-lisp"
               ;;  :components ((:file "packages")
               ;;               ;; Chapter08/macro-utilities.asd
               ;;               (:file "macro-utilities" :depends-on ("packages"))
               ;;               ;; Chapter31/html.asd
               ;;               (:file "html" :depends-on ("macro-utilities"))
               ;;               (:file "css" :depends-on ("html"))
               ;;               ;; Chapter26/url-function.asd
               ;;               (:file "html-infrastructure" :depends-on ("html" "css"))))
               (:file "package")
               (:file "pratical-common-lisp")
               (:file "main")))
