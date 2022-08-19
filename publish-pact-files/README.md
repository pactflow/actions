# publish-pact-files action

Publishes pactfiles to a Pactflow server (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Example

```yaml
# (This just saves defining these multiple times for different pact jobs)
env:
  version: "1.2.3"
  application_name: "my_api_consumer"
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }}
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  publish-pact-files:
    runs-on: ubuntu-latest
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v2
      - uses: pactflow/actions/publish-pact-files@v0.0.3
        env:
          pactfiles: src/pactfiles
```
