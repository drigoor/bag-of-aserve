(in-package #:bag-of-aserve)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Chapter08/macro-utilities.asd
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (defmacro with-gensyms ((&rest names) &body body)
;;   `(let ,(loop for n in names collect `(,n (make-symbol ,(string n))))
;;      ,@body))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Chapter26/html-infrastructure.lisp
;;; Chapter29/mp3-browser.lisp
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime

(defgeneric string->type (type value))

(defmethod string->type ((type (eql 'string)) value)
  (and (plusp (length value)) value))

(defmethod string->type ((type (eql 'integer)) value)
  (parse-integer (or value "") :junk-allowed t))

(defmethod string->type ((type (eql 'keyword)) value)
  (and (plusp (length value)) (intern (string-upcase value) :keyword)))

(defun get-cookie-value (request name)
  (cdr (assoc name (get-cookie-values request) :test #'string=)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Compiler code

(defun normalize-param (param)
  (etypecase param
    (list param)
    (symbol `(,param string nil nil))))

(defun param-bindings (function-name request params)
  (loop for param in params
        collect (param-binding function-name request param)))

(defun param-binding (function-name request param)
  (destructuring-bind (name type &optional default sticky) param
    (let ((query-name (symbol->query-name name))
          (cookie-name (symbol->cookie-name function-name name sticky)))
      `(,name (or
               (string->type ',type (request-query-value ,query-name ,request))
               ,@(if cookie-name
                     (list `(string->type ',type (get-cookie-value ,request ,cookie-name))))
               ,default)))))

(defun symbol->query-name (sym)
  (string-downcase sym))

(defun symbol->cookie-name (function-name sym sticky)
  (let ((package-name (package-name (symbol-package function-name))))
    (when sticky
      (ecase sticky
        (:global
         (string-downcase sym))
        (:package
         (format nil "~(~a:~a~)" package-name sym))
        (:local
         (format nil "~(~a:~a:~a~)" package-name function-name sym))))))

(defun set-cookies-code (function-name request params)
  (loop for param in params
        when (set-cookie-code function-name request param) collect it))

(defun set-cookie-code (function-name request param)
  (destructuring-bind (name type &optional default sticky) param
    (declare (ignore type default))
    (if sticky
      `(when ,name
         (set-cookie-header
          ,request
          :name ,(symbol->cookie-name function-name name sticky)
          :value (princ-to-string ,name))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; API

;; (defmacro define-url-function (name (request &rest params) &body body)
;;   (with-gensyms (entity stream)
;;     (let ((params (mapcar #'normalize-param params)))
;;       `(progn
;;          (defun ,name (,request ,entity)
;;            (with-http-response (,request ,entity :content-type "text/html")
;;              (let* (,@(param-bindings name request params))
;;                ,@(set-cookies-code name request params)
;;                (with-http-body (,request ,entity)
;;                  (let ((,stream (request-reply-stream ,request)))
;;                    (who:with-html-output (,stream nil :prologue t :indent t)
;;                      ,@body))))))
;;          (publish :path ,(if (string= (symbol-name name) "INDEX")
;;                              "/"
;;                              (format nil "/~(~a~)" name))
;;                   :function ',name)))))


(defvar *http-stream* nil) ; dynamically binded in `define-url-function'


(defmacro html* (&body body)
  `(who:with-html-output (*http-stream* nil :prologue t :indent t)
     ,@body))


(defmacro htm* (&body body)
  `(who:with-html-output (*http-stream* nil :prologue nil :indent t)
     ,@body))


(defmacro define-url-function (name (request &rest params) &body body)
  (with-gensyms (entity)
    (let ((params (mapcar #'normalize-param params)))
      `(progn
         (defun ,name (,request ,entity)
           (with-http-response (,request ,entity :content-type "text/html")
             (let* (,@(param-bindings name request params))
               ,@(set-cookies-code name request params)
               (with-http-body (,request ,entity)
                 (let ((*http-stream* (request-reply-stream ,request)))
                   ,@body)))))
         (publish :path ,(if (string= (symbol-name name) "INDEX")
                             "/"
                             (format nil "/~(~a~)" name))
                  :function ',name)))))
