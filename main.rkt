#lang racket/gui

(require "audio.rkt"
         "timer.rkt"
         "gui.rkt")

(define frame (create-main-frame))
(init-timer-thread!)
(send frame show #t) 