(asdf:defsystem #:bag-of-aserve
  :serial t
  :depends-on (#:alexandria
               #:aserve
               #:cl-who)
  :components ((:file "package")
               (:file "pratical")
               (:file "server")
               (:file "cytoscape")
               (:file "main")))
