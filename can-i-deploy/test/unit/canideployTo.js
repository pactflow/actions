const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");

const dockerMock = "./test/unit/docker-mock.sh";
const scriptTotest = "./canideployTo.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
  application_name: "application_name-set",
  to: "to-set",
};

// Examines the generated docker call to check each element is in place when called with `mandatoryVars`.
const dockerCallParameters = [
  ['calls docker with "run --rm"', /docker run --rm/],
  [
    "sets PACT_BROKER_BASE_URL",
    new RegExp(
      `docker .* -e PACT_BROKER_BASE_URL=${mandatoryVars.PACT_BROKER_BASE_URL}`
    ),
  ],
  [
    "sets PACT_BROKER_TOKEN",
    new RegExp(
      `docker .* -e PACT_BROKER_TOKEN=${mandatoryVars.PACT_BROKER_TOKEN}`
    ),
  ],
  ["uses latest pact-cli", /docker .* -e .*pactfoundation\/pact-cli:latest/],
  ["uses can-i-deploy", /pact-cli.*broker can-i-deploy/],
  [
    "sets the participant",
    new RegExp(`can-i-deploy.*--pacticipant ${mandatoryVars.application_name}`),
  ],
  ["VERSION defaults to latest", /can-i-deploy.* --latest/],
  ["sets target", new RegExp(`can-i-deploy.* --to ${mandatoryVars.to}`)],
];

// Runs the script we're testing, passing params etc....
const spawnScript = (env = mandatoryVars) =>
  spawnSync(dockerMock, [scriptTotest], { env, shell: true });

describe("canideployTo", () => {
  describe("docker command", () =>
    dockerCallParameters.forEach(([description, matcher]) =>
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
        const result = spawnScript(env);

        assert.strictEqual(result.status, 1);
      });
    }));

  it("fails if both 'version' and 'latest' are specified", () => {
    const result = spawnScript({
      version: "123",
      latest: "true",
      ...mandatoryVars,
    });

    assert.strictEqual(result.status, 1);
  });

  it("uses specified VERSION", () => {
    const result = spawnScript({ version: "123", ...mandatoryVars });

    assert.match(result.stdout.toString(), /can-i-deploy.* --version 123/);
  });

  it("does not fail if all variables are set", () => {
    const result = spawnScript();

    assert.strictEqual(result.status, 0);
  });
});
