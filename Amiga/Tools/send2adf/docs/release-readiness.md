# ADFlib automation and release-readiness handoff

This checklist covers the owner-controlled work that cannot be completed or
simulated by a local checkout. Keep update and release workflows fail-closed
until every item is verified against the repository's current default-branch
commit.

## Required repository configuration

1. Create the `adflib-verification` and `send2adf-release` environments. Limit
   deployment to the protected default branch and require the same maintainer
   team for both environments.
2. Create and enable the branch and tag rulesets required by the automation
   policy: default-branch protection, ADFlib automation namespaces, immutable
   ADFlib release tags, send2adf release tags, and send2adf release leases.
3. Disable GitHub Actions approval of pull requests and set the default
   workflow permission to read. The dedicated App, not `GITHUB_TOKEN`, owns
   mutation authority.
4. Install the least-privilege `ADFLIB_AUTOMATION_APP` with only the repository
   and ref permissions described by the reviewed automation policy. Store its
   private-key source in the `GI Business` 1Password vault with both
   `development` and `Projects` tags.
5. Add the required repository values:

   - variables: `ADFLIB_AUTOMATION_APPROVER_TEAM`,
     `ADFLIB_AUTOMATION_APP_ID`, `ADFLIB_AUTOMATION_APP_INSTALLATION_OWNER`,
     `ADFLIB_AUTHORITY_ALLOWED_SIGNER`, `ADFLIB_AUTHORITY_FINGERPRINT`,
     `ADFLIB_AUTHORITY_IDENTITY`, and the approved public-provenance value
     `ADFLIB_POST_MERGE_LICENSE_RECEIPT_B64`;
   - secrets: `ADFLIB_SETTINGS_READ_TOKEN` and
     `ADFLIB_AUTOMATION_APP_PRIVATE_KEY`.
6. Produce the signed external-authority prerequisite receipt from an
   authenticated settings read-back. Only then add the receipt-bound
   `.github/adflib-automation-policy.json` and literal-team `.github/CODEOWNERS`
   in a separately reviewed commit. Do not use placeholders for owner, team,
   App, environment, ruleset, signer, or credential identities.

## Hosted validation sequence

After the policy/CODEOWNERS commit is reviewed and merged to `master`:

1. Run `adflib-consumers-ci.yml` at the exact merge SHA. Require green native
   send2adf jobs on macOS arm64, macOS x86_64, and Linux x86_64, plus green
   ADFinder test and Release-build jobs on macOS arm64 and macOS x86_64.
2. Run `adflib-update.yml` in its non-publishing validation mode. Confirm that
   settings read-back, namespace denial tests, candidate resolution, consumer
   dispatch, and cleanup all bind to the same immutable SHA and ADFlib identity.
3. Run `adflib-canary.yml`. Confirm that upstream `master` is resolved once to
   a commit and tree hash, all consumers use that identity, failures remain
   read-only, and no canary artifact can enter a release.
4. Run `send2adf-release.yml` with `mode=validate`. Confirm deterministic
   source and native archives for all three triplets, complete license and
   corresponding-source inventories, architecture checks, and no tag, release,
   appcast, or download mutation.
5. Obtain legal approval for the exact ADFlib inventory and record the
   post-merge receipt. Production release remains blocked until this approval
   and the protected-environment review both succeed.

## Read-only verification

Repository owners can inspect the live configuration without exposing secret
values:

```sh
gh api repos/{owner}/{repo}/environments --jq '.environments[].name'
gh api repos/{owner}/{repo}/rulesets \
  --jq '.[] | [.name,.target,.enforcement] | @tsv'
gh api repos/{owner}/{repo}/actions/permissions/workflow \
  --jq '{default_workflow_permissions,can_approve_pull_request_reviews}'
gh api repos/{owner}/{repo}/actions/variables --jq '.variables[].name'
gh api repos/{owner}/{repo}/actions/secrets --jq '.secrets[].name'
```

The absence of any required item is a release blocker, not a reason to weaken
the workflow or substitute local fixture evidence.
