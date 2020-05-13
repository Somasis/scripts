me_git := $(HOME)/git/me.git

IRC_NETWORKS := \
	somasis@irc.freenode.net somasis@irc.oftc.net

POUNCE_HOST := angela.somas.is

CATGIRL_FILES := \
	$(foreach network,$(IRC_NETWORKS),.config/catgirl/$(network).conf)

LITTERBOX_FILES := \
	$(foreach network,$(IRC_NETWORKS),.config/litterbox/$(network).conf)

POUNCE_FILES := \
	$(foreach network,$(IRC_NETWORKS),.config/pounce/$(network).conf)

NEWSBOAT_URLS := \
	.config/newsboat/urls.pub .config/newsboat/urls.secret

CONFIG_FILES := \
	$(CATGIRL_FILES) $(LITTERBOX_FILES) $(POUNCE_FILES) .config/newsboat/urls

.PHONY: all
all: config

.PHONY: config
config: $(CONFIG_FILES)

newsboat: ~/.config/newsboat/urls

.PHONY: pounce-$(POUNCE_HOST)
pounce-$(POUNCE_HOST): $(POUNCE_FILES)
	rsync -ru --delete-after $^ pounce@$(POUNCE_HOST):~/.config/pounce
	ssh pounce@$(POUNCE_HOST) mkdir -p '~/.cache/pounce'

.PHONY: litterbox-$(POUNCE_HOST)
litterbox-$(POUNCE_HOST): $(LITTERBOX_FILES)
	rsync -ru --delete-after $^ pounce@$(POUNCE_HOST):~/.config/litterbox
	ssh pounce@$(POUNCE_HOST) mkdir -p '~/.local/share/litterbox'

.PHONY: pull
pull:
	git --git-dir="$(me_git)" --work-tree="$(HOME)" pull

.DELETE_ON_ERROR: .config/catgirl/%.conf
.config/catgirl/%.conf: .config/catgirl/pounce.in .config/catgirl/catgirl.in .config/catgirl/
	pp $< $(POUNCE_HOST) $* > $@

.DELETE_ON_ERROR: .config/litterbox/%.conf
.config/litterbox/%.conf: .config/litterbox/pounce.in .config/litterbox/
	pp $< $(POUNCE_HOST) $* > $@

.DELETE_ON_ERROR: .config/pounce/%.conf
.config/pounce/%.conf: .config/pounce/pounce.in .config/pounce/
	pp $< $(POUNCE_HOST) $* > $@

.config/%/:
	mkdir -p .config/$*

.config/newsboat/urls: $(NEWSBOAT_URLS)
	cat $(NEWSBOAT_URLS) > $@
