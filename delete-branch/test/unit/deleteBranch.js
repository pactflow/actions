const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");

const dockerMock = "./test/unit/docker-mock.sh";
const scriptTotest = "./canideployTo.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
  application_name: "application_name-set",
  branch: "branch-set",
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
  ["uses delete-branch", /pact-cli.*broker delete-branch/],
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
const spawnScript = (env = mandatoryVars) =>
  spawnSync(dockerMock, [scriptTotest], { env, shell: true });

describe("deleteBranch", () => {
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
});
