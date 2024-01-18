# delete-branch action

Deletes a pacticipant branch. Does not delete the versions or pacts/verifications associated with the branch, but does make the pacts inaccessible for verification via consumer versions selectors or WIP pacts.

## Example

```yml
# (This just saves defining these multiple times for different pact jobs)
env:
  application_name: "my-consumer-app" # The pacticipant name of which the branch belongs to
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }} # The base URL of the Pact Broker
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }} # Pactflow Broker API Read/Write token

jobs:
  pact-delete-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: pactflow/actions/delete-branch@v1.2.0
        env:
          branch: "test" # The branch name
          error_when_not_found: false # (Optional) - Raise an error if the branch that is to be deleted is not found, default true
```

