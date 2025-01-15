#lang racket/gui

(require rsound
         ffi/unsafe)

;; Constants
(define DEFAULT-WORK-TIME 25)  ; 25 minutes
(define DEFAULT-REST-TIME 5)   ; 5 minutes
(define TICK-INTERVAL 1000)    ; 1 second in milliseconds

;; State variables
(define current-seconds 0)
(define is-running? #f)
(define is-work-period? #t)
(define work-minutes DEFAULT-WORK-TIME)
(define rest-minutes DEFAULT-REST-TIME)

;; Initialize audio
(define current-sound #f)

;; Simple beep as fallback if file not found
(define (play-alarm)
  (system "afplay bell.aiff"))  ; Changed to use bell.aiff

;; Main frame
(define frame 
  (new frame% 
       [label "Pomodoro Timer"]
       [width 400]
       [height 300]))

;; Timer display
(define timer-display
  (new message% 
       [parent frame]
       [label "25:00"]
       [font (make-object font% 32 'default)]))

;; Work time input
(define work-input
  (new text-field% 
       [parent frame]
       [label "Work time (minutes):"]
       [init-value (number->string DEFAULT-WORK-TIME)]))

;; Rest time input
(define rest-input
  (new text-field% 
       [parent frame]
       [label "Rest time (minutes):"]
       [init-value (number->string DEFAULT-REST-TIME)]))

;; Helper functions
(define (format-time seconds)
  (let ([minutes (quotient seconds 60)]
        [secs (remainder seconds 60)])
    (format "~a:~a" 
            minutes 
            (if (< secs 10) 
                (format "0~a" secs) 
                secs))))

(define (reset-timer)
  (set! current-seconds 
        (* (if is-work-period? work-minutes rest-minutes) 60))
  (send timer-display set-label (format-time current-seconds)))

;; Button callbacks
(define (start-stop-timer)
  (set! is-running? (not is-running?))
  (send start-button set-label (if is-running? "Stop" "Start"))
  (when is-running?
    (reset-timer)))

(define (toggle-period)
  (set! is-work-period? (not is-work-period?))
  (reset-timer)
  (send period-button set-label 
        (if is-work-period? "Switch to Rest" "Switch to Work")))

;; Timer callback
(define (timer-callback)
  (when is-running?
    (set! current-seconds (sub1 current-seconds))
    (send timer-display set-label (format-time current-seconds))
    (when (zero? current-seconds)
      (play-alarm)
      (set! is-running? #f)
      (send start-button set-label "Start")
      (toggle-period))))

;; Create buttons
(define button-panel (new horizontal-panel% [parent frame]))

(define start-button
  (new button% 
       [parent button-panel]
       [label "Start"]
       [callback (lambda (button event) (start-stop-timer))]))

(define period-button
  (new button% 
       [parent button-panel]
       [label "Switch to Rest"]
       [callback (lambda (button event) (toggle-period))]))

(define reset-button
  (new button% 
       [parent button-panel]
       [label "Reset"]
       [callback (lambda (button event) (reset-timer))]))

;; Apply button
(define apply-button
  (new button% 
       [parent frame]
       [label "Apply Settings"]
       [callback (lambda (button event)
                  (set! work-minutes 
                        (string->number (send work-input get-value)))
                  (set! rest-minutes 
                        (string->number (send rest-input get-value)))
                  (reset-timer))]))

;; Timer thread
(define timer-thread
  (thread
   (lambda ()
     (let loop ()
       (sleep/yield (/ TICK-INTERVAL 1000.0))
       (timer-callback)
       (loop)))))

;; Show the frame
(send frame show #t)
