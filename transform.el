;;; transform.el --- example Emacs package
;; Copyright (C) 2016 Rune Kaagaard

;; Author: Rune Kaagaard <rumi.kg@gmail.com>
;; Maintainer: Rune Kaagaard <rumi.kg@gmail.com>
;; URL: https://github.com/runekaagaard/emacs-transform
;; Version: 0.1
;; Keywords: shell
;; Package-Requires: ((s "1.7.0")(f "20160426.527"))

;;; Code:

(require 's)
(require 'f)

(setq transform-mode-map (make-sparse-keymap))
(define-key transform-mode-map (kbd "C-c C-r") 'transform-run)
(define-key transform-mode-map (kbd "C-c C-c") 'transform-confirm)

(defun transform-read-line (name)
  (let ((match
    (second(s-match
     (s-concat "#" name " \\(.*\\)\n")
     (buffer-substring-no-properties (point-min) (point-max))
    ))))
    (if (not match)
      (error (s-concat "Missing line: #" name))
      (s-trim match)
    )
  )
)

(defun transform-read-section (name)
  (let
    ((match
      (second(s-match
       (s-concat "#" name "\\([[:unibyte:]]+\\)" "#end" name)
       (buffer-substring-no-properties (point-min) (point-max))
      ))
    ))
    (if (not match)
      (error (s-concat "Missing or unmatched section: #" name))
      (s-chop-prefix "\n" (s-chop-suffix "\n" match))
    )
  )
)

(defun transform-replace-section (name content)
  (save-excursion
    (beginning-of-buffer)
    (re-search-forward
      (s-concat "#" name "\\([[:unibyte:]]+\\)" "#end" name)
      nil
      t
    )
    (replace-match (s-concat "#output\n" (s-chop-suffix "\n" content) "\n#endoutput") t t)
  )
)

(defgroup transform nil
  "Perform a transformation on the active region by writing a script in a new buffer."
  :group 'external)

(defcustom transform-transformation-template "#!/usr/bin/env bash
while IFS='' read -r LINE || [ -n \"$LINE\" ]; do
  printf '%s\\n' \"$LINE\"
done"
  "The default content of the #transform [content] #endtransform block."
  :type '(string)
  :group 'transform)

;;;###autoload
(defun transform-start (begin end)
  (interactive "r")
  (let (
    (buffer-name (generate-new-buffer "*transform*"))
    (current-buffer-name (buffer-name))
    (input (buffer-substring begin end))
  )
      (switch-to-buffer-other-window buffer-name)
      (insert (s-concat
        "#buffer " current-buffer-name "\n"
        "#beginpos " (number-to-string begin) "\n"
        "#endpos " (number-to-string end) "\n"
        "\n"
        "#input\n" input "\n#endinput\n\n"
        "#transform\n" transform-transformation-template "\n#endtransform\n\n"
        "#output\n" "#endoutput"
      ))
      (transform-mode)
  )
)

;;;###autoload
(defun transform-run ()
  (interactive)
  (f-write (transform-read-section "input") 'utf-8 "/tmp/transform-input")
  (f-write (transform-read-section "transform") 'utf-8 "/tmp/transform-transform")
  (set-file-modes "/tmp/transform-transform" #o700)
  (transform-replace-section
    "output"
    (shell-command-to-string "cat /tmp/transform-input | /tmp/transform-transform")
  )
)

;;;###autoload
(defun transform-confirm ()
  (interactive)
  (let (
    (output (transform-read-section "output"))
    (buffer-name (transform-read-line "buffer"))
    (beginpos (string-to-number (transform-read-line "beginpos")))
    (endpos (string-to-number (transform-read-line "endpos")))
  )
    (switch-to-buffer-other-window buffer-name)
    (delete-region beginpos endpos)
    (insert output)
  )
)

(setq transform-highlights
      '(
        ("#output\\|#input\\|#transform\\|#endoutput\\|#endinput\\|#endtransform\\|#buffer\\|#beginpos\\|#endpos" . font-lock-constant-face))
)

;;;###autoload
(define-derived-mode transform-mode fundamental-mode
  (kill-all-local-variables)
  (setq major-mode 'transform-mode)
  (setq font-lock-defaults '(transform-highlights))
  (setq mode-name "Transform")
  (use-local-map transform-mode-map)
)

(provide 'transform)

;;; transform.el ends here
