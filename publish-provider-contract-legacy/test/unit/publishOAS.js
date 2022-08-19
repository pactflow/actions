const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");
const path = require("path");

const curlMock = "./test/unit/curl_mock.sh";
const scriptTotest = "./publishOAS.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
  application_name: "application_name-set",
  version: "version-set",
  oas_file: path.join(__dirname, "results_file.txt"),
  results_file: path.join(__dirname, "results_file.txt"),
};

const URL = `${mandatoryVars.PACT_BROKER_BASE_URL}/contracts/provider/${mandatoryVars.application_name}/version/${mandatoryVars.version}`;

// Examines the generated curl call to check each element is in place when called with `mandatoryVars`.
const curlCallParameters = [
  ['uses "-i -X PUT"', /curl *-i *-X PUT/],
  [
    "sets bearer token",
    new RegExp(
      `curl .* -H Authorization: Bearer ${mandatoryVars.PACT_BROKER_TOKEN}`
    ),
  ],
  ["sets content type", /curl .* -H Content-Type: application\/json/],
  ["passes payload content", /"content":".*"/],
  ["passes payload contractType", /"contractType":"oas"/],
  ["passes payload contentType", /"contentType":"application\/yaml"/],
  [
    "passes payload verificationResults.success",
    /verificationResults.*"success":true/,
  ],
  [
    "passes payload verificationResults.content",
    /verificationResults.*"content":".*"/,
  ],
  [
    "passes payload verificationResults.contentType",
    /verificationResults.*"contentType":"text\/plain"/,
  ],
  [
    "passes payload verificationResults.verifier",
    /verificationResults.*"verifier":"verifier"/,
  ],
  ["passes url", new RegExp(`curl .* ${URL}`)],
];

// Runs the script we're testing, passing params etc....
const spawnScript = ({ responseStatus, env } = {}) => {
  return spawnSync(curlMock, [scriptTotest, responseStatus || 200], {
    env: env || mandatoryVars,
    shell: true,
  });
};

describe("publishOAS", () => {
  describe("curl command", () =>
    curlCallParameters.forEach(([description, matcher]) =>
      it(description, () => {
        const result = spawnScript();

        assert.match(result.stdout.toString(), matcher);
      })
    ));

  describe("mandatory variables", () =>
    Object.keys(mandatoryVars).forEach((testVar) => {
      it(`fails if mandatory variable '${testVar} 'is not set`, () => {
        // Deep clone, so the 'delete' doesn't affect the original.
        const env = JSON.parse(JSON.stringify(mandatoryVars));
        delete env[testVar];
        const result = spawnScript({ env });

        assert.strictEqual(result.status, 1);
      });
    }));

  it("has an exit code of 1 if status returned is > 300", () => {
    const result = spawnScript({ responseStatus: 300 });

    assert.strictEqual(result.status, 1);
  });

  it("has an exit code of 0 if status returned is < 300", () => {
    const result = spawnScript({ responseStatus: 299 });

    assert.strictEqual(result.status, 0);
  });
});
