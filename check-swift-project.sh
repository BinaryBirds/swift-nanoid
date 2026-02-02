#!/bin/sh

set -u

# State
ERROR_COUNT=0

# Logging helpers
log()   { printf -- "%s\n" "$*" >&2; }
error() { printf -- "%s\n" "$*" >&2; ERROR_COUNT=$((ERROR_COUNT + 1)); }

fatal() {
  printf -- "%s\n" "$*" >&2
  exit 1
}

fatal_if_errors() {
  if [ "$ERROR_COUNT" -gt 0 ]; then
    printf -- "\n❌ %d error(s) found\n" "$ERROR_COUNT" >&2
    exit 1
  fi
}

log "Starting Swift Package validation"

# jq is a hard requirement
command -v jq >/dev/null 2>&1 || fatal "❌ jq not found (required)"

# Helper to check required files
check_file() {
  file="$1"
  if [ -f "$file" ]; then
    log "✅ $file exists"
  else
    error "❌ $file missing (expected at repository root)"
  fi
}

# Package.swift
check_file "Package.swift"

# swift-tools-version
TOOLS_LINE="$(grep '^// swift-tools-version:' Package.swift 2>/dev/null || true)"
if [ -n "$TOOLS_LINE" ]; then
  TOOLS_VERSION="$(printf "%s" "$TOOLS_LINE" | sed 's/.*: *//')"
  major="$(printf "%s" "$TOOLS_VERSION" | cut -d. -f1)"
  minor="$(printf "%s" "$TOOLS_VERSION" | cut -d. -f2)"

  if [ "$major" -lt 6 ] || { [ "$major" -eq 6 ] && [ "$minor" -lt 1 ]; }; then
    error "❌ swift-tools-version too old ($TOOLS_VERSION), expected >= 6.1"
  else
    log "✅ swift-tools-version >= 6.1 ($TOOLS_VERSION)"
  fi
else
  error "❌ swift-tools-version missing"
fi

# defaultSwiftSettings
if grep -q 'defaultSwiftSettings' Package.swift 2>/dev/null; then
  log "✅ defaultSwiftSettings found"
else
  error "❌ defaultSwiftSettings missing"
fi

# Swift 6 concurrency default (string presence only)
if grep -q '"NonisolatedNonsendingByDefault"' Package.swift 2>/dev/null; then
  log "✅ NonisolatedNonsendingByDefault present"
else
  error "❌ NonisolatedNonsendingByDefault missing"
fi

# Parse Package.swift via SwiftPM
PACKAGE_JSON="$(swift package dump-package 2>/dev/null || true)"
if [ -n "$PACKAGE_JSON" ]; then
  log "✅ Package.swift parsed by SwiftPM"
else
  error "❌ Failed to parse Package.swift via SwiftPM"
fi

# Top-level dependencies
if [ -n "$PACKAGE_JSON" ]; then
  if echo "$PACKAGE_JSON" | jq -e '.dependencies | type == "array"' >/dev/null; then
    log "✅ Top-level dependencies array exists"
  else
    error "❌ Top-level dependencies missing"
  fi
fi

# docc placeholder
if grep -q '// *\[docc-plugin-placeholder\]' Package.swift 2>/dev/null; then
  log "✅ docc plugin placeholder present"
else
  error "❌ docc plugin placeholder missing"
fi

# swiftSettings: defaultSwiftSettings on all targets
if [ -n "$PACKAGE_JSON" ]; then
  TARGETS="$(echo "$PACKAGE_JSON" | jq -r '.targets[].name')"

  for target in $TARGETS; do
    if awk '
      # Start scanning when we see the target name
      /name:[[:space:]]*"'$target'"/ {
        in_target = 1
      }

      # While inside the target, look for swiftSettings
      in_target && /swiftSettings[[:space:]]*:[[:space:]]*defaultSwiftSettings/ {
        found = 1
      }

      # If we are inside the target and a new target starts, stop
      in_target && /^\s*\.(target|testTarget|executableTarget|macro|plugin)[[:space:]]*\(/ && !seen_start {
        seen_start = 1
        next
      }

      in_target && seen_start && /^\s*\.(target|testTarget|executableTarget|macro|plugin)[[:space:]]*\(/ {
        exit
      }

      END {
        exit !found
      }
    ' Package.swift
    then
      log "✅ $target uses swiftSettings: defaultSwiftSettings"
    else
      error "❌ $target missing swiftSettings: defaultSwiftSettings"
    fi
  done
fi

# Directories
if [ -d Sources ]; then
  log "✅ Sources directory exists"
else
  error "❌ Sources directory missing"
fi

if [ -d Tests ]; then
  log "✅ Tests directory exists"
else
  error "❌ Tests directory missing"
fi

# Required repository files
check_file ".swift-format"
check_file ".swiftformatignore"
check_file "LICENSE"
check_file "Makefile"
check_file "README.md"


# LICENSE must contain current year
CURRENT_YEAR="$(date +%Y)"

if grep -q "$CURRENT_YEAR" LICENSE; then
  log "✅ LICENSE contains current year ($CURRENT_YEAR)"
else
  error "❌ LICENSE does not contain current year ($CURRENT_YEAR)"
fi

fatal_if_errors
log "✅ Swift Package validation passed"
