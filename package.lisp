(in-package #:cl)


(defpackage #:bag-of-aserve
  (:use #:cl
        #:alexandria
        #:net.aserve
        #:cl-who
        ;; #:com.gigamonkeys.macro-utilities
        ;; #:com.gigamonkeys.html
        ;; #:com.gigamonkeys.url-function
        )
  (:export #:start-bag))
