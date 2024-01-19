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
        (css-source))
       (:body
        ,@body
        (js-source)))))


(define-url-function index (request)
  (index-page (:title "web demo")
    (:div
     :id "content"
     :class "gtfl")
    (:div
     :class "gtfl"
     (:button :hx-post "/hello?lixo=293847AAAXXX"
              :hx-swap "outerHTML"
              "hello"))))


(define-url-function hello (request)
  (htm*
    ;;
    ;; it is working
    ;; (:div :id "content" :class "gtfl"
    ;;       (tree-drawing-example))
    ;;

    ;; (expandable-elements-example)

    ;; (draw-asdf-dependency-tree :gtfl)


    (:div :id "content" :class "gtfl"
          (str (let (;; (example-tree '("description"
                     ;;                 ("asd") ("asdasd")
                     ;;                 ("ehllo")
                     ;;                 ("asd" ("asd"))
                     ;;                 ("asdasd" ("asd990" ("23223"))))
                     ;;               ;; '("top node."
                     ;;               ;;   ("child node one with three children"
                     ;;               ;;    ("first out of three children")
                     ;;               ;;    ("second out of three children")
                     ;;               ;;    ("third out of three children"))
                     ;;               ;;   ("child node two with one child"
                     ;;               ;;    ("very long text. very long text. very long text. very long text. very long text. very long text. very long text. very long text. ")))
                     ;;               )
                     )
                 (my-tree-drawing-example (system-to-tree :hunchentoot)))))

    ))


(defun slot-keyword-and-value (system slot)
  (let* ((name (closer-mop:slot-definition-name slot))
         (value (slot-value system name)))
    (when value
      (list (make-keyword name)
            value))))


(defun system-direct-slots (system-name)
  (let* ((system (asdf:find-system system-name))
         (slots (closer-mop:class-direct-slots (class-of system))))
    (mapcan #'(lambda (slot)
                (slot-keyword-and-value system slot))
            slots)))


