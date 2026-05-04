---
date-created: 2026-05-04T01:31:00
status: draft
---

# PRD: Type-stable parse and load pipeline

## User statement

Verbatim user direction for this architecture effort:

> "Nothing off the table, fully rearchitecting permitted, what would it take to get end-to-end type stability while maintaining its flexible concrete/container/type-agnostic design. Write a full PRD : ./workflow-docs/20260504T0131--type-stable-parse"

Follow-up clarifications captured during discovery:

> "this is scoped to this repo"

> "I want a full audit and diagnosis of where we are not type-stable in a full load end-to-end transaction, and whether the situation can be fixed by:
>
> - proper annotation (without narrowing/constraining of course)
> - parameter typed functions
> - multiple dispatch
> - or and CASES WHERE THIS WORKS and DOES NOT WORK HAVE TO BE CLEARLY DOCUMENTED compiler inference"

## Problem statement

The current load pipeline mixes 3 different concerns in one control path:

1. public compatibility entrypoints
2. authoritative table construction
3. optional graph materialization

This produces 2 different classes of type-stability problems that must be kept distinct.

The first class is an upstream compatibility-boundary problem. The current public `FileIO.load(...)` entrypoint is not an end-to-end statically typed boundary because upstream `FileIO` performs runtime format resolution and calls the selected loader with `Base.invokelatest`.

The second class is a LineagesIO-owned architecture problem. Inside the package, the current materialization design erases construction-handle types in the flexible paths that matter most:

- multi-parent materialization stores handles in `Vector{Any}`
- parent collections are reconstructed with runtime `typejoin`
- `BuilderLoadRequest` infers parent-handle samples by walking `methods(builder)`
- multi-parent validation probes capability with `which(Core.kwcall, ...)`
- the request model conflates the user-facing construction target with the internal construction-handle type

This means the package currently has some narrow locally type-stable regions, but it does not provide a full end-to-end type-stable load transaction across its supported public surfaces.

The design problem is therefore not "make one function infer better." The real problem is to define:

- which entrypoints are promised to be type-stable
- which compatibility wrappers are intentionally not promised to be type-stable
- how to encode internal construction-handle types without breaking the current flexible load semantics
- how to support extension-owned materializers whose internal handle type differs from the public target type

## Target outcome

When this work is complete, LineagesIO will have a package-owned typed load core whose supported cases are fully documented and machine-verifiable.

The target state must make the following statements true:

- The package clearly distinguishes a typed core load API from compatibility wrappers.
- The supported typed cases are explicit, documented, and testable with inference-oriented verification.
- The typed core does not rely on `Vector{Any}` handle storage, runtime `typejoin` to recover handle types, or method-table probing to decide whether construction is allowed.
- Multi-parent materialization uses explicitly encoded handle and parent-collection types.
- Extension-owned materializers can declare an internal construction-handle type that differs from the public target graph type.
- The current flexible semantics remain available, either as typed cases or as documented compatibility-only cases.
- Documentation explicitly states which surfaces are guaranteed type-stable and which are not.

The target outcome is not "make `FileIO.load(...)` itself statically typed under the current upstream contract." That is not an honest goal while `FileIO` remains the dispatching owner of the public `load` call.

## User stories

