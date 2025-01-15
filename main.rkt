#lang racket/gui

(require "gui.rkt")

;; Create and show the main window
(define frame (create-main-frame))
(send frame show #t) 