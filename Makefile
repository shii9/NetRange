#!/usr/bin/make -f

# NetRange v2.1.0 Development Makefile

.PHONY: help install install-local test test-full bench lint verify clean

SHELL := /bin/bash

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)NetRange v2.1.0 Development Tasks$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  $(GREEN)help$(NC)              - Show this help message"
	@echo "  $(GREEN)install$(NC)           - Install NetRange system-wide (requires sudo)"
	@echo "  $(GREEN)install-local$(NC)     - Install NetRange locally in ~/.local/bin"
	@echo "  $(GREEN)uninstall$(NC)         - Remove NetRange installation"
	@echo "  $(GREEN)verify$(NC)            - Verify installation"
	@echo "  $(GREEN)test$(NC)              - Run quick smoke tests"
	@echo "  $(GREEN)test-full$(NC)         - Run comprehensive Python test suite"
	@echo "  $(GREEN)bench$(NC)             - Run performance benchmarks"
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
	@echo "$(BLUE)Running quick smoke tests...$(NC)"
	@echo ""
	@echo "$(YELLOW)Test 1: CIDR /28$(NC)"
	@bash netrange.sh 10.50.0.0/28 -o test_cidr.txt -q
	@lines=$$(wc -l < test_cidr.txt) && [ $$lines -eq 16 ] && echo "$(GREEN)✓ CIDR /28 → 16 IPs$(NC)" || echo "$(RED)✗ CIDR /28 failed (got $$lines)$(NC)"
	@
	@echo "$(YELLOW)Test 2: IP range$(NC)"
	@bash netrange.sh 172.16.10.0 172.16.10.10 -o test_range.txt -q
	@lines=$$(wc -l < test_range.txt) && [ $$lines -eq 11 ] && echo "$(GREEN)✓ Range → 11 IPs$(NC)" || echo "$(RED)✗ Range failed (got $$lines)$(NC)"
	@
	@echo "$(YELLOW)Test 3: Stdout piping$(NC)"
	@lines=$$(bash netrange.sh 203.0.113.0/30 -q | wc -l) && [ $$lines -eq 4 ] && echo "$(GREEN)✓ Stdout pipe → 4 IPs$(NC)" || echo "$(RED)✗ Stdout pipe failed$(NC)"
	@
	@echo "$(YELLOW)Test 4: Count-only$(NC)"
	@cnt=$$(bash netrange.sh 198.51.100.0/24 -c -q) && [ "$$cnt" = "256" ] && echo "$(GREEN)✓ Count = 256$(NC)" || echo "$(RED)✗ Count failed (got $$cnt)$(NC)"
	@
	@echo "$(YELLOW)Test 5: Error handling (reversed range)$(NC)"
	@bash netrange.sh 192.168.1.255 192.168.1.0 -o test_err.txt -q 2>/dev/null || echo "$(GREEN)✓ Reversed range rejected$(NC)"
	@
	@echo ""
	@echo "$(GREEN)All smoke tests completed!$(NC)"

test-full: clean
	@echo "$(BLUE)Running comprehensive test suite...$(NC)"
	@python3 comprehensive_test.py

bench: clean
	@echo "$(BLUE)Running performance benchmarks...$(NC)"
	@python3 test_large_range.py

lint:
	@echo "$(BLUE)Checking shell script syntax...$(NC)"
	@bash -n netrange.sh && echo "$(GREEN)✓ netrange.sh syntax OK$(NC)" || echo "$(RED)✗ Syntax error in netrange.sh$(NC)"
	@bash -n install.sh && echo "$(GREEN)✓ install.sh syntax OK$(NC)" || echo "$(RED)✗ Syntax error in install.sh$(NC)"
	@bash -n test_ranges.sh && echo "$(GREEN)✓ test_ranges.sh syntax OK$(NC)" || echo "$(RED)✗ Syntax error in test_ranges.sh$(NC)"

clean:
	@echo "$(BLUE)Cleaning test artifacts...$(NC)"
	@rm -f test_*.txt bench_*.txt
	@echo "$(GREEN)Clean complete$(NC)"

.DEFAULT_GOAL := help
