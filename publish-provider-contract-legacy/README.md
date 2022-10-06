# publish-provider-contract-legacy action

Publishes OAS and test evidence to a Pactflow server for 'bi-directional' testing (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Example

```yaml
# (This just saves defining these multiple times for different pact jobs)
env:
  version: "1.2.3"
  application_name: "my-api-provider"
  PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_BASE_URL }}
  PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  pact-publish-oas-action:
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v2
      - uses: pactflow/actions/publish-provider-contract-legacy@v1.0.1
        env:
          oas_file: src/oas/user.yml
          results_file: src/results/report.md
```

## Notes

- If you change your `application_name` you willl need to inform your consumers (their pact tests rely on the name you use here).
- Assumes 'success = true' (you can control this action by depending on an earliler successful test job).
- You must ensure `additionalProperties` in your OAS is set to `false` on any response body, to ensure a consumer won't get false positives if they add a new field that isn't actually part of the spec.
