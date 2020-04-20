stacks := control-plane builder-node-pool storage dns vault kaniko keyring helmboot
environments := prod staging $(if $(dev),$(dev),dev)
targets := update preview destroy

define control-plane-bindings-template =
$(info "control-plane-bindings-template")
$(call stack-binding-template,control-plane,gcpProject,build-jx-prod)
$(call stack-binding-template,control-plane,gcpRegion,eu-east1)
$(call stack-binding-template,control-plane,gcpZone,eu-east1-b)
endef

define control-plane-prod-bindings-template =
$(info "control-plane-prod-bindings-template")
$(call stack-env-binding-template,control-plane,gcpProject,build-jx-prod)
$(call stack-env-binding-template,control-plane,gcpRegion,eu-east1)
$(call stack-env-binding-template,control-plane,gcpZone,eu-east1-b)
endef


define stack-env-binding-template =
$(info "$(1)@$(2)%: options = $(3) := $(4)")
$(1)@$(2)%: env-options = $(3) $(env-options)
$(1)@$(2)%: $(3) := $(4)
endef

define stack-env-target-rule-template =
$(1)@$(2)!$(3):
	@echo gcpProject="!$(gcpProject)!"
	@echo make -C $(1) $(2)!$($3)
endef

define stack-env-target-rule =
$(eval $(call stack-env-target-rule-template,$(1),$(2),$(3)))
endef

define stack-env-bindings =
$(if $(value $(1)@$(2)-bindings-template),$(eval $(call $(1)@($2)-bindings-template)),$(info "no env bindings for $(1)@$(2)"))
endef

define stack-env-rules =
$(call stack-env-bindings,(1),$(2))
$(foreach target,$(targets),$(call stack-env-target-rule,$(1),$(2),$(target)))
endef

define stack-bindings-template =
$(info "$(1)@$(2)%: options = $(3) := $(4)")
$(1)@$(2)%: stack-options = $(3) $(stack-options)
$(1)@$(2)%: $(3) := $(4)
endef

define stack-bindings =
$(if $(value $(1)-bindings-template),$(eval $(call $(1)-bindings-template)),$(info "no env bindings for $$(1)"))
endef

define stack-rules =
$(call stack-bindings-template,$(1))
$(foreach env,$(environments),$(call stack-env-rules,$(1),$(env)))
endef

define rules :=
$(foreach stack,$(stacks),$(call stack-rules,$(stack)))
endef


$(call rules)
