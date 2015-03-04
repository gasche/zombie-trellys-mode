;;; zombie-mode.el --- A minor mode for interaction with Zombie Trellys  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  David Raymond Christiansen

;; Author: David Raymond Christiansen <drc@drc.itu.dk>
;; Keywords: languages
;; Package-Requires: ((emacs "24") (cl-lib "0.5"))
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a minor mode for interaction with Zombie - a
;; dependently-typed language that is a result of the Trellys
;; project. Due to limited time, zombie-mode is implemented as a minor
;; mode with a command for loading the current buffer's file into
;; Zombie and viewing the results. Use this with `haskell-mode' for
;; somewhat reasonable syntax highlighting.
;;
;; This could eventually become a proper major mode.
;;
;; Zombie is available from https://code.google.com/p/trellys/

;;; Code:
(require 'compile)
(require 'cl-lib)



(defgroup zombie nil
  "Customization options for working with Zombie."
  :prefix 'zombie-
  :group 'languages)

(defcustom zombie-command "trellys"
  "The path to the Zombie executable."
  :type '(string)
  :group 'zombie)



(defun zombie--compilation-buffer-name-function (_mode)
  "Compute a buffer name for the zombie-mode compilation buffer."
  "*zombie*")

(defun zombie-compile-buffer ()
  "Load the current file into Zombie."
  (interactive)
  (let* ((filename (buffer-file-name))
         (dir (file-name-directory filename))
         (file (file-name-nondirectory filename))
         (command (concat zombie-command " " file))

         ;; Emacs compile config stuff - these are special vars
         (compilation-buffer-name-function
          'zombie--compilation-buffer-name-function)
         (default-directory dir))
    (compile command)))



(defvar zombie-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-l") #'zombie-compile-buffer)
    map)
  "The keymap for `zombie-minor-mode'.")

(define-minor-mode zombie-minor-mode
  "A minor mode for calling Zombie." nil " Z"
  'zombie-minor-mode-map
  (when zombie-minor-mode
    (add-to-list 'compilation-error-regexp-alist-alist
                 '(zombie-type-error
                   "\\(Type Error:\\)\\s-+\\(\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\):\\)"
                   3 4 5 nil 2 (1 "compilation-error")))
    (cl-pushnew 'zombie-type-error compilation-error-regexp-alist)))


(provide 'zombie-mode)
;;; zombie-mode.el ends here
