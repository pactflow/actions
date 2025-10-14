# publish-provider-contract action

Publishes OAS and test evidence to a Pactflow server for 'bi-directional' testing (relies on [actions/checkout](https://github.com/marketplace/actions/checkout) being called first).

## Pre-Requisities

- A Pactflow account
  - Don't have one - sign up 👉 [here](https://pactflow.io/try-for-free) - don't worry, the developer tier is free.
- A Pactflow API Token
  - Log in to your Pactflow account (`https://<your-subdomain>.pactflow.io`), and go to Settings > API Tokens - See [here](/#configuring-your-api-token) for the docs

## Example

```yaml
jobs:
  pact-publish-oas-action:
    runs-on: ubuntu-latest
    steps:
      # MANDATORY: Must use 'checkout' first
      - uses: actions/checkout@v4
      - name: Publish provider contract on passing test run
        if: success()
        uses: pactflow/actions/publish-provider-contract@v2
        with:
          version: "1.2.3"
          application_name: "my-api-provider"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
          contract: src/oas/user.yml
          contract_content_type: application/yaml # optional, defaults to application/yml
          verification_results: src/results/report.md
          verifier: "the testing tool used to verify the contract"
      - name: Publish provider contract on failing test run
        # ensure we publish results even if the tests fail
        if: failure()
        uses: pactflow/actions/publish-provider-contract@v2
        with:
          version: "1.2.3"
          application_name: "my-api-provider"
          broker_url: ${{ secrets.PACT_BROKER_BASE_URL }}
          token: ${{ secrets.PACT_BROKER_TOKEN }}
          contract: src/oas/user.yml
          verification_results: src/results/report.md
          # ensure we set the verification_exit_code to ensure we upload a failing self-verification result
          verification_exit_code: 1 # defaults to 0 (success)
          verifier: "the testing tool used to verify the contract"
```

## Notes

- If you change your `application_name` you will need to inform your consumers (their pact tests rely on the name you use here).
- Assumes 'success = true' (you can control this action by depending on an earlier successful test job).
- You must ensure `additionalProperties` in your OAS is set to `false` on any response body, to ensure a consumer won't get false positives if they add a new field that isn't actually part of the spec.
