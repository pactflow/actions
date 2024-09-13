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

Alternatively you can use the [pact-ruby-standalone](https://github.com/pact-foundation/pact-ruby-standalone) bundle of tools, available to the GitHub Runners shell, with the action below.

```yml
      - uses: pactflow/actions@main
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
      - uses: pactflow/actions@main
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
      - uses: pactflow/actions@main
      - name: pact-broker.bat on pwsh
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: pwsh
```

### powershell

```yml
      - uses: pactflow/actions@main
      - name: pact-broker.bat on powershell
        run: pact-broker.bat help
        if: runner.os == 'windows'
        shell: powershell
```