1. As a user loading rooted Newick into a simple native node type, I want a documented typed path so that the compiler can infer the full package-owned transaction.
2. As a user loading rooted Newick through the current `FileIO.load(...)` compatibility surface, I want the load to keep working, but I also want documentation to say honestly that this surface is not the typed guarantee boundary.
3. As a user loading an alife table already in memory, I want a typed package-owned path that does not depend on upstream `FileIO` dispatch.
4. As a user materializing only authoritative tables, I want tables-only loads to remain supported and clearly classified in the type-stability matrix.
5. As a user loading a single-parent graph into a caller-defined node type, I want the package to preserve the currently good single-parent inference properties rather than regressing them during redesign.
6. As a user loading a multi-parent rooted network into a caller-defined node type, I want the scheduler to remain flexible without erasing all construction-handle types.
7. As a user supplying a pre-existing basenode or graph target, I want the package to support binding into that target even when the internal construction handle is not the same type as the supplied target.
8. As an extension author, I want to declare that the public target type and the internal construction-handle type are different, without relying on escape-hatch overrides that repair a mismatched core contract.
9. As a `MetaGraphsNext` integration, I want a first-class way to say "the public target is `MetaGraph`, the construction handle is a typed cursor."
10. As a `PhyloNetworks` integration, I want a first-class way to say "the public target is `HybridNetwork`, the construction handle is a typed build cursor."
11. As a user of the builder callback surface, I want the documentation to say clearly whether the plain `builder = fn` form is inside or outside the typed guarantee.
12. As a maintainer, I want to know whether adding argument annotations alone would fix a given instability, so that we do not waste time on anti-fixes.
13. As a maintainer, I want a diagnosis matrix that distinguishes return-type inference, internal abstract containers, runtime dynamic dispatch, and compatibility wrappers.
14. As a reviewer, I want tests that prove the typed cases are inferred, not just that they run.
15. As a reviewer, I want negative cases documented explicitly so that the package does not imply stronger type guarantees than it actually owns.
16. As a future contributor, I want downstream tranche documents to inherit the exact list of typed and untyped cases, not a vague "make it faster" summary.
17. As a user depending on retained annotations and authoritative tables, I want the redesign to preserve table ownership and retained row-reference semantics.
18. As a maintainer, I want green-state rules that prevent a large architecture refactor from landing with only behavioral tests and no inference-oriented verification.

## Authorized disruption boundary

- internal redesign allowed:
  complete replacement of the current load-request and materialization-core architecture, including new internal surface descriptors, new typed executors, new validation ownership, and new extension hooks
- internal redesign forbidden:
  do not discard authoritative table ownership, retained annotation semantics, current rooted-tree and rooted-network source support, or the public concept of optional materialization surfaces
- external breaking changes allowed:
  additive change is preferred; external breakage is permitted only if a typed direct API cannot be introduced honestly without it
- required migration or compatibility obligations:
  if any current public surface changes meaning, document the new contract, retain compatibility wrappers or deprecation shims where feasible, update examples, and restate which surfaces are and are not in the typed guarantee
- non-negotiable protections:
  preserve authoritative `node_table` and `edge_table` ownership, the `basenodekey == 1` materialization invariant, extension support boundaries, and the distinction between supported typed cases and compatibility-only cases

## Current-state architecture

### Existing owners

- `src/fileio_integration.jl` owns FileIO-facing wrapper entrypoints and request construction.
- `src/newick_format.jl` and `src/alife_format.jl` own source parsing and authoritative table construction.
- `src/construction.jl` owns materialization validation, basenode discovery, single-parent recursion, multi-parent scheduling, and construction-protocol dispatch.
- `src/views.jl` owns `LineageGraphAsset`, `LineageGraphStore`, and row-reference projection.
- `ext/MetaGraphsNextIO.jl` and `ext/PhyloNetworksIO.jl` own extension-specific materialization logic and adapt LineagesIO’s generic construction protocol to extension-owned graph types.

### Existing failure modes

The current codebase contains 3 distinct failure classes.

#### Upstream compatibility-boundary instability

- `FileIO.load(file, args...)` routes through runtime loader lookup and `Base.invokelatest` in upstream `FileIO` source.
- Consequence: no public `FileIO.load(...)` call can honestly be claimed as end-to-end statically type-stable while that upstream contract remains the public owner of dispatch.

#### Package-owned orchestration instability

- `materialize_graphs(graph_assets, request::AbstractLoadRequest)` returns the original `graph_assets` unchanged in the empty case and a newly typed vector in the materializing case.
- `build_newick_store` and `build_alife_store_from_rows` then assemble `LineageGraphStore` from a value whose inferred vector type is widened by that branch.
- Consequence: the package-owned store-assembly layer loses precision even before the construction loop is considered.

