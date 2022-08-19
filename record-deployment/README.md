# record-deployment action

Record deployment of an application to an environment

## Example

```yml
# (This just saves defining these multiple times for different pact jobs)
env:
  application_name: "my-consumer-app"
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }}
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  pact-record-deployment:
    needs: can-i-deploy
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/record-deployment@v1.0.0
        env:
          version: "1.0.1"
          environment: "test"
```
