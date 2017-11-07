;;; upbo.el --- Karma Test Runner Emacs Integration
;;
;; Filename: upbo.el
;; Description: karma Test Runner Emacs Integration
;; Author: Sungho Kim(shiren)
;; Maintainer: Sungho Kim(shiren)
;; URL: http://github.com/shiren
;; Version: 0.0.0
;; Package-Requires: ((pkg-info "0.4") (emacs "24"))
;; Keywords: language, javascript, js, karma, testing

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;  Karma Test Runner Emacs Integration

;;  Usage:
;;  (add-to-list 'upbo-project-config '("~/masterpiece/tui.chart/" "~/masterpiece/tui.chart/karma.conf.js"))

;;; Code:
(defgroup upbo nil
  "Karma Test Runner Emacs Integration"
  :prefix "upbo-"
  :group 'applications
  :link '(url-link :tag "Github" "https://github.com/shiren")
  :link '(emacs-commentary-link :tag "Commentary" "karma"))

(defcustom upbo-project-config '()
  "Each element is a list of the form (KEY VALUE).")

(defvar upbo-last-result)

;;;;;;;;; upbo-view-mode
(defun open-upbo-view ()
  (interactive)
  (let* ((buffer-name (get-upbo-view-buffer-name))
         (upbo-view-buffer (get-buffer buffer-name)))
    (unless upbo-view-buffer
      (generate-new-buffer buffer-name))
    (with-current-buffer upbo-view-buffer
      (unless (string= major-mode "upbo-view-mode")
        (upbo-view-mode))
      (switch-to-buffer upbo-view-buffer))))

(defun kill-upbo-buffer ()
  "HELLO"
  (interactive)
  (kill-buffer (get-upbo-view-buffer-name)))

(defvar upbo-view-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "w") 'karma-auto-watch)
    (define-key map (kbd "r") 'karma-single-run)
    (define-key map (kbd "k") 'kill-upbo-buffer)
    map))

(define-key upbo-view-mode-map (kbd "w") 'karma-auto-watch)
(define-key upbo-view-mode-map (kbd "r") 'karma-single-run)
(define-key upbo-view-mode-map (kbd "k") 'kill-upbo-buffer)

(define-derived-mode upbo-view-mode special-mode "upbo-view"
  "Major mode for upbo"
  (use-local-map upbo-view-mode-map)

  ;; (let ((inhibit-read-only t))
  ;;   (insert (concat "Project: " (git-root-dir) "\n"))
  ;;   (insert (concat "Karma conf: " (get-karma-conf-setting) "\n"))
  ;;   (insert "upbo started\nw: auto-watch, r: single-run, k: kill upbo"))
  )

;;;;;;;; Minor
(defun karma-start (args upbo-view-buffer-name)
  (print upbo-view-buffer-name)
  (let (upbo-process (get-buffer-process upbo-view-buffer-name))
    (when (process-live-p upbo-process)
      (kill-process upbo-process)))

  (let ((default-directory (git-root-dir)))
    (apply 'start-process-shell-command
           (append
            (list "upboProcess"
                  upbo-view-buffer-name
                  "npx" "karma" "start"
                  (get-karma-conf-setting)
                  "--reporters" "dots")
            args)))

  ;; 프로세스 필터 설정
  (set-process-filter (get-buffer-process upbo-view-buffer-name) 'upbo-minor-process-filter))

(defun karma-single-run ()
  (interactive)
  (karma-start '("--single-run") (get-upbo-view-buffer-name)))

(defun karma-auto-watch ()
  (interactive)
  (karma-start '("--auto-watch") (get-upbo-view-buffer-name)))

(defun parse-output-for-mode-line (output)
  (setq upbo-last-result
        (if (string-match "Executed \\([0-9]+\\) of \\([0-9]+\\)" output)
            (concat (match-string 1 output) "/" (match-string 2 output))
          "~"))
  (force-mode-line-update))

(defun update-upbo-view-buffer (buffer output)
  (let ((inhibit-read-only t))
    (set-buffer buffer)
    (insert output)
    ;; ansi 코드있는 버퍼 렌더링하기
    (ansi-color-apply-on-region (point-min) (point-max))))

(defun upbo-minor-process-filter (process output)
  (parse-output-for-mode-line output)
  (update-upbo-view-buffer (process-buffer process) output))

(defun get-upbo-view-buffer-name ()
  (concat "*upbo:" (git-root-dir) "*"))

(defun git-root-dir ()
  "Returns the current directory's root Git repo directory, or
NIL if the current directory is not in a Git repo."
  (let ((dir (locate-dominating-file default-directory ".git")))
    (when dir
      (file-name-directory dir))))

(defun get-karma-conf-setting ()
  (car (cdr (car (seq-filter
                  (lambda (el)
                    (string= (car el) (git-root-dir))) upbo-project-config)))))

(defvar upbo-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key global-map (kbd "C-c u r") 'open-upbo-view)
    (define-key global-map (kbd "C-c u s") 'karma-single-run)
    (define-key global-map (kbd "C-c u w") 'karma-auto-watch)
    map)
  "The keymap used when `upbo-mode' is active.")

(defun upbo-mode-hook ()
  "Hook which enables `upbo-mode'"
  (upbo-mode 1))

(defun project-test-result ()
  (if upbo-last-result
      (concat "[" upbo-last-result "]")
    ""))

;;;###autoload
(define-minor-mode upbo-mode
  "Toggle upbo mode.
Key bindings:
\\{upbo-mode-map}"
  :lighter (:eval (format " upbo%s" (project-test-result)))
  :group 'upbo
  :global nil
  :keymap 'upbo-mode-map
  (make-local-variable 'upbo-last-result)

  (setq upbo-last-result nil))

(add-hook 'js-mode-hook 'upbo-mode-hook)
(add-hook 'js2-mode-hook 'upbo-mode-hook)

(provide 'upbo)
;;; upbo.el ends here