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
         (error "Unknown content type for '~a'" file))))


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
