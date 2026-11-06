# Agent Skills

個人的な AI エージェント用スキル集です。

このリポジトリは、各スキルをリポジトリ直下の `<skill-name>/SKILL.md` として管理します。Codex では `~/.agent-skills`、Claude Code では `~/.claude/skills` へこのリポジトリを配置またはリンクするとスキルを認識できます。

## 現在のスキル

| スキル | 概要 |
|---|---|
| `grow-obsidian-knowledge` | 作業中に得た再利用可能な知識を Obsidian vault（`obsidian-knowledge`）へ追記・統合して育てる。 |
| `imozuru` | 知らない分野を、原文にたどりつくまで芋づる式に掘る。[MaryCache/imozuru](https://github.com/MaryCache/imozuru)（MIT、v2.1.0、`659f46c`）の `skills/imozuru/` を取り込んだもの。 |
| `mini-sdd` | 利用者が出したユーザーストーリーと機能要件を観点表で十分か判定し、ストーリーごとに設計と TDD を繰り返して PR 作成まで、利用者と対話しながら実装する。 |
| `pr-review` | PR をユーザーストーリー、設計、コードの順に、利用者と対話しながらレビューし、修正のコミットと PR コメントまで行う。 |
| `skill-authoring` | スキルを長く変わらない骨格と使いながら育てていく部分に分け、育てていく部分を別ファイルにして作成、修正する。 |
| `workflow-base` | ワークフロー系スキル（`mini-sdd`、`pr-review`）が共通で使う止まり方と書式。単独では使わない。 |
| `yomiyasu` | AI が生成した日本語を、意味と条件を保ったまま自然な日本語へ推敲する。[nanaism/yomiyasu](https://github.com/nanaism/yomiyasu)（MIT、v2.4.0、`41e5aec`）の `skills/yomiyasu/` を取り込んだもの。 |

## 共通手順と対象固有値の境界

スキルには複数の対象で再利用する判断・手順・安全条件だけを書き、チャンネル名、作品名、環境固有パス、設定値などの具体は対象repoの設定へ置きます。同じ情報をスキルとrepoへ重複させません。具体を共通へ昇格するのは、2つ目の利用先でも責務と条件が一致すると確認できた場合だけです。
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

スキルの構成と書き方は、`skill-authoring` スキルに従います。

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
