# Agent Skills

個人的な AI エージェント用スキル集です。

このリポジトリは、各スキルをリポジトリ直下の `<skill-name>/SKILL.md` として管理します。Codex では `~/.agent-skills`、Claude Code では `~/.claude/skills` へこのリポジトリを配置またはリンクするとスキルを認識できます。

## 現在のスキル

| スキル | 概要 |
|---|---|
| `azure-devops-work-item-entry` | Azure DevOps の Bug / Product Backlog Item を画面の表示項目に合わせて作成・更新する。 |
| `csharp-coding-rules` | C# / .NET 実装で DI、1 ファイル 1 型、コメントに頼らない可読性を守るためのコーディングルール。 |
| `grow-obsidian-knowledge` | 作業中に得た再利用可能な知識を Obsidian vault（`obsidian-knowledge`）へ追記・統合して育てる。 |
| `plan-mode-preflight` | Plan Modeの前にリードオンリーで事前調査し、根拠付きの修正方針と実装To Doを整理する。 |
| `product-design` | 会社での製品設計に関する参照先と変更先を定めるユーザー共通ルール。 |
| `tobe-asis-gap-writing` | 説明文を TOBE / ASIS / GAP / 対応方針 の構造で整理して書く。 |
| `update-agent-skills` | グローバルとプロジェクトのスキルを同期して更新し、必要なPR作成まで行う。 |
| `youtube-video-production` | 設定済みの複数YouTubeチャンネルで、横動画・Shorts制作、レビュー、投稿を安全に進める。 |

## 共通手順と対象固有値の境界

スキルには複数の対象で再利用する判断・手順・安全条件だけを書き、チャンネル名、作品名、環境固有パス、設定値などの具体は対象repoの設定へ置きます。同じ情報をスキルとrepoへ重複させません。具体を共通へ昇格するのは、2つ目の利用先でも責務と条件が一致すると確認できた場合だけです。

`youtube-video-production` は全チャンネル共通の制作手順を所有し、チャンネル具体は `youtube-video-pipeline/config/channels/<channel-id>.json`、作品具体は `youtube-production/channels/<channel-id>/projects` を正本とします。

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

既存の `~/.agent-skills` や `~/.claude/skills` が通常ディレクトリの場合は、リンクを作る前に退避します。

```powershell
git clone https://github.com/taiseiishiyama00/agent-skills.git $HOME\repos\agent-skills
New-Item -ItemType Junction -Path $HOME\.agent-skills -Target $HOME\repos\agent-skills
New-Item -ItemType Junction -Path $HOME\.claude\skills -Target $HOME\repos\agent-skills
```

Unix 系環境では次を使います。

```sh
git clone https://github.com/taiseiishiyama00/agent-skills.git ~/repos/agent-skills
ln -s ~/repos/agent-skills ~/.agent-skills
ln -s ~/repos/agent-skills ~/.claude/skills
```

## Codex で認識させる

1. このリポジトリを `~/.agent-skills` として配置するか、`~/.agent-skills` からリンクする。
2. Codex を新しいセッションで起動する。
3. 起動後、`~/.agent-skills/<skill-name>/SKILL.md` が読み込まれ、スキル一覧に表示されることを確認する。

この会話の途中でファイルを変更しても、すでに起動済みの Codex セッションではスキル一覧が即時更新されないことがあります。反映確認は新しいセッションで行います。

## Claude Code で認識させる

1. このリポジトリを `~/.claude/skills` として配置するか、`~/.claude/skills` からリンクする。
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
- ローカルだけにある未管理スキルを失わないよう、リンクを作る前に既存の `~/.agent-skills` と `~/.claude/skills` を削除せず退避します。
- プラグイン由来やシステム由来のスキルは、このリポジトリでは管理しません。
