(unless (featurep 'jxlabs-nos/features/coding)

  ;; git modes
  (require 'magit)

  
  ;; languages mode
  (require 'groovy-mode)
  (require 'java-mode-plus)
  (require 'typescript-mode)
  (require 'yaml-mode)

  ;; k8s
  (require 'kubernetes)
  
  (provide 'jxlabs-nos/features/coding))
