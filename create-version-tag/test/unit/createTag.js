const { describe, it } = require('mocha')
const assert = require('assert')
const { spawnSync } = require('child_process')

const dockerMock = './test/unit/docker-mock.sh'
const scriptTotest = './createTag.sh'

const mandatoryVars = {
  pact_broker: 'pact_broker-set',
  pact_broker_token: 'pact_broker_token-set',
  application_name: 'application_name-set',
  version: 'version-set',
  tag: 'tag-set'
}

// Examines the generated docker call to check each element is in place when called with `mandatoryVars`.
const dockerCallParameters = [
  ['calls docker with "run --rm"', /docker run --rm/],
  [
    'sets PACT_BROKER_BASE_URL',
    new RegExp(`docker .* -e PACT_BROKER_BASE_URL=${mandatoryVars.pact_broker}`)
  ],
  [
    'sets PACT_BROKER_TOKEN',
    new RegExp(
      `docker .* -e PACT_BROKER_TOKEN=${mandatoryVars.pact_broker_token}`
    )
  ],
  ['uses latest pact-cli', /docker .* -e .*pactfoundation\/pact-cli:latest/],
  ['uses create-version-tag', /pact-cli.*broker create-version-tag/],
  [
    'sets the participant',
    new RegExp(
      `create-version-tag.*--pacticipant ${mandatoryVars.application_name}`
    )
  ],
  [
    'sets version',
    new RegExp(`create-version-tag.* --version ${mandatoryVars.version}`)
  ],
  ['sets tag', new RegExp(`create-version-tag.* --tag ${mandatoryVars.tag}`)]
]

// Runs the script we're testing, passing params etc....
const spawnScript = (env = mandatoryVars) =>
  spawnSync(dockerMock, [scriptTotest], { env, shell: true })

describe('createTag', () => {
  describe('docker command', () =>
    dockerCallParameters.forEach(([description, matcher]) =>
      it(description, () => {
        const result = spawnScript()

        assert.match(result.stdout.toString(), matcher)
      })
    ))

  describe('mandatory variables', () =>
    Object.keys(mandatoryVars).forEach(testVar => {
      it(`fails if mandatory variable '${testVar} 'is not set`, () => {
        // Deep clone, so the 'delete' doesn't affect the original.
        const env = JSON.parse(JSON.stringify(mandatoryVars))
        delete env[testVar]
        const result = spawnScript(env)

        assert.strictEqual(result.status, 1)
      })
    }))

  it('uses specified VERSION', () => {
    const result = spawnScript({ ...mandatoryVars, version: '123' })

    assert.match(result.stdout.toString(), /create-version-tag.* --version 123/)
  })

  it('does not fail if all variables are set', () => {
    const result = spawnScript()

    assert.strictEqual(result.status, 0)
  })
})
