;;; pulseaudio.scm --- Chez Scheme interface for libpulse C library

;; Copyright © 2026 Alex Kost <alezost@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file DOES NOT provide a full-featured interface for PulseAudio.
;; It provides just a bare minimum required to get/set volume and mute
;; of a particular sink.

;; See "/usr/include/pulse/*.h" files for the meaning of constants, enum
;; definitions, structures and procedures.

;; Procedures to get/set various sink info (`get-sink-info',
;; `number-of-channels', `set-volume', `set-mute') use `current-sink'
;; parameter if sink is not specified otherwise.

;;; Code:

;; `sink-info' records are populated by `sink-info-callback'.
(define-drecord sink-info
  ;; I decided not to include `volume' (which is the max value of all
  ;; channel volumes) since `channels' already contains volume info.
  ;;
  ;; volume                ; volume value integer (not percentage)
  mute?                 ; #t (if sound is off) or #f (if sound is on)
  (channels '())        ; list with volumes for each channel
  )

;; `current-sink' should be a sink index (integer).
;; Sink name is not used by this library.
(define current-sink (make-parameter 0))
(define current-sink-info (make-parameter #f))
(define current-context-state (make-parameter #f))


;;; Foreign constants, enum definitions, and structures

(define PA_CONTEXT_UNCONNECTED  0)
(define PA_CONTEXT_CONNECTING   1)
(define PA_CONTEXT_AUTHORIZING  2)
(define PA_CONTEXT_SETTING_NAME 3)
(define PA_CONTEXT_READY        4)
(define PA_CONTEXT_FAILED       5)
(define PA_CONTEXT_TERMINATED   6)

(define PA_OPERATION_RUNNING   0)
(define PA_OPERATION_DONE      1)
(define PA_OPERATION_CANCELLED 2)

(define PA_VOLUME_NORM #x10000)

(define-ftype ft/cvolume
  (struct
    (channels unsigned-8)
    (values (array 32 unsigned-32))))

(define-ftype ft/sample-spec
  (struct
    ;; `int' here is `pa_sample_format_t' enum:
    (format    int)
    (rate      unsigned-32)
    (channels  unsigned-8)))

(define-ftype ft/channel-map
  (struct
    (channels unsigned-8)
    (map (array 32 int))))

;; The original `pa_sink_info' (see "/usr/include/pulse/introspect.h")
;; contains more fields but we stop at `mute' since the rest are not
;; used by this library.
(define-ftype ft/sink-info
  (struct
    (name         (* char))
    (index        unsigned-32)
    (description  (* char))
    (sample_spec  ft/sample-spec)
    (channel_map  ft/channel-map)
    (owner_module unsigned-32)
    (volume       ft/cvolume)
    (mute         int)))


;;; Wrappers for foreign procedures

(define mainloop-new
  (foreign-procedure "pa_mainloop_new" () void*))

(define mainloop-free
  (foreign-procedure "pa_mainloop_free" (void*) void))

(define mainloop-iterate
  (foreign-procedure "pa_mainloop_iterate" (void* int void*) int))

(define mainloop-get-api
  (foreign-procedure "pa_mainloop_get_api" (void*) void*))

(define context-new
  (foreign-procedure "pa_context_new" (void* string) void*))

(define context-unref
  (foreign-procedure "pa_context_unref" (void*) void))

(define context-set-state-callback
  (foreign-procedure "pa_context_set_state_callback"
                     (void* void* void*)
                     void))

(define context-get-state
  (foreign-procedure "pa_context_get_state" (void*) int))

(define context-connect
  (foreign-procedure "pa_context_connect"
                     (void* string int void*)
                     int))

(define context-disconnect
  (foreign-procedure "pa_context_disconnect" (void*) void))

(define context-get-sink-info
  (foreign-procedure "pa_context_get_sink_info_by_index"
                     (void* unsigned-32 void* void*)
                     void*))

(define context-set-sink-volume
  (foreign-procedure "pa_context_set_sink_volume_by_index"
                     (void* unsigned-32 (* ft/cvolume) void* void*)
                     void*))

(define context-set-sink-mute
  (foreign-procedure "pa_context_set_sink_mute_by_index"
                     (void* unsigned-32 int void* void*)
                     void*))

