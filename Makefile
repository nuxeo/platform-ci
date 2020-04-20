stacks := control-plane builder-node-pool storage dns vault kaniko keyring helmboot
environments := prod staging $(if $(dev),$(dev),dev)
targets := update preview destroy

define control-plane-bindings-template =
$(call stack-binding-template,control-plane,gcpProject,build-jx-prod)
$(call stack-binding-template,control-plane,gcpRegion,eu-east1)
$(call stack-binding-template,control-plane,gcpZone,eu-east1-b)
endef

define control-plane-prod-bindings-template =
$(call stack-env-binding-template,control-plane,zooo,ca-marche)
endef


define stack-env-binding-template =
$(1)@$(2)%: $(3) := $(4)
endef

define stack-env-target-rule-template =
$(1)@$(2)!$(3):
	@echo make -C $(1) $(2)!$($3)
endef

define stack-env-target-rule =
$(eval $(call stack-env-target-rule-template,$(1),$(2),$(3)))
endef

define stack-env-bindings =
$(if $(value $(1)-$(2)-bindings-template),$(eval $(call $(1)-($2)-bindings-template)))
endef

define stack-env-rules =
$(eval $(1)-environnements = $(sort $($(1)-environnements),$(2)))
$(foreach target,$(targets),$(call stack-env-target-rule,$(1),$(2),$(target)))
endef

define stack-binding-template =
$(1)%: $(2) := $(3)
endef

define stack-bindings =
$(eval stacks = $(sort $(stacks),$(1)))
$(if $(value $(1)-bindings-template),$(eval $(call $(1)-bindings-template)))
$(foreach env,$(environments),$(call stack-env-bindings,$(1),$(nv)))
endef

define stack-rules =
$(foreach env,$(environments),$(call stack-env-rules,$(1),$(env)))
endef

define bindings :=
$(foreach stack,$(stacks),$(call stack-bindings,$(stack)))
endef

define rules :=
$(foreach stack,$(stacks),$(call stack-rules,$(stack)))
endef

$(call bindings)
$(call rules)


control-plane%test!other:
	@echo stackOptions=$(stackOptions)