#### Package-owned construction-handle erasure

- `materialize_graph_basenode` stores multi-parent handles in `materialized_handles = Any[...]`.
- `emit_childnode` reads parent handles back out as `Any`.
- `build_parent_collection` reconstructs a typed parent vector either from `request.node_type` or from runtime `typejoin`.
- `BuilderLoadRequest` derives handle samples by walking the builder method table.
- multi-parent capability validation uses `which(Core.kwcall, ...)` against fallback methods.
- Consequence: flexible construction surfaces recover handle types dynamically rather than carrying them as owned type parameters.

### Existing coupling, duplication, or design debt

- `AbstractLoadRequest` currently serves as both a user-surface selector and an internal execution descriptor, but those are not the same responsibility.
- The request model does not encode the internal handle type separately from the public target type.
- Extension-owned materializers already contain evidence that the core ownership model is wrong:
  `MetaGraphsNext` must override `emit_basenode` because target graph type and handle type differ.
  `PhyloNetworks` must override `build_parent_collection` because target graph type and handle type differ.
- The builder surface is intentionally open-ended, but the current design tries to recover typed behavior from that openness after the fact through runtime inspection.

### Current audit matrix

| Case | Current status | Why |
|---|---|---|
| `FileIO.load(path)` | not end-to-end type-stable | upstream runtime format resolution and `Base.invokelatest` |
| `FileIO.load(File{format"Newick"}(...))` | not end-to-end type-stable | explicit format bypasses query, but not upstream `action(..., file, ...) -> Base.invokelatest` |
| `LineagesIO.fileio_load(File{...}, ...)` | more inferable than `FileIO.load`, but still not fully typed end-to-end | package-owned path begins after upstream dynamic dispatch, and store assembly still widens |
| `build_newick_store(text, path, request)` | not fully typed today | `materialize_graphs` empty-branch union widens `graph_assets`; store assembly inherits that |
| `load_alife_table(table, NodeT)` | not fully typed today | no `FileIO` boundary, but the same store-assembly widening remains |
| `construct_single_parent_descendants!` with `NodeTypeLoadRequest{NodeT}` | locally type-stable | concrete parent handle recurses through one concrete child-handle type |
| `materialize_graph_basenode` single-parent `NodeTypeLoadRequest{NodeT}` | locally type-stable in current narrow case | concrete basenode handle plus stable recursion |
| multi-parent `NodeTypeLoadRequest{NodeT}` | return type may infer, but internal execution is still dynamically recovered | `Vector{Any}` handle storage and `Any` parent reads remain on the hot path |
| multi-parent `BasenodeLoadRequest` | not fully typed in the general design | request does not encode the internal handle type, so parent collection falls back to runtime `typejoin` |
| multi-parent `BuilderLoadRequest` | not fully typed in the general design | request does not encode handle type; builder capability and parent-type sampling are runtime-introspected |
| `MetaGraphsNext` library-created path | works functionally, but reveals a core type-model mismatch | target graph type is `MetaGraph`; handle type is `MetaGraphsNextBuildCursor` |
| `PhyloNetworks` library-created path | works functionally, but reveals a core type-model mismatch | target graph type is `HybridNetwork`; handle type is `PhyloNetworksBuildCursor` |

## Target architecture

### Major modules and responsibilities

- a typed source-ingest layer that reads text, path, stream, or in-memory table inputs and produces authoritative graph assets without taking ownership of compatibility dispatch
- a typed materialization-surface layer that encodes internal handle type, finalized graph type, finalized basenode projection type, and construction capabilities
- a single-parent executor specialized on one concrete handle type
- a multi-parent executor specialized on one concrete handle type and one concrete parent-collection type
- a result-assembly layer that produces a concretely typed `LineageGraphStore`
- compatibility wrappers for `FileIO.load(...)` and legacy open-ended builder syntax
- extension adapters that plug typed extension-owned surfaces into the core without overriding mismatched ownership assumptions

