#lang racket/gui

(provide create-main-frame)

(require "pomodoro.rkt")

;; GUI elements
(define timer-display #f)
(define work-input #f)
(define break-input #f)
(define start-button #f)
(define period-button #f)

;; Style constants
(define BACKGROUND-COLOR (make-object color% 40 40 40))
(define TEXT-COLOR (make-object color% 255 255 255))
(define BUTTON-COLOR (make-object color% 80 80 80))
(define TIMER-FONT (make-object font% 48 'default 'normal 'normal))
(define INPUT-FONT (make-object font% 14 'default))

(define (create-main-frame)
  (define frame 
    (new frame% 
         [label "Pomodoro Timer"]
         [width 400]
         [height 300]
         [style '(no-resize-border)]))
  
  ;; Create a canvas for the background
  (define bg-canvas
    (new canvas% 
         [parent frame]
         [style '(border)]
         [paint-callback
          (lambda (canvas dc)
            (let ([width (send canvas get-width)]
                  [height (send canvas get-height)])
              (send dc set-background BACKGROUND-COLOR)
              (send dc clear)))]))
  
  ;; Main container
  (define main-panel 
    (new vertical-panel% 
         [parent frame]
         [alignment '(center center)]
         [spacing 20]))
  
  (create-timer-display main-panel)
  (create-input-fields main-panel)
  (create-buttons main-panel)
  
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

(define (create-timer-display parent)
  (define timer-panel 
    (new vertical-panel% 
         [parent parent]
         [alignment '(center center)]
         [min-height 120]))
  
  (set! timer-display
        (new message% 
             [parent timer-panel]
             [label "25:00"]
             [font TIMER-FONT]
             [color TEXT-COLOR]))
  timer-panel)

(define (create-input-fields parent)
  (define input-panel 
    (new horizontal-panel% 
         [parent parent]
         [alignment '(center center)]
         [spacing 10]))
  
  (set! work-input
        (new text-field% 
             [parent input-panel]
             [label "Work Time (minutes)"]
             [init-value (number->string DEFAULT-WORK-TIME)]
             [min-width 40]
             [font INPUT-FONT]))
  
  (set! break-input
        (new text-field%
             [parent input-panel]
             [label "Break Time (minutes)"]
             [init-value (number->string DEFAULT-REST-TIME)]
             [min-width 40]
             [font INPUT-FONT]))
  
  (new button%
       [parent input-panel]
       [label "Apply"]
       [callback (lambda (button event)
                  (update-settings
                   (string->number (send work-input get-value))
                   (string->number (send break-input get-value))))]))

(define (create-custom-button parent label callback)
  (new button% 
       [parent parent]
       [label label]
       [callback callback]
       [min-width 120]))

(define (create-buttons parent)
  (define button-panel 
    (new horizontal-panel% 
         [parent parent]
         [alignment '(center center)]
         [spacing 10]))
  
  (set! start-button
        (create-custom-button 
         button-panel "Start"
         (lambda (button event)
           (if (is-running?)
               (stop-timer)
               (start-timer)))))
  
  (set! period-button
        (create-custom-button 
         button-panel "Switch to Rest"
         (lambda (button event)
           (toggle-period))))
  
  (create-custom-button 
   button-panel "Reset"
   (lambda (button event)
     (reset-timer))))

;; ... rest of GUI-related functions ... 