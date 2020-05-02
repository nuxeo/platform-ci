;;
;; Thanks to https://github.com/jinnovation/nested-dir-locals.el/blob/master/README.org
;; I'm thinking more about the friends relation-ship, ie: projects
;;
(unless (featurep 'jxlabs-nos/features/dir-locals-nested)

  (defun jxlabs-nos/dir-locals/nested--all-parent-dirs (&optional dir)
    "discover parent tree"
    (let* ((base (or dir default-directory))
	   (parent-dir-cmps (eshell-split-path base)))
      (mapcar (lambda (depth)
		(apply 'concat (subseq parent-dir-cmps 0 depth)))
	      (number-sequence 1 (length parent-dir-cmps)))))

  (defun jxlabs-nos/dir-locals/nested--parent-dir-locals (&optional dir)
    "discover .dir-locals.el hierarchy"
    (let ((parent-dirs (jxlabs-nos/dir-locals/nested--all-parent-dirs dir)))
      (seq-filter 'file-exists-p
		  (mapcar (lambda (d)
			    (concat d ".dir-locals.el"))
			  parent-dirs))))
  
  ;; install hack, load merged .dir-locals.el when visiting files
  (advice-add 'hack-dir-local-variables
	      :around
	      (lambda (fn &rest args)
		(dolist (file (jxlabs-nos/dir-locals/nested--parent-dir-locals))
		  (let ((dir-locals-file (expand-file-name file)))
		    (apply fn args))))
	      '((name . nested-dir-locals)))
  
  (provide 'jxlabs-nos/features/dir-locals-nested))

