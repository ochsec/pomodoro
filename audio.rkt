#lang racket

(provide play-alarm)

(define (play-alarm)
  (system "afplay bell.aiff")) 