(define-html-macro :home-page ((&key title (header title)) &body body)
  `(:html
     :xmlns "http://www.w3.org/1999/xhtml"
          :xml\:lang "en"
          :lang "en"
     (:head
      (:meta :http-equiv "Content-Type"
              :content    "text/html;charset=utf-8")
      ;; (:meta :charset "UTF-8")
      (:title ,title)
      ;; (:link :rel "stylesheet" :type "text/css" :href "mp3-browser.css")
      )
     (:body
      ;; (standard-header)
      (when ,header (html (:h1 :class "title" ,header)))
      ,@body
      ;; (standard-footer)
      (:script :src "htmx.js" ;; :type "text/javascript"
               ))))


;; from: practical-common-lisp/practicals/Chapter29/mp3-browser.lisp
(defun urlencode (string)
  (net.aserve::encode-form-urlencoded string))


;; from: practical-common-lisp/practicals/Chapter29/mp3-browser.lisp
(defun link (target &rest attributes)
  (html
    (:attribute
     (:format "~a~@[?~{~(~a~)=~a~^&~}~]" target (mapcar #'urlencode attributes)))))


(define-url-function home-page
    (request)
  (html
    (:home-page
     (:title "Hello" :header nil)

     (:a :hx-post "/hello?lixo=aksjdh" :hx-swap "outerHTML" "All genres")

     (:hr)

     (:button :hx-post "/hello?lixo=from_button34" :hx-swap "outerHTML" "click me")

     (:hr)

     ((:form :method "POST" :action "hello")
      (:input :name "action" :type "hidden" :value :something)
      (:input :name "submit" :type "submit" :value "Add all"))



     (:hr)

     )))


(define-url-function hello
    (request
     lixo)
  (html
    (:p (:format "hello - ~a" lixo))))


;; TODO
;; 0) missing end / in "<meta charset="UTF-8" />"
;; 1) add "<!DOCTYPE html>"
