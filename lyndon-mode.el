;;; lyndon-mode.el --- Display Lyndon factorizations of a buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Reed Mullanix
;; Author: Reed Mullanix <reedmullanix@gmail.com>
;; Keywords: strings, tools
;; Version: 0.0.1
;; URL: https://github.com/totbwf/lyndon-mode
;; Package-Requires: ((emacs "24.3"))

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

;; This package offers an minor mode for displaying Lyndon factorization
;; of the buffer.  To enable, simply call `lyndon-mode'.

;;; Code:

;; Faces borrowed from `re-builder', with some modifications.
(defface lyndon-factor-0
  '((((class color) (background light))
     :background "lightblue")
    (((class color) (background dark))
     :background "steelblue4")
    (t
     :inverse-video t))
  "Used for displaying the 0th Lyndon factor."
  :group 'lyndon-factor)

(defface lyndon-factor-1
  '((((class color) (background light))
     :background "aquamarine")
    (((class color) (background dark))
     :background "purple3")
    (t
     :inverse-video t))
  "Used for displaying the 1st Lyndon factor."
  :group 'lyndon-factor)

(defface lyndon-factor-2
  '((((class color) (background light))
     :background "springgreen")
    (((class color) (background dark))
     :background "chartreuse4")
    (t
     :inverse-video t))
  "Used for displaying the 2nd Lyndon factor."
  :group 'lyndon-factor)

(defface lyndon-factor-3
  '((((min-colors 88) (class color) (background light))
     :background "yellow1")
    (((class color) (background light))
     :background "yellow")
    (((class color) (background dark))
     :background "sienna4")
    (t
     :inverse-video t))
  "Used for displaying the 3rd Lyndon factor."
  :group 'lyndon-factor)

(defvar-local lyndon-mode-overlays nil
  "List of overlays used by `lyndon-mode'.")

(defun lyndon-mode-delete-overlays ()
  "Delete all `lyndon-mode' overlays in the current buffer."
  (mapc 'delete-overlay lyndon-mode-overlays)
  (setq lyndon-mode-overlays nil))

(defun lyndon-mode-update-overlays ()
  "Compute the Lyndon factorization of the current buffer, and update overlays."
  (interactive)
  (lyndon-mode-delete-overlays)
  (save-excursion
    (goto-char (point-min))
    (let ((nface 0)
  	s e)
      (while (not (eobp))
        (setq s (point))
        (setq e (1+ (point)))
        (while (and (< e (point-max)) (<= (char-after s) (char-after e)))
  	(if (< (char-after s) (char-after e))
              (setq s (point))
  	  (setq s (1+ s)))
  	(setq e (1+ e)))
        (while (<= (point) s)
  	(let ((overlay (make-overlay (point) (+ (point) (- e s))))
                (face (intern (format "lyndon-factor-%d" nface))))
  	  (overlay-put overlay 'face face)
  	  (push overlay lyndon-mode-overlays)
  	  (setq nface (mod (1+ nface) 4))
  	  (forward-char (- e s))))))))

(defun lyndon-mode-after-change (_start _end _len)
  "Shim `lyndon-mode-update-overlays' for `after-change-functions'."
  (lyndon-mode-update-overlays))

;;;###autoload
(define-minor-mode lyndon-mode
  "Display the lyndon factorization of the current buffer."
  :lighter " Lyndon"
  (if lyndon-mode
      (progn
        (add-hook 'after-change-functions #'lyndon-mode-after-change nil t)
        (lyndon-mode-update-overlays))
    (lyndon-mode-delete-overlays)
    (remove-hook 'after-change-functions #'lyndon-mode-after-change t)))

(provide 'lyndon-mode)
;;; lyndon-mode.el ends here
