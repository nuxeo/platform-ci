(unless (featurep 'jxlabs-nos/projects/helmboot-config)

  (defconst jxlabs-nos/directories/helmboot-config
    (jxlabs-nos/workspace/expand-directory-name "jxlabs-nos-helmboot-config")
    "basically our jx environment project directory")

  (defun jxlabs-nos/directories/helmboot-config/expand-file-name (name)
    "name files helmboot-config"
    (expand-file-name name jxlabs-nos/directories/helmboot-config))

  (defun jxlabs-nos/directories/helmboot-config/expand-directory-name (name)
    "name directories helmboot-config"
    (file-name-as-directory (jxlabs-nos/directories/helmboot-config/expand-file-name name)))

  (defconst jxlabs-nos/directories/get-things-done
    (jxlabs-nos/directories/helmboot-config/expand-directory-name ".get-things-done.d")
    "where the things get done")

  (defun jxlabs-nos/directories/get-things-done/expand-file-name (name)
    "name files in get things done"
    (expand-file-name name jxlabs-nos/directories/helmboot-config))

  (defconst jxlabs-nos/directories/book
    (jxlabs-nos/directories/helmboot-config/expand-directory-name "book")
    "directory which hold our book")
  
  (defun jxlabs-nos/directories/book/expand-file-name (name)
    "name files in book"
    (expand-file-name name jxlabs-nos/directories/book))

  (provide 'jxlabs-nos/projects/helmboot-config))
