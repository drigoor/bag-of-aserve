(in-package #:bag-of-aserve)


(defmacro is-string-p (x)
  (alexandria:with-gensyms (msg)
    `(let ((,msg (format nil "'~a' should be a string" ,x)))
       (assert (stringp ,x) nil ,msg))))


(defmacro is-symbol-p (x)
  (alexandria:with-gensyms (msg)
    `(let ((,msg (format nil "'~a' should be a symbol" ,x)))
       (assert (symbolp ,x) nil ,msg))))


(defmacro is-list-p (x)
  (alexandria:with-gensyms (msg)
    `(let ((,msg (format nil "'~a' should be a list" ,x)))
       (assert (listp ,x) nil ,msg))))


(defun ->node (str)
  (is-string-p str)
  (let* ((str-length (length str))
         (length (cond ((< str-length 10)
                        100)
                       ((< str-length 33)
                        200)
                       (t
                        300))))
    (format nil "{ data: { id: '~a' } , style: { 'width': '~apx'} }" str length)))


(defun ->edge (src dst)
  (is-string-p src)
  (is-string-p dst)
  (format nil "{ data: { source: '~a', target: '~a' } }" src dst))


(defun ->cytoscape (plist)
  (let* ((nodes "")
         (edges ""))
    (alexandria:doplist (src lst plist)
      (setf nodes (format nil "~a    ~a,~%" nodes (->node src)))
      (dolist (dst lst)
        (setf nodes (format nil "~a    ~a,~%" nodes (->node dst)))
        (setf edges (format nil "~a    ~a,~%" edges (->edge src dst)))))
    (values nodes
            edges)))


(defmacro cytoscape.template (nodes edges)
  (let ((control-string (uiop:read-file-string (concatenate 'string *cwd* "/cytoscape.template.js"))))
    `(format nil ,control-string ,nodes ,edges)))
