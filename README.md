# Agent Skills

個人的な AI エージェント用スキル集です。

このリポジトリは、各スキルをリポジトリ直下の `<skill-name>/SKILL.md` として管理します。Codex では `~/.agent-skills`、Claude Code では `~/.claude/skills` へこのリポジトリを配置またはリンクするとスキルを認識できます。

## 現在のスキル

| スキル | 概要 |
|---|---|
| `csharp-coding-rules` | C# / .NET 実装で DI、1 ファイル 1 型、コメントに頼らない可読性を守るためのコーディングルール。 |
| `debug-red-green` | バグ修正、失敗テスト、flaky テスト、回帰、実行時エラー、ログベースのデバッグ用。 |
| `develop-feature-workflow` | TOBE 設計から最小 diff 実装、検証、レビューまで通す機能開発ワークフロー。 |
| `japanese-repo-writing` | リポジトリ作業の日本語コミュニケーションと、日本語 Markdown ドキュメント作成用。 |
| `resolve-git-conflicts` | merge、rebase、cherry-pick、pull などで発生した Git コンフリクト解消用。 |
| `review-pr-diff` | PR やブランチ差分を中心にしたコードレビュー用。 |

## 使い方

### 方法 1: `~/.agent-skills` として直接 clone する

まだ `~/.agent-skills` が存在しない場合は、この方法が一番単純です。

```powershell
git clone https://github.com/taiseiishiyama00/agent-skills.git $HOME\.agent-skills
```

既存の `~/.agent-skills` がある場合は、先に退避してから clone します。

```powershell
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Move-Item $HOME\.agent-skills "$HOME\.agent-skills.backup-$timestamp"
git clone https://github.com/taiseiishiyama00/agent-skills.git $HOME\.agent-skills
```

### 方法 2: 任意の場所に clone してエージェント用ディレクトリへリンクする

このリポジトリを通常の作業ディレクトリに clone し、Codex 用の `~/.agent-skills` と Claude Code 用の `~/.claude/skills` をそこへ向けます。

```powershell
git clone https://github.com/taiseiishiyama00/agent-skills.git $HOME\repos\agent-skills
cd $HOME\repos\agent-skills
.\scripts\install-windows.ps1
```

`install-windows.ps1` は、既存の `~/.agent-skills` または `~/.claude/skills` が通常ディレクトリならバックアップしてから junction を作成します。既存の対象がリンクなら、そのリンクだけを作り直します。

Unix 系環境では次を使います。

```sh
git clone https://github.com/taiseiishiyama00/agent-skills.git ~/repos/agent-skills
cd ~/repos/agent-skills
sh scripts/install-unix.sh
```

## Codex で認識させる

1. このリポジトリを `~/.agent-skills` として配置するか、`scripts/install-windows.ps1` / `scripts/install-unix.sh` でリンクする。
2. Codex を新しいセッションで起動する。
3. 起動後、`~/.agent-skills/<skill-name>/SKILL.md` が読み込まれ、スキル一覧に表示されることを確認する。

この会話の途中でファイルを変更しても、すでに起動済みの Codex セッションではスキル一覧が即時更新されないことがあります。反映確認は新しいセッションで行います。

## Claude Code で認識させる

1. このリポジトリを `~/.claude/skills` として配置するか、`scripts/install-windows.ps1` / `scripts/install-unix.sh` でリンクする。
2. Claude Code を新しいセッションで起動する。
3. 起動後、`~/.claude/skills/<skill-name>/SKILL.md` が読み込まれ、スキル一覧に表示されることを確認する。

すでに起動済みの Claude Code セッションではスキル一覧が即時更新されないことがあります。反映確認は新しいセッションで行います。

## スキルの追加・更新

スキルは次の構成にします。

```text
<skill-name>/
  SKILL.md
  agents/
    openai.yaml
```

`SKILL.md` の先頭には YAML frontmatter を置きます。

```markdown
---
name: example-skill
description: このスキルをいつ使うか、何をするかを簡潔に書く。
---

# Example Skill

## 目的

...
```

基本ルール:

- `name` はディレクトリ名と同じ lowercase hyphen-case にする。
- `description` には、何をするスキルかだけでなく、どんな依頼で発火してほしいかを書く。
- 本文は、Codex や Claude Code が読んで作業できる手順にする。
- `agents/openai.yaml` には、UI 表示用の `display_name`、`short_description`、`default_prompt` を置く。
- README や補助資料をスキルディレクトリ内に増やしすぎず、必要最小限にする。

## 更新の流れ

```powershell
git pull
# SKILL.md を編集または追加
git status
git add .
git commit -m "スキルを更新"
git push
```

別の環境では、clone 済みのリポジトリで `git pull` した後、Codex や Claude Code などのエージェントを再起動すると更新されたスキルが認識されます。

## 注意

- このリポジトリは個人用スキルを管理する source of truth として扱います。
- ローカルだけにある未管理スキルを失わないよう、セットアップスクリプトは既存の `~/.agent-skills` と `~/.claude/skills` を削除せずバックアップします。
- プラグイン由来やシステム由来のスキルは、このリポジトリでは管理しません。
