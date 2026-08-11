# actions

GitHub Actions to perform common Pact &amp; Pactflow commands

see each subfolder for an individual readme with details on how to use :)

```sh
├── can-i-deploy
├── create-or-update-version
├── create-version-tag
├── delete-branch
├── publish-pact-files
├── publish-provider-contract
├── record-deployment
└── record-release
```

## Versioning

Releases are published as immutable `vX.Y.Z` tags. There are no moving major
tags — a given tag always points at the same commit, forever.

Pin to a released version:

```yml
- uses: pactflow/actions/can-i-deploy@v2.0.0
```

Or, for the strongest supply-chain guarantee, pin to the commit SHA and let
Renovate or Dependabot keep it current:

```yml
- uses: pactflow/actions/can-i-deploy@2b4e9b508f6b0eb9db3350562c3adc1a75977161 # v2.0.0
```

Do **not** use `@main`. It is a moving reference that changes with every
merge, so what runs in your workflow can change without warning.

### Legacy tags

`v2` and the `v1.x` tags are frozen and will not be updated. `v2` points at
the same commit as `v2.0.0`. If you are still on `@v2`, move to `@v2.0.0` or
a SHA — you will get identical behaviour and a reference that cannot move.

Alternatively you can use the [pact-ruby-standalone](https://github.com/pact-foundation/pact-ruby-standalone) bundle of tools, available to the GitHub Runners shell, with the action below.

```yml
      - uses: pactflow/actions@v2.0.0
      - run: pact-broker help
        if: runner.os != 'windows'
        shell: bash
      - name: pact-broker.bat on bash
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: bash
```

## other shells

### sh

```yml
      - uses: pactflow/actions@v2.0.0
      - run: pact-broker help
        if: runner.os != 'windows'
        shell: sh
      - name: pact-broker.bat on sh
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: sh
```


### pwsh

```yml
      - uses: pactflow/actions@v2.0.0
      - name: pact-broker.bat on pwsh
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: pwsh
```

### powershell

```yml
      - uses: pactflow/actions@v2.0.0
      - name: pact-broker.bat on powershell
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: powershell
```

## Releasing

A draft pull request on the `release/actions` branch tracks `main`
continuously. It carries the proposed version in `VERSION` and the release
notes in `CHANGELOG.md`, both regenerated on every push to `main`.

To cut a release:

1. Open the draft release PR and check the `VERSION` and `CHANGELOG.md` diff.
2. Mark it **Ready for review**. This triggers the full test suite; CI is
   skipped while the PR is a draft.
3. Merge it. Merging creates the `vX.Y.Z` tag from `VERSION` and publishes
   the GitHub release.

`VERSION` and `CHANGELOG.md` are the source of truth — not the PR title or
description. To override the version or the notes, push a commit to
`release/actions` before merging. Note that any subsequent push to `main`
resets that branch and discards manual edits, so do it just before merging.

The version is proposed by [git-cliff](https://git-cliff.org) from
conventional commit messages: `fix:` bumps the patch, `feat:` the minor, and
`feat!:` or a `BREAKING CHANGE:` footer the major.
