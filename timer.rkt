#lang racket

(provide init-timer-thread!
         start-stop-timer
         toggle-period
         reset-timer
         timer-callback
         current-seconds
         is-running?
         is-work-period?
         work-minutes
         rest-minutes)

(require "audio.rkt")

;; Constants
(define DEFAULT-WORK-TIME 25)
(define DEFAULT-REST-TIME 5)
(define TICK-INTERVAL 1000)

;; State variables
(define current-seconds 0)
(define is-running? #f)
(define is-work-period? #t)
(define work-minutes DEFAULT-WORK-TIME)
(define rest-minutes DEFAULT-REST-TIME)

;; Timer functions
(define (init-timer-thread!)
  (thread
   (lambda ()
     (let loop ()
       (sleep/yield (/ TICK-INTERVAL 1000.0))
       (timer-callback)
       (loop)))))

;; ... rest of timer-related functions ... 