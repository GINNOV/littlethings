# Assembly Mutation Workspace

This workspace mutates the actual `current.s` assembly source instead of the derived `out/copper-list.s` file.

The mutable Copper list is inlined between the markers:

- `; BEGIN MUTATION COPPER LIST`
- `; END MUTATION COPPER LIST`

The mutation loop extracts just that block, proposes candidate edits, writes the edited assembly file back, and then runs the same Copper screenshot benchmark.

This workspace starts from a stepped-back version of the passing source so the loop has visible headroom to recover.
