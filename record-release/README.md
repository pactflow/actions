# record-release action

Record release of an application to an environment

## Example

```yml
jobs:
  pact-record-release:
    needs: can-i-deploy
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/record-release@v2
        with:
          version: "1.0.1" # defaults to git sha if not specified
          environment: "test"
          application_name: "my-consumer-app"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
```