### Ownership boundaries

- compatibility wrappers own runtime dispatch, loader selection, and user-facing translation of legacy surfaces into typed internal descriptors
- format parsers own authoritative table construction only
- typed materialization surfaces own the mapping from user-facing target to internal construction-handle representation
- executors own construction scheduling, handle storage, and invariant-preserving traversal
- extension adapters own extension-specific graph mutations, but not core scheduler type recovery

### Shared contracts and invariants

- authoritative graph assets remain the source of truth for structure and retained annotations
- `basenodekey == 1` remains a required invariant at materialization time
- single-parent and multi-parent execution paths must both preserve authoritative row-reference semantics
- typed-core guarantees must be stated per surface, not implied globally
- compatibility wrappers must not claim the typed guarantee if they still cross an upstream dynamic boundary

### Target deep modules and simplified interfaces

The central deep module should be a typed materialization core that consumes:

- authoritative graph assets
- a typed materialization surface descriptor

and produces:

- a concretely typed `LineageGraphStore{GraphT, BasenodeT, ...}`

without recovering handle types from runtime values.

Each typed materialization surface descriptor must encode at least:

- `HandleT` for the internal construction handle
- `GraphT` for the finalized graph container
- `BasenodeT` for the finalized basenode projection
- `ParentCollectionT` for multi-parent calls
- capability flags or traits for supported construction tiers

This separates 3 concepts that are currently conflated:

- public target type
- internal construction-handle type
- finalized basenode projection type

## Implementation decisions

### Decision 1

Do not define "end-to-end type-stable" as starting at `FileIO.load(...)`.

Verified upstream fact:

- `FileIO/src/loadsave.jl` selects loaders at runtime and calls them with `Base.invokelatest`.

Local inference from that fact:

- while `FileIO` remains the public dispatch owner of `load(...)`, LineagesIO cannot honestly promise that the whole `FileIO.load(...)` transaction is a compile-time-typed path

Therefore the design must distinguish:

- package-owned typed load API
- FileIO compatibility wrapper

### Decision 2

Do not attempt to fix LineagesIO-owned dynamic boundaries with annotations alone.

Annotations can document and enforce already-true contracts. They cannot remove:

- upstream `Base.invokelatest`
- `Vector{Any}` storage
- runtime `typejoin`
- runtime method-table inspection
- a request type that does not encode the handle type it later needs

### Decision 3

Use parametric surface descriptors as the primary repair.

The typed core should be parameterized over the internal handle type and finalized result types. This is the main architectural repair that unlocks:

- typed handle storage
- typed parent collections
- typed executors
- typed result assembly
- honest extension support when target type and handle type differ

### Decision 4

Use multiple dispatch to separate surface families, not to recover erased types after the fact.

Multiple dispatch should define distinct typed surface families such as:

- library-created native node materialization
- supplied-target binding
- typed callback adapter
- extension-owned graph materialization

Multiple dispatch should not be used as a late-stage patch over `Any` storage and runtime `typejoin`.

### Decision 5

Treat the current plain `builder = fn` compatibility surface as potentially outside the strongest typed guarantee unless wrapped in a typed adapter.

If the project wants the builder concept inside the typed guarantee, the design must introduce an explicit typed builder adapter that declares:

- handle type
- finalized result type
- supported parent argument shapes

The plain open-ended callback syntax can remain as a compatibility surface if needed, but it should not silently define the core typed contract.

### Decision 6

Remove runtime method-table probing from the typed core.

The typed core should not use:

- `methods(builder)`
- `which(Core.kwcall, ...)`
- runtime fallback comparison to infer protocol support

Those behaviors belong either:

- in compatibility adapters
- or in explicit traits/capability declarations owned by the typed surface descriptor

### Fixability matrix

