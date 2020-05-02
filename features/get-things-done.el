(unless (featurep 'jxlabs-nos/features/get-things-done)

  (require 'jxlabs-nos/projects/helmboot-config)

  (require 'org)
  (require 'org-gtd)
  (require 'org-agenda)
  (require 'org-cliplink)
  (require 'org-macs) ;; needed for templating ...
  (require 'org-capture)

  (defconst jxlabs-nos/features/get-things-done/tags/audience
    '((:startgroup) ("audience" . ?A) (:grouptags)
      ("company"  ) ("individual" ) ("management"  ) ("team" )
      (:endgroup)))
  
  (defconst jxlabs-nos/features/get-things-done/tags/context
    '((:startgrouptag) ("context" . ?C) (:grouptags)
      ("@authoring") ("@brainstorming")
      ("@building") ("@coding") ("@designing")
      ("@deploying") ("@evaluating" ) ("@meeting") 
      ("@reading papers") ("@reporting") ("@scripting")
      ("@troubleshooting") ("@testing")
      (:endgrouptag)))

  (defconst jxlabs-nos/features/get-things-done/tags/kind
    '((:startgroup) ("kind" . ?K) (:grouptags)
      ("design") ("idea") ("problem") ("task")
      (:endgroup)))

  (defconst jxlabs-nos/features/get-things-done/tags/language
    '((:startgroup) ("language" . ?L) (:grouptags)
      ("java") ("golang") ("groovy") ("lisp")
      ("typescript")
      (:endgroup)))

  (defconst jxlabs-nos/features/get-things-done/tags/methodology
   '((:startgroup) ("methodology" . ?M) (:grouptags)
      ("kanban") ("scrum") ("tdd")
      (:endgroup)))

  (defconst jxlabs-nos/features/get-things-done/tags/technology
    '((:startgroup) ("technology" . ?T) (:grouptags)
      ("jx") ("k8s") ("make")
      (:endgroup)))

  (defvar jxlabs-nos/features/get-things-done/tags
    (nconc
     jxlabs-nos/features/get-things-done/tags/context
     jxlabs-nos/features/get-things-done/tags/language
     jxlabs-nos/features/get-things-done/tags/kind
     jxlabs-nos/features/get-things-done/tags/methodology
     jxlabs-nos/features/get-things-done/tags/technology
     jxlabs-nos/features/get-things-done/tags/audience)
     "tags we use in get things done")

  (defun jxlabs-nos/features/get-things-done/is-get-things-done-p (directory)
    (and directory
	 (equal directory jxlabs-nos/directories/get-things-done)))

  (defun jxlabs-nos/features/get-things-done/is-org-file-p (file-name)
    (and file-name
	 (let ((extension (file-name-extension file-name)))
	   (and extension
		(equal (file-name-extension file-name) "org")))))

  (defun jxlabs-nos/features/get-things-done/handle-buffer-p ()
    (and (jxlabs-nos/features/get-things-done/is-get-things-done-p default-directory)
	 (jxlabs-nos/features/get-things-done/is-org-file-p buffer-file-name)))
    
  (defun jxlabs-nos/features/get-things-done/tags-advice (&rest _)
      (prog1
	  (when (jxlabs-nos/features/get-things-done/handle-buffer-p)
	    (message "tags set")
	    (setq-local org-tag-alist
			(org--tag-add-to-alist jxlabs-nos/features/get-things-done/tags
					       (default-value 'org-tag-alist))))))

  (advice-add #'org-set-regexps-and-options :before #'jxlabs-nos/features/get-things-done/tags-advice)

  (defun jxlabs-nos/features/get-things-done/handle-buffer ()
    (with-eval-after-load 'org-gtd
      (setq-local org-gtd-directory jxlabs-nos/directories/get-things-done)) ;; where org-gtd will put its files

    (with-eval-after-load 'org-agenda
      (setq-local org-agenda-files `(,org-gtd-directory))))

  (add-hook 'jxlabs-nos/workspace/handle-buffer-hook 'jxlabs-nos/features/get-things-done/handle-buffer)
  
  (defun org-gtd-auto-tag ()
    (interactive)
    (let ((alltags (append org-tag-persistent-alist org-tag-alist))
	  (headline-words (split-string (org-get-heading t t))))
      (mapcar (lambda (word) (if (assoc word alltags)
				 (org-toggle-tag word 'on)))
	      headline-words)))
  
  (provide 'jxlabs-nos/features/get-things-done))
