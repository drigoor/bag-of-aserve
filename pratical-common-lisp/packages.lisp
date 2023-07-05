(in-package :cl-user)


;; Chapter08
(defpackage :com.gigamonkeys.macro-utilities
  (:use :common-lisp)
  (:export
   :with-gensyms
   :with-gensymed-defuns
   :once-only
   :spliceable
   :ppme))


;; Chapter31
(defpackage :com.gigamonkeys.html
  (:use :common-lisp :com.gigamonkeys.macro-utilities)
  (:export :with-html-output
           :with-html-to-file
           :in-html-style
           :define-html-macro
           :define-css-macro
           :css
           :html
           :emit-css
           :emit-html
           :&attributes))


;; Chapter26
(defpackage :com.gigamonkeys.url-function
  (:use :common-lisp
        :net.aserve
        :com.gigamonkeys.html
        :com.gigamonkeys.macro-utilities)
  (:export :define-url-function
           :string->type))
