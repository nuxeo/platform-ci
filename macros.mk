define check-variable-defined =
    $(strip $(foreach 1,$1,
        $(call __check-variable-defined,$1,$(strip $(value 2)))))
endef

define __check-variable-defined =
    $(if $(value $1),,
        $(error Undefined variable '$1'$(if $2, ($2))$(if $(value @),
                required by target '$@')))
endef
