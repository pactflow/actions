# create-or-update-version action

Create or update pacticipant version by version number

## Example

```yml
# (This just saves defining these multiple times for different pact jobs)
env:
  version: "1.2.3"
  application_name: "my-app"
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }}
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  create-or-update-version:
    runs-on: ubuntu-latest
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v2
      - uses: pactflow/actions/create-or-update-version@v1.1.0
```
