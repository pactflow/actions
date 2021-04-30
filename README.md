# pact-publish-oas-action

Publishes OAS and test evidence to a Pactflow server for 'bi-directional' testing (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Example
```yaml
# (This just saves defining these multiple times for different pact jobs)
env:
  version: "1.2.3"
  participant_name: "my-api-provider"
  pact_broker: ${{ secrets.pact_broker }}
  pact_broker_token: ${{ secrets.pact_broker_token }}

jobs:
  pact-publish-oas-action:
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v2
      - uses: roycdiscovery/pact-publish-oas-action@v1.0
        env:
          oas_file: src/oas/user.yml
          results_file: src/results/report.md
```

## Notes
- If you change your `participant_name` you willl need to inform your consumers (their pact tests rely on the name you use here).
- Assumes 'success = true' (you can control this action by depending on an earliler successful test job).
- You must ensure `additionalProperties` in your OAS is set to `false` on any response body, to ensure a consumer won't get false positives if they add a new field that isn't actually part of the spec.
