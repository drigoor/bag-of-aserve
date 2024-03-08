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


#+nil
(start-server)


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
       (:script :src "/vendor/htmx.js" :type "text/javascript")
       )

      (:body
       (:div :id "cy")
       (:script
        (cl-who::str (uiop:read-file-string
                      (concatenate 'string *cwd* "/code2.js")
                      ;; (uiop:merge-pathnames* "code2.js" *cwd*)
                      )))

       ;; (:section :class "section"
       ;;           (:div :hx-post "/new-graph"
       ;;                :hx-trigger "click, myEvent from:body"
       ;;                :hx-target "#parent-div"
       ;;                :hx-swap "outerHTML"
       ;;                "Click Me!")
       ;;          (:div :id "parent-div")
       ;;
       ;;          (:button :id "myBtn" "Try it")
       ;;
       ;;          (:button :hx-post "/new-graph" :hx-swap "outerHTML" "click me"
       ;;                   ;; :hx-trigger ""
       ;;                   )
       ;;          )
       ))
    ))




;; https://stackoverflow.com/questions/73389202/how-to-execute-javascript-code-after-htmx-makes-an-ajax-request

;; https://marcus-obst.de/blog/htmx-json-handling


;; ;; from: https://www.reddit.com/r/htmx/comments/10sdk43/how_can_i_assign_an_hxget_response_to_a/
;; (define-url-function new-graph (request)
;;   (htm*
;;     "<script id=\"data\" type=\"application/json\">{\"foo\": 10, \"bar\":\[\"one\",\"two\"\]}</script>"))


;; (define-url-function random-number (request (limit integer 1000))
;;   (html*
;;     (:body
;;      (:p "Random number: " (who:str (random limit))))))


;; (define-url-function hello (request (hi integer 1999) (coisa string "-"))
;;   (html*
;;     (:html
;;       (:h1 (who:str hi))
;;       (:h2 (who:str coisa)))))








;; ref: https://stackoverflow.com/questions/35102637/undefined-function-after-macroexpansion
;;    (search by: "cl-who undefined function: :BODY")


;; later reading
;;    https://building.nubank.com.br/server-driven-ui-framework-at-nubank/





;; ;;
;; ;; from: cl-dot
;; ;;
;; (defun foreign-name->lisp-name (name)
;;   "Return an idiomatic Lisp name derived from the GraphViz name NAME."
;;   (intern (string-upcase (substitute #\- #\_ name)) :keyword))
;;
;;
;; (foreign-name->lisp-name "lixo-asd")


;; hyperscript.org
;; alpinejs.dev



;; https://two.js.org/
;; https://d3js.org/getting-started
;;      react -- https://2019.wattenberger.com/blog/react-and-d3

;; https://duckdb.org/#quickinstall


;; https://www.freecodecamp.org/news/d3-visualizations-with-datasets-how-to-build-a-gantt-like-chart-9c9afa9b8d9d/
;; https://www.codehim.com/chart-graph/interactive-gantt-chart-using-d3-js/
;; https://www.codehim.com/html5-css3/task-manager-ui-with-css-grid/



;; server side events -- https://icinga.com/blog/2024/02/14/server-sent-events-an-overlooked-browser-feature/
