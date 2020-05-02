((nil
  .
  ((eval
    .
    (progn
      (unless (featurep 'jxlabs-nos/workspace)
	(let* ((this-directory (locate-dominating-file default-directory ".dir-locals.el"))
	       (this-name (file-name-base this-directory))
	       (this-lisp-directory (expand-file-name ".elisp.d" this-directory)))
	  (push this-lisp-directory load-path)
	  (require 'jxlabs-nos/workspace)))
      (jxlabs-nos/workspace/handle-buffer))))))
