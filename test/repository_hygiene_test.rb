# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class RepositoryHygieneTest < Minitest::Test
  def test_gitignore_covers_local_and_development_artifacts
    ignore_lines = File.readlines(File.join(ROOT, ".gitignore"), chomp: true)
    expected_rules = %w[
      /.claude/
      /.codex/
      /.superpowers/
      /.idea/
      /.vscode/
      /.worktrees/
      /.ruby-lsp/
      .DS_Store
      Thumbs.db
      *.swp
      *.swo
      *~
      /.env
      /.env.*
      !/.env.example
      /_site/
      /.jekyll-cache/
      /.jekyll-metadata
      /.sass-cache/
      /.bundle/
      /vendor/
      /tmp/
      /coverage/
      *.log
      /docs/
      /test/
    ]

    expected_rules.each do |rule|
      assert_includes ignore_lines, rule
    end
  end

  def test_jekyll_excludes_repository_only_files
    config = YAML.safe_load(File.read(File.join(ROOT, "_config.yml")))
    expected_exclusions = %w[docs test Gemfile Gemfile.lock README.md LICENSE tmp vendor]

    expected_exclusions.each do |path|
      assert_includes config.fetch("exclude"), path
    end
  end
end
