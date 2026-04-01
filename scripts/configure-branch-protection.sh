#!/usr/bin/env bash
set -euo pipefail

REPO="brianhartsock/ansible-role-smartmontools"
BRANCH="master"
REQUIRED_CHECKS=("Lint" "Molecule")

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

echo "Repository: $REPO"
echo "Branch: $BRANCH"
echo "Required checks: ${REQUIRED_CHECKS[*]}"
echo

# Fetch current branch protection
echo "=== Current Branch Protection ==="
PROTECTION=$(gh api "repos/$REPO/branches/$BRANCH/protection" 2>/dev/null) || true

if [[ -z "$PROTECTION" ]] || echo "$PROTECTION" | jq -e '.message == "Branch not protected"' &>/dev/null; then
  echo "No branch protection currently configured."
  CURRENT_CHECKS=()
else
  CURRENT_CHECKS_JSON=$(echo "$PROTECTION" | jq -r '.required_status_checks.contexts // []')
  echo "Current required status checks:"
  echo "$CURRENT_CHECKS_JSON" | jq -r '.[]' 2>/dev/null || echo "  (none)"
  mapfile -t CURRENT_CHECKS < <(echo "$CURRENT_CHECKS_JSON" | jq -r '.[]' 2>/dev/null)
fi

echo
echo "=== Check Analysis ==="
MISSING=()
for check in "${REQUIRED_CHECKS[@]}"; do
  found=false
  for current in "${CURRENT_CHECKS[@]:-}"; do
    if [[ "$check" == "$current" ]]; then
      found=true
      break
    fi
  done
  if $found; then
    echo "  ✓ $check (already required)"
  else
    echo "  ✗ $check (missing)"
    MISSING+=("$check")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo
  echo "All required checks are already configured. Nothing to do."
  exit 0
fi

if $CHECK_ONLY; then
  echo
  echo "Run without --check to apply changes."
  exit 1
fi

echo
echo "=== Applying Branch Protection ==="

# Build the checks array for the API
CHECKS_JSON=$(printf '%s\n' "${REQUIRED_CHECKS[@]}" | jq -R . | jq -s .)

gh api -X PUT "repos/$REPO/branches/$BRANCH/protection" \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": false,
    "contexts": $CHECKS_JSON
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null
}
EOF

echo "Branch protection updated."

echo
echo "=== Verification ==="
VERIFY=$(gh api "repos/$REPO/branches/$BRANCH/protection/required_status_checks")
echo "Required status checks now configured:"
echo "$VERIFY" | jq -r '.contexts[]'
