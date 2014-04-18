;;; For working use emacs keybindings with russian keymap in Linux Desktop.

(defun reverse-input-method (input-method)
  "Build the reverse mapping of single letters from INPUT-METHOD."
  (interactive
   (list (read-input-method-name "Use input method (default current): ")))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (let ((current current-input-method)
        (modifiers '(nil (control) (meta) (control meta))))
    (when input-method
      (activate-input-method input-method))
    (when (and current-input-method quail-keyboard-layout)
      (dolist (map (cdr (quail-map)))
        (let* ((to (car map))
               (from (quail-get-translation
                      (cadr map) (char-to-string to) 1)))
          (when (and (characterp from) (characterp to))
            (dolist (mod modifiers)
              (define-key local-function-key-map
                  (vector (append mod (list from)))
                (vector (append mod (list to)))))))))
    (when input-method
      (activate-input-method current))))

(reverse-input-method 'russian-computer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Great thing but there is ruby error when creating new note

(add-to-list 'load-path "~/.emacs.d/")

                                        ;(add-to-list 'load-path "<your load path>")
;;EVERNOTE_MODE
(require 'evernote-mode)
(setq evernote-username "pashapm") ; optional: you can use this username as default.
(setq evernote-enml-formatter-command '("w3m" "-dump" "-I" "UTF8" "-O" "UTF8")) ; option
(global-set-key "\C-cec" 'evernote-create-note)
(global-set-key "\C-ceo" 'evernote-open-note)
(global-set-key "\C-ces" 'evernote-search-notes)
(global-set-key "\C-ceS" 'evernote-do-saved-search)
(global-set-key "\C-cew" 'evernote-write-note)
(global-set-key "\C-cep" 'evernote-post-region)
(global-set-key "\C-ceb" 'evernote-browser)

;; Updatetee with new helm plugin
;; http://steckerhalter.co.vu/posts/emacs-helm-know-how.html
;; https://github.com/emacs-helm/helm/wiki
;; (add-to-list 'anything-sources anything-c-source-evernote-title)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m/")
(require 'w3m-load)

                                        ;(require 'mime-w3m)
;;;;  http://www.emacswiki.org/emacs/WThreeMHintsAndTips

(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
(global-set-key "\C-xm" 'browse-url-at-point)

(autoload 'browse-url-interactive-arg "browse-url")

;;------------—

(defun w3m-new-tab ()
  (interactive)
  (w3m-copy-buffer nil nil nil t))

(defun w3m-browse-url-new-tab (url &optional new-session)
  (interactive)
  (w3m-new-tab)
  (w3m-browse-url url))

(setq browse-url-browser-function 'w3m-browse-url-new-tab)

(setq browse-url-browser-function 'w3m-browse-url
      browse-url-new-window-flag t)

;;-------------—

(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map "\C-xm" 'dired-w3m-find-file)))

(defun dired-w3m-find-file ()
  (interactive)
  (require 'w3m)
  (let ((file (dired-get-filename)))
    (if (y-or-n-p (format "Open 'w3m' %s " (file-name-nondirectory file)))
        (w3m-find-file file))))

;;-----------—

    (add-hook 'w3m-display-hook
              (lambda (url)
                (let ((buffer-read-only nil))
                  (delete-trailing-whitespace))))

;;;;;;;;;;;;;;;;;    http://beatofthegeek.com/2014/02/my-setup-for-using-emacs-as-web-browser.html

;;change default browser for 'browse-url' to w3m
(setq browse-url-browser-function 'w3m-goto-url-new-session)

;;change w3m user-agent to android
(setq w3m-user-agent "Mozilla/5.0 (Linux; U; Android 2.3.3; zh-tw; HTC_Pyramid Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.")

;;quick access hacker news
(defun hn ()
(interactive)
(browse-url "http://news.ycombinator.com"))

;;quick access reddit
(defun reddit (reddit)
"Opens the REDDIT in w3m-new-session"
(interactive (list
(read-string "Enter the reddit (default: psycology): " nil nil "psychology" nil)))
(browse-url (format "http://m.reddit.com/r/%s" reddit))
)

;;i need this often
(defun wikipedia-search (search-term)
"Search for SEARCH-TERM on wikipedia"
(interactive
(let ((term (if mark-active
(buffer-substring (region-beginning) (region-end))
(word-at-point))))
(list
(read-string
(format "Wikipedia (%s):" term) nil nil term)))
)
(browse-url
(concat
"http://en.m.wikipedia.org/w/index.php?search="
search-term
))
)

;;when I want to enter the web address all by hand
(defun w3m-open-site (site)
"Opens site in new w3m session with 'http://' appended"
(interactive
(list (read-string "Enter website address(default: w3m-home):" nil nil w3m-home-page nil )))
(w3m-goto-url-new-session
(concat "http://" site)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FROM SACHA CHUA

(defun org-get-subtree-region ()
  "Return the start and end of the current subtree."
  (save-excursion
    (let (beg end folded (beg0 (point)))
      (if (org-called-interactively-p 'any)
          (org-back-to-heading nil) ; take what looks like a subtree
          (org-back-to-heading t)) ; take what is really there
      (org-back-over-empty-lines)
      (setq beg (point))
      (skip-chars-forward " \t\r\n")
      (save-match-data
        (save-excursion (outline-end-of-heading)
                        (setq folded (outline-invisible-p)))
        (condition-case nil
            (org-forward-same-level (1- n) t)
          (error nil))
        (org-end-of-subtree t t))
      (org-back-over-empty-lines)
      (setq end (point))
      (list beg end))))

(defun org-post-subtree-to-evernote (&optional notebook)
  "Post the current subtree to Evernote."
  (interactive)
  (let ((title (nth 4 (org-heading-components)))
        (body (apply 'buffer-substring-no-properties (sacha/org-get-subtree-region))))
    (with-temp-buffer
      (insert body)
      (enh-command-with-auth
       (let (note-attr)
         (setq note-attr
               (enh-command-create-note (current-buffer)
                                        title
                                        notebook
                                        nil "TEXT"))
         (enh-update-note-and-new-tag-attrs note-attr))))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; http://stackoverflow.com/questions/17483598/maintaining-multiple-emacs-configurations-at-the-same-timee


(defvar *emacs-prelude-enabled* nil)
(defvar *emacs-starter-enabled* nil)
(defvar *default-config-enabled* nil)
(defvar *emacs-live-enabled* nil)
(defvar *emacs-graphene-enabled* nil)
(defvar *emacs-dotemacs-enabled* t)
(defvar *emacs-ome-enabled* nil)

(cond (*emacs-prelude-enabled*
       (add-to-list 'load-path "~/.emacs1.d/")
       (load "~/.emacs1.d/init.el"))
      (*emacs-starter-enabled*
       (add-to-list 'load-path "~/.emacs2.d/")
       (load "~/.emacs2.d/init.el"))
      (*emacs-ome-enabled*
       (add-to-list 'load-path "~/.emacs7.d/")
       (load "~/.emacs7.d/init.el"))
      (*default-config-enabled*
       (add-to-list 'load-path "~/.emacs.d/")
                                        ;(load "~/.emacs.d/init.el")
       )
      (*emacs-dotemacs-enabled*
       (add-to-list 'load-path "~/.emacs6.d/")
       (load "~/.emacs6.d/init.el")
       )

      (*emacs-live-enabled*
       (add-to-list 'load-path "~/.emacs4.d/")
       (load "~/.emacs4.d/init.el"))
      (*emacs-graphene-enabled*
       (add-to-list 'load-path "~/.emacs5.d/")
       (load "~/.emacs5.d/init.el")))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; FROM BUSHENKO
;;; http://my-clojure.blogspot.ru/2013/03/emacs.html

(require 'package)
(package-initialize)
(require 'ergoemacs-mode)
(setq ergoemacs-theme "guru")
(ergoemacs-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                                        ;(setq ergoemacs-theme "guru")
                                        ;(ergoemacs-mode 1)

;; (when
;; (load
;;  (expand-file-name "~/.emacs.d/elpa/package.el"))
;; (package-initialize))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(custom-safe-themes (quote ("5a1a016301ecf6874804aef2df36ca8b957443b868049d35043a02a0c1368517" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Disable menu bar
;; (menu-bar-mode -1)

                                        ;(require 'ido)
                                        ;(ido-mode t)

                                        ;(setq show-paren-style 'expression)

(require 'yasnippet) ;; not yasnippet-bundle
;;(yas/initialize)
(yas/load-directory "~/.emacs.d/snippets")

                                        ;(setq make-backup-files         nil) ; Don't want any backup files
                                        ;(setq auto-save-list-file-name  nil) ; Don't want any .saves files
                                        ;(setq auto-save-default         nil) ; Don't want any auto saving

(setq search-highlight           t) ; Highlight search object
(setq query-replace-highlight    t) ; Highlight query object
(setq mouse-sel-retain-highlight t) ; Keep mouse high-lightening

;; ;; Autocomplete
;; regular auto-complete initialization
                                        ;(require 'auto-complete-config)
                                        ;(ac-config-default)

(defun format-all ()

  (interactive)
  (indent-region (point-min) (point-max)))

(defun scroll-one-line-behind ()
  "Scroll behind one line."
  (interactive)
  (scroll-down 1))

(defun scroll-one-line-ahead ()
  "Scroll ahead one line."
  (interactive)
  (scroll-up 1))

(defun my-kill-ring-save ()
  (interactive)
  (let ((beg (region-beginning))
        (end (region-end)))
    (if (use-region-p)
        (kill-ring-save beg end))))

(setq make-backup-files nil)

                                        ;(require 'auto-complete-config)
                                        ;(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
                                        ;(ac-config-default)

(require 'sr-speedbar)


(global-unset-key (kbd "M-c"))
(global-unset-key (kbd "C-<SPC>"))
(global-unset-key (kbd "M-0"))
(global-unset-key (kbd "M-q"))

(defun my-keybindings (my-key-map)
  (define-key my-key-map (kbd "M-3") 'delete-other-windows)
  (define-key my-key-map (kbd "M-q") 'other-window)
  (define-key my-key-map (kbd "C-$") 'toggle-input-method) ;; Switch keyboard layout by CTRL+;
  (define-key my-key-map (kbd "C-SPC") 'set-mark-command)
  (define-key my-key-map (kbd "M-SPC") 'set-mark-command)
  (define-key my-key-map (kbd "C-M-SPC") 'set-mark-command)
  (define-key my-key-map (kbd "C-l") 'goto-line)
  (define-key my-key-map (kbd "C-M-P") 'my-close-tag)
  (define-key my-key-map (kbd "C-p") 'company-complete)
  (define-key my-key-map (kbd "C-(") 'my-shrink-vert)
  (define-key my-key-map (kbd "C-)") 'my-enlarge-vert)
  (define-key my-key-map (kbd "C-9") 'my-shrink-horz)
  (define-key my-key-map (kbd "C-0") 'my-enlarge-horz)
  (define-key my-key-map (kbd "M-(") 'my-super-shrink-vert)
  (define-key my-key-map (kbd "M-)") 'my-super-enlarge-vert)
  (define-key my-key-map (kbd "M-9") 'my-super-shrink-horz)
  (define-key my-key-map (kbd "M-0") 'my-super-enlarge-horz)
  (define-key my-key-map (kbd "M-8") 'my-50%-horz)
  (define-key my-key-map (kbd "<f8>") 'my-format)
  (define-key my-key-map (kbd "M-c") 'my-kill-ring-save)
  (define-key my-key-map (kbd "C-c l") 'toggle-truncate-lines)
  (define-key my-key-map (kbd "M-a") 'mark-whole-buffer)
                                        ;  (define-key my-key-map (kbd "M-n") 'reindent-then-newline-and-indent)
  (define-key my-key-map (kbd "M-m") 'reindent-then-newline-and-indent)
  (define-key my-key-map (kbd "<S-M-left>") 'windmove-left)
  (define-key my-key-map (kbd "<S-M-down>") 'windmove-down)
  (define-key my-key-map (kbd "<S-M-right>") 'windmove-right)
  (define-key my-key-map (kbd "<S-M-up>") 'windmove-up)
  (define-key my-key-map (kbd "S-M-j") 'windmove-left)
  (define-key my-key-map (kbd "S-M-k") 'windmove-down)
  (define-key my-key-map (kbd "S-M-l") 'windmove-right)
  (define-key my-key-map (kbd "S-M-i") 'windmove-up)
  (define-key my-key-map (kbd "C-b") 'bookmark-set)
  (define-key my-key-map (kbd "M-b") 'bookmark-jump)
  (define-key my-key-map (kbd "<f4>") 'bookmark-bmenu-list)
  (define-key my-key-map (kbd "C-M-.") 'pop-tag-mark)
  (define-key my-key-map (kbd "C-t") 'indent-for-tab-command)
  (define-key my-key-map (kbd "C-x C-s") 'save-buffer)
  (define-key my-key-map (kbd "M-s") 'save-buffer)
  (define-key my-key-map (kbd "C-,") 'repeat)
  (define-key my-key-map (kbd "<f2>") 'bs-show)
  (define-key my-key-map (kbd "<f3>") 'visit-tags-table)
  (define-key my-key-map (kbd "<f12>") 'sr-speedbar-toggle)
  (define-key my-key-map (kbd "<f9>") 'upcase-region)
  (define-key my-key-map (kbd "C-S-i") 'comint-previous-input)
  (define-key my-key-map (kbd "C-S-k") 'comint-next-input)
  (define-key my-key-map (kbd "M-q") 'ergoemacs-move-cursor-next-pane)
  (define-key my-key-map (kbd "<f11>") 'show-my-help)
  (define-key my-key-map (kbd "<f5>") 'execute-extended-command))

(my-keybindings (current-global-map))

(defun show-my-help ()
  (interactive)
  (message "<f12> -- show/hide speedbar; <f2> -- select opened file; <f3> -- visit tags table; <f4> -- bookmarks list; <f5> -- run emacs command; <f8> -- format all; <f9> -- upcase selected text (for SQL); <M-Space> -- set mark; <M-i> -- up, <M-k> -- down, <M-j> -- left; <M-l> -- right; <M-S-i> -- page up; <M-S-k> -- page down; <M-u> -- word-left; <M-o> -- word-right; <M-h> -- end of line; <M-S-h> -- beginning of line; <M-c> -- copy; <M-x> -- cut; <M-v> -- paste; <M-s> -- save buffer; <C-b> -- set bookmark; <M-b> -- jump bookmark; <M-q> -- move cursor to next window; <C-l> -- goto line; <C-0> -- enlarge current buffer (horizontal); <C-9> -- shrink current buffer (horizontal); <M-0> -- enlarge current buffer more (horizontal); <M-9> -- shrink current buffer more (horizontal); <C-S-0> -- enlarge current buffer (vertical); <C-S-9> -- shrink current buffer (vertical); <M-S-0> -- enlarge current buffer more (vertical); <M-S-9> -- shrink current buffer more (vertical);"))

(defun reload-keybindings ()
  (interactive)
  (my-keybindings (current-global-map)))

(add-hook 'clojure-mode-hook  (lambda () (my-keybindings clojure-mode-map)))

(setq auto-mode-alist (cons '("\\.cljs$" . closure-mode) auto-mode-alist))

                                        ; (add-to-list 'load-path "~/.emacs.d/color-theme/")
                                        ;(require 'color-theme)
                                        ; (color-theme-initialize)
                                        ; (setq color-theme-is-global t)

(tool-bar-mode -1)
(show-paren-mode 2)



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector (vector "#708183" "#c60007" "#728a05" "#a57705" "#2075c7" "#c61b6e" "#259185" "#042028"))
 ;; '(custom-enabled-themes (quote (tango-dark)))
 ;; '(custom-safe-themes (quote ("b350a2b83904e2bc8e0978f7b48836903fa5149b6eaaad7aa3e15cf3f4adb060" "7eb9c9db72afc647b2704923458d46e33515564d84a81f0c68383f80eb045b7d" "7fe1e3de3e04afc43f9a3d3a8d38cd0a0efd9d4c" "d14db41612953d22506af16ef7a23c4d112150e5" "2c2877aa7de2d5ec7e06d1c978bd69f01ab2a15f" "1f392dc4316da3e648c6dc0f4aad1a87d4be556c" "baac41e6656dd9a5fd1f76d7d41662b8bc1dc10b" default)))
 ;; '(javahome "/opt/jdk/6")
 ;; '(semantic-java-dependency-system-include-path (quote ("/opt/jdk6")))
 '(show-paren-mode t)
 '(speedbar-directory-button-trim-method (quote trim))
 '(speedbar-frame-parameters (quote ((minibuffer) (width . 27) (border-width . 1) (menu-bar-lines . 0) (tool-bar-lines . 0) (unsplittable . t) (left-fringe . 0))))
 '(speedbar-hide-button-brackets-flag nil)
 '(speedbar-mode-specific-contents-flag t)
 '(speedbar-show-unknown-files t)
 '(speedbar-use-images t)
 '(sr-speedbar-max-width 70)
 '(sr-speedbar-right-side nil)
 '(sr-speedbar-width-console 70)
 '(sr-speedbar-width-x 70)
 '(tool-bar-mode nil))


(setq mouse-drag-copy-region nil)  ; stops selection with a mouse being immediately injected to the kill ring
(setq x-select-enable-primary nil)  ; stops killing/yanking interacting with primary X11 selection
(setq x-select-enable-clipboard t)  ; makes killing/yanking interact with clipboard X11 selection

(setq select-active-regions t) ;  active region sets primary X11 selection
(global-set-key [mouse-2] 'mouse-yank-primary)  ; make mouse middle-click only paste from primary X11 selection, not clipboard and kill

(setq redisplay-dont-pause t)

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:family "Consolas" :foundry "microsoft" :slant normal :weight normal :height 143 :width normal)))))

(defun my-enlarge-vert ()
  (interactive)
  (enlarge-window 2))

(defun my-shrink-vert ()
  (interactive)
  (enlarge-window -2))

(defun my-enlarge-horz ()
  (interactive)
  (enlarge-window-horizontally 2))

(defun my-shrink-horz ()
  (interactive)
  (enlarge-window-horizontally -2))

(defvar *larg-window-size-percent* 0.7)

(defun my-50%-horz ()
  (interactive)
  (let* ((width (round (* (frame-width) 0.5)))
         (cur-width (window-width))
         (delta (- width (+ cur-width 5))))
    (enlarge-window-horizontally delta)))

(defun my-super-enlarge-horz ()
  (interactive)
  (let* ((width (round (* (frame-width) *larg-window-size-percent*)))
         (cur-width (window-width))
         (delta (- width cur-width)))
    (enlarge-window-horizontally delta)))

(defun my-super-enlarge-vert ()
  (interactive)
  (let* ((height (round (* (frame-height) *larg-window-size-percent*)))
         (cur-height (window-height))
         (delta (- height cur-height)))
    (enlarge-window delta)))

(defun my-super-shrink-horz ()
  (interactive)
  (let* ((width (round (* (frame-width) (- 1 *larg-window-size-percent*))))
         (cur-width (window-width))
         (delta (- width cur-width)))
    (enlarge-window-horizontally delta)))

(defun my-super-shrink-vert ()
  (interactive)
  (let* ((height (round (* (frame-height) (- 1 *larg-window-size-percent*))))
         (cur-height (window-height))
         (delta (- height cur-height)))
    (enlarge-window delta)))

(defun my-format ()
  (interactive)
  (save-excursion
    (indent-region 1 (point-max))))


(defun my-speedbar-jump (dir)
  (interactive "DDirectory: ")
  (dframe-select-attached-frame speedbar-frame)
  (setq default-directory dir)
  (speedbar-update-contents))

(put 'dired-find-alternate-file 'disabled nil)


(defun my-test-message ()
  (interactive)
  (message "Hello, World!"))


(put 'upcase-region 'disabled nil)


(defun my-close-tag ()
  "Close the previously defined XML tag"
  (interactive)
  (let ((tag nil)
        (quote nil))
    (save-excursion
      (do ((skip 1))
          ((= 0 skip))
        (re-search-backward "</?[a-zA-Z0-9_-]+")
        (cond ((looking-at "</")
               (setq skip (+ skip 1)))
              ((not (looking-at "<[a-zA-Z0-9_-]+[^>]*?/>"))
               (setq skip (- skip 1)))))
      (when (looking-at "<\\([a-zA-Z0-9_-]+\\)")
        (setq tag (match-string 1)))
      (if (eq (get-text-property (point) 'face)
              'font-lock-string-face)
          (setq quote t)))
    (when tag
      (setq quote (and quote
                       (not (eq (get-text-property (- (point) 1) 'face)
                                'font-lock-string-face))))
      (if quote
          (insert "\""))
      (insert "</" tag ">")
      (if quote
          (insert "\"")))))


;; Company mode
(require 'company)
(global-company-mode t)


(global-unset-key (kbd "C-M-i"))
(global-unset-key (kbd "C-M-k"))

(define-key minibuffer-local-completion-map (kbd "C-M-i") 'previous-history-element)
(define-key minibuffer-local-completion-map (kbd "C-M-k") 'next-history-element)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load-theme 'tsdh-dark)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Internationalization
                                        ;(prefer-coding-system 'utf-8)
                                        ;(setq locale-coding-system 'utf-8)
                                        ;(set-terminal-coding-system 'utf-8)
                                        ;(set-keyboard-coding-system 'utf-8)
                                        ;(set-selection-coding-system 'utf-8)
