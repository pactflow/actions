# pact-publish-oas-action

Publishes OAS and test evidence to a Pactflow server for 'bi-directional' testing.

## Required environment variables (secrets)
`PACT_BROKER`: the url of your pactflow
`PACT_BROKER_TOKEN`: your pactfllow token

## Example
```yaml
  pact-publish-oas-action:
    steps:
      # MANDATORY: Must checkout first
      - uses: actions/checkout@v2
      - uses: roycdiscovery/pact-publish-oas-action@v1.0
        env:
          participant_name: "my-api-provider"
          version: "1.2.3"
          oas_file: src/oas/user.yml
          results_file: src/results/report.md
```

## Notes
- Assumes 'success = true' (you can control this action by depending on an earliler successful test job).
- You must ensure `additionalProperties` in your OAS is set to `false` on any response body, to ensure a consumer won't get false positives if they add a new field that isn't actually part of the spec.
