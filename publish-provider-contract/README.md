# publish-provider-contract action

Publishes OAS and test evidence to a Pactflow server for 'bi-directional' testing (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Pre-Requisities

- A Pactflow account
  - Don't have one - sign up 👉 [here](https://pactflow.io/try-for-free) - don't worry, the developer tier is free.
- A Pactflow API Token
  - Log in to your Pactflow account (`https://<your-subdomain>.pactflow.io`), and go to Settings > API Tokens - See [here](/#configuring-your-api-token) for the docs

## Example

```yaml
# (This just saves defining these multiple times for different pact jobs)
env:
  version: "1.2.3"
  application_name: "my-api-provider"
  pact_broker: ${{ secrets.PACT_BROKER }}
  pact_broker_token: ${{ secrets.PACT_BROKER_TOKEN }}

jobs:
  pact-publish-oas-action:
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v2
      - name: Publish provider contract on passing test run   
        if: success()
        uses: pactflow/actions/publish-provider-contract@v0.0.5
        env:
          oas_file: src/oas/user.yml
          results_file: src/results/report.md
      - name: Publish provider contract on failing test run
        # ensure we publish results even if the tests fail   
        if: failure() 
        uses: pactflow/actions/publish-provider-contract@v0.0.5
        env:
          oas_file: src/oas/user.yml
          results_file: src/results/report.md
          # ensure we set the EXIT_CODE to ensure we upload a failing self-verification result 
          EXIT_CODE: 1
```

## Notes

- If you change your `application_name` you willl need to inform your consumers (their pact tests rely on the name you use here).
- Assumes 'success = true' (you can control this action by depending on an earliler successful test job).
- You must ensure `additionalProperties` in your OAS is set to `false` on any response body, to ensure a consumer won't get false positives if they add a new field that isn't actually part of the spec.
