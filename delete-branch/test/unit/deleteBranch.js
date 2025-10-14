const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");

const cliMock = "./test/unit/cli-mock.sh";
const scriptTotest = "./deleteBranch.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  application_name: "application_name-set",
  branch: "branch-set",
};

const optionalVars = {
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set"
};

// Examines the generated cli call to check each element is in place when called with `mandatoryVars`.
const cliCallParameters = [
  ['calls pact-broker-cli', /pact-broker-cli/],
  ["uses delete-branch", /pact-broker-cli delete-branch/],
  [
    "sets the pacticipant",
    new RegExp(`delete-branch.*--pacticipant ${mandatoryVars.application_name}`),
  ],
  [
    "sets the branch",
    new RegExp(`delete-branch.*--branch ${mandatoryVars.branch}`),
  ],

];

// Runs the script we're testing, passing params etc....
const spawnScript = (env = {...mandatoryVars, ...optionalVars}) =>
  spawnSync(cliMock, [scriptTotest], { env, shell: true });

describe("deleteBranch", () => {
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
});
