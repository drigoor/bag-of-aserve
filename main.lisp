(in-package #:bag-of-aserve)


(setf (who:html-mode) :html5)


(defparameter *cwd*
  "d:/projects/lisp/bag-of-aserve")


(defparameter *static-data*
  '("bulma.css"
    "htmx.js"
    "cytoscape.js"
    "styles.css"
    "cytoscape-dagre.js"
    "dagre.js"))


(defun retv-content-type (file)
  (cond ((search ".css" file)
         "text/css")
        ((search ".js" file)
         "text/javascript")
        (t
         (error "Unknown content type for ~a" file))))


(defun publish-static-data (data data-pathname)
  (loop for path in data
        do (net.aserve:publish-file :path (concatenate 'string "/vendor/" path)
                                    :content-type (retv-content-type path)
                                    :file (concatenate 'string data-pathname "/static/" path))))


(defun start-server (&key (port 9090) (static-data *static-data*) (cwd *cwd*))
  (net.aserve:publish-file :path "/favicon.ico" :file (concatenate 'string cwd "/favicon.png") :content-type "image/png")
  (publish-static-data static-data cwd)
  (net.aserve::debug-on :notrap)
  (net.aserve:start :port port))


(define-url-function index (request)
  (html*
    (:html
      (:head
       (:meta :charset "utf-8")
       (:meta :name "viewport" :content "width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1")
       (:link :rel "icon" :type "image/png" :href "/favicon.ico")
       (:script :src "/vendor/cytoscape.js" :type "text/javascript")
       (:link :rel "stylesheet" :href "/vendor/styles.css")
       (:script :src "/vendor/dagre.js" :type "text/javascript")
       (:script :src "/vendor/cytoscape-dagre.js" :type "text/javascript")
       (:link :rel "stylesheet" :href "/vendor/bulma.css")
       (:script :src "/vendor/htmx.js" :type "text/javascript"))
      (:body
       (:div :id "cy")
       (:script (cl-who::str (uiop:read-file-string (concatenate 'string *cwd* "/code2.js"))))))))


#+nil
(start-server)
