;;; match.sls --- Chez-Scheme library for Alex Shinn's Match (Wright Compatible)

;; Copyright (c) 2016 Federico Beffa <beffa@fbengineering.ch>

;; Permission to use, copy, modify, and distribute this software for
;; any purpose with or without fee is hereby granted, provided that the
;; above copyright notice and this permission notice appear in all
;; copies.
;;
;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;; PERFORMANCE OF THIS SOFTWARE.

;;; Commentary:

;; This file originates from
;; <https://github.com/fedeinthemix/chez-matchable/blob/master/matchable.sls>

;;; Code:

;; The reader in #!r6rs mode doesn't allow the '..1' identifier.
#!chezscheme

(library (match)
  (export
    match
    match-lambda
    match-lambda*
    match-let
    match-let*
    match-letrec
    match-named-let
    · … ___ ..1 ..= ..* *** ? $ @ struct object)

  (import
   (rnrs base)
   (rnrs lists)
   (rnrs mutable-pairs)
   (rnrs records syntactic)
   (rnrs records procedural)
   (rnrs records inspection)
   (rnrs syntax-case)
   (only (chezscheme) iota include)
   (lib-aux)
   (srfi :0))

  ;; We declare end export the symbols used as auxiliary identifiers
  ;; in 'syntax-rules' to make them work in Chez Scheme's interactive
  ;; environment. (FBE)
  ;;
  ;; Also "_" is replaced with "·" as the special identifier matching
  ;; anything and not binding.  This is because R6RS forbids its use
  ;; as an auxiliary literal in a syntax-rules form.
  (define-aux-symbols · … ___ ..1 ..= ..* *** ? $ @ struct object)

  (include "match.r6rs.scm")
  (include "match.scm"))

;;; match.sls ends here
