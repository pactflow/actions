# can-i-deploy action

Checks you can deploy based on target tag (i.e. an environment name).

## Example

```yml
# (This just saves defining these multiple times for different pact jobs)
env:
  application_name: "my-consumer-app"
  pact_broker: ${{ secrets.PACT_BROKER }}
  pact_broker_token: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  pact-can-i-deploy-latest:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/can-i-deploy
        env:
          to: "test"

  # or ...
  pact-can-i-deploy-specific:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/can-i-deploy
        env:
          version: "1.0.1"
          to: "test"

  # or ...
  pact-can-i-move-upstream:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/can-i-deploy
        env:
          latest: "test"
          to: "stage"
```
