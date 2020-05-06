(unless (featurep 'jxlabs-nos/projects) ;; protect from reloading

  (setq debug-on-error t)
  
  (defconst jxlabs-nos/projects/visited '())

  (require 'jxlabs-nos/projects/helmboot-config)

  (provide 'jxlabs-nos/projects))
