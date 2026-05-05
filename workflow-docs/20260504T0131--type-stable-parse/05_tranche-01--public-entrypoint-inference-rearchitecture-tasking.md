# Tasks for tranche 1 public-entrypoint inference rearchitecture: remove data-dependent authoritative-table types from the package-owned typed return boundary

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`
Parent tranche tasking: `03_tranche-01--tasking.md`
Parent review-remediation tasking: `04_tranche-01--review-remediation-tasking.md`

## Settled user decisions and environment baseline

- This tasking is repo-scoped only. Do not look for controlling workspace-level style or vocabulary files outside this repo.
- This file is a governed supplemental tasking authority for the remaining tranche-01 public-inference blocker. Read it together with `03_tranche-01--tasking.md` and `04_tranche-01--review-remediation-tasking.md`. When remediating the still-open public-entrypoint inference defect after the prior review-remediation pass, this file controls the next implementation pass.
- The remaining scope is fixed to exactly 1 defect class:
  - package-owned public tranche-01 parse/load surfaces still do not infer exactly end to end because their return types still depend on authoritative table types whose identity is derived from runtime source content
- The target success condition is fixed:
  - `build_newick_store(text, path)`
  - `build_newick_store(text, path, NodeTypeLoadRequest(NodeT))`
  - `build_alife_store(text, path)`
  - `build_alife_store(text, path, NodeTypeLoadRequest(NodeT))`
  - `load_alife_table(table; source_path = ...)`
  - `load_alife_table(table, NodeT; source_path = ...)`
  must all pass direct exact public-entrypoint inference proof under `Test.@inferred` for tranche-01 package-owned cases
- This supplemental pass explicitly authorizes deeper internal redesign of authoritative table, graph-asset, and store typing because the prior narrower tranche-01 owner repair is now proven insufficient to satisfy the approved package-owned typed-boundary goal.
- Keep the external API and docs truth boundary unchanged during this pass:
  - do not rename public functions
  - do not change public argument signatures
  - do not change `FileIO` compatibility semantics
  - do not add a new public typed API in this pass
- Preserve all of the following:
  - authoritative table ownership
  - retained annotation access
  - Tables.jl compatibility
  - row-reference semantics
  - tranche-01 shared typed-owner routing for package-owned tables-only and single-parent `NodeType` surfaces
- No new `src/*.jl` file is allowed in this pass.
- Do not modify `src/LineagesIO.jl` to add a new include or export.
- Do not add or remove exports.
- Do not change dependency versions, manifest policy, or path-override policy.
- Do not touch `docs/src/index.md` or any docs file in this pass.

## Governance

All tasks in this supplemental tasking must read line by line and comply with:

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
- `workflow-docs/20260504T0131--type-stable-parse/04_tranche-01--review-remediation-tasking.md`
- this file, `workflow-docs/20260504T0131--type-stable-parse/05_tranche-01--public-entrypoint-inference-rearchitecture-tasking.md`

Mandatory pass-forward rule:

- Any downstream implementation prompt, review scope, audit scope, or delegation generated from this supplemental tasking must restate 3 obligations explicitly:
  - governance documents must be read line by line and complied with before proceeding
  - relevant upstream primary-source files must be identified at file level, read line by line, and complied with before proceeding
  - this supplemental tasking corrects a prior tasking misdiagnosis, so the implementation prompt must explicitly say that the remaining blocking owner is the data-dependent authoritative-table type boundary, not merely weak tests
- A summary, a parent link, repo familiarity, module-root awareness, or a statement that the files were merely "considered" is not an acceptable substitute.

Read-only git and shell commands may be used freely.
Mutating git operations such as commit, merge, push, and branch remain the human project owner's responsibility unless explicitly requested otherwise.

## Controlled vocabulary

- Use the canonical project term `basenode`. Do not introduce `rootnode`.
- Preserve the tranche vocabulary distinction between package-owned surfaces, extension-owned surfaces, compatibility wrappers, typed owners, legacy owners, authoritative tables, and typed return boundaries.
- Use the term `data-dependent type boundary` for the surviving blocker described here. Do not rename it locally.

## Current-state diagnosis

This supplemental pass exists because the previous remediation tasking still left one wrong architectural assumption in place.

What was wrong in the prior tasking:

- The prior remediation correctly identified that the public proof was weak.
- The prior remediation incorrectly assumed that exact public-entrypoint inference could be recovered without redesigning the authoritative table and store type boundary.
- That assumption was false.

What the code now proves:

- `build_store_from_graph_assets(...)` and `build_tranche_01_store(...)` infer exactly once they are given a graph-asset vector whose element type is already concrete.
- The remaining loss of exact public inference happens before those helpers own execution.
- `build_graph_asset(...)` currently infers only `LineageGraphAsset{Nothing, Nothing, NodeTableT, EdgeTableT} where {NodeTableT, EdgeTableT}`.
- `build_alife_graph_asset(...)` currently infers only `LineageGraphAsset{Nothing, Nothing, NodeTableT, EdgeTableT} where ...`.
- `@code_warntype` on `build_newick_store(text, path, NodeTypeLoadRequest(NodeT))` shows `graph_assets::VECTOR` and a returned `LineageGraphStore` type with free `GraphTableT` and `GraphAssetVectorT`.
- `@inferred` therefore still fails on the public tranche-01 parse/load surfaces even though the shared typed owner itself is locally correct.

Why that happens:

- `NodeTable`, `EdgeTable`, and `GraphTable` currently encode `Tables.Schema` and `NamedTuple` column-layout types in their type parameters.
- Those schema and column-layout types are derived from runtime source content such as parsed retained-annotation names and parsed column layouts.
- A public parser/load surface that starts from `String` or table input cannot infer those value-derived type parameters exactly at compile time.
- As long as those data-dependent table types remain part of the public returned `LineageGraphAsset` and `LineageGraphStore` type boundary, exact public `@inferred` proof for tranche-01 parse/load surfaces is impossible.

Therefore the remaining blocker is not:

- weak tests alone
- `request_uses_tranche_01_single_parent_owner`
- `build_store_from_graph_assets`
- `build_tranche_01_store`

The remaining blocker is:

- the authoritative-table, graph-asset, and store type boundary still carries data-dependent table-schema identity into the public returned type

The correct fix is therefore:

- redesign the authoritative table and returned store typing so package-owned public tranche-01 parse/load surfaces return exact concrete store types whose identity does not depend on runtime annotation-name tuples or runtime table schema tuples

## Required revalidation before implementation

- Read the tranche, parent PRD, parent tasking, prior remediation tasking, and this supplemental tasking in full.
- Read the following project files in full before writing code:
  - `src/tables.jl`
  - `src/views.jl`
  - `src/construction.jl`
  - `src/newick_format.jl`
  - `src/alife_format.jl`
  - `test/core/type_stability_tranche_01.jl`
  - `test/core/alife_format.jl`
  - `test/core/newick_tables_only.jl`
  - `test/core/construction_protocol_single_parent.jl`
  - `ext/MetaGraphsNextIO.jl`
  - `ext/PhyloNetworksIO.jl`
- Reproduce the current blocker directly before changing code:
  - confirm that `Test.@inferred LineagesIO.build_newick_store(text, path, request)` fails for the tranche-01 single-parent `NodeType` case
  - confirm that `Test.@inferred LineagesIO.load_alife_table(table, NodeT; source_path = ...)` fails for the tranche-01 single-parent `NodeType` case
  - confirm that `Base.return_types(LineagesIO.build_graph_asset, ...)` returns a `UnionAll`/existential `LineageGraphAsset` shape rather than one exact concrete type
  - confirm that `Base.return_types(LineagesIO.build_alife_graph_asset, ...)` returns a `UnionAll`/existential `LineageGraphAsset` shape rather than one exact concrete type
  - confirm that `Base.return_types(LineagesIO.build_store_from_graph_assets, ...)` is already exact once given a concrete graph-asset vector type
- If any of those statements is false, stop and update this supplemental tasking before changing code.

## Tranche execution rule

This pass repairs the remaining tranche-01 public typed-boundary blocker by redesigning the data-dependent authoritative-table type boundary inside the repo-owned package-owned load core.

The owners and invariants that must remain after this pass:

- one shared tranche-01 typed owner for package-owned tables-only and package-owned single-parent `NodeType` surfaces
- authoritative tables remain the source of truth
- retained annotation values remain `Union{Nothing, String}`
- public row-reference semantics remain intact
- package-owned public tranche-01 parse/load surfaces infer exactly under `Test.@inferred`

The owners or behaviors that must no longer exist after this pass:

- `SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`, or `EdgeTable` type identity derived from runtime `Tables.Schema` or runtime `NamedTuple` column-layout types
- public `LineageGraphAsset` return types that still infer as existential `where`-types because table types remain data-dependent
- public `LineageGraphStore` return types that still infer with free `GraphTableT` or `GraphAssetVectorT` because table identity remains data-dependent
- public tranche-01 inference proofs that accept subtype checks, runtime-type equality checks, or helper-only proof as a substitute for exact public-entrypoint inference

Docs and API truth-boundary rule for this pass:

- docs must not be changed in this pass
- the API must not be broadened or renamed in this pass
- do not quietly redefine tranche-01 success as "helper-level inference only" without explicit user approval

Green-state rule for this pass:

- every WRITE, TEST, and MIGRATE task must end with `julia --project=test test/runtests.jl` green
- REVIEW tasks must also end with that command green if any code changed during the review cleanup

## Non-negotiable execution rules

- Do not lower the success condition from exact public-entrypoint inference to helper-only inference.
- Do not treat stronger tests as the fix while leaving the data-dependent type boundary unchanged.
- Do not preserve runtime-schema-dependent table identity by moving the same `Tables.Schema` and `NamedTuple` parameterization into a different wrapper or helper.
- Do not fix the problem by hardcoding fixture annotation names, fixture column sets, or format-specific schema tuples.
- Do not erase the problem by stuffing table payloads into `Any`, `Vector{Any}`, `Dict{Symbol, Any}`, or similarly untyped storage.
- Do not break Tables.jl compatibility, row-reference semantics, or retained annotation access in order to make `@inferred` pass.
- Do not change public function names, keyword names, or argument shapes.
- Do not pull `FileIO`, multi-parent redesign, builder redesign, basenode redesign, or extension-execution redesign into this pass.
- If extension files need signature-only adjustments because `LineageGraphAsset` or table types changed, keep those changes strictly mechanical and do not change extension behavior or routing ownership.

## Concrete anti-patterns or removal targets

- `struct SourceTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} ...`
- `struct CollectionTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} ...`
- `struct GraphTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} ...`
- `struct NodeTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} ...`
- `struct EdgeTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} ...`
- `LineageGraphAsset{Nothing, Nothing, NodeTableT, EdgeTableT} where {NodeTableT, EdgeTableT}` as the inferred return shape of public asset builders
- `LineageGraphStore{..., GraphTableT, GraphAssetIterator{GraphAssetVectorT}} where ...` as the inferred return shape of public tranche-01 parse/load entrypoints
- tests that prove only `typed_return_type <: public_return_type`
- tests that prove only `typeof(public_store) <: public_return_type`
- tests that prove only `public_return_type != legacy_store_return_type`

## Failure-oriented verification

The following checks must fail the current known bad implementation or a fake-fix regression:

- direct `Test.@inferred` on `build_newick_store(text, path, NodeTypeLoadRequest(NodeT))`
- direct `Test.@inferred` on `load_alife_table(table, NodeT; source_path = ...)`
- direct proof that `Base.return_types(LineagesIO.build_graph_asset, ...)` is still a `UnionAll`/existential shape on the bad implementation
- direct proof that `Base.return_types(LineagesIO.build_alife_graph_asset, ...)` is still a `UnionAll`/existential shape on the bad implementation
- direct proof that merely comparing helper inferred types to public inferred types with `<:` or runtime equality would still pass the bad implementation

The following are required positive proofs after the fix:

- `Test.@inferred LineagesIO.build_graph_asset(...)`
- `Test.@inferred LineagesIO.build_alife_graph_asset(...)`
- `Test.@inferred LineagesIO.build_newick_store(text, path)`
- `Test.@inferred LineagesIO.build_newick_store(text, path, NodeTypeLoadRequest(NodeT))`
- `Test.@inferred LineagesIO.build_alife_store(text, path)`
- `Test.@inferred LineagesIO.build_alife_store(text, path, NodeTypeLoadRequest(NodeT))`
- `Test.@inferred LineagesIO.load_alife_table(table; source_path = ...)`
- `Test.@inferred LineagesIO.load_alife_table(table, NodeT; source_path = ...)`
- existing builder regression tests remain green
- existing extension activation tests remain green
- existing core behavior tests remain green

The following are not acceptable as the only proof:

- "the full suite passes"
- "the shared typed helper still infers"
- "the public return type is a supertype of the concrete helper return type"
- "the runtime store has the same type as the helper-built store"

## Tasks

### 1. Revalidate the remaining blocker and freeze the redesign boundary

**Type**: REVIEW
**Output**: a written session baseline confirming that the remaining tranche-01 blocker is the data-dependent authoritative-table type boundary and not a still-broken typed owner
**Depends on**: none
**Positive contract**: read the governing docs, the tranche, both earlier tranche-01 tasking files, and the required source and test files in full; reproduce the failing public `@inferred` checks; reproduce the existential `build_graph_asset` and `build_alife_graph_asset` inferred return shapes; reproduce that `build_store_from_graph_assets` is already exact once graph assets are concrete
**Negative contract**: do not change code in this task; do not broaden the diagnosis into `FileIO`, multi-parent, builder, basenode, docs, or extension-execution redesign; if the revalidation disproves this diagnosis, stop and rewrite this supplemental tasking instead of improvising
**Files**:
- read `src/tables.jl`
- read `src/views.jl`
- read `src/construction.jl`
- read `src/newick_format.jl`
- read `src/alife_format.jl`
- read `test/core/type_stability_tranche_01.jl`
- read `test/core/alife_format.jl`
- read `test/core/newick_tables_only.jl`
- read `test/core/construction_protocol_single_parent.jl`
- read `ext/MetaGraphsNextIO.jl`
- read `ext/PhyloNetworksIO.jl`
**Out of scope**:
- source edits
- test edits
- docs edits
- dependency or environment changes
**Verification**:
- reproduce failing exact public `@inferred` on Newick single-parent `NodeType`
- reproduce failing exact public `@inferred` on `load_alife_table(..., NodeT)`
- confirm `build_graph_asset` and `build_alife_graph_asset` still infer existential types
- confirm `build_store_from_graph_assets` already infers exactly once graph assets are concrete

### 2. Replace schema-parametric authoritative table types with concrete table owners

**Type**: WRITE
**Output**: concrete authoritative table types whose public identity no longer depends on runtime schema tuples or runtime `NamedTuple` column-layout types
**Depends on**: 1
**Positive contract**: in `src/tables.jl`, replace the current schema-parametric `SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`, and `EdgeTable` definitions with concrete structs; implement the summary tables with dedicated typed vector fields for their fixed structural columns; add one non-exported concrete `AnnotationColumnStore` helper in `src/tables.jl` with exact fields `names::Vector{Symbol}`, `columns::Vector{Vector{OptionalString}}`, and `index_by_name::Dict{Symbol, Int}`; make `NodeTable` and `EdgeTable` store their structural vectors directly plus one `AnnotationColumnStore`; keep the existing constructor call shapes and validation behavior; implement `Tables.schema`, `Tables.columnnames`, and `Tables.getcolumn` against the new concrete field layout so runtime schema is computed from stored columns rather than encoded in the table type
**Negative contract**: do not reintroduce runtime schema identity through a different table type parameter; do not use `NamedTuple` or `Tables.Schema` type parameters in the new table definitions; do not store annotation payloads in `Any`-typed containers; do not change annotation value contracts; do not change public constructor names or keywords
**Files**:
- `src/tables.jl`
**Out of scope**:
- `src/construction.jl`
- `src/views.jl`
- `src/newick_format.jl`
- `src/alife_format.jl`
- extension files
- docs files
**Verification**:
- confirm by inspection that all 5 table types are now concrete and non-parametric
- confirm by direct check that `Tables.columnnames`, `Tables.getcolumn(table, i)`, and `Tables.getcolumn(table, nm)` still work for summary, node, and edge tables
- run `julia --project=test test/runtests.jl`

### 3. Migrate graph assets, stores, and tranche-01 source builders to the new concrete table boundary

**Type**: MIGRATE
**Output**: package-owned public tranche-01 parse/load surfaces now build and return stores whose type identity no longer depends on runtime table schema types
**Depends on**: 2
**Positive contract**: in `src/views.jl`, keep the exported type names and current constructor call shapes, but update `LineageGraphAsset`, `GraphAssetIterator`, `LineageGraphStore`, and `build_lineage_graph_store` so the authoritative table portion of the returned public type uses the concrete `SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`, and `EdgeTable` owners from task 2 rather than runtime-schema-derived table types; preserve current type arity by keeping the existing public `LineageGraphAsset` and `LineageGraphStore` type parameter counts, with the table-typed slots now fixed to the concrete table owners instead of data-dependent table types; in `src/construction.jl`, update tranche-01 helper signatures and temporary vector construction to target the new concrete asset shape rather than `NodeTableT`/`EdgeTableT` existential parameters; in `src/newick_format.jl` and `src/alife_format.jl`, keep the current parsing and validation behavior but make `build_graph_asset` and `build_alife_graph_asset` return one exact concrete asset type through the new table boundary
**Negative contract**: do not reduce the success condition to helper-only inference; do not reintroduce runtime schema identity through a different asset or store type parameter; do not move structural or annotation payloads into `Any` fields; do not change public function names, argument shapes, builder behavior, or typed-owner routing; do not change extension behavior beyond strictly mechanical signature updates required to keep extension code compiling against the new asset/table types
**Files**:
- `src/views.jl`
- `src/construction.jl`
- `src/newick_format.jl`
- `src/alife_format.jl`
- `ext/MetaGraphsNextIO.jl` only if a signature-only compatibility update is required
- `ext/PhyloNetworksIO.jl` only if a signature-only compatibility update is required
**Out of scope**:
- `src/fileio_integration.jl`
- docs files
- multi-parent redesign
- builder redesign
- basenode redesign
- extension behavior changes
**Verification**:
- confirm by direct check that `Test.@inferred LineagesIO.build_graph_asset(...)` passes
- confirm by direct check that `Test.@inferred LineagesIO.build_alife_graph_asset(...)` passes
- confirm by direct check that `Base.return_types(LineagesIO.build_newick_store, ...)` no longer returns a `UnionAll`/existential store shape for tranche-01 package-owned cases
- run `julia --project=test test/runtests.jl`

### 4. Replace surrogate public inference proofs with exact package-owned public `@inferred` coverage

**Type**: TEST
**Output**: direct exact public-entrypoint inference proof for all tranche-01 package-owned parse/load surfaces, plus anti-regression checks for the old existential asset-builder shape
**Depends on**: 3
**Positive contract**: in `test/core/type_stability_tranche_01.jl`, keep the useful legacy-owner regression checks and shared-owner routing checks, but replace the public subtype/runtime-equality proof pattern with direct `Test.@inferred` checks on the package-owned public tranche-01 surfaces themselves; add exact public `@inferred` checks for the 6 public surfaces listed in the settled success condition; add direct `@inferred` checks for `build_graph_asset` and `build_alife_graph_asset`; add explicit anti-regression checks proving the inferred return type for those 2 asset builders is not a `UnionAll`; keep the existing `load_alife_table` builder regression tests and extension owner-location tests green
**Negative contract**: do not keep `typed_return_type <: public_return_type`, `typeof(public_store) <: public_return_type`, or `public_return_type != legacy_store_return_type` as the primary proof; do not move proof into comments or source-text assertions; do not reclassify helper-only proof as public proof; do not broaden this test file into multi-parent or `FileIO` guarantees
**Files**:
- `test/core/type_stability_tranche_01.jl`
- `test/core/alife_format.jl` only if a narrow assertion adjustment is required by the exact proof rewrite
- `test/extensions/metagraphsnext_activation.jl` only if a signature-only adjustment is required by task 3
- `test/extensions/phylonetworks_activation.jl` only if a signature-only adjustment is required by task 3
**Out of scope**:
- docs files
- `test/core/fileio_load_surfaces.jl`
- new feature tests unrelated to tranche-01 exact public inference
**Verification**:
- confirm `Test.@inferred` passes for all 6 package-owned public tranche-01 surfaces
- confirm `Test.@inferred` passes for `build_graph_asset` and `build_alife_graph_asset`
- confirm the anti-regression checks fail the old existential asset-builder return shape
- run `julia --project=test test/runtests.jl`

### 5. Audit final boundary honesty and freeze tranche 1 again

**Type**: REVIEW
**Output**: a review-complete confirmation that tranche-01 now owns honest exact public package-owned inference for its scoped surfaces and that the old data-dependent type boundary is gone
**Depends on**: 4
**Positive contract**: inspect the final code and tests and confirm all of the following:
  - the remaining blocker was fixed by redesigning the data-dependent authoritative-table type boundary, not by weakening proof
  - public package-owned tranche-01 parse/load surfaces now pass exact `@inferred`
  - table ownership, annotation retention, Tables.jl compatibility, and row-reference semantics remain intact
  - no docs or public API truth-boundary changes slipped in
  - extension changes, if any, are signature-only and do not alter extension behavior
**Negative contract**: fail this task if any public proof still relies mainly on subtype/runtime-equality surrogates, if any authoritative table type still depends on runtime schema tuples, if any fake fix uses `Any`-typed payload storage, or if the pass accidentally dragged in `FileIO`, multi-parent, builder, basenode, or docs redesign
**Files**:
- review every file touched by tasks 2 through 4
- make cleanup edits only if they are required to remove a surviving bad shape
**Out of scope**:
- new feature work
- docs updates
- dependency changes
- tranche-02 or tranche-03 architecture
**Verification**:
- run `julia --project=test test/runtests.jl`
- confirm by inspection that the public exact typed-boundary goal is now honest for tranche-01 package-owned surfaces
