# Experiments with lisp and web

+ using htmx to provide htm to the front-end
+ use ideas / code of gtfl

+ [GTFL](https://martin-loetzsch.de/gtfl/index.html) - graphical terminal for lisp
+ [asdf-viz](https://github.com/guicho271828/asdf-viz) - ASDF system dependency visualizer

+ gtfl supports (babel)[https://gitlab.ai.vub.ac.be/ehai/babel] - The all-in-one toolkit for multi-agent experiments on emergent communication.

Note that GTFL was initially developed as part of the (Babel2)[http://emergent-languages.org/] framework.


# Implementation details:

* Used (Pratical Common Lisp)[https://gigamonkeys.com/book/] code:
** changed 'define-url-function' macro to support cl-who
** changed 'define-url-function' to support "/", making index a special case

* favicon from <a href="https://www.flaticon.com/free-icons/lisp" title="lisp icons">Lisp icons created by Freepik - Flaticon</a>



<!--


https://project-awesome.org/CodyReichert/awesome-cl
* Interactive SSR
* clog
* spinneret
* snooze
* postmodern


http://www.thoughtstuff.com/rme/
Lead developer for the Cocoa-based user interface for Opusmodus, a music composition application for the Macintosh. Written using Clozure CL.
(Opusmodus)[http://opusmodus.com/]

-->


# notes

First, what is a middleware? A middleware is a function which wraps an existing application and returns a new application. (from)[https://dnaeon.github.io/common-lisp-web-dev-ningle-middleware/]
