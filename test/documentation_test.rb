# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class DocumentationTest < Minitest::Test
  def test_readme_documents_every_editing_entry_point
    readme = File.read(File.join(ROOT, "README.md"))
    %w[
      _data/profile.yml
      _data/research.yml
      _data/projects.yml
      _posts/YYYY-MM-DD-slug.md
      CV/yihaosun_cv.pdf
      CNAME
      leonidk/leonidk.github.io
      jonbarron.info
    ].each do |text|
      assert_includes readme, text
    end
  end

  def test_reference_license_notice_is_retained
    license = File.read(File.join(ROOT, "LICENSE"))
    assert_includes license, "Copyright (c) 2015 Barry Clark"
    assert_includes license, "The MIT License (MIT)"
  end
end
