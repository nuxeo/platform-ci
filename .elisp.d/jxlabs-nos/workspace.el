(unless (featurep 'jxlabs-nos/workspace) ;; protect from reloading

  (defconst jxlabs-nos/directories/root
    (expand-file-name ".."
		      (file-name-directory (locate-dominating-file default-directory
								   ".dir-locals.el")))
    "directory which contains our projects clone")


  (defun jxlabs-nos/workspace/expand-file-name (name)
    "name files located in the workspace"
    (expand-file-name name
		      jxlabs-nos/directories/root))

  (defun jxlabs-nos/workspace/expand-directory-name (name)
    "name directories located in the workspace"
    (file-name-as-directory  (jxlabs-nos/workspace/expand-file-name name)))

  (defun jxlabs-nos/workspace/load-project (name)
    (let* ((this-project-name (concat "jxlabs-nos-" name))
	   (this-project-dir (jxlabs-nos/workspace/expand-file-name this-project-name))
	   (this-project-lisp-directory (expand-file-name ".elisp.d" this-directory))
	   (this-project-init-symbol (intern (concat "jxlabs-nos/projects/" name))))
      (when (file-exists-p this-project-lisp-directory)
	(unless (member this-project-lisp-directory load-path)
	  (push this-project-lisp-directory load-path))
	(require this-project-init-symbol))))
  
  (defconst jxlabs-nos/directories/project-prefix
    (concat jxlabs-nos/directories/root "/jxlabs-nos-"))

  (defun jxlabs-nos/workspace/handle-buffer-p ()
    (string-prefix-p jxlabs-nos/directories/project-prefix
		     (expand-file-name default-directory)))
			 
  
  (defvar jxlabs-nos/workspace/handle-buffer-hook nil)
  
  (defun jxlabs-nos/workspace/handle-buffer ()
    (when (jxlabs-nos/workspace/handle-buffer-p)
      (run-hooks 'jxlabs-nos/workspace/handle-buffer-hook)))

  (jxlabs-nos/workspace/load-project "helmboot-config")
  
  (require 'jxlabs-nos/features/coding)
  (require 'jxlabs-nos/features/get-things-done)

  (provide 'jxlabs-nos/workspace))

