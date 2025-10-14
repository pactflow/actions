const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");

const cliMock = "./test/unit/cli-mock.sh";
const scriptTotest = "./canideployTo.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  // PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
  application_name: "application_name-set",
  to: "to-set",
};


const optionalVars = {
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
};


// Examines the generated cli call to check each element is in place when called with `mandatoryVars`.
const cliCallParameters = [
  ['calls pact-broker-cli', /pact-broker-cli/],
  ["uses can-i-deploy", /pact-broker-cli can-i-deploy/],
  [
    "sets the participant",
    new RegExp(`can-i-deploy.*--pacticipant ${mandatoryVars.application_name}`),
  ],
  ["VERSION defaults to latest", /can-i-deploy.* --version .*/],
  ["sets target", new RegExp(`can-i-deploy.* --to ${mandatoryVars.to}`)],
];

// Runs the script we're testing, passing params etc....
const spawnScript = (env = {...mandatoryVars, ...optionalVars}) =>
  spawnSync(cliMock, [scriptTotest], { env, shell: true });

describe("canideployTo", () => {
  describe("cli command", () =>
    cliCallParameters.forEach(([description, matcher]) =>
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

  describe("optional variables", () => {
    it("sets retry_while_unknown and retry_interval", () => {
      const result = spawnScript({
        ...mandatoryVars,
        retry_while_unknown: 5,
        retry_interval: 10,
      });

      assert.match(result.stdout.toString(), /can-i-deploy.* --retry-while-unknown 5 --retry-interval 10/);
      assert.strictEqual(result.status, 0);
    });

    it("fails when retry_while_unknown is not an integer", () => {
      const result = spawnScript({
        ...mandatoryVars,
        retry_while_unknown: "foo",
      });

      assert.match(result.stdout.toString(), /retry_while_unknown has to be an integer/);
      assert.strictEqual(result.status, 1);
    });

    it("fails when retry_interval is not an integer", () => {
      const result = spawnScript({
        ...mandatoryVars,
        retry_while_unknown: 5,
        retry_interval: "foo",
      });

      assert.match(result.stdout.toString(), /retry_interval has to be an integer/);
      assert.strictEqual(result.status, 1);
    });

    it("does not set retry_interval when retry_while_unknown is not set", () => {
      const result = spawnScript({
        ...mandatoryVars,
        retry_interval: 10,
      });

      assert.doesNotMatch(result.stdout.toString(), /--retry-interval/);
      assert.strictEqual(result.status, 0);
    });
  });
});
