# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

ROOT = File.expand_path("..", __dir__)

class SourceContentTest < Minitest::Test
  def load_yaml(path)
    YAML.load_file(File.join(ROOT, path))
  end

  def test_custom_domain_is_preserved
    assert_equal "www.yihaosun.cn\n", File.read(File.join(ROOT, "CNAME"))
  end

  def test_profile_uses_current_information
    profile = load_yaml("_data/profile.yml")
    assert_equal "Yihao Sun", profile.fetch("name")
    assert_equal "Ph.D. Student in Computer Science", profile.fetch("role")
    assert_includes profile.fetch("bio"), "May 2025 to present"
    assert_equal "yihao.sun@mila.quebec", profile.dig("links", "email")
    assert_equal "/CV/yihaosun_cv.pdf", profile.dig("links", "cv")
    assert_equal "/assets/img/avatar.jpg", profile.fetch("portrait")
  end

  def test_tmp_is_excluded_from_the_site_build
    config = load_yaml("_config.yml")
    assert_includes config.fetch("exclude"), "tmp"
  end

  def test_initial_research_collection_has_one_requested_paper
    research = load_yaml("_data/research.yml")
    assert_equal 1, research.length
    paper = research.first
    assert_equal "Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models", paper.fetch("title")
    assert_equal "ICML", paper.fetch("venue")
    assert_equal 2026, paper.fetch("year")
    assert_equal 3, paper.fetch("authors").count { |author| author["equal"] }
    assert paper.fetch("authors").any? { |author| author["name"] == "Yihao Sun" && author["self"] }
  end

  def test_initial_project_collection_has_two_requested_projects
    projects = load_yaml("_data/projects.yml")
    assert_equal ["VLARLKit", "OfflineRL-Kit"], projects.map { |project| project.fetch("name") }
    projects.each do |project|
      assert project.fetch("repository").start_with?("https://github.com/")
      assert File.file?(File.join(ROOT, project.fetch("image").delete_prefix("/")))
    end
  end

  def test_old_al_folio_tree_is_gone
    %w[_bibliography _news _pages _plugins _projects _sass].each do |path|
      refute Dir.exist?(File.join(ROOT, path)), "expected #{path} to be removed"
    end
    refute File.exist?(File.join(ROOT, "Dockerfile"))
    refute File.exist?(File.join(ROOT, "docker-compose.yml"))
  end

  def test_remaining_legacy_template_configuration_is_gone
    %w[
      .all-contributorsrc
      .github/ISSUE_TEMPLATE/bug_report.md
      .github/ISSUE_TEMPLATE/feature_request.md
      .github/stale.yml
      .github/workflows/deploy-docker-tag.yml
      .github/workflows/deploy-image.yml
      .github/workflows/deploy.yml
      .pre-commit-config.yaml
    ].each do |path|
      refute File.exist?(File.join(ROOT, path)), "expected #{path} to be removed"
    end
  end
end
