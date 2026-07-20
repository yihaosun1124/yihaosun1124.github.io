# frozen_string_literal: true

require "digest"
require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class AssetsAndStyleTest < Minitest::Test
  def test_reference_layout_rules_exist
    style = File.read(File.join(ROOT, "assets/css/style.scss"))
    assert_includes style, "max-width: 800px"
    assert_includes style, "grid-template-columns: 3fr 2fr"
    assert_includes style, "grid-template-columns: 1fr 3fr"
    assert_match(/@media \(max-width: 640px\)/, style)
  end

  def test_template_credit_is_presented_as_a_subtle_centered_footer
    style = File.read(File.join(ROOT, "assets/css/style.scss"))
    assert_match(/\.site-footer\s*\{[^}]*display:\s*flex;/m, style)
    assert_match(/\.site-footer\s*\{[^}]*justify-content:\s*center;/m, style)
    assert_match(/\.site-footer\s*\{[^}]*width:\s*100%;/m, style)
    assert_match(/\.site-footer\s*\{[^}]*text-align:\s*center;/m, style)
    assert_match(/\.site-footer\s*\{[^}]*color:\s*var\(--muted\);/m, style)
  end

  def test_required_images_exist
    %w[
      assets/img/avatar.jpg
      assets/img/peep.png
      assets/img/projects/vlarlkit_logo.png
      assets/img/projects/offlinerl_kit_logo.png
      assets/img/research/vla-mbpo-placeholder.svg
    ].each do |path|
      assert File.file?(File.join(ROOT, path)), "missing #{path}"
    end
  end

  def test_cv_has_the_expected_content_hash
    public_copy = File.join(ROOT, "CV/yihaosun_cv.pdf")
    assert File.file?(public_copy)
    assert_equal "c26d01cbf145b4d61ecb455619fbfcd071029ab2e4e3848820153be503e5f38d", Digest::SHA256.file(public_copy).hexdigest
  end

  def test_linked_local_assets_exist_in_built_site
    html = File.read(File.join(ROOT, "_site/index.html"))
    html.scan(/(?:src|href)="(\/(?:assets|CV)\/[^"#?]+)"/).flatten.each do |url|
      assert File.file?(File.join(ROOT, "_site", url.delete_prefix("/"))), "missing built asset #{url}"
    end
  end
end
