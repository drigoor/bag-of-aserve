(in-package #:bag-of-aserve)


(setf (who:html-mode) :html5)


(defparameter *htmx-js*
  (uiop:merge-pathnames* "static/unpkg.com_htmx.org@1.9.2_dist_htmx.min.js" (uiop:getcwd)))


(defparameter *favicon*
  (uiop:merge-pathnames* "static/favicon.png" (uiop:getcwd)))


(defun start-bag (&optional (port 9090))
  (publish-file :path "/htmx.js" :file *htmx-js* :content-type "text/javascript")
  (publish-file :path "/favicon.ico" :file *favicon* :content-type "image/png")
  (net.aserve::debug-on :notrap)
  (start :port port))


(defmacro js-source-file (filename)
  `(htm (:script :src ,filename :type "text/javascript")))


;; (defmacro css-source-file (filename)
;;   `(htm (:link :href ,filename :rel "stylesheet")))


(defmacro base-page ((&key title) &body body)
  `(who ; ref: https://stackoverflow.com/questions/35102637/undefined-function-after-macroexpansion (search by "cl-who undefined function: :BODY")
    (:html
      :lang "en"
      (:head
       (:meta :charset "utf-8")
       (:title ,title)
       ;; (css-source-file "styles.css")
       )
      (:body
       ,@body
       (js-source-file "htmx.js")))))


(define-url-function index
    (request)
  (base-page (:title "web demo")
    (:div :class "app"
          (:button :hx-post "/hello?lixo=2435622" :hx-swap "outerHTML" "hello"))))


(defun lixo (lixo)
  (who
   (:div
    :style "padding:4px;border:1px solid #888;margin-top:4px;margin-bottom:4px;background-color:#eee;"
    (str (format nil "--> ~a" lixo)))))


(define-url-function hello
    (request (lixo string))
  (lixo lixo)

  (who
   :br)

  (loop for (link . title) in '(("http://zappa.com/" . "Frank 1 Zappa")
                                ("http://marcusmiller.com/" . "Marcus 2 Miller")
                                ("http://www.milesdavis.com/" . "Miles 3 Davis"))
        do (who (:a :href link
                    (:b (str title)))
             :br))

  (who
    :br)

  (tree-drawing-example))




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
         (who (:td (funcall node))))
       (h-line ()
         ;; a single horizontal line to and from the vertical connector
         (when children
           (who
             (:td (:div :style (conc "border-top:" line-width " " style " "
                                     color ";width:" width))))))
       (v-line (pos)
         ;; the vertical connector between the horizontal lines
         (unless (= (length children) 1) ;; only one child -> no vertical line
           (who
             (:div
              :class (conc (cond ((= pos 1) "vl-top")
                                 ((= pos (length children)) "vl-bottom")
                                 (t "vl-middle"))
                           (if right-to-left " vl-right" " vl-left"))
              :style (conc "border-left:" line-width " " color " " style)))))
       (child (child)
         ;; a td for a child node"
         (who (:td (funcall child))))
       (children ()
         (when children
           (who
             (:td
              (loop for child in children
                    for i from 1
                    do (who
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
    (who
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
                         ("very long text. very long text. very long text. very long text. very long text. very long text. very long text. very long text. "))))
        )
    (labels (;; this makes a div with a border for each node
             (draw-node (content)
               (who (:div :style "padding:4px;border:1px solid #888;margin-top:4px;margin-bottom:4px;background-color:#eee;"
                          (princ content))))
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
      (who
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



;; later reading
;;    https://building.nubank.com.br/server-driven-ui-framework-at-nubank/