#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
# SPDX-License-Identifier: BlueOak-1.0.0
# Description:
_base=$(basename "$0")
_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P || exit 126)
export _base _dir
set "${SETOPTS:--eu}"

OPENAI_API_KEY='' cover-agent \
  --source-file-path calc.py \
  --test-file-path test_calc.py \
  --code-coverage-report-path coverage.xml \
  --test-command "pytest --cov=. --cov-report=xml --cov-report=term" \
  --test-command-dir "./" \
  --coverage-type cobertura \
  --desired-coverage 80 \
  --max-iterations 100 \
  --model ollama/${MODEL:-qwen2.5:14b} \
  --api-base http://${OLLAMA_HOST:-localhost}:${OLLAMA_PORT:-11434} \
  --additional-instructions "Since I am using a test class, each line of code (including the first line) needs to be prepended with 4 whitespaces. This is extremely important to ensure that every line returned contains that 4 whitespace indent; otherwise, my code will not run. Ensure that all code is indented by 4 whitespaces."
