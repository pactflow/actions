# publish-pact-files action

Publishes pactfiles to a Pactflow server (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Example

```yaml
jobs:
  publish-pact-files:
    runs-on: ubuntu-latest
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v4
      - uses: pactflow/actions/publish-pact-files@v2
        with:
          pactfiles: src/pactfiles
          version: "1.2.3" # optional, defaults to git sha if not specified
          branch: main # optional, defaults to git branch if not specified
          tag: main # optional, defaults to not set if not specified
          tag_with_git_branch: false # optional, defaults to not false if not set. will auto tag with user specified branch, or set to auto detected branch
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
```
