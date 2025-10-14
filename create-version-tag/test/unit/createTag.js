const { describe, it } = require("mocha");
const assert = require("assert");
const { spawnSync } = require("child_process");

const cliMock = "./test/unit/cli-mock.sh";
const scriptTotest = "./createTag.sh";

const mandatoryVars = {
  PACT_BROKER_BASE_URL: "PACT_BROKER_BASE_URL-set",
  application_name: "application_name-set",
  tag: "tag-set",
};

const optionalVars = {
  PACT_BROKER_TOKEN: "PACT_BROKER_TOKEN-set",
  version: "version-set",
};


// Examines the generated cli call to check each element is in place when called with `mandatoryVars`.
const cliCallParameters = [
  ['calls pact-broker-cli', /pact-broker-cli/],
  ["uses create-version-tag", /pact-broker-cli create-version-tag/],
  [
    "sets the participant",
    new RegExp(
      `create-version-tag.*--pacticipant ${mandatoryVars.application_name}`
    ),
  ],
  [
    "sets version",
    new RegExp(`create-version-tag.* --version .*`),
  ],
  ["sets tag", new RegExp(`create-version-tag.* --tag ${mandatoryVars.tag}`)],
];

// Runs the script we're testing, passing params etc....
const spawnScript = (env = {...mandatoryVars, ...optionalVars}) =>
  spawnSync(cliMock, [scriptTotest], { env, shell: true });

describe("createTag", () => {
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

  it("uses specified VERSION", () => {
    const result = spawnScript({ ...mandatoryVars, version: "123" });

    assert.match(
      result.stdout.toString(),
      /create-version-tag.* --version 123/
    );
  });

  it("does not fail if all variables are set", () => {
    const result = spawnScript();

    assert.strictEqual(result.status, 0);
  });
});
