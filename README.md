# 🐺 Balto

Balto is Smart:

* Installs the latest version of brakeman
* _Only_ annotates lines that have changed

While Balto will only annotate changed lines of code, Brakeman scans the entire Rails app.

Sample config (place in `.github/workflows/balto.yml`):

```yaml
name: Balto

on: [pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: ruby/setup-ruby@v1
      - uses: planningcenter/balto-brakeman@v0.3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          conclusionLevel: "neutral"
```

## Inputs

| Name | Description | Required | Default |
|:-:|:-:|:-:|:-:|
| `conclusionLevel` | Which check run conclusion type to use when annotations are created (`"neutral"` or `"failure"` are most common). See [GitHub Checks documentation](https://developer.github.com/v3/checks/runs/#parameters) for all available options.  | no | `"neutral"` |


## Contributing

### Local testing

1. Setup [act](https://github.com/nektos/act) (`brew install act`)
2. `npm test` (Note: this will download a large (6-12gb) docker image that
   matches what is ran on a GitHub action run)