| Issue | Annotation only | Parametric typing | Multiple dispatch | Compiler inference alone | Required action |
|---|---|---|---|---|---|
| `FileIO.load(...)` upstream dynamic boundary | no | no | no | no | typed direct API plus compatibility wrapper boundary |
| `materialize_graphs` empty-branch union | no | yes | minor | no | typed return design or explicit typed empty result path |
| multi-parent `Vector{Any}` handle storage | no | yes | supports | no | replace with typed handle storage |
| basenode surface handle-type erasure | no | yes | yes | no | separate supplied target type from internal handle type |
| builder surface handle-type erasure | no | yes | yes | no | typed builder adapter or explicit compatibility downgrade |
| runtime `typejoin` parent recovery | no | yes | supports | no | typed parent collection ownership |
| runtime method-table probing | no | yes | yes | no | explicit capability traits or typed adapter declarations |
| single-parent native node recursion | already adequate | not required for this slice | already adequate | already works | preserve during redesign |
| store-assembly precision loss after materialization | no | yes | minor | no | keep graph-asset vector concretely typed through assembly |

## Module design

### Typed source-ingest layer

- **Name**
  typed source-ingest layer
- **Responsibility**
  translate text, path, stream, or in-memory table input into authoritative graph assets without taking ownership of compatibility dispatch
- **Interface**
  explicit format-owned package APIs for Newick text, Newick path/stream, alife text, and alife table input
- **Tested**
  yes

### Typed materialization surface layer

- **Name**
  typed materialization surface layer
- **Responsibility**
  define the internal handle type, finalized result types, and construction capabilities for each supported materialization family
- **Interface**
  one typed surface descriptor per materialization family
- **Tested**
  yes

### Single-parent executor

- **Name**
  single-parent executor
- **Responsibility**
  perform concrete-handle recursive materialization for single-parent graphs
- **Interface**
  accepts authoritative graph asset plus typed surface descriptor with one concrete `HandleT`
- **Tested**
  yes

### Multi-parent executor

- **Name**
  multi-parent executor
- **Responsibility**
  schedule and materialize rooted networks without erasing handle types
- **Interface**
  accepts authoritative graph asset plus typed surface descriptor with concrete `HandleT` and `ParentCollectionT`
- **Tested**
  yes

### Result-assembly layer

- **Name**
  result-assembly layer
- **Responsibility**
  assemble concretely typed `LineageGraphAsset` and `LineageGraphStore` values without widening vector element types during orchestration
- **Interface**
  typed graph-asset vector in, typed store out
- **Tested**
  yes

### Compatibility wrapper layer

- **Name**
  compatibility wrapper layer
- **Responsibility**
  preserve current public convenience surfaces while documenting which ones are outside the typed guarantee
- **Interface**
  FileIO-facing wrappers and legacy builder/bound-target adapters
- **Tested**
  yes

### Extension adapter layer

- **Name**
  extension adapter layer
- **Responsibility**
  provide typed surface descriptors and graph mutations for extension-owned materializers such as `MetaGraphsNext` and `PhyloNetworks`
- **Interface**
  extension-owned typed adapters that declare target type, handle type, and finalized basenode projection type explicitly
- **Tested**
  yes

## Governance and controlled vocabulary

Downstream contributors and agents must read the following governance documents line by line and comply with them before planning, trancheing, tasking, implementing, reviewing, auditing, or delegating this work:

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

This is an execution precondition, not a documentation suggestion.
No downstream workflow artifact, task description, implementation prompt, review scope, audit scope, or agent handoff may replace that reading-and-compliance obligation with:

- a summary
- a parent-document link
- a claim that the reader is already generally familiar with the repo rules
- or a statement that the files were merely "considered"

Every downstream artifact generated from this PRD must restate and pass forward 2 distinct obligations explicitly:

- governance documents must be read line by line and complied with before proceeding
- upstream and technological-context primary sources required by the specific work must be read line by line and complied with before proceeding

That pass-forward chain is mandatory at every handoff boundary in this effort:

