#lang racket/gui

(provide create-main-frame)

(require "pomodoro.rkt")

;; GUI elements
(define timer-display #f)
(define work-input #f)
(define break-input #f)
(define start-button #f)
(define period-button #f)

(define (create-main-frame)
  (define frame 
    (new frame% 
         [label "Pomodoro Timer"]
         [width 400]
         [height 300]))
  
  (create-timer-display frame)
  (create-input-fields frame)
  (create-buttons frame)
  
  ;; Register callbacks
  (register-display-callback
   (lambda (time-str) 
     (send timer-display set-label time-str)))
  
  (register-period-callback
   (lambda (is-work?) 
     (send period-button set-label
           (if is-work? "Switch to Rest" "Switch to Work"))))
  
  (register-running-callback
   (lambda (is-running?) 
     (send start-button set-label
           (if is-running? "Stop" "Start"))))
  
  frame)

(define (create-timer-display frame)
  (define timer-panel (new vertical-panel% [parent frame]))
  (set! timer-display
        (new message% 
             [parent timer-panel]
             [label "25:00"]
             [font (make-object font% 32 'default)])))

(define (create-input-fields frame)
  (define input-panel (new horizontal-panel% [parent frame]))
  (set! work-input
        (new text-field% 
             [parent input-panel]
             [label "Work Time (minutes)"]
             [init-value (number->string DEFAULT-WORK-TIME)]))
  (set! break-input
        (new text-field%
             [parent input-panel]
             [label "Break Time (minutes)"]
             [init-value (number->string DEFAULT-REST-TIME)]))
  
  ;; Add Apply Settings button
  (new button%
       [parent input-panel]
       [label "Apply"]
       [callback (lambda (button event)
                  (update-settings
                   (string->number (send work-input get-value))
                   (string->number (send break-input get-value))))]))

(define (create-buttons frame)
  (define button-panel (new horizontal-panel% [parent frame]))
  (set! start-button
        (new button% 
             [parent button-panel]
             [label "Start"]
             [callback (lambda (button event)
                        (if (is-running?)
                            (stop-timer)
                            (start-timer)))]))
  
  (set! period-button
        (new button%
             [parent button-panel]
             [label "Switch to Rest"]
             [callback (lambda (button event)
                        (toggle-period))]))
  
  (new button%
       [parent button-panel]
       [label "Reset"]
       [callback (lambda (button event)
                  (reset-timer))]))

;; ... rest of GUI-related functions ... 