(define operation-unref
  (let ((fproc (foreign-procedure "pa_operation_unref"
                                  (void*) void)))
    (lambda (ptr)
      (when (pointer? ptr)
        (fproc ptr)))))

(define operation-get-state
  (foreign-procedure "pa_operation_get_state" (void*) int))

(define cvolume-max
  (foreign-procedure "pa_cvolume_max" ((* ft/cvolume)) unsigned-32))

(define cvolume-set
  ;; (cvolume-set FPTR COUNT VOLUMES ...)
  ;;
  ;; Set "ft/cvolume" structure pointed by FPTR (foreign pointer)
  ;; using channel COUNT and channel VOLUMES.
  (let ((fproc (foreign-procedure
                "pa_cvolume_set"
                ((* ft/cvolume) unsigned-32 unsigned-32)
                void*)))
    (lambda (vol-fptr count . volumes)
      (match volumes
        ((volume)
         (fproc vol-fptr count volume))
        (volumes
         (let ((chn-fptr (ftype-&ref ft/cvolume (channels) vol-fptr))
               (val-fptr (ftype-&ref ft/cvolume (values) vol-fptr)))
           (ftype-set! unsigned-8 () chn-fptr count)
           (let loop ((chn 0)
                      (volumes volumes))
             (when (and (< chn count)
                        (not-null? volumes))
               (match volumes
                 ((vol . rest)
                  (ftype-set! unsigned-32 () val-fptr chn vol)
                  (loop (inc chn) rest)))))))))))

(define (cvolume->channels fptr)
  ;; Return list of channel volumes.
  ;; FPTR is `ftype-pointer' to "ft/cvolume" structure.
  (let ((count    (ftype-ref ft/cvolume (channels) fptr))
        (val-fptr (ftype-&ref ft/cvolume (values) fptr)))
    (let loop ((chn (dec count))
               (res '()))
      (if (<0 chn)
        res
        (loop (dec chn)
              (cons (ftype-ref unsigned-32 () val-fptr chn)
                    res))))))

(define (cvolume-alloc)
  ;; Allocate `ft/cvolume' and return ftype pointer to it.
  (let ((buf (foreign-alloc (ftype-sizeof ft/cvolume))))
    (make-ftype-pointer ft/cvolume buf)))


;;; Auxiliary utils

(define (pointer? n)
  (and (fixnum? n) (fx<? 0 n)))

(define (volume->percent volume)
  (exact (round (/ (* volume 100.0)
                   PA_VOLUME_NORM))))

(define (percent->volume percent)
  ;; Division with `round' is more precise than `quotient' (which always
  ;; rounds to the floor).  However, since volume value is usually
  ;; measured in tens of thousands (PA_VOLUME_NORM is 65536), it does
  ;; not matter.
  ;;
  ;; (exact (round (/ (* percent PA_VOLUME_NORM) 100)))
  (quotient (* percent PA_VOLUME_NORM) 100))


;;; State checkers

