## 0.1.5 / 2021-10-20

* change site data name from `years` to `date-info`
* `date-info` structure:
    ```ruby
    [
        {
            "year"=>"2021",
            "months"=>[
                {
                    "month"=>"10",
                    "days"=>[
                        {
                            "day"=>"15",
                            "post_count"=>1
                        },
                        {
                            "day"=>"14",
                            "post_count"=>1
                        },
                        {
                            "day"=>"11",
                            "post_count"=>1
                        },
                        {
                            "day"=>"07",
                            "post_count"=>4
                        },
                        {
                            "day"=>"05",
                            "post_count"=>2
                        }
                    ],
                    "post_count"=>9
                },
                {
                    "month"=>"09",
                    "days"=>[
                        {
                            "day"=>"26",
                            "post_count"=>1
                        }
                    ],
                    "post_count"=>1
                }
            ],
            "post_count"=>10
        },
        ...
    ```

## 0.1.4 / 2021-10-19

  * add site data `years`
    which have the struct:
    ```ruby
    [
        { "year" => "2021",
            "months" => [
                { "month" => "07",
                    "days" => ["03", "26", "28"] },
                { "month" => "06",
                    "days" => ["03", "22", "28"] },
                { "month" => "04",
                    "days" => ["04"]
                }
            ]
        },
        { "year" => "2020",
            "months" => [
                { "month" => "07",
                    "days" => ["03", "26", "28"] },
                { "month" => "06",
                    "days" => ["03", "22", "28"] },
                { "month" => "04",
                    "days" => ["04"]
                }
            ]
        },
    ]
    ```

## 0.1.3 / 2021-10-13

  * change post's attribute name `category-name`/`update-time` to `category_name`/`update_time`

## 0.1.2 / 2021-09-22

  * add `update-time` to post (use git commit date)
  * add site data `category-info`

## 0.1.0 / 2021-09-19

  * First release
  * Add directory category support

## 0.0.0 / 2021-09-15
  * fork from https://github.com/jekyll/jekyll-archives