- PRD -> tranche
- tranche -> tasking
- tasking -> implementation, review, audit, and delegation instructions

Vocabulary decisions in force for this effort:

- use `basenode`, not `rootnode`, for project-owned abstractions and identifiers in this repo
- keep the distinction between reader-facing prose and exact API names
- preserve the governance terms `tranche`, `verification artifact`, `ownership boundary`, and `pass forward`
- do not introduce new canonical project lexemes for this effort unless explicitly ratified

Terms that must be avoided in repo-owned terminology for this effort:

- `rootnode` as the project-owned canonical abstraction name
- vague phrases such as "typed enough", "probably inferred", or "compiler magic"

## Primary upstream references

Downstream work must read the relevant primary sources line by line and comply with the contracts they define before proceeding:

- workspace technological-context checkout for `FileIO`: `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl`
- workspace technological-context checkout for `MetaGraphsNext.jl`: `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl`
- workspace technological-context checkout for `PhyloNetworks.jl`: `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl`
- upstream `FileIO` entrypoint contract: `/home/jeetsukumaran/.julia/packages/FileIO/ZlWq2/src/FileIO.jl`
- upstream `FileIO` load dispatch path: `/home/jeetsukumaran/.julia/packages/FileIO/ZlWq2/src/loadsave.jl`

For this effort, "read the relevant primary sources" means actual file-level reading of the files that own the behavior being changed.
Repo-root awareness, module-root awareness, directory listing awareness, summaries, second-hand notes, or inherited mentions from a parent document are not substitutes.
If a tranche, task, implementation, review, audit, or delegation touches a behavior owned inside one of these upstream checkouts, it must identify the relevant files and require the next contributor or agent to read those files line by line and comply with the contracts they define before proceeding.

Mandated review obligations for these technological-context checkouts:

- any tranche, task, implementation, review, or audit that touches the public `FileIO.load(...)` compatibility boundary, typed direct-load surfaces, or compatibility-wrapper ownership must identify and read the relevant `FileIO` checkout files line by line and comply with the contracts they define before proceeding, and must pass that same file-level reading-and-compliance obligation forward in any generated downstream instructions
- any tranche, task, implementation, review, or audit that touches `ext/MetaGraphsNextIO.jl` or any shared typed-surface contract intended to support graph-owned construction handles must identify and read the relevant `MetaGraphsNext.jl` checkout files and docs line by line and comply with the contracts they define before proceeding, and must pass that same file-level reading-and-compliance obligation forward in any generated downstream instructions
- any tranche, task, implementation, review, or audit that touches `ext/PhyloNetworksIO.jl` or any shared multi-parent typed-surface contract intended to support rooted-network construction handles must identify and read the relevant `PhyloNetworks.jl` checkout files and docs line by line and comply with the contracts they define before proceeding, and must pass that same file-level reading-and-compliance obligation forward in any generated downstream instructions
- extension tranches, extension tasks, extension implementation prompts, extension review scopes, and extension audit scopes must require file-level review inside those checkouts, not just module-root awareness

Project-owned primary sources that constrain the redesign:

- `src/fileio_integration.jl`
- `src/newick_format.jl`
- `src/alife_format.jl`
- `src/construction.jl`
- `src/views.jl`
- `ext/MetaGraphsNextIO.jl`
- `ext/PhyloNetworksIO.jl`
- `test/core/construction_protocol_single_parent.jl`
- `test/core/network_target_validation.jl`
- `test/core/network_protocol_multi_parent.jl`
- `test/core/builder_callback.jl`

Verified fact versus local inference boundary:

- Verified fact: upstream `FileIO` calls the selected loader via `Base.invokelatest`.
- Local inference from verified fact: the `FileIO.load(...)` entrypoint is outside the strongest package-owned compile-time type guarantee unless upstream ownership changes.

## Tranche gates

- required green checks at tranche start and end:
  package tests green, including core load-path tests and extension tests that are in scope for the tranche
