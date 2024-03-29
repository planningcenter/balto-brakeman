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
    permissions: # may not be necessary, see note below
      contents: read
      checks: write
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: ruby/setup-ruby@v1
      - uses: planningcenter/balto-brakeman@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          conclusionLevel: "neutral"
```

## Inputs

| Name | Description | Required | Default |
|:-:|:-:|:-:|:-:|
| `conclusionLevel` | Which check run conclusion type to use when annotations are created (`"neutral"` or `"failure"` are most common). See [GitHub Checks documentation](https://developer.github.com/v3/checks/runs/#parameters) for all available options.  | no | `"neutral"` |

## A note about permissions

Because some tools, like [dependabot](https://github.com/dependabot), use tokens for actions that have read-only permissions, you'll need to elevate its permissions for this action to work with those sorts of tools. If you don't use any of those tools, and your workflow will only run when users with permissions in your repo create and update pull requests, you may not need these explicit permissions at all.

When defining any permissions in a workflow or job, you need to explicitly include any permission the action needs. In the sample config above, we explicitly give `write` permissons to the [checks API](https://docs.github.com/en/rest/checks/runs) for the job that includes balto-brakeman as a step. Because balto-brakeman uses [check runs](https://docs.github.com/en/rest/guides/getting-started-with-the-checks-api), the `GITHUB_TOKEN` used in an action must have permissions to create a `check run`. You'll also need `contents: read` for `actions/checkout` to be able to clone the code.

## Contributing

### Local testing

1. Setup [act](https://github.com/nektos/act) (`brew install act`)
2. `npm test` (Note: this will download a large (6-12gb) docker image that
   matches what is ran on a GitHub action run)
