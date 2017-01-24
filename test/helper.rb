# Taken from jekyll/jekyll-mentions
# (Copyright (c) 2014 GitHub, Inc. Licensened under the MIT).

require "rubygems"
require "minitest/autorun"
require "shoulda"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "jekyll-archives"

TEST_DIR     = File.expand_path("../", __FILE__)
SOURCE_DIR   = File.expand_path("source", TEST_DIR)
DEST_DIR     = File.expand_path("destination", TEST_DIR)

class Minitest::Test
  def fixture_site(config = {})
    Jekyll::Site.new(
      Jekyll::Utils.deep_merge_hashes(
        Jekyll::Utils.deep_merge_hashes(
          Jekyll::Configuration::DEFAULTS,
          {
            "source"      => SOURCE_DIR,
            "destination" => DEST_DIR
          }
        ),
        config
      )
    )
  end

  def archive_exists?(site, path)
    site.config["archives"].any? { |archive| archive.path == path }
  end

  def read_file(path)
    read_path = File.join(DEST_DIR, path)
    if File.exist? read_path
      File.read(read_path).strip
    else
      return false
    end
  end
end
