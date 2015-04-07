## Assignment 1.2

### Specification of a protocol

| Path and method | Parameters   | Return value (HTTP code, value) |
| --------------- | ------------ | ------------------------------- |
| `/:id` - GET    | `:id`        | 301, value; 404, -              |
| `/:id` - PUT    | `:id`, `:url`| 200, -; 400, "error"; 404, -    |
| `/:id` - DELETE | `:id`        | 204, -; 404, -                  |
| --------------- | ------------ | ------------------------------- |
| `/` - GET       | -            | 200, :keys                      |
| `/` - POST      | `:url`       | 201, :id; 400, "error"          |
| `/` - DELETE    | -            | 204, -                          |

### Testing

There are two tests provided, before executing the test, you need to install its dependencies including Ruby and a number of Ruby gems (just run `bundle install` or check `Gemfile`).

- `test.rb` contains tests for applications developed with Ruby (please remember to change function `app` according to the framework that you use)
- `test-universal` is a universal test - it should work with any implementation, execute it as follows:

    `ruby test-universal.rb <server address>`
