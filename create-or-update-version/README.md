# create-or-update-version action

Create or update pacticipant version by version number

## Example

```yml
jobs:
  create-or-update-version:
    runs-on: ubuntu-latest
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v4
      - uses: pactflow/actions/create-or-update-version@v2
        with:
          version: "1.2.3" # optional, defaults to git sha if not specified
          branch: "test" # optional, defaults to git branch if not specified
          tag: "test" # optional
          application_name: "my-app"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
```
