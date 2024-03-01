(asdf:defsystem #:bag-of-aserve
  :serial t
  :depends-on (#:alexandria
               #:aserve
               #:cl-who)
  :components ((:file "package")
               (:file "pratical-common-lisp")
               (:file "main")))