(defun system-to-tree (system-name)
  (cons (string-downcase (string system-name))
        (loop for (name value) on (system-direct-slots system-name) by #'cddr
              collect (list (string name)
                           (if (listp value)
                               (mapcar #'list value)
                               (list value))))))


;; (system-direct-slots :hunchentoot)

;; (system-to-tree :hunchentoot)



;; (system-to-tree :hunchentoot)


(defmacro html-debug (&body body)
  `(with-output-to-string (*http-stream*)
     ,@body))


;; (html-debug
;;   (let ((example-tree '("description" ("ehllo"))
;;                       ;; '("top node."
;;                       ;;   ("child node one with three children"
;;                       ;;    ("first out of three children")
;;                       ;;    ("second out of three children")
;;                       ;;    ("third out of three children"))
;;                       ;;   ("child node two with one child"
;;                       ;;    ("very long text. very long text. very long text. very long text. very long text. very long text. very long text. very long text. ")))
;;                       ))
;;     (my-tree-drawing-example (system-to-tree :hunchentoot))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; to support gtlf examples more directly
;;; princ and alike should be envolved with cl-who `str' (if not, the nodes will be empty - which are also cool)
;;;

(defmacro who (&body body)
  `(who:with-html-output (*http-stream* nil :prologue nil :indent t)
     ,@body))


(defmacro who2s (&body body)
  `(who:with-html-output (*http-stream* nil :prologue nil :indent t)
     ,@body))


(defmacro who-lambda (&body body)
  "makes an anonymous function that generates cl-who output for expression"
  `(lambda ()
     (who:with-html-output (*http-stream* nil :prologue nil :indent t)
       ,@body)))


(defmacro gtfl-out (&body body)
  `(who:with-html-output (*http-stream* nil :prologue nil :indent t)
     ,@body))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; from: gtfl main site `tree-drawing.lisp'
;;;       with redefinitions of who, who-lambda, and gtfl-out macros to directly call cl-who
;;;

(defun draw-node-with-children (node children &key (right-to-left nil)
                                                (color "#888") (width "10px")
                                                (line-width "1px") (style "solid"))
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
  (let ((right-to-left nil) (color "#888") (width "10px")
        (line-width "1px") (style "solid")
    (example-tree '("top node."
            ("child node one with three children"
             ("first out of three children")
             ("second out of three children")
             ("third out of three children"))
            ("child node two with one child"
             ("very long text. very long text. very long text. very long text. very long text. very long text. very long text. very long text. ")))))
    (labels (;; this makes a div with a border for each node
         (draw-node (content)
           (who (:div :style "padding:4px;border:1px solid #888;margin-top:4px;margin-bottom:4px;background-color:#eee;"
              (str (princ content)))))

         ;; recursive tree drawing
         (draw-tree (tree)
           (draw-node-with-children
        ;; an anonymous function for drawing the current node
        (who-lambda (draw-node (car tree)))
        ;; anonymous functions for each child of the node
        (mapcar #'(lambda (x) (who-lambda (draw-tree x)))
            (cdr tree))
        :right-to-left right-to-left :color color
        :width width :line-width line-width :style style)))
      (gtfl-out (:h2 "tree drawing example"))
      (gtfl-out (:p "resize your browser window to see the dynamic tree
                    rendering in action."))
      (gtfl-out (:p "with default parameters:"))
      (gtfl-out (draw-tree example-tree))
      (gtfl-out (:div "&#160;"))
      (gtfl-out
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
      (draw-tree example-tree))))))))





(defun my-tree-drawing-example (example-tree)
  (let ((right-to-left nil)
        (color "#888")
        (width "10px")
        (line-width "1px")
        (style "solid"))
    (labels (;; this makes a div with a border for each node
             (draw-node (content)
               (who (:div :style "padding:4px;border:1px solid #888;margin-top:4px;margin-bottom:4px;background-color:#eee;"
                          (str (princ content)))))
             ;; recursive tree drawing
             (draw-tree (tree)
               (draw-node-with-children
                ;; an anonymous function for drawing the current node
                (who-lambda (draw-node (car tree)))
                ;; anonymous functions for each child of the node
                (mapcar #'(lambda (x) (who-lambda (draw-tree x)))
                        (cdr tree))
                :right-to-left right-to-left :color color
                :width width :line-width line-width :style style)))
      (gtfl-out (:h2 "tree drawing example"))
      (gtfl-out (:p "resize your browser window to see the dynamic tree
                    rendering in action."))
      (gtfl-out (:p "with default parameters:"))
      (gtfl-out (draw-tree example-tree))
      (gtfl-out (:div "&#160;"))
      (gtfl-out
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
           (draw-tree example-tree))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; from: gtfl examples code `examples/asdf-dependency-tree.lisp'
;;;

(defparameter *systems-already-drawn* nil
  "since asdf dependencies are not really a tree, we remember which
   systems have been drawn already and don's show them a second time.")


(defmacro system-slot (slot)
  "retuns the slot-value or nil when slot is unbound"
  `(when (slot-boundp system ,slot) (slot-value system ,slot)))


(defun draw-system-details (system)
  (who
   (:table
    :class "asdf-system"
    (:tbody
     (let ((slots '(asdf::description asdf::long-description asdf::author
                    asdf::maintainer asdf::licence asdf::version)))
       (if (loop for slot in slots never (system-slot slot))
           (htm (:tr (:td (:i "no details available"))))
           (loop for slot in slots
              when (system-slot slot)
              do (htm
                  (:tr
                   (:td (format t "~(~a~):" slot))
                   (:td (esc (system-slot slot))))))))))))



;; #########################################################
;; make-id-string
;; ---------------------------------------------------------

;; counters for strings
(defvar *nid-table* (make-hash-table :test #'equal))

(defun make-id-string (&optional (base "id"))
  "Creates an uniquely numbered id string"
  (format nil "~a-~d" base (if (gethash base *nid-table*)
                   (incf (gethash base *nid-table*))
                   (setf (gethash base *nid-table*) 1))))


(defun make-expandable/collapsable-element (element-id expand/collapse-all-id
                                            collapsed-element expanded-element
                                            &key (expand-initially nil))
  (declare (ignore expand/collapse-all-id))
  (who
    (:div
     :style "display:none;"
     :id element-id
     (str (if expand-initially
              (str (princ expanded-element))
              (str (princ collapsed-element)))))))


(defmacro make-expand/collapse-link (element-id expand? title &rest content)
  "makes a link for expanding/collapsing an element"
  `(who (:a :href (conc ,element-id)
            ;; (conc "javascript:" (if ,expand? "expand" "collapse")
            ;;       (if *create-static-expandable/collapsable-elements*
            ;;           "Static" "")
            ;;       "('" ,element-id "');")
            :title (or ,title (if ,expand? "expand" "collapse"))
            ,@content)))


(defun draw-asdf-dependency-tree* (system expand/collapse-all-id)
  "a helper function for recursively drawing asdf dependencies"
  (if (find system *systems-already-drawn*)
      (who (:div :class "asdf-duplicate"
                 (format t "~(~a~)" (asdf:component-name system))))
      (progn
        (push system *systems-already-drawn*)
        (draw-node-with-children
         (who-lambda
           (let ((element-id (make-id-string "asdf")))
             (htm
              (:div
               :class "asdf"
               (make-expandable/collapsable-element
                element-id expand/collapse-all-id
                (who2s
                 (:div
                  :class "title"
                  (make-expand/collapse-link
                   element-id t "show details"
                   (str (princ (asdf:component-name system))))))
                (who-lambda
                  (:div
                   :class "title"
                   (make-expand/collapse-link
                    element-id nil "hide details"
                    (str (princ (asdf:component-name system)))))
                  (draw-system-details system)))))))
         (mapcar
          #'(lambda (system-name)
              (who-lambda (draw-asdf-dependency-tree*
                           (asdf:find-system system-name)
                           expand/collapse-all-id)))
          (reverse
           (when (slot-boundp system 'asdf::in-order-to)
             (cdadr (assoc 'asdf::load-op
                           (slot-value system 'asdf::in-order-to))))))
         :color "black"))))


(defun draw-asdf-dependency-tree (system-name)
  (let ((id (make-id-string "asdf"))
        (*systems-already-drawn* nil))
    (who
      (:h2 "dependencies for asdf system " (str (princ system-name)))
      (:div (make-expandable/collapsable-element
             (make-id-string) id
             ""
             ""
             ;; (who2s (make-expand/collapse-all-link id t nil  "expand all"))
             ;; (who2s (make-expand/collapse-all-link id nil nil "collapse all"))
             ))
      (:div (draw-asdf-dependency-tree* (asdf:find-system system-name) id)))))



;; from: `expandable-elements.lisp'

(defun expandable-elements-example ()
  (let ((expand/collapse-all-id (make-id-string "expand-collapse-all-expample"))
        (element-id-1 (make-id-string "expand-collapse-expample"))
        (element-id-2 (make-id-string "expand-collapse-expample")))
    (gtfl-out (:h2 "expandable elements example"))
    (gtfl-out (:p "click on the links to see what happens"))
    (gtfl-out
      (:p ;; the expand/collapse-all button
       (make-expandable/collapsable-element
        (make-id-string) expand/collapse-all-id
        ""
        ""
        ;; (who2s (make-expand/collapse-all-link expand/collapse-all-id t
        ;;                                       "custom expand all title" "expand all"))
        ;; (who2s (make-expand/collapse-all-link expand/collapse-all-id nil
        ;;                                       nil "collapse all"))
        )))
    (gtfl-out
      (:p
       ;; with expanded and collapsed version pre-computed
       (:div
        :style "border:1px solid #aaa;display:inline-block;margin-right:10px;"
        (make-expandable/collapsable-element
         element-id-1 expand/collapse-all-id
         (who2s
           (:div
            (make-expand/collapse-link element-id-1 t nil "expand")
            (:br) "collapsed"))
         (who2s
           (:div
            (make-expand/collapse-link element-id-1 nil nil "collapse")
            (:br) (:div :style "font-size:150%" "expanded")))))

       ;; with closures. The value for the expanded version is only
       ;; computed when the expand button is hit.
       (:div
        :style "border:1px solid #aaa;display:inline-block;margin-right:10px;"
        (make-expandable/collapsable-element
         element-id-2 expand/collapse-all-id
         (who2s
           (:div (make-expand/collapse-link element-id-2 t nil "expand with closure")
                 (:br) "collapsed"))
         (who-lambda
           (:div (make-expand/collapse-link element-id-2 nil nil "collapse")
                 (:br)
                 (:div :style "font-size:150%"
                       "expanded version, computed when expand button clicked")))))))))


#|

;;; list struct slots...
;; from: https://www.reddit.com/r/lisp/comments/6c9xpj/how_do_you_get_the_slot_names_from_a_structure/

(defstruct ship
  (x-position 0.0 :type short-float)
  (y-position 0.0 :type short-float)
  (x-velocity 0.0 :type short-float)
  (y-velocity 0.0 :type short-float)
  ;; (mass *default-ship-mass* :type short-float :read-only t)
  )

(sb-mop:class-direct-slots (find-class 'ship))






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

|#


;; (defun all-direct-slots (class)
;;   (append (class-direct-slots class)
;;           (mappend #'all-direct-slots
;;                    (class-direct-superclasses class))))
;;
;;
;; (defun all-slot-readers (class)
;;   (mappend #'slot-definition-readers ;; SLOT-DEFINITION-READERS seems to return the actual list of readers (rather than a copy) on SBCL
;;            (all-direct-slots class)))



;; https://github.com/kisp/arfe/blob/master/gtfl-output-graph.lisp




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
