# Tasks for tranche 1 review remediation: restore `load_alife_table` normalization, remove core extension classification, and harden public inference verification

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`
Parent tranche tasking: `03_tranche-01--tasking.md`

## Supplemental public-inference rearchitecture tasking

This file remains the controlling tasking for the first 3 tranche-01
review-remediation findings.

If the work targets the still-open public package-owned inference blocker after
those 3 findings were remediated, read
`workflow-docs/20260504T0131--type-stable-parse/05_tranche-01--public-entrypoint-inference-rearchitecture-tasking.md`
line by line and comply with it as a mandatory supplemental tasking
authority.

That newer supplemental file closes the remaining tasking misdiagnosis that
this file still left open:

- exact public tranche-01 parse/load inference cannot be recovered honestly
  while authoritative table identity still depends on runtime schema-derived
  type parameters

## Settled user decisions and environment baseline

- This tasking is repo-scoped only. Do not look for controlling workspace-level style or vocabulary files outside this repo.
- This file is a governed supplemental tasking authority for review-detected tranche-01 defects. Read it together with `03_tranche-01--tasking.md`. When remediating the already-committed tranche-01 fulfillment state, this file controls the remediation pass.
- The remediation scope is fixed to exactly 3 review findings:
  - restore the public `load_alife_table` builder and mixed-surface normalization behavior
  - remove concrete extension-target classification from tranche-01 core owner selection
  - replace weak public runtime-type-only inference proofs with direct public-entrypoint inference verification
- Keep the external API and docs truth boundary unchanged during this remediation.
- Tranche-02 multi-parent scheduler redesign and tranche-03 extension migration remain out of scope.
- Extension files may be touched only to install explicit owner-routing exclusions required to remove core concrete extension classification. Do not migrate extension execution into the tranche-01 typed owner in this remediation.
- No new `src/*.jl` file is allowed in this remediation.
- Do not modify `src/LineagesIO.jl` to add a new include or export.
- Do not add or remove exports.
- Do not change dependency versions, manifest policy, or path-override policy.
- Do not touch `docs/src/index.md` or any docs file in this remediation.
- The `load_alife_table` builder-only surface and the mutually exclusive `NodeT` plus `builder` error path must be restored through the same public normalization contract already owned by `build_load_request`.
- If extension files are touched, the authoritative upstream reading source is the workspace technological-context checkout under `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`, not the package cache alone.

## Governance

All remediation tasks must read line by line and comply with:

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
- `workflow-docs/20260504T0131--type-stable-parse/03_tranche-01--tasking.md`
- this file, `workflow-docs/20260504T0131--type-stable-parse/04_tranche-01--review-remediation-tasking.md`

Mandatory pass-forward rule:

- Any downstream implementation prompt, review scope, audit scope, or delegation generated from this remediation tasking must restate 2 obligations explicitly:
  - governance documents must be read line by line and complied with before proceeding
  - relevant upstream primary-source files must be identified at file level, read line by line, and complied with before proceeding
- A summary, a parent link, repo familiarity, module-root awareness, or a statement that the files were merely "considered" is not an acceptable substitute.

Read-only git and shell commands may be used freely.
Mutating git operations such as commit, merge, push, and branch remain the human project owner's responsibility unless explicitly requested otherwise.

## Controlled vocabulary

- Use the canonical project term `basenode`. Do not introduce `rootnode`.
- Preserve the tranche vocabulary distinction between package-owned surfaces, extension-owned surfaces, compatibility wrappers, typed owners, legacy owners, and authoritative tables.
- If a new term seems necessary during remediation, stop and route that through `STYLE-vocabulary.md` instead of coining it locally.

## Upstream primary sources

- This remediation does not reopen `FileIO` compatibility-wrapper design. Do not read or change `FileIO` sources unless a remediation step unexpectedly requires that boundary, and if it does, stop and escalate before proceeding.
- If task 4 or task 5 touches the `MetaGraphsNext` extension opt-out path, read line by line and comply with:
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/MetaGraphsNext.jl`
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`
- If task 4 or task 5 touches the `PhyloNetworks` extension opt-out path, read line by line and comply with:
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/PhyloNetworks.jl`
  - `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/types.jl`
- Module-root awareness is not sufficient for those extension touches. File-level reading inside those checkouts is mandatory before implementation, review, audit, or delegation proceeds.

## Current-state diagnosis

This remediation exists because the committed tranche-01 fulfillment state still has 3 review findings that violate the approved boundary.

Current defect 1:

- The new public `load_alife_table` narrow overloads intercept builder-bearing calls and cause `MethodError` before the canonical `build_load_request` normalization contract runs.
- This is a public-surface regression. It changes externally visible behavior even though the function signatures look unchanged.
- The correct owner is one public normalization point for `load_alife_table`, not multiple narrow overloads that each decide independently which keywords are valid.

Current defect 2:

- The tranche-01 core owner-selection logic in `src/construction.jl` currently names concrete extension targets through `Base.get_extension`, `MetaGraphsNext`, and `PhyloNetworks` to decide whether the typed owner may run.
- That leaks extension classification into core, duplicates extension-sensitive ownership knowledge, and creates a new requirement that every future extension update core to stay out of the tranche-01 path.
- The correct owner is a package-owned core default plus extension-owned opt-out overrides, not core-side package-name or concrete-type classification.

Current defect 3:

- The public tranche-01 verification in `test/core/type_stability_tranche_01.jl` proves internal helper inference, but its public-surface checks rely mainly on `typeof(public_store) == typeof(typed_store)`.
- That is a weak proxy. It would still pass if a public surface used the legacy widened owner or if format-specific typed facades returned the same runtime store type through different owners.
- The correct owner-level proof is direct inference on the public migrated entrypoints themselves, with negative checks that fail the legacy widened owner shape.

## Required revalidation before implementation

- Read the tranche, parent PRD, parent tranche-01 tasking, and this remediation tasking in full.
- Read the following project files in full before writing code:
  - `src/alife_format.jl`
  - `src/construction.jl`
  - `src/views.jl`
  - `test/core/alife_format.jl`
  - `test/core/type_stability_tranche_01.jl`
  - `test/extensions/metagraphsnext_activation.jl`
  - `test/extensions/phylonetworks_activation.jl`
  - `ext/MetaGraphsNextIO.jl`
  - `ext/PhyloNetworksIO.jl`
  - any additional file whose behavior is changed
- Reproduce the current review findings directly before changing code:
  - confirm that `load_alife_table(table; builder = fn)` currently throws `MethodError` instead of exercising the public builder surface
  - confirm that `load_alife_table(table, NodeT; builder = fn)` currently throws `MethodError` instead of the curated exclusivity `ArgumentError` already owned by `build_load_request`
  - confirm that `src/construction.jl` currently owns extension exclusion through concrete extension-target classification
  - confirm that the public tranche-01 tests currently prove helper inference but not direct public-entrypoint inference
- If tasks 4 or 5 touch extension opt-out ownership, read the relevant workspace checkout files listed above line by line before proceeding.
- Re-check the user-authorized disruption boundary before making deep changes.
- If any of the 3 findings no longer matches reality, stop and update this remediation tasking before changing code.

## Tranche execution rule

This remediation repairs review findings inside the already approved tranche-01 redesign.
It does not authorize a new public API, a docs truth-boundary rewrite, a `FileIO` contract change, a tranche-02 multi-parent redesign, or a tranche-03 extension migration.

The owners that must remain after remediation:

- one public normalization point for `load_alife_table` surface selection and builder exclusivity
- one shared tranche-01 package-owned typed owner for tables-only and single-parent package-owned `NodeType` materialization and store assembly
- extension-owned owner-eligibility exclusions for library-created extension targets whose final graph and basenode projection types differ from the requested `NodeT`

The owners or behaviors that must no longer exist after remediation:

- public `load_alife_table` overloads that intercept builder-bearing calls before `build_load_request` can normalize them
- tranche-01 core owner-selection logic that names `MetaGraphsNext`, `PhyloNetworks`, or uses `Base.get_extension` to classify concrete extension targets
- public tranche-01 inference checks that only compare runtime store types without proving public-entrypoint inference

Docs and API truth-boundary rule for this remediation:

- docs must not be changed in this remediation
- the API must not be broadened or renamed in this remediation to satisfy speculative docs goals
- if a code change would force a docs truth-boundary decision or a public migration policy decision, stop and escalate because that belongs to a later tranche

Green-state rule for this remediation:

- every WRITE, TEST, and MIGRATE task must end with `julia --project=test test/runtests.jl` green
- REVIEW tasks must also end with that command green if any code changed during the review cleanup
- docs builds are not part of this remediation green state because docs are fixed out of scope here; if docs would need to change, stop and escalate

## Non-negotiable execution rules

- Do not change public load signatures.
- Do not fix the `load_alife_table` regression by dropping builder support, changing the exclusivity surface, or replacing the existing curated `build_load_request` error contract with a new one.
- Do not let `src/fileio_integration.jl` become the owner of typed semantics.
- Do not migrate `MetaGraphsNext` or `PhyloNetworks` execution into the tranche-01 typed owner in this remediation.
- Do not solve the extension-leak finding by relocating the same concrete extension-target classification into a different core helper or a different core file.
- If a routing hook is introduced or repurposed, the core default must remain package-owned and the extension-specific `false` overrides must live in `ext/MetaGraphsNextIO.jl` and `ext/PhyloNetworksIO.jl`, not in `src/construction.jl`.
- Do not use source-text greps as the only proof that core no longer owns extension classification.
- Do not accept `typeof(public_store) == typeof(typed_store)` as the only proof that a public migrated surface is inferred or shared-owner-backed.
- Do not touch multi-parent, basenode, builder, or extension execution semantics beyond what is necessary to close the 3 review findings above.

## Concrete anti-patterns or removal targets

- the narrow public `load_alife_table(table; source_path = nothing)` overload at `src/alife_format.jl`
- the narrow public `load_alife_table(table, node_type::Type{NodeT}; source_path = nothing)` overload at `src/alife_format.jl`
- `request_uses_tranche_01_single_parent_owner(request::NodeTypeLoadRequest)` implemented through `is_extension_owned_node_type`
- `is_extension_owned_node_type(node_type::Type)` and any replacement core helper that classifies extension targets through `Base.get_extension`, package names, or concrete extension target types
- public tranche-01 tests that prove only runtime store-type equality rather than direct public-entrypoint inference
- omission of `load_alife_table` builder-only and mixed-surface regression tests

## Failure-oriented verification

The following checks must fail the known bad implementation or forbidden regression shape:

- a direct public regression test for `load_alife_table(table; builder = fn)` that fails if the call routes back to `MethodError`
- a direct public regression test for `load_alife_table(table, NodeT; builder = fn)` that fails if the call routes back to `MethodError` instead of the curated exclusivity `ArgumentError`
- a direct public inference-oriented check for `build_newick_store(text, path, NodeTypeLoadRequest(...))` that fails if the public migrated path routes through the legacy widened owner
- a direct public inference-oriented check for `build_alife_store(text, path, NodeTypeLoadRequest(...))` that fails if the public migrated path routes through the legacy widened owner
- a direct public inference-oriented check for `load_alife_table(table, NodeT; source_path = ...)` that fails if the public migrated path routes through the legacy widened owner
- a direct owner-location check for `MetaGraphsNext` showing that the tranche-01 owner exclusion method is extension-owned rather than core-owned
- a direct owner-location check for `PhyloNetworks` showing that the tranche-01 owner exclusion method is extension-owned rather than core-owned

The following are required positive proofs:

- a direct public success test for `load_alife_table(table; builder = fn)`
- a direct public exclusivity test for `load_alife_table(table, NodeT; builder = fn)`
- one direct public inference proof for a package-owned `tables-only` Newick path
- one direct public inference proof for a package-owned `single-parent NodeType` Newick path
- one direct public inference proof for a package-owned `tables-only` alife text path
- one direct public inference proof for a package-owned `single-parent NodeType` alife text path
- one direct public inference proof for a package-owned `load_alife_table` path
- existing extension activation tests and existing package-owned core tests remain green

The following are not acceptable as the only proof:

- "the full suite passes"
- "the function returns a store"
- "the source no longer contains a specific string"
- "the public store has the same runtime type as the helper-built store"

## Tasks

### 1. Revalidate the review findings and freeze the remediation boundary

**Type**: REVIEW
**Output**: a written remediation baseline in the session notes confirming that all 3 findings still reproduce and that the remediation boundary remains tranche-01-only
**Depends on**: none
**Positive contract**: read the tranche, PRD, parent tasking, remediation tasking, required source files, required tests, and required extension files in full; reproduce the current `load_alife_table` builder regressions, the current core extension-classification leak, and the current weak public inference proof shape before any write task begins
**Negative contract**: do not change code in this task; do not broaden the remediation into tranche-02 scheduler work, tranche-03 extension migration, docs truth-boundary work, or `FileIO` compatibility redesign; if any review finding no longer reproduces, stop and rewrite this remediation tasking instead of improvising
**Files**:
- read `src/alife_format.jl`
- read `src/construction.jl`
- read `src/views.jl`
- read `test/core/alife_format.jl`
- read `test/core/type_stability_tranche_01.jl`
- read `test/extensions/metagraphsnext_activation.jl`
- read `test/extensions/phylonetworks_activation.jl`
- read `ext/MetaGraphsNextIO.jl`
- read `ext/PhyloNetworksIO.jl`
- read the relevant upstream checkout files if tasks 4 or 5 will touch extension opt-out ownership
**Out of scope**:
- source edits
- test edits
- docs edits
- dependency or environment changes
**Verification**:
- reproduce that `load_alife_table(table; builder = fn)` currently throws `MethodError`
- reproduce that `load_alife_table(table, NodeT; builder = fn)` currently throws `MethodError`
- confirm by inspection that `src/construction.jl` currently names concrete extension targets in owner-selection logic
- confirm by inspection that `test/core/type_stability_tranche_01.jl` currently proves helper inference but not direct public-entrypoint inference

### 2. Restore `load_alife_table` to one public normalization owner

**Type**: WRITE
**Output**: the public `load_alife_table` surfaces normalize through one builder-aware public owner again, without `MethodError` regressions
**Depends on**: 1
**Positive contract**: make the variadic public `load_alife_table(table, args...; builder, source_path)` method the sole public normalization owner again; keep `ensure_alife_table_input(table)` as the shared validation helper; preserve the no-argument tables-only path and the `NodeT` path by routing them through `build_load_request` rather than through separate narrow public overload ownership
**Negative contract**: do not redefine public signatures; do not change docs; do not replace the existing exclusivity error contract with a new one; do not leave a second narrow public overload in place that can intercept builder-bearing calls before the normalization owner runs
**Files**:
- `src/alife_format.jl`
**Out of scope**:
- `src/construction.jl`
- `src/views.jl`
- `src/fileio_integration.jl`
- `ext/MetaGraphsNextIO.jl`
- `ext/PhyloNetworksIO.jl`
- all docs files
**Verification**:
- run a direct public check proving `load_alife_table(table; builder = fn)` no longer raises `MethodError`
- run a direct public check proving `load_alife_table(table, Int; builder = fn)` now raises the curated exclusivity `ArgumentError` owned by `build_load_request`, not `MethodError`
- run `julia --project=test test/runtests.jl`

### 3. Add public `load_alife_table` builder-surface regression coverage

**Type**: TEST
**Output**: direct public tests that fail the old `MethodError` regressions for builder-only and mixed-surface `load_alife_table`
**Depends on**: 2
**Positive contract**: add a successful public `load_alife_table(table; builder = fn)` test and a public `load_alife_table(table, Int; builder = fn)` exclusivity-error test; place both in `test/core/alife_format.jl`; use a local valid builder in that file for the successful case and assert the curated exclusivity `ArgumentError` message shape for the mixed case
**Negative contract**: do not test only internal helpers; do not weaken the regression to a looser runtime proxy; do not accept `MethodError`; do not move this coverage into extension tests or unrelated error-path files
**Files**:
- `test/core/alife_format.jl`
**Out of scope**:
- `test/core/type_stability_tranche_01.jl`
- `test/extensions/metagraphsnext_activation.jl`
- `test/extensions/phylonetworks_activation.jl`
- all source files except to support compilation if an unavoidable local helper import is needed
**Verification**:
- confirm the new tests fail on the known bad implementation where the narrow overloads intercept `builder`
- run `julia --project=test test/runtests.jl`

### 4. Move tranche-01 extension exclusion out of core and into extension-owned overrides

**Type**: WRITE
**Output**: core owner-selection no longer classifies concrete extension targets, and extension files own the explicit opt-out methods for their library-created `NodeType` requests
**Depends on**: 1
**Positive contract**: keep `request_uses_tranche_01_single_parent_owner` as the routing hook name; in `src/construction.jl`, make the core default method for `NodeTypeLoadRequest` return `true` without naming concrete extension targets; delete `is_extension_owned_node_type`; add explicit `false` overrides in `ext/MetaGraphsNextIO.jl` for `NodeTypeLoadRequest{<:MetaGraph}` and in `ext/PhyloNetworksIO.jl` for `NodeTypeLoadRequest{PhyloNetworks.HybridNetwork}`; leave extension execution methods such as `validate_extension_load_target`, `emit_basenode`, and `build_parent_collection` otherwise unchanged
**Negative contract**: do not move the same package-name or `Base.get_extension` classification into another core helper; do not migrate extension execution into the tranche-01 typed owner; do not introduce a new generalized trait design beyond this routing hook; do not change the public target semantics of either extension
**Files**:
- `src/construction.jl`
- `ext/MetaGraphsNextIO.jl`
- `ext/PhyloNetworksIO.jl`
**Out of scope**:
- `src/alife_format.jl`
- `src/newick_format.jl`
- `src/views.jl`
- `src/fileio_integration.jl`
- docs files
- multi-parent core execution
- supplied-target core execution
**Verification**:
- confirm by inspection that `src/construction.jl` no longer names `MetaGraphsNext`, `PhyloNetworks`, or `Base.get_extension` for tranche-01 owner selection
- run direct checks showing `request_uses_tranche_01_single_parent_owner(NodeTypeLoadRequest(Tranche01TestNode)) == true`, `request_uses_tranche_01_single_parent_owner(NodeTypeLoadRequest(MetaGraphsNext.MetaGraph)) == false`, and `request_uses_tranche_01_single_parent_owner(NodeTypeLoadRequest(PhyloNetworks.HybridNetwork)) == false` when the corresponding extensions are active
- run `julia --project=test test/runtests.jl`

### 5. Add owner-routing regression coverage for extension opt-out and package-owned default routing

**Type**: TEST
**Output**: automated proof that package-owned single-parent requests stay on the tranche-01 typed owner by default while extension exclusions are owned in extension code, not in core
**Depends on**: 4
**Positive contract**: add one package-owned default-routing assertion to `test/core/type_stability_tranche_01.jl`; add one `MetaGraphsNext` owner-location assertion to `test/extensions/metagraphsnext_activation.jl`; add one `PhyloNetworks` owner-location assertion to `test/extensions/phylonetworks_activation.jl`; the extension assertions must prove not just that the hook returns `false`, but that the method selected by `which(...)` or the equivalent method-location inspection is owned by the extension module rather than by `LineagesIO` core
**Negative contract**: do not use source-text greps as the only proof; do not test only the returned boolean value without checking owner location; do not broaden these tests into extension migration or execution-behavior rewrites
**Files**:
- `test/core/type_stability_tranche_01.jl`
- `test/extensions/metagraphsnext_activation.jl`
- `test/extensions/phylonetworks_activation.jl`
**Out of scope**:
- source files except for compilation fixes required by the new tests
- docs files
- multi-parent extension tests
- extension execution semantics
**Verification**:
- confirm the new tests fail if the extension-specific `false` overrides are removed
- confirm the owner-location checks fail if core retakes ownership of extension exclusion
- run `julia --project=test test/runtests.jl`

### 6. Strengthen direct public inference proofs for migrated Newick and alife surfaces

**Type**: TEST
**Output**: direct public-entrypoint inference checks for the migrated tranche-01 surfaces, with negative comparisons against the legacy widened owner shape
**Depends on**: 2, 3, 4, 5
**Positive contract**: keep the existing helper-level legacy-versus-typed proof in `test/core/type_stability_tranche_01.jl`, but replace the public runtime-type-only checks with direct public inference checks on the public migrated entrypoints themselves; for each public surface, compute the public inferred return type and compare it to the direct shared-owner helper inferred type for the same graph assets and request; for the `NodeType` paths, also compare against the `build_legacy_store_from_graph_assets` inferred return type and assert that the public inferred type differs from the legacy widened owner shape
**Negative contract**: do not use `FileIO.load(...)` as typed proof; do not settle for `typeof(public_store) == typeof(typed_store)`; do not move the proof into comments or source-text assertions; do not broaden this task into multi-parent or basenode verification
**Files**:
- `test/core/type_stability_tranche_01.jl`
**Out of scope**:
- `test/core/fileio_load_surfaces.jl`
- extension tests except where task 5 already touched them
- source files except for compilation fixes required by the new tests
- docs files
**Verification**:
- add a direct public inference proof for `build_newick_store(text, path)`
- add a direct public inference proof for `build_newick_store(text, path, NodeTypeLoadRequest(...))`
- add a direct public inference proof for `build_alife_store(text, path)`
- add a direct public inference proof for `build_alife_store(text, path, NodeTypeLoadRequest(...))`
- add a direct public inference proof for `load_alife_table(table; source_path = ...)`
- add a direct public inference proof for `load_alife_table(table, Tranche01TestNode; source_path = ...)`
- confirm the `NodeType` public inference checks fail if those paths are restored to `build_legacy_store_from_graph_assets`
- run `julia --project=test test/runtests.jl`

### 7. Audit remediation completeness and freeze tranche 1 again

**Type**: REVIEW
**Output**: a review-complete confirmation that all 3 findings are closed without reopening tranche-02 or tranche-03 design
**Depends on**: 3, 5, 6
**Positive contract**: inspect the final remediation code and tests and confirm all of the following:
  - `load_alife_table` again has one public normalization owner
  - builder-only and mixed-surface public regressions are closed
  - tranche-01 core no longer classifies concrete extension targets
  - extension-specific opt-out ownership lives in the extension files
  - public tranche-01 inference proofs now target the public migrated entrypoints directly
  - existing unaffected behavior remains green
**Negative contract**: fail this task if any helper or wrapper preserves the bad `load_alife_table` overload shape, if core still owns extension classification, if public inference proof still relies mainly on runtime type equality, or if the remediation accidentally drags in multi-parent redesign, extension migration, docs truth-boundary changes, or `FileIO` redesign
**Files**:
- review every file touched by tasks 2 through 6
- make cleanup edits only if they are required to remove a surviving bad shape
**Out of scope**:
- new feature work
- docs updates
- dependency changes
- tranche-02 and tranche-03 architecture
**Verification**:
- run `julia --project=test test/runtests.jl`
- confirm by inspection that the remediation closed all 3 findings without changing the approved tranche-01 external boundary