(define (context-done? state)
  (cond
   ((eqv? state PA_CONTEXT_READY) #t)
   ((eqv? state PA_CONTEXT_FAILED)
    (print-error "Failed to connect to Pulseaudio")
    #t)
   ((eqv? state PA_CONTEXT_TERMINATED)
    (print-error "Pulseaudio connection terminated")
    #t)
   (else #f)))

(define (operation-done? state)
  (cond
   ((eqv? state PA_OPERATION_DONE) #t)
   ((eqv? state PA_OPERATION_CANCELLED)
    (print-error "Pulseaudio operation failed")
    #t)
   (else #f)))


;;; Callbacks

(define state-callback
  (foreign-callable
   (lambda (context userdata)
     (current-context-state (context-get-state context)))
   (void* void*)
   void))

(define sink-info-callback
  (foreign-callable
   (lambda (context info-ptr eol userdata)
     ;; In case of any error, callback is called without any information
     ;; structure (`info-ptr').  See "/usr/include/pulse/introspect.h"
     ;; for details.
     (when (pointer? info-ptr)
       (let* ((fptr      (make-ftype-pointer ft/sink-info info-ptr))
              (mute      (ftype-ref  ft/sink-info (mute) fptr))
              (vol-fptr  (ftype-&ref ft/sink-info (volume) fptr))
              ;; (volume    (cvolume-max vol-fptr))
              (channels  (cvolume->channels vol-fptr)))
         (set-sink-info! (current-sink-info)
           ;; (volume volume)
           (mute? (integer->bool mute))
           (channels channels)))))
   (void* void* int void*)
   void))


;;; Mainloop and context helpers

(define mainloop-iterate-until
  ;; (mainloop-iterate-until MAINLOOP PROC)
  ;;
  ;; Iterate PulseAudio MAINLOOP until (PROC) returns non-false.

  ;; Usually, it takes a couple of dozens of mainloop iterations at most
  ;; to perform an operation, so if 500 iterations is reached then
  ;; something went wrong.
  (let ((max-iterations 500))
    (lambda (mainloop proc)
      (let iterate ((i 0))
        (cond
         ((proc) #t)
         ((fx>? i max-iterations)
          (print-error "Pulseaudio mainloop exceeds ~a iterations"
                       max-iterations))
         (else
          (mainloop-iterate mainloop 1 0)
          (iterate (inc i))))))))

(define-values (call-with-connection disconnect)
  (let ((mainloop #f)
        (context #f))
    (values
      (lambda (proc)
        ;; Call PROC with MAINLOOP and CONTEXT arguments.
        ;; (current-context-state) inside `call-with-connection' returns
        ;; state of CONTEXT.
        (parameterize ((current-context-state #f))
          ;; TODO Checking that mainloop is not #f is not enough, what
          ;; if connection is not active anymore? (e.g., pulseaudio
          ;; daemon is restarted).
          (unless mainloop
            (set! mainloop (mainloop-new))
            (unless (pointer? mainloop)
              (error 'call-with-connection
                     "Failed to create Pulseaudio mainloop"))
            (set! context (context-new (mainloop-get-api mainloop)
                                       "Chez FFI"))
            (context-set-state-callback
             context (foreign-callable-entry-point state-callback) 0)
            (context-connect context #f 0 0)
            (mainloop-iterate-until
             mainloop
             (lambda () (context-done? (current-context-state)))))
          (proc mainloop context)))

      (lambda ()
        (when mainloop
          (context-disconnect context)
          (context-unref context)
          (mainloop-free mainloop)
          (set! context #f)
          (set! mainloop #f))))))

(define (call-context-operation operation . args)
  ;; Call (OPERATION context ARGS ...) and iterate until success.
  (call-with-connection
   (lambda (mainloop context)
     (let ((op-ptr (apply operation context args)))
       (mainloop-iterate-until
        mainloop
        (lambda () (operation-done? (operation-get-state op-ptr))))
       (operation-unref op-ptr)))))


;;; Get/set sink info (volume and mute)

(define get-sink-info
  ;; (get-sink-info [SINK])
  ;;
  ;; Return `sink-info' record for SINK (sink index).
  (case-lambda
    (() (get-sink-info (current-sink)))
    ((index)
     (parameterize ((current-sink-info (sink-info)))
       (call-context-operation context-get-sink-info
                               index
                               (foreign-callable-entry-point
                                sink-info-callback)
                               0)
       (current-sink-info)))))

(define number-of-channels
  ;; (number-of-channels [SINK])
  ;;
  ;; Return the number of channels of SINK (sink index).
  (let ((chn-num (memoize
                  (lambda (sink)
                    (length (sink-info-channels
                             (get-sink-info sink)))))))
    (case-lambda
      (()     (chn-num (current-sink)))
      ((sink) (chn-num sink)))))

(define (set-volume . volumes)
  ;; Set channel VOLUMES of the `current-sink'.
  ;;
  ;; If VOLUMES is a single value, set all channel volumes to this
  ;; value.
  (if (null? volumes)
    (print-error "At least one channel volume should be specified")
    (let ((sink (current-sink))
          ;; XXX Maybe allocate volume structure once and reuse it instead
          ;; of reallocating it on each `set-volume' call?
          (vol-fptr (cvolume-alloc)))
      (apply cvolume-set
             vol-fptr (number-of-channels sink) volumes)
      (call-context-operation context-set-sink-volume
                              sink vol-fptr 0 0)
      (foreign-free (ftype-pointer-address vol-fptr)))))

(define (set-mute mute)
  ;; Set channel MUTE (#t or #f) of the `current-sink'.
  (call-context-operation context-set-sink-mute
                          (current-sink)
                          (bool->integer mute)
                          0 0))

;;; pulseaudio.scm ends here
