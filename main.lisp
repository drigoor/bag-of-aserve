(in-package #:bag-of-aserve)


(setf (who:html-mode) :html5)


(defvar *default-static-pathname*
  (uiop:merge-pathnames* "static/" (uiop:getcwd)))


(defvar *static-data-to-publish*
  '(:favicon (("/favicon.ico" "image/png"       "favicon.png"))
    :js      (("/htmx.js"     "text/javascript" "unpkg.com_htmx.org@1.9.10_dist_htmx.min.js")
              ("/graph.js"    "text/javascript" "graph.js"))
    :css     (("/graph.css"  "text/css"        "graph.css")
              ("/styles.css"  "text/css"        "bulma.min@0.9.4.css"))))


(defmethod html-resource ((type (eql :favicon)) content-type path)
  (htm*
    (:link :rel "icon" :type content-type :href path)))


(defmethod html-resource ((type (eql :js)) content-type path)
  (htm*
    (:script :type content-type :src path)))


(defmethod html-resource ((type (eql :css)) content-type path)
  (htm*
    (:link :rel "stylesheet" :type content-type :href path)))


(defun htm*-resource (data type)
  (loop for (path content-type) in (getf data type)
        do (html-resource type content-type path)))


(defun publish-static-data (data data-pathname)
  (alexandria:doplist (type details data)
    (loop for (path content-type file) in details
          do (net.aserve:publish-file :path path
                                      :content-type content-type
                                      :file (uiop:merge-pathnames* file data-pathname)))))


(defun start-server (&key (port 9090) (static-data-to-publish *static-data-to-publish*) (static-pathname *default-static-pathname*))
  (publish-static-data static-data-to-publish static-pathname)
  (net.aserve::debug-on :notrap)
  (net.aserve:start :port port))


(defmacro home-page ((data &key title) &body body)
  `(html*
     (:html
       :lang "en"
       (:head
        (:meta :charset "utf-8")
        (:title ,title)
        (htm*-resource ,data :favicon)
        (htm*-resource ,data :css))
       (:body
        ,@body

        ;; (:div :id "graph")
        ;; (:div :id "graph" :class "graph")

        (htm*-resource ,data :js)
        (:script :src "https://d3js.org/d3.v5.min.js")
        (:script :src "https://unpkg.com/@hpcc-js/wasm@0.3.13/dist/index.min.js")
        (:script :src "https://unpkg.com/d3-graphviz@3.1.0/build/d3-graphviz.js")
        (:script :src "graph.js")
        ;; (:script "renderGraph()")
        ))))


(define-url-function index (request)
  (home-page (*static-data-to-publish* :title "bag of nothing")
    (:h1 "hello, world!")
    (:section :class "section"

              ;; (:div :hx-post "/new-graph"
              ;;       :hx-trigger "click, myEvent from:body"
              ;;       :hx-target "#parent-div"
              ;;       :hx-swap "outerHTML"
              ;;       "Click Me!")
              ;; (:div :id "parent-div"

              ;;       )


              (:button :id "myBtn" "Try it")
              (:p :id "demo")

              (:button :hx-post "/new-graph" :hx-swap "outerHTML" "click me"
                       ;; :hx-trigger ""
                       )
              )))


;; https://stackoverflow.com/questions/73389202/how-to-execute-javascript-code-after-htmx-makes-an-ajax-request

;; https://marcus-obst.de/blog/htmx-json-handling


;; from: https://www.reddit.com/r/htmx/comments/10sdk43/how_can_i_assign_an_hxget_response_to_a/
(define-url-function new-graph (request)
  (htm*
    "<script id=\"data\" type=\"application/json\">{\"foo\": 10, \"bar\":\[\"one\",\"two\"\]}</script>"))


(define-url-function random-number (request (limit integer 1000))
  (html*
    (:body
     (:p "Random number: " (who:str (random limit))))))


(define-url-function hello (request (hi integer 1999) (coisa string "-"))
  (html*
    (:html
      (:h1 (who:str hi))
      (:h2 (who:str coisa)))))




;; for index:


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyWebPage</title>
</head>
<body>

</body>
</html>






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
