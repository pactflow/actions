# actions

GitHub Actions to perform common Pact &amp; Pactflow commands

see each subfolder for an individual readme with details on how to use :)

For the pact-ruby-standalone bundle of tools, available to the GitHub Runners shell, you can use the full fat action.

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
