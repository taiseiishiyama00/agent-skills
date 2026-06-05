#!/usr/bin/env bash
set -euo pipefail

range="${1:-HEAD~10..HEAD}"

echo "## Git 状態"
git status --short --branch

echo
echo "## 直近コミット (${range})"
git log --oneline --decorate --date=short --pretty='%h %ad %d %s' "${range}" 2>/dev/null || git log --oneline --decorate -10

echo
echo "## 未ステージ変更ファイル"
git diff --name-status

echo
echo "## ステージ済みファイル"
git diff --cached --name-status

echo
echo "## 未追跡ファイル"
git ls-files --others --exclude-standard

echo
echo "## テスト/ビルド候補ファイル"
if command -v rg >/dev/null 2>&1; then
  rg --files -g '!*node_modules*' -g '!bin/**' -g '!obj/**' \
    | rg '(^|/)(package.json|pnpm-lock.yaml|yarn.lock|package-lock.json|.*\.slnx?$|.*\.csproj|.*\.fsproj|pytest.ini|pyproject.toml|tox.ini|Cargo.toml|go.mod|Makefile)$' || true
else
  find . -maxdepth 4 \( -name package.json -o -name '*.sln' -o -name '*.slnx' -o -name '*.csproj' -o -name pyproject.toml -o -name Cargo.toml -o -name go.mod -o -name Makefile \) -print
fi
