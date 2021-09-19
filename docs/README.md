## About Jekyll Archives Dir-Category

This plugin is based on [Jekyll Archives](https://github.com/jekyll/jekyll-archives)
Added directory category function:
generate category information acrodding the directory structure
**the `category`/`categories` tags set in the markdown file will be ignored**

## Example

Usage is same as `Jekyll Archives` except the category things:

* path: `_posts/linux/2018-02-02-example1.md`
    this post will have category: `linux`
* path: `_posts/linux/shell/2018-02-02-example2.md`
    this post will have category: `linux/shell`
* path: `_posts/linux/shell/bash/2018-02-02-example3.md`
    this post will have category: `linux/shell/bash`

## Getting started

### Installation

1. Add `gem 'jekyll-archives-dir-category'` to your site's Gemfile
2. Add the following to your site's `_config.yml`:

```yml
plugins:
  - jekyll-archives-dir-category
```

### Configuration

Archives can be configured by using the `jekyll-archives-dir-category` key in the Jekyll configuration (`_config.yml`) file. See the [Configuration](configuration.md) page for a full list of configuration options.

All archives are rendered with specific layouts using certain metadata available to the archive page. The [Layouts](layouts.md) page will show you how to create a layout for use with Archives.

## Documentation

For more information, see:

* [Getting-started](getting-started.md)
* [Configuration](configuration.md)
* [Layouts](layouts.md)
