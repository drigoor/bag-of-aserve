(in-package #:bag-of-aserve)


(setf (who:html-mode) :html5)


(defvar *default-static-pathname* (uiop:merge-pathnames* "static/" (uiop:getcwd)))


(defvar *static-data-to-publish*        ; ({path content-type file}*)
  '(("/favicon.ico" "image/png" "favicon.png")
    ("/htmx.js" "text/javascript" "unpkg.com_htmx.org@1.9.2_dist_htmx.min.js")
    ("/styles.css" "text/css" "styles.css")))


(defun favicon-source (&optional (index 0))
  (destructuring-bind (file type *)
      (nth index *static-data-to-publish*)
    (htm* (:link :rel "icon" :type type :href file))))


(defun js-source (&optional (index 1)) ; index in the *static-data-to-publish*
  (destructuring-bind (file type *)
      (nth index *static-data-to-publish*)
    (htm* (:script :src file :type type))))


(defun css-source (&optional (index 2))
  (destructuring-bind (file type *)
      (nth index *static-data-to-publish*)
    (htm* (:link :rel "stylesheet" :type type :href file))))


(defun start-bag (&key (port 9090) (static-data-to-publish *static-data-to-publish*))
  (mapc #'(lambda (data)
            (destructuring-bind (path content-type file) data
              (publish-file :path path
                            :content-type content-type
                            :file (uiop:merge-pathnames* file *default-static-pathname*))))
        static-data-to-publish)
  (net.aserve::debug-on :notrap)
  (start :port port))


(defmacro index-page ((&key title) &body body)
  `(html*
     (:html
       :lang "en"
       (:head
        (:meta :charset "utf-8")
        (:title ,title)
        (favicon-source)
        (css-source)
        )
       (:body
        ,@body
        (js-source)))))


(define-url-function index
    (request)
  (index-page (:title "web demo")

    (:div :id "content" :class "gtfl")

    (:div :class "app" :class "gtfl"
          (:button :hx-post "/hello?lixo=293847AAAXXX" :hx-swap "outerHTML" "hello"))))


(define-url-function hello
    (request ;; (lixo string)
             )
  (htm*
    (:div :id "content" :class "gtfl"
    (tree-drawing-example))))


(defun draw-node-with-children (node children &key (right-to-left nil) (color "#888") (width "10px") (line-width "1px") (style "solid"))
  "A function for recursively drawing trees in html. It draws a node
   with connections to it's children (which can be trees
   themselves). See example below."
  (assert (functionp node))
  (assert (listp children))
  (assert (loop for child in children always (functionp child)))
  (labels ;; these will be called in a different order depending on right-to-left
      ((node ()
         ;; a td for the parent node
         (htm* (:td (funcall node))))
       (h-line ()
         ;; a single horizontal line to and from the vertical connector
         (when children
           (htm*
             (:td (:div :style (conc "border-top:" line-width " " style " "
                                     color ";width:" width))))))
       (v-line (pos)
         ;; the vertical connector between the horizontal lines
         (unless (= (length children) 1) ;; only one child -> no vertical line
           (htm*
             (:div
              :class (conc (cond ((= pos 1) "vl-top")
                                 ((= pos (length children)) "vl-bottom")
                                 (t "vl-middle"))
                           (if right-to-left " vl-right" " vl-left"))
              :style (conc "border-left:" line-width " " color " " style)))))
       (child (child)
         ;; a td for a child node"
         (htm* (:td (funcall child))))
       (children ()
         (when children
           (htm*
             (:td
              (loop for child in children
                    for i from 1
                    do (htm*
                         (:div
                          :class "child"
                          :style (when right-to-left "clear:both;float:right;")
                          (:table :class "tree"
                                  (:tbody
                                   (:tr
                                    (if right-to-left
                                        (progn (child child) (h-line))
                                        (progn (h-line) (child child))))))
                          (v-line i)))))))))
    (htm*
      (:div
       :style (when right-to-left "clear:both;float:right;")
       (:table
        :class "tree"
        (:tbody
         (:tr
          (if right-to-left
              (progn (children) (h-line) (node))
              (progn (node) (h-line) (children)))))))
      (:div :style "clear:both"))))


(defun tree-drawing-example ()
  (let ((right-to-left nil)
        (color "#888")
        (width "10px")
        (line-width "1px")
        (style "solid")
        (example-tree '("top node."
                        ("child node one with three children"
                         ("first out of three children")
                         ("second out of three children")
                         ("third out of three children"))
                        ("child node two with one child"
                         ("very long text. very long text. very long text. very long text. very long text. very long text. very long text. very long text. ")))))
    (labels (;; this makes a div with a border for each node
             (draw-node (content)
               (htm* (:div :style "padding:4px;border:1px solid #888;margin-top:4px;margin-bottom:4px;background-color:#eee;"
                           (str (princ content)))))
             ;; recursive tree drawing
             (draw-tree (tree)
               (draw-node-with-children
                #'(lambda ()
                    (draw-node (car tree)))
                ;; anonymous functions for each child of the node
                (mapcar #'(lambda (x)
                            #'(lambda ()
                                (draw-tree x)))
                        (cdr tree))
                :right-to-left right-to-left :color color
                :width width :line-width line-width :style style)))
      (htm*
        (:h2 "tree drawing example")
        (:p "resize your browser window to see the dynamic tree
                    rendering in action.")
        (draw-tree example-tree)
        (:div "&#160;")
        (:table
         (:tr
          (:td :style "vertical-align:top"
               "with parameters "
               (:tt ":right-to-left t :color &quot;black&quot;
                :width &quot;30px&quot; :style &quot;dotted&quot;")
               ":" (setf right-to-left t  color "black"  width "30px"
                         line-width "1px"  style "dotted")
               (draw-tree example-tree))
          (:td
           :style "padding-left:20px" "with parameters "
           (:tt ":color &quot;#33a;&quot; :line-width &quot;2px&quot;") ":"
           (setf right-to-left nil  color "#33a"  width "10px"
                 line-width "2px" style "solid")
           (draw-tree example-tree))))
        )
      )))






;; # 2
;;
;; (defun urlencode (string)
;;   (net.aserve::encode-form-urlencoded string))
;;
;; ;; from: Chapter29/mp3-browser.lisp
;; (defun link (target &rest attributes)
;;   (htm
;;    (:attribute
;;     (:format "~a~@[?~{~(~a~)=~a~^&~}~]" target (mapcar #'urlencode attributes)))))


;; # 3
;; (:link :rel "icon" :type "image/x-icon" :href "favicon.ico")




;; mklink /J C:\home\quicklisp\local-projects\gtfl C:\home\projects\lisp\_externals\gtfl


;; ref: https://stackoverflow.com/questions/35102637/undefined-function-after-macroexpansion
;;    (search by: "cl-who undefined function: :BODY")


;; later reading
;;    https://building.nubank.com.br/server-driven-ui-framework-at-nubank/
