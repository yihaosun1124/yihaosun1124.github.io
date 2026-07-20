# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class RenderedSiteTest < Minitest::Test
  def setup
    @index_path = File.join(ROOT, "_site", "index.html")
    assert File.file?(@index_path), "run bundle exec jekyll build before this test"
    @html = File.read(@index_path)
  end

  def test_homepage_contains_requested_content
    assert_includes @html, "Yihao Sun"
    assert_includes @html, "Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models"
    visible_text = @html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ")
    assert_includes visible_text, "*: equal contribution, see the CV for the full list"
    assert_includes @html, "VLARLKit"
    assert_includes @html, "OfflineRL-Kit"
    assert_includes @html, "/CV/yihaosun_cv.pdf"
  end

  def test_initial_homepage_has_one_research_entry_and_two_project_entries
    assert_equal 1, @html.scan('class="entry research-entry"').length
    assert_equal 2, @html.scan('class="entry project-entry"').length
  end

  def test_empty_blog_collection_does_not_render_an_empty_section
    refute_includes @html, "<h2>Blog</h2>"
  end

  def test_reference_author_content_is_absent
    %w[Leonid Keselman Intel RealSense al-folio].each do |legacy_text|
      refute_includes @html, legacy_text
    end
  end

end
