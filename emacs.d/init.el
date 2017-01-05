;;; package --- Summary
;;; Commentary:
;;; Begin initialization
;;; Turn off mouse interface early in startup to avoid momentary display
;;; Code:
(when window-system
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

(setq inhibit-startup-message t)
(setq initial-scratch-message "")

(setq ad-redefinition-action 'accept)

(setq-default indent-tabs-mode nil)

(set-language-environment "Korean")
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(when (and window-system (eq system-type 'darwin))
  (set-face-attribute 'default nil :family "Source code pro")
  (set-face-attribute 'default nil :height 140)
  (set-fontset-font t 'hangul (font-spec :name "NanumGothicCoding")))

(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)

(setq echo-keystrokes 0.01)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; 미니 버퍼로 들어갈때 영문키입력으로 전환(그냥되는것같은데 예제로 남김)
;; (add-hook 'minibuffer-setup-hook (lambda () (set-input-method nil)))

;;; 라인넘버 보이도록
;;; (global-linum-mode t)
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(unless window-system
  (setq interprogram-cut-function 'paste-to-osx)
  (setq interprogram-paste-function 'copy-from-osx))

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-conservatively 200) ;; 스크롤 도중에 센터로 커서 이동하지 않도록
(setq scroll-margin 3) ;; 스크롤시 남기는 여백

;;; mouse setup
(require 'mouse)
(xterm-mouse-mode t)
;(defun track-mouse (e))

;; 백업들 끄기
(setq backup-inhibited t)
(setq make-backup-files nil)
(setq auto-save-default nil)

;; no popup frame(새버퍼열때 현재 프레임에서 열기)
(setq ns-pop-up-frames nil)
(setq pop-up-frames nil)

;; 소리 끄고 비쥬얼벨로
(setq visible-bell t)

;; splitting
(defun split-smart ()
  (print "split-smart")
  (if (< (window-pixel-width) (window-pixel-height))
      (split-window-vertically)
    (split-window-horizontally)))
(add-hook 'temp-buffer-setup-hook 'split-smart)
(setq split-width-threshold 120)
;;(setq split-height-threshold nil)

;;; Set up package
(require 'package)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)
; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; unset some default keybinding for my custom key bindings
(define-key global-map (kbd "C-j") nil)

(eval-when-compile
  (require 'use-package))

;; dired
(put 'dired-find-alternate-file 'disabled nil)

;; dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 10)
                          (projects . 10))))

;; Setup PATH environment
(use-package exec-path-from-shell
  :ensure t
  :init
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

;;;; Themes
(use-package zenburn-theme
  :ensure t
  :init
  (load-theme 'zenburn t))

;;; multi term
(use-package multi-term
  :ensure t
  :init
  (setq multi-term-program "/usr/local/bin/zsh")
  :bind
  ("C-c t" . multi-term))

(use-package paren
  :init
  (show-paren-mode 1)
  (setq show-paren-delay 0))

;; hl line
(use-package hl-line
  :init
  (global-hl-line-mode +1))

(use-package highlight-thing
  :ensure t
  :init
  (setq highlight-thing-case-sensitive-p t)
  (setq highlight-thing-limit-to-defun t)
  (add-hook 'prog-mode-hook 'highlight-thing-mode))

;;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package git-gutter
  :ensure t
  :init
  (global-git-gutter-mode +1))

(use-package git-timemachine
  :ensure t
  :bind
  ("C-j t" . git-timemachine-toggle))

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode)
  :bind
  ("C-z" . undo)
  ("C-S-z" . undo-tree-redo))

;;; Eyebrowse
(use-package eyebrowse
  :ensure t
  :init
  (eyebrowse-mode t)
  :bind
  ("C-j ;" . eyebrowse-last-window-config)
  ("C-j 0" . eyebrowse-close-window-config)
  ("C-j 1" . eyebrowse-switch-to-window-config-1)
  ("C-j 2" . eyebrowse-switch-to-window-config-2)
  ("C-j 3" . eyebrowse-switch-to-window-config-3))

;;; ace window
(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?1 ?2 ?3 ?4 ?5))
  ;(setq aw-dispatch-always t)
  :bind ("C-x o" . ace-window))

;; swiper and ivy
(use-package swiper
  :ensure t
  :init
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers nil)
  ;; number of result lines to display
  (setq ivy-height 12)
  ;; does not count candidates
  (setq ivy-count-format "")
  :bind
  (("M-x". counsel-M-x)
  ("C-x C-f". counsel-find-file)
  ("C-c r". counsel-recentf)
  ("C-c g". counsel-ag)
  ("C-c e". ivy-switch-buffer)
  ("C-c 4 e". ivy-switch-buffer-other-window)
  ("C-c o". counsel-imenu)
  ("C-c y" . counsel-yank-pop)
  ("C-j i". swiper)
  ("C-j o". swiper-all)
  :map ivy-mode-map
  ("S-SPC" . toggle-input-method)))

;;; Avy
(use-package avy
  :ensure t
  :bind
  ("C-j j". avy-goto-char-2)
  ("C-j k". avy-goto-char)
  ("C-j w". avy-goto-word-1)
  ("C-j g". avy-goto-line))

(use-package git-timemachine
  :ensure t)

(use-package goto-last-change
  :ensure t
  :bind
  ("C-j l" . goto-last-change))

(use-package dumb-jump
  :bind (("C-j n" . dumb-jump-go-other-window)
         ("C-j m" . dumb-jump-go))
  :config (setq dumb-jump-selector 'ivy)
  :ensure t)

;;; hydra
(use-package hydra
  :ensure t
  :init
  ;; (defhydra hydra-jump (:hint nil)
  ;;   "MOVE"
  ;;   ("i" swiper "swiper!")
  ;;   ("j" avy-goto-char "to char")
  ;;   ("k" avy-goto-char-2 "to 2char")
  ;;   ("w" avy-goto-word-1 "to word")
  ;;   ("g" avy-goto-line "to line")
  ;;   ("l" goto-last-change "to last Change")
  ;;   ("t" git-timemachine-toggle "to timemachine"))

  ;; (define-key global-map (kbd "C-j") 'hydra-jump/body)
  )

(use-package company
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'company-mode)
  (add-hook 'org-mode-hook 'company-mode)
  :config
  (setq company-idle-delay 0.3)
  (setq company-show-numbers t)
  (setq company-dabbrev-downcase nil)
  (setq company-minimum-prefix-length 2)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous))

(use-package yasnippet
  :ensure t
  :init
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'org-mode-hook #'yas-minor-mode)
  :config
  (setq yas-snippet-dirs '("~/dotfiles/yaSnippets"))
  (yas-reload-all))

;;; Iedit
(use-package iedit
  :ensure t)

;;; Auto pair
(use-package autopair
  :ensure t
  :init
  (add-hook 'js2-mode-hook #'autopair-mode))

;;; Expand Region
(use-package expand-region
  :ensure t
  :bind
  ("C-c v" . er/expand-region))

;; recent file list
(use-package recentf
  :init
  (setq recentf-max-saved-items 300
        recentf-exclude '("/auto-install/" ".recentf" "/repos/" "/elpa/"
                          "\\.mime-example" "\\.ido.last" "COMMIT_EDITMSG"
                          ".gz"
                          "~$" "/tmp/" "/ssh:" "/sudo:" "/scp:"))
  (recentf-mode t))

(use-package counsel
  :ensure t)

;;; projectile
(use-package projectile
  :ensure t
  :init
  (projectile-global-mode)
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-enable-caching t)
  ;;; 아무데서나 프로젝타일을 사용하게하려면 주석해제
  ;; (setq projectile-require-project-root nil)
  (setq projectile-indexing-method 'alien)
  (setq projectile-globally-ignored-directories
        (append '(".DS_Store" ".git" ".svn" "out" "repl" "target" "dist" "lib" "node_modules" "libs")
                projectile-globally-ignored-directories))
  (setq projectile-globally-ignored-files
        (append '(".#*" ".DS_Store" "*.tar.gz" "*.tgz" "*.zip" "*.png" "*.jpg" "*.gif")
                projectile-globally-ignored-files)))

;;; countsel-projectile
(use-package counsel-projectile
  :ensure t
  :init
  (counsel-projectile-on))

;;; Web mode
(use-package web-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode)))

;;; flyCheck
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode)
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers
                        '(javascript-jshint)))
  (setq flycheck-checkers '(javascript-eslint)))

;;;; javascript
;; js2-mode
(use-package js2-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-hook 'js2-mode-hook
          '(lambda ()
             (js2-imenu-extras-mode)))
  :config
  (setq js2-include-node-externs t)
  (setq-default js2-basic-offset 4
                js1-bounce-indent-p nil)
  (setq-default js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil))

;; tern
(use-package tern
  :ensure t
  :init
  (autoload 'tern-mode' "tern.el" nil t)
  (add-hook 'js-mode-hook (lambda () (tern-mode t))))

(use-package company-tern
  :ensure t
  :init
  (add-to-list 'company-backends 'company-tern))

;; jsdoc
(use-package js-doc
  :ensure t
  :bind
  (:map js2-mode-map
        ("\C-cd" . js-doc-insert-function-doc)
        ("@" . js-doc-insert-tag))
  :config
  (setq js-doc-mail-address "your email address"
      js-doc-author (format "your name <%s>" js-doc-mail-address)
      js-doc-url "url of your website"
      js-doc-license "MIT"))

;;; Clojure setup
;; CIDER
(use-package cider
  :ensure t
  :init
  (add-hook 'cider-repl-mode-hook #'company-mode)
  (add-hook 'cider-mode-hook #'company-mode))

;; clojure-mode
(use-package clojure-mode
  :ensure t)

;;; C# and Unity
(use-package csharp-mode
  :ensure t
  :init
  (add-hook 'csharp-mode-hook #'company-mode))

;;; Swift
(use-package swift-mode
  :ensure t)

;; Sourcekittendaemon이 설치 되어 있어야함
;; https://github.com/terhechte/SourceKittenDaemon
(use-package company-sourcekit
  :ensure t
  :init
  (add-to-list 'company-backends 'company-sourcekit))

;;; org
(use-package ob-swift
  :ensure t)

(use-package ox-gfm
  :ensure t)

(use-package ox-reveal
  :ensure t
  :init
  (setq org-reveal-root "https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.3.0/"))

(use-package org-tree-slide
  :ensure t)

(use-package org
  :ensure t
  :bind
  (("\C-cl" . org-store-link)
  ("\C-ca" . org-agenda)
  ("\C-cc" . org-capture)
  ("\C-cb" . org-iswitchb))
  :init
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  (setq org-agenda-files (list "~/org"))
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  (setq org-babel-clojure-backend 'cider)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((js . t)
     (emacs-lisp . t)
     (clojure . t)
     (plantuml . t)
     (swift . t)
     (sh . t)
     ))
  (setq org-confirm-babel-evaluate nil)
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-src-strip-leading-and-trailing-blank-lines t)
  (setq org-log-done t)
  (setq org-edit-src-content-indentation 0)
  (setq org-adapt-indentation nil)
  (eval-after-load "org"
    '(require 'ox-gfm nil t))
  (setq org-plantuml-jar-path
        (expand-file-name "~/plantuml/plantuml.jar"))

  ;;yasnippet 하고 tab 충돌 해결
  (defun yas/org-very-safe-expand ()
    (let ((yas-fallback-behavior 'return-nil)) (yas-expand)))

  (add-hook 'org-mode-hook
            (lambda ()
              (make-variable-buffer-local 'yas-expand-from-trigger-key)
              (setq yas-expand-from-trigger-key [tab])
              (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
              (define-key yas/keymap [tab] 'yas-next-field)))

  ;; org에서 linewrap 되게
  (add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))
  :config
  (define-key org-mode-map (kbd "C-j") nil)
  (define-key org-mode-map (kbd "M-j") 'org-return-indent)
  (define-key org-mode-map (kbd "<return>") 'org-return-indent))

;; (require 'org)
;; (require 'ox-reveal)
;; (require 'ob-clojure)

;;; markdown mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;;; Magit
(use-package magit
  :ensure t
  :init
  (add-to-list 'load-path "~/.emacs.d/site-lisp/magit/lisp")
  ;; magit 오토 리버트시 버퍼의 브랜치명까지 갱신하도록
  (setq auto-revert-check-vc-info t)
  (with-eval-after-load 'info
    (info-initialize)
    (add-to-list 'Info-directory-list
                 "~/.emacs.d/site-lisp/magit/Documentation/"))
  :bind
  ("C-c m" . magit-status))

;;; prodigy
(use-package prodigy
  :ensure t
  :bind
  ("C-c f" . prodigy)
  :init
  (prodigy-define-service
    :name "Tui Chart server"
    :command "npm"
    :cwd "~/masterpiece/ws_nhn/fedev/tui.chart"
    :args '("run" "dev")
    :port 8080
    :tags '(webpack-server))

  (prodigy-define-service
    :name "Tui Chart test"
    :command "npm"
    :cwd "~/masterpiece/ws_nhn/fedev/tui.chart"
    :args '("run" "test")
    :tags '(karma))

  (prodigy-define-tag
    :name 'webpack-server
    :ready-message "Http://0.0.0.0:[0-9]+/webpack-dev-server/")

  (prodigy-define-tag
    :name 'karma
    :ready-message " Executed [0-9]+ of [0-9]+ SUCCESS"))

(use-package dash-at-point
  :ensure t
  :init
  (add-to-list 'dash-at-point-mode-alist '(js2-mode . "js"))
  (add-to-list 'dash-at-point-mode-alist '(elisp-mode . "elisp"))
  (add-to-list 'dash-at-point-mode-alist '(clojure-mode . "clojure"))
  (add-to-list 'dash-at-point-mode-alist '(csharp-mode . "unity3d"))
  :bind
  ("C-c d" . dash-at-point)
  ("C-c ." . dash-at-point-with-docset))

(use-package google-translate
  :ensure t
  :init
  (require 'google-translate)
  (require 'google-translate-smooth-ui)
  (setq google-translate-translation-directions-alist
        '(("en" . "ko") ("ko" . "en")))
  (setq google-translate-pop-up-buffer-set-focus t)
  (setq google-translate-output-destination 'echo-area)
  (setq max-mini-window-height 0.5)
  :bind
  ("C-c n" . google-translate-smooth-translate))


(provide 'init)
;;; init.el ends here
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hi-yellow ((t (:foreground nil :background nil :underline t)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (company-sourcekit flycheck-swift swift-mode google-translate company-tern company dash-at-point undo-tree dumb-jump highlight-thing highlight-parentheses omnisharp csharp-mode yasnippet smooth-scroll org-tree-slide counsel projectile hydra prodigy autopair paredit iedit ace-window multi-term markdown-mode magit ox-reveal ox-gfm counsel-projectile swiper eyebrowse zenburn-theme cyberpunk-theme base16-theme tern-auto-complete tern auto-complete flycheck cider js-doc js2-mode web-mode goto-last-change git-timemachine git-gutter rainbow-delimiters expand-region use-package))))
