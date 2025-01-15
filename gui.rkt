#lang racket/gui

(provide create-main-frame)

(require "timer.rkt")

(define (create-main-frame)
  (define frame 
    (new frame% 
         [label "Pomodoro Timer"]
         [width 400]
         [height 300]))
  
  ;; Create UI components
  (create-timer-display frame)
  (create-input-fields frame)
  (create-buttons frame)
  
  frame)

;; ... rest of GUI-related functions ... 