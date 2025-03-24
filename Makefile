# Define required variables
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= root

NIXDIR ?= /mnt/etc/nix-config

BOOT_DISK ?= sda
HOSTNAME ?= main
PRIMARY_IFACE ?= ens160

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Check if required variables are set
.PHONY: check-vars
check-vars:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set"; \
		exit 1; \
	fi
	@if [ -z "$(NIXPORT)" ]; then \
		echo "Error: NIXPORT is not set"; \
		exit 1; \
	fi
	@if [ -z "$(NIXUSER)" ]; then \
		echo "Error: NIXUSER is not set"; \
		exit 1; \
	fi


.PHONY: copy
copy: check-vars 
	@echo "Setting up directories"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "\
		uname -m; \
		sudo mkdir -p $(NIXDIR); \
	"

	@echo "Copying files"
	@COPYFILE_DISABLE=1 tar --no-xattrs -C $(MAKEFILE_DIR) \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='iso/' \
		--exclude='._*' -cpf- . | ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "tar -C $(NIXDIR) -xf-"


.PHONY: clean
clean: check-vars
	@echo "Removing directory $(NIXDIR)"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "rm -rf $(NIXDIR)" 


.PHONY: disk
disk: check-vars
	@echo "Partitioning disk"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "\
		nix run --extra-experimental-features nix-command --extra-experimental-features flakes \
    github:nix-community/disko -- --mode zap_create_mount $(NIXDIR)/modules/nixos/disk-config.nix" 


.PHONY: info
info: check-vars
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "\
		ip -o -4 route show to default | awk '{print $5}'; \
		lsblk -nd --output NAME,SIZE | grep -v loop; \
		lsblk -d -o NAME,SIZE /dev/sda; \
		"

.PHONY: install
install: check-vars
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "nixos-install --show-trace --flake $(NIXDIR)#aarch64-linux"


.PHONY: switch
switch: check-vars
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "nixos-rebuild switch --flake $(NIXDIR)#aarch64-linux"
	# @ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "reboot"


.PHONY: flake
flake: check-vars
	@scp $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR):/mnt/etc/nix-config/flake.lock ./flake.lock


# Add this new target for updating flakes
.PHONY: update-flake
update-flake: check-vars
	@echo "Updating flake on remote system"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "cd $(NIXDIR) && nix flake update"
	@echo "Copying updated flake.lock back to local machine"
	@scp $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR):$(NIXDIR)/flake.lock ./flake.lock
	@echo "Deleting old generations"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "nix-collect-garbage -d"
	@echo "Flake updated and local flake.lock synchronized"


.PHONY: clean
clean: check-vars
	@echo "Removing directory $(NIXDIR)"
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "rm -rf $(NIXDIR)"


.PHONY: reboot
reboot: check-vars
	@ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "reboot"


