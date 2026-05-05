# Tasks for Tranche 1: Establish the typed core owner for package-owned tables-only and single-parent loads

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`

## Supplemental remediation tasking

This file remains the controlling tasking for the original tranche-01
implementation scope.

If the work targets the already-committed tranche-01 fulfillment state after
architecture review findings were reported, read
`workflow-docs/20260504T0131--type-stable-parse/04_tranche-01--review-remediation-tasking.md`
line by line and comply with it as a mandatory supplemental tasking authority.

If the work targets the still-open exact public package-owned inference blocker
after that review-remediation pass, also read
`workflow-docs/20260504T0131--type-stable-parse/05_tranche-01--public-entrypoint-inference-rearchitecture-tasking.md`
line by line and comply with it as an additional mandatory supplemental
tasking authority.

That supplemental file closes 3 post-review findings that this original file
did not encode:

- the public `load_alife_table` builder-surface regression
- the tranche-01 core owner-selection leak that names concrete extension
  targets in core
- the weak public inference proofs that only compare runtime store types

The second supplemental file closes 1 additional post-remediation diagnosis
error that both earlier files still left open:

- exact public tranche-01 parse/load inference cannot be achieved honestly
  while authoritative table identity still depends on runtime schema-derived
  type parameters

## Settled user decisions and environment baseline

- This tasking is repo-scoped only. Do not look for controlling workspace-level style or vocabulary files outside this repo.
- The tranche scope is fixed to package-owned `tables-only` and package-owned `single-parent NodeType` loads only.
- The following are explicitly out of scope for implementation in this tranche:
  - `BasenodeLoadRequest`
  - `BuilderLoadRequest`
  - all multi-parent execution paths
  - all extension-owned execution paths
  - any new public typed direct-load API
  - any docs truth-boundary or compatibility-boundary rewrite
- The public request types may remain in place, but `AbstractLoadRequest` must stop being the sole execution owner for the tranche-migrated surfaces.
- No new exported names are allowed in this tranche.
- No new `src/*.jl` file is allowed in this tranche.
- Do not modify `src/LineagesIO.jl` to add a new include or export.
- Source-file modification scope is fixed:
  - `src/construction.jl`
  - `src/views.jl`
  - `src/newick_format.jl`
  - `src/alife_format.jl`
  - `src/fileio_integration.jl` only if needed to preserve thin compatibility-wrapper behavior
- Test-file modification scope is fixed:
  - create `test/core/type_stability_tranche_01.jl`
  - add one include for it in `test/runtests.jl`
  - touch existing Newick and alife core tests only if narrowly needed for behavior coverage that the new dedicated tranche-01 test file cannot express cleanly
- The include placement decision is already made:
  - add `include("core/type_stability_tranche_01.jl")` in `test/runtests.jl` immediately after `include("core/construction_protocol_single_parent.jl")` and before `include("core/basenode_binding.jl")`
- Do not touch `docs/src/index.md` or any docs file in this tranche.
- Do not change any public load surface signature in this tranche.
- `FileIO.load(...)` remains a compatibility wrapper only and is not valid proof of typed tranche-01 success.
- If a task would require changing docs truth boundaries, public API naming, builder classification, basenode semantics, multi-parent ownership, extension contracts, or dependency baseline, stop and escalate rather than deciding that locally.
- Dependency and environment baseline are fixed:
  - do not change dependency versions
  - do not change manifest policy
  - do not add path overrides
  - do not vendor or fork upstream packages
- If compatibility-wrapper ownership is touched, the authoritative upstream source is the workspace checkout at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl`.

## Governance

All tasks must read line by line and comply with:

- `CONTRIBUTING.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `workflow-docs/20260504T0131--type-stable-parse/01_prd.md`
- `workflow-docs/20260504T0131--type-stable-parse/02_tranches.md`

Mandatory pass-forward rule:

- Any downstream implementation prompt, review scope, audit scope, or delegation generated from this tasking file must restate 2 obligations explicitly:
  - governance documents must be read line by line and complied with before proceeding
  - relevant upstream primary-source files must be identified at file level, read line by line, and complied with before proceeding
- A summary, a parent link, repo familiarity, module-root awareness, or a statement that the files were merely "considered" is not an acceptable substitute.

Read-only git and shell commands may be used freely.
Mutating git operations such as commit, merge, push, and branch remain the human project owner's responsibility unless explicitly requested otherwise.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the following repo files in full before writing code:
  - `src/construction.jl`
  - `src/views.jl`
  - `src/newick_format.jl`
  - `src/alife_format.jl`
  - `src/fileio_integration.jl`
  - `src/LineagesIO.jl`
  - `test/runtests.jl`
  - `test/core/newick_tables_only.jl`
  - `test/core/construction_protocol_single_parent.jl`
  - `test/core/alife_format.jl`
  - `test/core/fileio_load_surfaces.jl`
- Reproduce the current tranche-01 failure mode directly before changing code:
  - confirm that `materialize_graphs` still widens through the empty-branch behavior for tranche-owned typed cases
  - confirm that `build_newick_store` and `build_alife_store_from_rows` still assemble stores through that widened path
  - confirm that `LineageGraphStore` still derives type parameters from the resulting graph-asset vector element type
  - confirm that single-parent recursion remains the locally good case
- If a task touches compatibility-wrapper ownership, read the following upstream files in full before proceeding:
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/FileIO.jl`
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
  - plus `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`, `registry.jl`, or `types.jl` if the task depends on those contracts
- Re-check the user-authorized disruption boundary before making deep changes.
- If the diagnosis no longer matches reality, stop and raise that before changing code.

## Tranche execution rule

This tranche may redesign and replace internal owners for the authorized surfaces, but it must do so without changing the external API or docs truth boundary.

The owner that must remain after tranche completion:

- one internal typed owner for package-owned `tables-only` and package-owned `single-parent NodeType` materialization and store assembly

The owners or behaviors that must no longer exist for migrated tranche-01 surfaces:

- `materialize_graphs` empty-branch widening as the effective typed store-assembly owner
- direct Newick or alife store assembly from a possibly widened graph-asset vector for migrated tranche-01 surfaces
- `AbstractLoadRequest` as the sole execution owner for migrated tranche-01 surfaces

Docs and API truth-boundary rule for this tranche:

- docs must not be changed in this tranche
- the API must not be broadened or renamed in this tranche to satisfy speculative docs goals
- if code changes would force a docs truth-boundary decision, stop and escalate because that belongs to a later tranche

Green-state rule for this tranche:

- every WRITE, TEST, and MIGRATE task must end with `julia --project=test test/runtests.jl` green
- REVIEW tasks must also end with that command green if any code changed during the review cleanup
- docs builds are not part of tranche-01 green state because docs are fixed out of scope here; if docs would need to change, stop and escalate

## Non-negotiable execution rules

- Do not create a new `src/*.jl` file.
- Do not add a new include to `src/LineagesIO.jl`.
- Do not add or remove exports.
- Do not change public load signatures.
- Do not migrate `BasenodeLoadRequest`, `BuilderLoadRequest`, multi-parent, or extension paths into the tranche-01 typed owner.
- Do not use `FileIO.load(...)` as proof that the package-owned typed contract is fixed.
- Do not solve the tranche by adding annotations while leaving the same widened owner in place.
- Do not wrap the old widened owner in a new facade and call that a fix.
- Do not create a Newick-specific typed owner and an alife-specific typed owner. Both must normalize through one shared internal typed owner.
- Do not let `src/fileio_integration.jl` become the owner of typed semantics. It may only remain a thin compatibility wrapper.
- Do not use source-text greps, comment assertions, or docs-string policing as the primary proof that the old owner is gone.
- Do not move product logic into tests to fake a green result.
- Do not weaken the tranche by silently pulling in later design decisions that belong to tranches 2 through 5.

## Concrete anti-patterns or removal targets

- `materialize_graphs(graph_assets, request::AbstractLoadRequest)` as the store-assembly owner for migrated tranche-01 surfaces
- the widened union behavior caused by `isempty(graph_assets) && return graph_assets` when that still governs migrated tranche-01 typed paths
- `build_newick_store(..., request)` directly assembling `LineageGraphStore` from a graph-asset vector whose type was widened by the old owner
- `build_alife_store_from_rows(..., request)` directly assembling `LineageGraphStore` from a graph-asset vector whose type was widened by the old owner
- `AbstractLoadRequest` carrying both user-surface selection and execution ownership for migrated tranche-01 surfaces
- any helper or wrapper that keeps the old widened path alive as a second implementation for migrated tranche-01 surfaces
- any alife-only or Newick-only duplicate typed owner that bypasses the shared tranche-01 core

## Failure-oriented verification

The following checks must fail the known bad implementation or forbidden regression shape:

- a direct inference-oriented check showing that the old tranche-01 path still returns a widened union between unmaterialized and materialized graph-asset vector shapes
- a direct inference-oriented check showing that store assembly for a migrated tranche-01 path is still partially abstract rather than concretely typed
- a direct check that would fail if migrated Newick tranche-01 surfaces still flow through the old widened owner
- a direct check that would fail if migrated alife tranche-01 surfaces still flow through the old widened owner
- a direct check that would fail if Newick and alife each own separate typed store-assembly paths instead of sharing one tranche-01 owner

The following are required positive proofs:

- one direct proof for a package-owned `tables-only` path
- one direct proof for a package-owned `single-parent NodeType` Newick path
- one direct proof for a package-owned `load_alife_table` path
- existing behavior tests for Newick and alife remain green

The following are not acceptable as the only proof:

- "the full suite passes"
- "the function returns a store"
- "the docs still look right"
- "the source no longer contains a specific string"

## Tasks

### 1. Revalidate the tranche-01 diagnosis and freeze the execution boundary

**Type**: REVIEW
**Output**: a written implementation baseline in the session notes confirming that the current failure is still the widened tranche-01 store-assembly owner and that the current local good case is still single-parent recursion
**Depends on**: none

Read the tranche, PRD, governance files, and the required source and test files in full.
Reproduce the current failure mode directly using internal calls or inference-oriented checks, not just behavior tests.
Confirm all of the following before any write task begins:

- `materialize_graphs` still widens tranche-01 paths through the empty-branch behavior
- `build_newick_store` and `build_alife_store_from_rows` still assemble stores through that path
- `LineageGraphStore` still derives its type parameters from the resulting graph-asset vector element type
- single-parent recursion is still the locally good case
- no already-merged change has moved this failure to multi-parent, builder, basenode, or extension ownership

If any of those statements are false, stop and escalate instead of tasking blindly.
Do not change code in this task unless a harmless diagnostic comment or test-note stub is absolutely necessary, and even then prefer not to.
No design decision is authorized in this task.

Verification for this task:

- reproduce the widened tranche-01 inference shape directly
- confirm that no code change is needed to establish the baseline

---

### 2. Introduce the shared tranche-01 typed internal owner in existing source files

**Type**: WRITE
**Output**: one new internal typed owner for tranche-01 surfaces, implemented inside existing source files, with the old owner still available only for non-migrated surfaces
**Depends on**: 1

Implement the new internal typed owner without changing the public source layout.
Place the new internal typed surface-descriptor definitions in `src/construction.jl` immediately after the existing public load-request definitions and before the protocol functions.
Place the typed tranche-01 store-assembly helper logic in `src/construction.jl` near the current `materialize_graphs` and `materialize_graph` region.
Modify `src/views.jl` only to add helper construction paths needed to build concretely typed `LineageGraphStore` values through the new owner.
Do not redesign the public `LineageGraphAsset` or `LineageGraphStore` field layout.
Do not rename the existing public request types.

The new owner must support exactly 2 migrated families in this tranche:

- package-owned `tables-only`
- package-owned `single-parent NodeType`

The new owner must not support in this tranche:

- `BasenodeLoadRequest`
- `BuilderLoadRequest`
- any multi-parent graph
- any extension-owned graph

For non-migrated surfaces, the legacy path may remain temporarily, but it must be explicit and it must not own any tranche-01 migrated surface.
Do not create a Newick-specific typed owner and an alife-specific typed owner.
Create one shared internal typed owner that both formats can call.
Do not modify `src/LineagesIO.jl`.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm by inspection that the new owner exists in `src/construction.jl` and that no new `src/*.jl` file or new export was introduced

---

### 3. Add dedicated tranche-01 inference and anti-regression coverage

**Type**: TEST
**Output**: a new dedicated inference/regression test file proving the tranche-01 owner exists and failing the old widened-owner shape
**Depends on**: 2

Create `test/core/type_stability_tranche_01.jl`.
Add `include("core/type_stability_tranche_01.jl")` to `test/runtests.jl` immediately after `include("core/construction_protocol_single_parent.jl")` and before `include("core/basenode_binding.jl")`.

Use self-contained helper node types inside the new test file when needed.
Use internal package-owned calls such as `build_newick_store`, `build_alife_store_from_table`, or the tranche-01 internal owner directly when needed.
Do not use `FileIO.load(...)` as typed proof in this file.
Do not use multi-parent fixtures or extension fixtures in this file.
Do not rely on source-text assertions.

This file must contain:

- one failure-oriented proof for the old widened-owner shape
- one positive proof for a `tables-only` package-owned path
- one positive proof for a `single-parent NodeType` Newick path
- one positive proof for a `load_alife_table` package-owned path

If `@inferred` is not the right tool for one of those internal proofs, use an equally direct inference-oriented check such as `Base.return_types`, but the check must still distinguish the real bad implementation from the real fixed implementation.
Do not weaken the test to "it returned a store".

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm that the new test file would fail on the old widened-owner shape

---

### 4. Migrate rooted Newick tables-only and single-parent package-owned paths to the shared typed owner

**Type**: MIGRATE
**Output**: `build_newick_store` tranche-01 paths route through the shared typed owner and no longer use the old widened owner for those surfaces
**Depends on**: 2, 3

Modify `src/newick_format.jl` so that tranche-01 Newick paths normalize through the new shared typed owner.
Keep the public overload surface unchanged:

- `build_newick_store(text, source_path)`
- `build_newick_store(text, source_path, request)`

The routing rule is fixed:

- if the request is `TablesOnlyLoadRequest`, use the new shared typed owner
- if the request is `NodeTypeLoadRequest{NodeT}` and the parsed graph is single-parent, use the new shared typed owner
- otherwise, do not migrate the path in this tranche; route it explicitly to the legacy non-tranche-01 path

Do not let `build_newick_store` continue assembling tranche-01 stores directly from the old widened graph-asset vector path once migrated.
Do not change `src/fileio_integration.jl` unless needed to preserve thin-wrapper behavior only.
If `src/fileio_integration.jl` is touched, do not move typed semantics there.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm that `test/core/newick_tables_only.jl`, `test/core/construction_protocol_single_parent.jl`, and `test/core/type_stability_tranche_01.jl` all remain green
- confirm that a failure-oriented Newick tranche-01 check would fail if the old widened owner were restored

---

### 5. Strengthen Newick tranche-01 positive and negative verification

**Type**: TEST
**Output**: Newick-facing tranche-01 tests that prove migrated Newick paths use the shared typed owner and fail if the old owner survives behind a wrapper
**Depends on**: 4

Extend `test/core/type_stability_tranche_01.jl` first.
Touch `test/core/newick_tables_only.jl` or `test/core/construction_protocol_single_parent.jl` only if a narrowly scoped behavior assertion is needed in addition to the dedicated inference file.

Add direct Newick-oriented checks that prove:

- a package-owned `tables-only` Newick path is routed through the shared typed owner
- a package-owned `single-parent NodeType` Newick path is routed through the shared typed owner
- the old widened-owner shape is not still governing migrated Newick paths through a wrapper or helper

Do not broaden these tests to FileIO compatibility classification, docs truth boundaries, builder paths, basenode paths, or multi-parent paths.
Do not replace the failure-oriented proof with behavior-only assertions.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm that at least one Newick tranche-01 test would fail on the pre-migration owner shape

---

### 6. Migrate alife text and in-memory table tranche-01 paths to the same shared typed owner

**Type**: MIGRATE
**Output**: `build_alife_store`, `build_alife_store_from_rows`, `build_alife_store_from_table`, and tranche-01 `load_alife_table` paths normalize through the same shared typed owner as Newick
**Depends on**: 4, 5

Modify `src/alife_format.jl` so that the following tranche-01 surfaces use the already-created shared typed owner:

- `build_alife_store(text, source_path)` tables-only path
- `build_alife_store(text, source_path, request)` for `TablesOnlyLoadRequest`
- `build_alife_store_from_rows(...)` for `TablesOnlyLoadRequest`
- `build_alife_store_from_table(...)` for `TablesOnlyLoadRequest`
- `load_alife_table(table; source_path = ...)`
- single-parent `NodeTypeLoadRequest{NodeT}` variants of the same package-owned alife paths

The routing rule is fixed:

- if the request is `TablesOnlyLoadRequest`, use the shared typed owner
- if the request is `NodeTypeLoadRequest{NodeT}` and the resulting graph is single-parent, use the shared typed owner
- otherwise, keep the path explicitly on the legacy non-tranche-01 route

Do not create an alife-specific typed owner.
Do not move typed semantics into `src/fileio_integration.jl`.
Do not change any `load_alife_table` public signature.
Do not migrate alife multi-parent `NodeType` behavior in this tranche.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm that the shared tranche-01 inference tests and existing alife behavior tests remain green

---

### 7. Strengthen alife and `load_alife_table` tranche-01 positive and negative verification

**Type**: TEST
**Output**: alife-facing tranche-01 tests that prove both text-backed and in-memory package-owned paths use the shared typed owner and fail if the old widened owner or a duplicate alife-specific owner survives
**Depends on**: 6

Extend `test/core/type_stability_tranche_01.jl` first.
Touch `test/core/alife_format.jl` only if a narrowly scoped behavior assertion is needed in addition to the dedicated inference file.

Add direct alife-oriented checks that prove:

- a package-owned alife text path is routed through the shared typed owner
- `load_alife_table(table)` is routed through the shared typed owner
- a package-owned single-parent alife `NodeType` path is routed through the shared typed owner
- the implementation does not use a hidden alife-only second owner

Do not use ambiguous `.csv` FileIO compatibility as the proof of typed tranche-01 success.
Do not treat multi-parent alife as tranche-01 success.
Do not weaken the proof to behavior-only checks.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm that at least one alife tranche-01 test would fail on the pre-migration owner shape or on an alife-specific duplicate-owner anti-fix

---

### 8. Audit tranche-01 owner removal and freeze the tranche boundary before tranche 2

**Type**: REVIEW
**Output**: a review-complete tranche-01 boundary check confirming that migrated surfaces have one shared typed owner, that the old owner no longer governs those surfaces, and that no later-tranche design decision slipped in
**Depends on**: 5, 7

Review all source and test changes from tasks 2 through 7.
The review question set is fixed:

- Do migrated package-owned `tables-only` and package-owned `single-parent NodeType` Newick paths all route through one shared typed owner?
- Do migrated package-owned `tables-only`, text-backed alife, and `load_alife_table` paths all route through that same shared typed owner?
- Does the old widened owner still govern any migrated tranche-01 surface?
- Did any wrapper, helper, or format-specific branch preserve a second implementation for a migrated tranche-01 surface?
- Did the implementation accidentally change public API, docs truth boundary, basenode semantics, builder semantics, multi-parent ownership, or extension contracts?
- Was `src/fileio_integration.jl` kept as a thin compatibility wrapper rather than turned into a typed owner?

If the answer to any of those questions is wrong or unclear, fix that drift before closing the tranche.
Do not use this review task to broaden tranche scope.
Do not touch docs in this task.

Verification for this task:

- run `julia --project=test test/runtests.jl`
- confirm by direct code inspection that the migrated tranche-01 surfaces have one shared owner and that the old owner no longer survives there as a second implementation

---
