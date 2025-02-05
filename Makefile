# Default configuration
APP_NAME ?= my_mcp_app
TEMPLATE_PATH ?= template.rb

# ANSI color codes
GREEN := \033[32m
RESET := \033[0m

.PHONY: help new clean

help: ## Show available commands
	@echo "Usage:"
	@echo "  make new APP_NAME=your_app_name    Create new Rails API app"
	@echo "  make clean APP_NAME=your_app_name  Delete app directory"

## Create a new Rails API application using the template
new:
	@echo "${GREEN}Creating new Rails API application: $(APP_NAME)${RESET}"
	@rails new $(APP_NAME) -m $(TEMPLATE_PATH) --api \
		--skip-active-record \
		--skip-action-mailer \
		--skip-action-mailbox \
		--skip-active-job \
		--skip-action-text \
		--skip-active-storage \
		--skip-action-cable \
		--skip-asset-pipeline \
		--skip-solid \
		--skip-hotwire \
		--skip-javascript \
		--skip-dev-gems \
		--skip-kamal

## Delete the app directory
clean:
	@echo "${GREEN}Deleting $(APP_NAME) directory...${RESET}"
	@rm -rf $(APP_NAME)
