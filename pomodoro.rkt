#lang racket/gui

(provide 
 ; Constants
 DEFAULT-WORK-TIME
 DEFAULT-REST-TIME
 ; Core functions
 start-timer
 stop-timer
 reset-timer
 toggle-period
 update-settings
 ; State queries
 get-time-display
 is-work-period?
 is-running?
 ; Callbacks
 register-display-callback
 register-period-callback
 register-running-callback)

(require rsound
         ffi/unsafe)

;; Constants
(define DEFAULT-WORK-TIME 25)  ; 25 minutes
(define DEFAULT-REST-TIME 5)   ; 5 minutes
(define TICK-INTERVAL 1000)    ; 1 second in milliseconds

;; State variables
(define current-seconds 0)
(define running? #f)
(define work-period? #t)
(define work-minutes DEFAULT-WORK-TIME)
(define rest-minutes DEFAULT-REST-TIME)

;; Callback registrations
(define display-callback void)  ; Will update timer display
(define period-callback void)   ; Will update period button text
(define running-callback void)  ; Will update start/stop button text

;; Register callback functions
(define (register-display-callback cb) (set! display-callback cb))
(define (register-period-callback cb) (set! period-callback cb))
(define (register-running-callback cb) (set! running-callback cb))

;; State queries
(define (is-running?) running?)
(define (is-work-period?) work-period?)

;; Helper functions
(define (format-time seconds)
  (let ([minutes (quotient seconds 60)]
        [secs (remainder seconds 60)])
    (format "~a:~a" 
            minutes 
            (if (< secs 10) 
                (format "0~a" secs) 
                secs))))

(define (get-time-display)
  (format-time current-seconds))

;; Core functions
(define (reset-timer)
  (set! current-seconds 
        (* (if work-period? work-minutes rest-minutes) 60))
  (display-callback (get-time-display)))

(define (start-timer)
  (set! running? #t)
  (running-callback #t)
  (reset-timer))

(define (stop-timer)
  (set! running? #f)
  (running-callback #f))

(define (toggle-period)
  (set! work-period? (not work-period?))
  (reset-timer)
  (period-callback work-period?))

(define (update-settings new-work-minutes new-break-minutes)
  (set! work-minutes new-work-minutes)
  (set! rest-minutes new-break-minutes)
  (reset-timer))

;; Timer callback
(define (timer-callback)
  (when running?
    (set! current-seconds (sub1 current-seconds))
    (display-callback (get-time-display))
    (when (zero? current-seconds)
      (play-alarm)
      (stop-timer)
      (toggle-period))))

;; Audio
(define (play-alarm)
  (system "afplay bell.aiff"))

;; Timer thread
(define timer-thread
  (thread
   (lambda ()
     (let loop ()
       (sleep/yield (/ TICK-INTERVAL 1000.0))
       (timer-callback)
       (loop)))))
