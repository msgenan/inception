# ********************************* SETUP ************************************ #

NAME        = inception
COMPOSE     = docker compose -f srcs/docker-compose.yml
DATA_DIR    = /home/mugenan/data

# Color codes and styles
RESET       = \033[0m
BOLD        = \033[1m
RED         = \033[31m
BLUE        = \033[34m
CYAN        = \033[36m
GREEN       = \033[32m
YELLOW      = \033[33m

# Message templates
MSG_BUILD     = $(CYAN)Building and starting containers:$(RESET) $(BOLD)$(NAME)$(RESET)
MSG_UP        = $(GREEN)Infrastructure is up.$(RESET)
MSG_DOWN      = $(YELLOW)Containers stopped and removed.$(RESET)
MSG_CLEAN     = $(YELLOW)Project images and volumes removed.$(RESET)
MSG_FCLEAN    = $(RED)Persistent data removed.$(RESET)
MSG_SUCCESS   = $(BLUE)$(BOLD)--- SUCCESS ---$(RESET)

# ********************************* RULES ************************************ #

all: up

# Create host directories for named volumes
$(DATA_DIR)/mariadb:
	@mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	@mkdir -p $(DATA_DIR)/wordpress

up: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@echo "$(MSG_BUILD)"
	@$(COMPOSE) up -d --build
	@echo "\n$(MSG_SUCCESS)"
	@echo "$(MSG_UP)\n"

down:
	@$(COMPOSE) down
	@echo "$(MSG_DOWN)\n"

stop:
	@$(COMPOSE) stop

start:
	@$(COMPOSE) start

restart: down up

clean: down
	@$(COMPOSE) down --rmi all --volumes
	@echo "$(MSG_CLEAN)\n"

fclean: clean
	@sudo rm -rf $(DATA_DIR)/mariadb/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*
	@echo "$(MSG_FCLEAN)\n"

re: fclean all

.PHONY: all up down stop start restart clean fclean re
