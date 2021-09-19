# frozen_string_literal: true

require "jekyll"

module Jekyll
  module Archives
    # Internal requires
    autoload :Archive, "jekyll-archives-dir-category/archive"
    autoload :VERSION, "jekyll-archives-dir-category/version"

    class Archives < Jekyll::Generator
      safe true

      DEFAULTS = {
        "layout" => "archive",
        "enabled" => [],
        "permalinks" => {
          "year" => "/:year/",
          "month" => "/:year/:month/",
          "day" => "/:year/:month/:day/",
          "tag" => "/tag/:name/",
          "category" => "/category/:name/",
        },
      }.freeze

      def initialize(config = {})
        archives_config = config.fetch("jekyll-archives-dir-category", {})
        printf("Init function of archives\n")

        if archives_config.is_a?(Hash)
          @config = Utils.deep_merge_hashes(DEFAULTS, archives_config)
        else
          @config = nil
          Jekyll.logger.warn "Archives:", "Expected a hash but got #{archives_config.inspect}"
          Jekyll.logger.warn "", "Archives will not be generated for this site."
        end
        @enabled = @config && @config["enabled"]
      end

      def generate(site)
        return if @config.nil?

        @site = site
        @posts = site.posts
        @archives = []

        @site.config["jekyll-archives-dir-category"] = @config

        # reset category info for all posts
        reset_posts_category(site)

        read
        @site.pages.concat(@archives)

        @site.config["archives"] = @archives
      end

      # get a category name from '_category.yml'
      # return the category name from path if '_category.yml' not exist
      def get_category_name(path)
        catname = ""

        curdir = path
        while !curdir.eql?("_posts")
          catpath = curdir + "/_category.yml"
          n = File.basename(curdir)
          if File.exists?(catpath)
            category_info = YAML.load_file(catpath)
            n = category_info["name"] if !category_info["name"].nil?
          end
          catname = n + "/" + catname
          curdir = File.dirname(curdir)
        end
        return catname.slice(0..-2)
      end

      # Reset category info for all posts
      # Add categories info to site.data["category-info"]
      #
      # the category's href is the path from '_posts' to the file name
      # the category's name is the info in '_category.yml' file
      def reset_posts_category(site)
        post_paths = []
        for p in site.posts.docs
          path = File.dirname(p.path)
          pos = path.index("_posts/")
          path = path[pos..-1]
          post_paths << path

          c = path[7..-1]
          cn = get_category_name(path)
          p.data["category"] = c
          p.data["categories"] = [c]
          p.data["category-name"] = cn
          p.data["update-time"] = File.mtime(p.path)
          #   printf("     category:%s\n", c)
          #   printf("     category name:%s\n\n", cn)
        end
        # printf("paths:%s\n", post_paths)
        info = get_category_info("_posts", post_paths)
        category_info = []
        for c in info["subs"]
          category_info << c
        end
        site.data["category-info"] = category_info
      end

      # the category info from '_category.yml' file
      # this is a recursive function
      def get_category_info(dir_path, paths)
        dir = Dir.new(dir_path)
        info = {
          "href" => dir_path.slice(7..-1),
          "name" => File.basename(dir_path),
          "priority" => 0,
          "subs" => [],
        }

        if paths.find { |a| a.include?(dir_path) }.nil?
          return nil
        end

        info_path = dir_path + "/_category.yml"
        if File.exists?(info_path)
          category_info = YAML.load_file(info_path)
          info["name"] = category_info["name"] if !category_info["name"].nil?
          info["priority"] = category_info["priority"] if !category_info["priority"].nil?
        end
        if info["href"].nil?
          info["count"] = 0
        else
          info["count"] = @posts.docs.count { |a|
            a.data["category"].start_with? info["href"]
          }
        end

        dir.children.each do |file_name|
          file_path = File.join(dir_path, file_name)
          if File.directory?(file_path)
            subinfo = get_category_info(file_path, paths)
            if !subinfo.nil?
              info["subs"] << subinfo
            end
          end
        end
        info["subs"] = info["subs"].sort_by { |a| a["priority"] }
        return info
      end

      # DEBUG: print category info
      def print_category(c, indent)
        printf("%sname:%s\n", " " * indent, c["name"])
        printf("%shref:%s\n", " " * indent, c["href"])
        printf("%spriority:%s\n\n", " " * indent, c["priority"])

        for cs in c["subs"]
          if !cs.nil?
            print_category(cs, indent + 4)
          end
        end
      end

      # DEBUG: print category info
      def dump_category_info(site)
        printf("====================================================\n")
        printf("info:%s\n", site.data["category-info"])
        printf("====================================================\n")

        for c in site.data["category-info"]
          if !c.nil?
            print_category(c, 1)
          end
        end
      end

      # Read archive data from posts
      def read
        read_tags
        read_categories
        read_dates
      end

      def read_tags
        if enabled? "tags"
          tags.each do |title, posts|
            @archives << Archive.new(@site, title, "tag", posts)
          end
        end
      end

      def read_categories
        if enabled? "categories"
          cats = []
          @site.categories.each { |title, posts_not_used|
            cat = ""
            title.split("/").each { |item|
              if cat == ""
                cat = item
              else
                cat = cat + "/" + item
              end
              cats << cat
            }
          }
          cats = cats.uniq
          for c in cats
            tmp_posts = []
            for post in @site.posts.docs
              # printf("message in plugin\n")
              if post.data["category"] && post.data["category"].start_with?(c)
                tmp_posts << post
              end
            end
            # printf("category:%s post count:%d\n", title, tmp_posts.size)
            @archives << Archive.new(@site, c, "category", tmp_posts)
          end
        end
      end

      def read_dates
        years.each do |year, y_posts|
          append_enabled_date_type({ :year => year }, "year", y_posts)
          months(y_posts).each do |month, m_posts|
            append_enabled_date_type({ :year => year, :month => month }, "month", m_posts)
            days(m_posts).each do |day, d_posts|
              append_enabled_date_type({ :year => year, :month => month, :day => day }, "day", d_posts)
            end
          end
        end
      end

      # Checks if archive type is enabled in config
      def enabled?(archive)
        @enabled == true || @enabled == "all" || (@enabled.is_a?(Array) && @enabled.include?(archive))
      end

      def tags
        @site.tags
      end

      def categories
        @site.categories
      end

      # Custom `post_attr_hash` method for years
      def years
        date_attr_hash(@posts.docs, "%Y")
      end

      # Custom `post_attr_hash` method for months
      def months(year_posts)
        date_attr_hash(year_posts, "%m")
      end

      # Custom `post_attr_hash` method for days
      def days(month_posts)
        date_attr_hash(month_posts, "%d")
      end

      private

      # Initialize a new Archive page and append to base array if the associated date `type`
      # has been enabled by configuration.
      #
      # meta  - A Hash of the year / month / day as applicable for date.
      # type  - The type of date archive.
      # posts - The array of posts that belong in the date archive.
      def append_enabled_date_type(meta, type, posts)
        @archives << Archive.new(@site, meta, type, posts) if enabled?(type)
      end

      # Custom `post_attr_hash` for date type archives.
      #
      # posts - Array of posts to be considered for archiving.
      # id    - String used to format post date via `Time.strptime` e.g. %Y, %m, etc.
      def date_attr_hash(posts, id)
        hash = Hash.new { |hsh, key| hsh[key] = [] }
        posts.each { |post| hash[post.date.strftime(id)] << post }
        hash.each_value { |posts| posts.sort!.reverse! }
        hash
      end
    end
  end
end
