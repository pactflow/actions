# create-version-tag action

Creates a tag on this version.

## Example

```yaml
jobs:
  pact-create-tag:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/create-version-tag@v2
        with:
          tag: prod
          version: "1.2.3" # autodetected if not provided
          application_name: "my-api-provider"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
```
