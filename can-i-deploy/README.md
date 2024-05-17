# can-i-deploy action

Checks you can deploy based on target environment or tag

Check https://docs.pact.io/pact_broker/can_i_deploy for an overview of can-i-deploy

## Example

```yml
# (This just saves defining these multiple times for different pact jobs)
env:
  application_name: "my-consumer-app" # The pacticipant name of which to check if it safe to deploy
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }} # The base URL of the Pact Broker
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }} # Pactflow Broker API Read/Write token

jobs:
  pact-can-i-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/can-i-deploy@v1.2.0
        env:
          version: "1.0.1" # The pacticipant/application version.
          to_environment: "environment_name" # The environment into which the pacticipant(s) are to be deployed
          # to: "tag_name" # The tag that represents the branch or environment of the integrated applications for which you want to check the verification result status.
          # retry_while_unknown: 5 # Optional: number of times to retry while the verification status is unknown
          # retry_interval: 10 # Optional: number of seconds to wait between retries
```

Set only 1 of `to_environment` or `to` depending on whether you are targeting your deployment location using `environments`(recommended) or `tags`

Read more about migrating from tags to branches [here](https://docs.pact.io/pact_broker/branches#migrating-from-tags-to-branches)
