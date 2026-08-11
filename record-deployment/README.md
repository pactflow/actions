# record-deployment action

Record deployment of an application to an environment

## Example

```yml
jobs:
  pact-record-deployment:
    needs: can-i-deploy
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/record-deployment@v2.0.0
        with:
          version: "1.0.1" # defaults to git sha if not specified
          environment: "test"
          application_name: "my-consumer-app"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
```
