# Copper Mutation Workspace

This folder is the writable source baseline for the Copper mutation benchmark.

- `current.s`: current entrypoint that the mutation benchmark assembles
- `out/copper-list.s`: intentionally degraded Copper list used as the starting point

The reference implementation remains under `../source/`.
Mutation runs should edit files here, not the golden source.