- required docs, example builds, or integration outputs:
  docs examples updated to distinguish typed-core surfaces from compatibility wrappers
- migration and compatibility verification obligations:
  if a public surface changes, update README and docs with explicit migration language and surface classification
- regression expectations:
  no loss of authoritative table ownership, retained annotation access, or supported rooted-tree/rooted-network behavior

Additional typed-core gates required for this effort:

- inference-oriented tests for each documented typed case
- explicit negative tests or docs assertions for documented non-typed compatibility cases
- no `Vector{Any}` handle storage in the typed core
- no runtime `typejoin`-based handle recovery in the typed core
- no method-table probing in the typed core

## Testing and verification decisions

### What must stay green throughout

- existing behavior tests for Newick, alife, single-parent, multi-parent, row references, basenode binding, builder callbacks, and extension-owned loads
- docs examples and quick-start examples that exercise current public behavior

### Required new verification artifacts

- `@inferred` or equivalent inference assertions for each supported typed package-owned load case
- targeted `@code_warntype` audit fixtures for the typed core methods most likely to regress
- regression tests proving that typed single-parent and typed multi-parent executors do not rely on `Any` handle storage
- compatibility tests proving that `FileIO.load(...)` still works while remaining explicitly outside the typed guarantee
- extension adapter tests proving that target type and internal handle type can differ without override hacks

### Multi-surface verification obligations

The following surfaces must be verified separately:

- package-owned typed Newick path
- package-owned typed alife text path
- package-owned typed alife table path
- compatibility `FileIO.load(...)` Newick path
- compatibility `FileIO.load(...)` alife path
- single-parent typed node materialization
- multi-parent typed node materialization
- supplied-target typed adapter path
- typed extension adapter path where handle type differs from public target type

### Cases that must be documented explicitly

- cases that are fully inside the typed guarantee
- cases that are functionally supported but intentionally outside the typed guarantee
- cases that remain unsupported for principled reasons

## Out of scope

- claiming that upstream `FileIO.load(...)` itself has become a compile-time-typed boundary without changing the upstream contract
- rewriting the parsers solely for allocation reduction when parser output typing is already adequate
- unrelated save-path or serialization redesign
- unrelated table-schema redesign beyond what is needed to preserve typed store assembly
- speculative generalization for unimplemented formats or graph families not currently supported by this repo

## Open questions

1. What should the additive typed direct API be called
Owner: project owner
Suggested resolution path: choose names during tranche planning after the typed surface descriptor design is settled

2. Should the plain `builder = fn` surface remain compatibility-only, or should the project require a typed builder adapter for typed-core guarantees
Owner: project owner
Suggested resolution path: decide during tranche planning whether plain builder flexibility is more important than bringing that surface inside the strongest typed contract

3. Should `FileIO.load(...)` remain the documented happy path, or should docs shift the primary recommendation toward the typed direct API while keeping `FileIO` as compatibility
Owner: project owner
Suggested resolution path: decide during tranche planning together with documentation and migration scope

## Further notes

### Diagnosis summary

The current codebase already proves that compiler inference is not the whole problem.

Some narrow internal paths are already good:

- single-parent native node recursion
- direct finalized return typing from `materialize_graph_basenode` in narrow concrete cases

The failures appear where the architecture erases type ownership:

- compatibility dispatch owned by upstream `FileIO`
- flexible surfaces that do not encode their internal handle type
- multi-parent scheduling that stores handles in `Any`
- runtime method-table probing used as a substitute for explicit capability ownership

### Design rule for downstream work

If a future tranche proposes only:

- more annotations
- more `where` parameters on the existing abstract request design
- or more extension-specific overrides over the same `Any`-based scheduler

then that tranche is almost certainly an anti-fix unless it also repairs the owning type model.

### Expected target-case classification

The redesign should leave the project with 3 clearly documented categories:

- fully typed package-owned load cases
- compatibility-only cases that remain supported but not part of the typed guarantee
- unsupported cases that are rejected explicitly rather than implied
