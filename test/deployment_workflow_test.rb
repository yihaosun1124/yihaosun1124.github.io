# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class DeploymentWorkflowTest < Minitest::Test
  WORKFLOW = ".github/workflows/pages.yml"

  def test_master_push_builds_and_publishes_the_site
    workflow = File.read(File.join(ROOT, WORKFLOW))

    assert_includes workflow, "branches: [master]"
    assert_includes workflow, "bundle exec jekyll build --trace"
    assert_includes workflow, "branch: gh-pages"
    assert_includes workflow, "folder: _site"
    refute_match(/al-folio|mermaid|docker/i, workflow)
    assert YAML.safe_load(workflow, aliases: true)
  end

  def test_lockfile_supports_the_linux_runner
    lockfile = File.read(File.join(ROOT, "Gemfile.lock"))
    assert_match(/^  x86_64-linux$/, lockfile)
  end
end
