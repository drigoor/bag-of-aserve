(in-package #:bag-of-aserve)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; From 'Pratical Common Lisp' book
;;;
;;; Chapter26/html-infrastructure.lisp
;;; Chapter29/mp3-browser.lisp
;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime


(defgeneric string->type (type value))


(defmethod string->type ((type (eql 'string)) value)
  (and (plusp (length value)) value))


(defmethod string->type ((type (eql 'integer)) value)
  (parse-integer (or value "") :junk-allowed t))


(defmethod string->type ((type (eql 'keyword)) value)
  (and (plusp (length value)) (intern (string-upcase value) :keyword)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Compiler code


(defun symbol->query-name (sym)
  (string-downcase sym))


(defun normalize-param (param)
  (etypecase param
    (list param)
    (symbol `(,param string nil nil))))


(defun param-binding (request param)
  (destructuring-bind (name type &optional default) param
    (let ((query-name (symbol->query-name name)))
      `(,name (or (string->type ',type (net.aserve:request-query-value ,query-name ,request))
                  ,default)))))


(defun param-bindings (request params)
  (loop for param in params
        collect (param-binding request param)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; different from 'pratical common lisp' book (support cl-who)


;; dynamically binded in `define-url-function', and used in `html*' and `htm*'
(defvar *http-stream* nil)


;; full html page with `DOCTYPE'
(defmacro html* (&body body)
  `(who:with-html-output (*http-stream* nil :prologue t :indent t)
     ,@body))


;; to construct simple html responses
(defmacro htm* (&body body)
  `(who:with-html-output (*http-stream* nil :prologue nil :indent nil)
     ,@body))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; API


;;; different from 'pratical common lisp' book:
;;;    + no support for cookies (as the original)
;;;    + now `index' name is a special case to support "/"
;;;    + it now uses cl-who:
;;;        - the html is required to be called in the caller
;;;        - it uses the dynamic binding of the var *http-stream*
;;;          (see `html*' and `htm*')
(defmacro define-url-function (name (request &rest params) &body body)
  (alexandria:with-gensyms (entity)
    (let ((params (mapcar #'normalize-param params)))
      `(progn
         (defun ,name (,request ,entity)
           (net.aserve:with-http-response (,request ,entity :content-type "text/html")
             (let* (,@(param-bindings request params))
               (net.aserve:with-http-body (,request ,entity)
                 (let ((*http-stream* (net.aserve:request-reply-stream ,request)))
                   ,@body)))))
         (net.aserve:publish :path ,(if (string= (symbol-name name) "INDEX")
                                        "/"
                                        (format nil "/~(~a~)" name))
                             :function ',name)))))
