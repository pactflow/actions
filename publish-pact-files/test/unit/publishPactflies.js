const { describe, it } = require('mocha')
const assert = require('assert')
const { spawnSync } = require('child_process')

const dockerMock = './test/unit/docker-mock.sh'
const scriptTotest = './publishPactfiles.sh'

const mandatoryVars = {
  pact_broker: 'pact_broker-set',
  pact_broker_token: 'pact_broker_token-set',
  application_name: 'application_name-set',
  version: 'version-set',
  pactfiles: 'pactfiles-set'
}

// Examines the generated docker call to check each element is in place when called with `mandatoryVars`.
const dockerCallParameters = [
  ['calls docker with "run --rm"', /docker run --rm/],
  ['uses working directory', new RegExp(`-w ${process.env.PWD}`)],
  ['uses volume', new RegExp(`-v ${process.env.PWD}:${process.env.PWD}`)],
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
  ['uses publish', /pact-cli.* publish /],
  [
    'sets version',
    new RegExp(`publish.* --consumer-app-version ${mandatoryVars.version}`)
  ],
  ['sets pactfiles', new RegExp(`publish.* ${mandatoryVars.pactfiles}`)]
]

// Runs the script we're testing, passing params etc....
const spawnScript = (env = mandatoryVars) =>
  spawnSync(dockerMock, [scriptTotest], { env, shell: true })

describe('canideployTo', () => {
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

    assert.match(
      result.stdout.toString(),
      /publish.* --consumer-app-version 123/
    )
  })

  it('does not fail if all variables are set', () => {
    const result = spawnScript()

    assert.strictEqual(result.status, 0)
  })
})
