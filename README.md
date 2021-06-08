
# Trufflehog Actions Scan :pig_nose::key:
![perform self-test of action](https://github.com/tRaugust/trufflehog-actions-scan/workflows/perform%20self-test%20of%20action/badge.svg)

Scan recent commits in repository for secrets with basic [trufflehog](https://github.com/dxa4481/truffleHog) defaults in place for easy setup.

Now updated to use the **updated** [trufflehog3](https://github.com/feeltheajf/truffleHog3) that is an updated fork of the original [trufflehog](https://github.com/dxa4481/truffleHog) 

This action is intended as a Continuous Integration secret scan in an already "clean" repository. The default commit scan depth is the last 50 commits and can be adjusted using Custom Arguments (see below).

It is recommended to run a basic trufflehog scan on your entire repository prior to relying on this CI solution (Note: this can be done manually from the command line or by using this action with custom options `"--regex --entropy=False"`).

## Usage

Default trufflehog options for this tool include:

- regex : Enable high signal regex checks

- entropy disabled: Disabled entropy checks

- max depth is 50: The max commit depth to go back when searching for secrets

For custom regex rules:

- rules: Uses custom [regexes.json](regexes.json)
- Note: this is similar to the default `trufflehog` version, however this `regexes.json` will catch some additional API keys including any key Encapsulation Boundary that ends in ` PRIVATE KEY-----` or ` PRIVATE KEY BLOCK-----`.

Edit your corresponding actions `yml` file or create a new one.

The default behavior of this action is to fail upon any finding that has not yet been white-listed
### Outputs

The action now has the following outputs.
* `numWarnings` - the number of warnings found in this scan
* `warningsText` - the text of the warnings as a human readable list (see this comment for [Example](https://github.com/tRaugust/trufflehog-actions-scan/commit/3ca6fb1e80eb05665ea42289f66f1a2820b8a846#commitcomment-39473874))
* `warningsJSON` - the output as a structured JSON file  (see the collapsed "details" section in this comment for [Example](https://github.com/tRaugust/trufflehog-actions-scan/commit/3ca6fb1e80eb05665ea42289f66f1a2820b8a846#commitcomment-39473874)

(i) You need to give an id to the step to be able to address the output variables. 

### config file 
you can place a file `trufflehog.yaml` in the root of your repository for trufflehog to pick it up and use the custom configuration.
This can be used to whitelist false positives in your repo.

Example file:
```yaml
skip_strings:
  # these literals will be skipped in all files:
  /:
    - test_key
    - test_pwd

no_regex: false
no_entropy: false
no_history: false
no_current: false
```
See original trufflehog3 [documentation](https://github.com/feeltheajf/truffleHog3/blob/master/README.md) and [samples](https://github.com/feeltheajf/truffleHog3/blob/master/examples/trufflehog.yaml) for more detail 

### Basic

```yaml
steps:
- uses: actions/checkout@master
- name: trufflehog-actions-scan
  uses: traugust/trufflehog-actions-scan@master
```

### Custom Arguments

```yaml
steps:
- uses: actions/checkout@master
- name: trufflehog-actions-scan
  uses: traugust/trufflehog-actions-scan@master
  with:
    scanArguments: "--regex --entropy=False --max_depth=5 --rules /regexes.json" # Add custom options here*

```

* if custom options argument string is used, it will overwrite default settings
* if you want to just run the `trufflehog` command with NO arguments, set as a single spaced string `" "`

### more sophisticated example

This example invokes the trufflehog action, posts a comment ([Example](https://github.com/tRaugust/trufflehog-actions-scan/commit/3ca6fb1e80eb05665ea42289f66f1a2820b8a846#commitcomment-39473874)) on the offending PR or push, utilizes the Output variables to output warnings -- 
You need to give an id to the step to be able to address the output variables. 
```yaml
name: Check For accidentally commited Secrets
on:
  push:
    branches: [ master ]
jobs:
  scan-code:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: scan code with trufflehog
        ## this id is used in the expressions to reference the step output
        id: scan_secrets 
        uses: traugust/trufflehog-actions-scan@master
        with:
          githubToken: ${{ secrets. GIT_HUB_CLONE_TOKEN }} # You have to create an access token manually, add it to the repo secrets
      - name: Uploading Logfile
        uses: actions/upload-artifact@v1
        if: failure()
        with:
          name: trufflehog-logfile.log
          path: TRufflehog.log
      - name: write comment on push
        if: failure()
        uses: peter-evans/commit-comment@v1
        with:
          token: ${{ secrets. GIT_HUB_CLONE_TOKEN }}
          body: |
            Trufflehog scan found ${{steps.scan_secrets.outputs.numWarnings}} suspicious lines in code.
            These could contain secrets that were committed accidentally.
            Please review the following files :
            ```
            ${{steps.scan_secrets.outputs.warningsText}}
            ```
            <details>
            <summary>Review the full trufflehog scan log:</summary>

            ```
            ${{steps.scan_secrets.outputs.warningsJSON}}
            ```
            </details>

```


### Private GitHub Repository

Pass a GitHub access token to action to clone from a private GitHub repository.
You can't use the default `GITHUB_TOKEN` as it doesn't have the permission to clone the repository.

```yaml
steps:
- uses: actions/checkout@master
- name: trufflehog-actions-scan
  uses: traugust/trufflehog-actions-scan@master
  with:
    githubToken: ${{ secrets.GIT_HUB_CLONE_TOKEN }} # You have to create an access token manually and store it into your repo's secrets

```

----

[MIT License](LICENSE)
