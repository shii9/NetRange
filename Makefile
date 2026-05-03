#!/usr/bin/make -f

# NetRange Development Makefile

.PHONY: help install install-local test lint verify clean

SHELL := /bin/bash

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)NetRange Development Tasks$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  $(GREEN)help$(NC)              - Show this help message"
	@echo "  $(GREEN)install$(NC)           - Install NetRange system-wide (requires sudo)"
	@echo "  $(GREEN)install-local$(NC)     - Install NetRange locally in ~/.local/bin"
	@echo "  $(GREEN)uninstall$(NC)         - Remove NetRange installation"
	@echo "  $(GREEN)verify$(NC)            - Verify installation"
	@echo "  $(GREEN)test$(NC)              - Run basic tests"
	@echo "  $(GREEN)lint$(NC)              - Check shell script syntax"
	@echo "  $(GREEN)clean$(NC)             - Remove test artifacts"
	@echo ""

install:
	@echo "$(BLUE)Installing NetRange system-wide...$(NC)"
	@bash install.sh

install-local:
	@echo "$(BLUE)Installing NetRange locally...$(NC)"
	@bash install.sh --local

uninstall:
	@echo "$(BLUE)Uninstalling NetRange...$(NC)"
	@bash install.sh --uninstall

verify:
	@echo "$(BLUE)Verifying installation...$(NC)"
	@bash install.sh --verify

test: clean
	@echo "$(BLUE)Running tests...$(NC)"
	@echo "$(YELLOW)Test 1: Single IP$(NC)"
	@netrange 8.8.8.8 8.8.8.8 -o test_single.txt
	@[ -f test_single.txt ] && echo "$(GREEN)✓ Single IP test passed$(NC)" || echo "$(RED)✗ Single IP test failed$(NC)"
	@
	@echo "$(YELLOW)Test 2: Small range (/25)$(NC)"
	@netrange 192.168.1.0 192.168.1.10 -o test_range.txt
	@lines=$$(wc -l < test_range.txt) && [ $$lines -eq 11 ] && echo "$(GREEN)✓ Range test passed ($$lines IPs)$(NC)" || echo "$(RED)✗ Range test failed$(NC)"
	@
	@echo "$(YELLOW)Test 3: Error handling (reverse range)$(NC)"
	@netrange 192.168.1.255 192.168.1.0 -o test_error.txt 2>/dev/null || echo "$(GREEN)✓ Error handling works$(NC)"
	@
	@echo "$(GREEN)All tests completed!$(NC)"

lint:
	@echo "$(BLUE)Checking shell script syntax...$(NC)"
	@bash -n netrange.sh && echo "$(GREEN)✓ netrange.sh syntax OK$(NC)" || echo "$(RED)✗ Syntax error in netrange.sh$(NC)"
	@bash -n install.sh && echo "$(GREEN)✓ install.sh syntax OK$(NC)" || echo "$(RED)✗ Syntax error in install.sh$(NC)"

clean:
	@echo "$(BLUE)Cleaning test artifacts...$(NC)"
	@rm -f test_*.txt
	@echo "$(GREEN)Clean complete$(NC)"

.DEFAULT_GOAL := help
