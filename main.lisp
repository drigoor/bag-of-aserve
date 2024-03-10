(in-package #:bag-of-aserve)


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
       (:script
        (who:str
         (multiple-value-bind (nodes edges)
             (->cytoscape '("root12" ("99999APOAWaw" "sa9iis9" "12adas" "12asdiui9" "21asjkdh") "another.thing" ("12adas" "root12" "as" "asdasdasld hasudh " "09a8oyihj")))
           (cytoscape.template nodes edges))))))))







#+nil
(defun all-callees (src-symbol)
  (is-symbol-p src-symbol)
  (let* ((callees (mapcar #'first (slynk-backend:list-callees src-symbol)))
         (src (symbol-name src-symbol))
         (nodes (format nil "nodes: [~%"))
         (edges (format nil "edges: [~%")))
    (setf nodes (format nil "~a    ~a,~%" nodes (->node src)))
    (dolist (dst callees)
      (setf dst (symbol-name dst))
      (setf nodes (format nil "~a    ~a,~%" nodes (->node dst)))
      (setf edges (format nil "~a    ~a,~%" edges (->edge src dst))))
    (setf nodes (format nil "~a]" nodes))
    (setf edges (format nil "~a]" edges))
    (values nodes
            edges)))


#+nil
(defun all-callees (src-symbol)
  (is-symbol-p src-symbol)
  (let* ((callees (mapcar #'first (slynk-backend:list-callees src-symbol)))
         (src (symbol-name src-symbol))
         (nodes (format nil "nodes: [~%"))
         (edges (format nil "edges: [~%")))
    (setf nodes (format nil "~a    ~a,~%" nodes (->node src)))
    (dolist (dst callees)
      (setf dst (symbol-name dst))
      (setf nodes (format nil "~a    ~a,~%" nodes (->node dst)))
      (setf edges (format nil "~a    ~a,~%" edges (->edge src dst))))
    (setf nodes (format nil "~a]" nodes))
    (setf edges (format nil "~a]" edges))
    (values nodes
            edges)))


#+nil
(let ((src-symbol '->cytoscape))
  ;; (sort (slynk-backend:list-callees src-symbol)
  ;;       #'(lambda (x)
  ;;           ))
  (third (second (first (slynk-backend:list-callees src-symbol))))
  )


#+nil
(format t "~a~%" (multiple-value-list (all-callees "root" '("adas" "asdiui9" "asjkdh"))))


#+nil
(format t "~a~%" (multiple-value-list (all-callees '->cytoscape)))

#+nil
(mapcar #'first (slynk-backend:list-callees 'start-server))

#+nil
(all-callees 'start-server)

#+nil
(all-callees "start-server")


#+nil
(start-server)
