# Tranches: Type-stable parse and load pipeline

Parent PRD: `workflow-docs/20260504T0131--type-stable-parse/01_prd.md`

## Global governance and pass-forward rule

This tranche document is itself a governed downstream artifact.
Before planning, tasking, implementing, reviewing, auditing, or delegating any tranche below, contributors and agents must read the required governance and upstream sources line by line and comply with them.

This is an execution precondition, not a suggestion.
No downstream tasking file, implementation prompt, review scope, audit scope, or agent handoff may replace those obligations with:

- a summary
- a parent-document link
- repo familiarity
- module-root awareness
- or a statement that the sources were merely "considered"

Every downstream artifact generated from this tranche file must restate and pass forward 2 distinct obligations explicitly:

- governance documents must be read line by line and complied with before proceeding
- upstream and technological-context primary sources required by the specific work must be identified at file level, read line by line, and complied with before proceeding

That pass-forward chain is mandatory at every handoff boundary in this effort:

- tranche -> tasking
- tasking -> implementation instructions
- tasking -> review instructions
- tasking -> audit instructions
- tasking -> delegation and agent handoff instructions

When a workspace technological-context checkout exists under `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`, that checkout is the authoritative reading source for upstream semantics in planning, implementation, review, and audit work.
Installed package-cache copies, recollection, summaries, or repo-root awareness are not sufficient replacements.

Extension work has an additional non-negotiable rule:

- extension tranches, extension tasks, extension implementation prompts, extension review scopes, and extension audit scopes must require file-level reading inside the relevant checkout, not just module-root awareness

## Tranche 1: Establish the typed core owner for package-owned tables-only and single-parent loads

**Type**: AFK
**Blocked by**: None - can start immediately

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` before proceeding.
- Read line by line the project-owned sources that constrain this tranche: `src/fileio_integration.jl`, `src/newick_format.jl`, `src/alife_format.jl`, `src/construction.jl`, `src/views.jl`, `test/core/newick_tables_only.jl`, `test/core/construction_protocol_single_parent.jl`, `test/core/alife_format.jl`, and any additional project file whose behavior is changed.
- If this tranche touches compatibility-wrapper ownership while establishing the typed owner, identify and read the relevant `FileIO` checkout files line by line and comply with the contracts they define before proceeding. The minimum file set is `fileio.jl/src/FileIO.jl` and `fileio.jl/src/loadsave.jl`; add `fileio.jl/src/query.jl`, `fileio.jl/src/registry.jl`, or `fileio.jl/src/types.jl` if the change depends on those contracts.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Build the foundational typed core owner for package-owned tables-only and single-parent materialization.

This tranche is foundational.
It establishes the typed materialization surface descriptor, typed result-assembly ownership, and the package-owned single-parent executor while preserving authoritative table ownership, retained row-reference behavior, and the `basenodekey == 1` invariant.

When this tranche is complete, package-owned tables-only and single-parent typed paths must no longer depend on:

- widened store assembly caused by `materialize_graphs`
- an abstract request object serving as the execution owner
- a shadow second implementation for the same package-owned typed surface

### Legacy artifacts to retire or demote

- The `materialize_graphs` empty-branch precision loss as an owner of typed-store widening for package-owned tables-only and single-parent paths
- The current request-type conflation in which a load-request object doubles as both user-surface selector and execution owner for these typed paths
- Any interim wrapper that would keep a second package-owned single-parent execution path alive after the typed core exists

### Forbidden regressions

- "Fixing" the tranche by adding annotations while keeping the same widened store-assembly owner
- Creating a new typed facade that still forwards to the old single-parent execution owner underneath
- Introducing a second single-parent implementation rather than moving ownership to one typed core
- Regressing authoritative table ownership, row-reference retention, or the `basenodekey == 1` invariant

### Environment and dependency baseline

- Use the repo-local governance set and the parent PRD as controlling authorities.
- Use the workspace technological-context checkout for upstream reading whenever this tranche touches compatibility-wrapper ownership. Do not substitute package-cache reading alone.
- Do not re-resolve dependencies or change the manifest baseline unless that becomes necessary and is explicitly approved later.
- Do not introduce a shadow owner or compatibility fallback that preserves the retired store-assembly behavior as a second implementation.

### How to verify

- **Manual**: inspect the typed-core ownership path and confirm that package-owned tables-only and single-parent materialization normalize through one typed owner and one typed result-assembly layer.
- **Manual**: inspect the resulting code and confirm that the retired widened store-assembly owner does not remain in force for the surfaces moved by this tranche.
- **Automated**: add or strengthen inference-oriented tests for package-owned tables-only and single-parent paths in the relevant core test files, including at least one assertion that fails if the store assembly widens or if the old owner remains in force.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: if this tranche changes public docs or examples, run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given a package-owned tables-only or single-parent typed load path, when materialization runs, then one typed core owner performs result assembly without inheriting the old `materialize_graphs` widening behavior.
- [ ] Given a current narrow single-parent typed case, when the tranche is complete, then the currently good inference behavior is preserved rather than regressed.
- [ ] Given the legacy store-assembly owner named above, when the tranche is complete, then it is removed as the typed owner for the migrated surfaces rather than surviving behind a facade.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 3: typed package-owned alife table path
- User story 4: tables-only support remains classified honestly
- User story 5: preserve good single-parent inference
- User story 12: anti-fix matrix for annotations versus ownership repair
- User story 13: diagnosis matrix distinguishes the actual failure classes
- User story 17: preserve authoritative tables and retained row references
- User story 18: green-state rules require inference-oriented verification

---

## Tranche 2: Replace the multi-parent scheduler and supplied-target handle model

**Type**: AFK
**Blocked by**: Tranche 1

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` and this tranche file before proceeding.
- Read line by line the project-owned sources that constrain this tranche: `src/construction.jl`, `src/fileio_integration.jl`, `src/views.jl`, `test/core/network_protocol_multi_parent.jl`, `test/core/network_target_validation.jl`, `test/core/basenode_binding.jl`, `test/core/network_newick_format.jl`, `test/core/alife_format.jl`, and any additional project file whose behavior is changed.
- If this tranche changes shared typed-surface contracts in ways meant to support extension-owned handles later, identify and read the relevant upstream checkout files line by line and comply with the contracts they define before proceeding. Module-root awareness is not sufficient.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Build the typed multi-parent executor and the supplied-target handle model that separates:

- public target type
- internal construction-handle type
- finalized basenode projection type

This tranche is foundational and migration-oriented.
It repairs the shared owner for rooted-network scheduling and supplied-target binding while preserving authoritative tables, retained row references, and supported rooted-tree/rooted-network behavior.

When this tranche is complete, the migrated multi-parent and supplied-target typed paths must no longer depend on runtime handle recovery from runtime values.

### Legacy artifacts to retire or demote

- `materialized_handles = Any[...]` as the typed-core multi-parent storage owner
- `emit_childnode(request::AbstractLoadRequest, materialized_handles::Vector{Any}, ...)` as the migrated typed-core scheduler owner
- `build_parent_collection(::AbstractLoadRequest, parent_handles::Vector{Any})` as the migrated typed-core parent-collection owner
- The basenode and supplied-target handle-type erasure that forces the core to guess the internal handle type from the public target

### Forbidden regressions

- Wrapping the old `Any`-based scheduler in a new typed facade without moving ownership
- Reconstructing handle types through runtime `typejoin`, `Any`, or late-stage value inspection in the typed core
- Preserving the public-target-versus-handle-type conflation and patching it in consumers
- Repeating the same defensive handle-recovery logic in sibling layers

### Environment and dependency baseline

- Use the repo-local governance set and the parent PRD as controlling authorities.
- Use workspace technological-context checkouts as authoritative upstream reading sources whenever this tranche shapes a shared contract intended to support later extension migration.
- Do not add a second multi-parent scheduler or a second supplied-target binding implementation as a migration crutch.
- Do not re-resolve dependencies or change the manifest baseline unless that becomes necessary and is explicitly approved later.

### How to verify

- **Manual**: inspect the migrated typed-core multi-parent path and confirm that handle storage, parent collection, and supplied-target binding are owned by typed descriptors rather than runtime recovery.
- **Manual**: inspect the migrated typed-core code and confirm that the retired `Any`-based scheduler does not remain as a second owner for the surfaces moved by this tranche.
- **Automated**: add or strengthen inference-oriented tests for migrated multi-parent and supplied-target typed paths, including at least one assertion that fails if `Vector{Any}` storage or runtime `typejoin` recovery still survives in the typed core.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: if this tranche changes public docs or examples, run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given a migrated multi-parent typed path, when construction runs, then the typed core stores and forwards one concrete handle type and one concrete parent-collection owner without `Any`-based recovery.
- [ ] Given a supplied-target typed path whose public target type is not the construction-handle type, when construction runs, then the typed core carries both explicitly instead of inferring one from the other.
- [ ] Given the legacy scheduler artifacts named above, when the tranche is complete, then they are removed or demoted out of the migrated typed-core path rather than surviving as a second owner.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 6: flexible multi-parent scheduling without handle erasure
- User story 7: supplied-target binding with distinct handle and target types
- User story 12: anti-fix matrix for annotations versus ownership repair
- User story 13: diagnosis matrix distinguishes runtime recovery from inference
- User story 14: tests prove typed cases are inferred
- User story 17: preserve authoritative tables and retained row references
- User story 18: green-state rules require inference-oriented verification

---

## Tranche 3: Migrate `MetaGraphsNext` and `PhyloNetworks` to first-class typed extension adapters

**Type**: AFK
**Blocked by**: Tranche 2

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` and this tranche file before proceeding.
- Read line by line the project-owned sources that constrain this tranche: `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, `src/construction.jl`, `src/views.jl`, `test/extensions/metagraphsnext_activation.jl`, `test/extensions/metagraphsnext_simple_newick.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_network_rejection.jl`, `test/extensions/phylonetworks_activation.jl`, `test/extensions/phylonetworks_newick_networks.jl`, `test/extensions/phylonetworks_rejection_paths.jl`, `test/extensions/phylonetworks_tree_compatible_newick.jl`, `test/integration/phylonetworks_soft_release.jl`, and any additional project file whose behavior is changed.
- Read line by line the relevant `MetaGraphsNext.jl` checkout files and comply with the contracts they define before proceeding. The minimum file set for this tranche is `MetaGraphsNext.jl/src/MetaGraphsNext.jl`, `MetaGraphsNext.jl/src/metagraph.jl`, and `MetaGraphsNext.jl/src/graphs.jl`. Add any additional included file that owns behavior you change.
- Read line by line the relevant `PhyloNetworks.jl` checkout files and comply with the contracts they define before proceeding. The minimum file set for this tranche is `PhyloNetworks.jl/src/PhyloNetworks.jl`, `PhyloNetworks.jl/src/types.jl`, `PhyloNetworks.jl/src/readwrite.jl`, `PhyloNetworks.jl/src/manipulateNet.jl`, and `PhyloNetworks.jl/src/graph_components.jl`. Add any additional included file that owns behavior you change.
- Module-root awareness is explicitly insufficient for this tranche. File-level reading inside those checkouts is mandatory before implementation, review, audit, or delegation proceeds.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Build the typed extension adapter layer for `MetaGraphsNext` and `PhyloNetworks` on top of the repaired typed core.

This tranche is migration-oriented and user-facing.
It establishes first-class extension ownership for cases where the public target type and the internal construction-handle type differ.

When this tranche is complete, extension behavior that currently works only because of core type-model mismatch repairs must no longer survive in that repair-shaped form.

### Legacy artifacts to retire or demote

- The `MetaGraphsNext` repair override shape whose only purpose is to compensate for a core contract that assumes `NodeT` is also the construction-handle type
- The `MetaGraphsNext` multi-parent probe shim whose only purpose is to satisfy the old probe path
- The `PhyloNetworks` `build_parent_collection` repair override shape whose only purpose is to compensate for the old core handle model
- Any extension-specific workaround that exists only because the core still expects extensions to repair erased ownership assumptions

### Forbidden regressions

- Preserving the old repair overrides and probe shims as permanent architecture after the typed extension adapter owner exists
- Reintroducing `Any`-based scheduler assumptions through extension methods
- Allowing extension code to become a shadow scheduler or shadow type-recovery layer
- Treating checkout-repo familiarity as a substitute for reading the owning upstream files line by line

### Environment and dependency baseline

- Use the repo-local governance set and the parent PRD as controlling authorities.
- Treat the workspace technological-context checkouts for `MetaGraphsNext.jl` and `PhyloNetworks.jl` as the authoritative upstream reading sources for this tranche.
- Do not add hard dependencies from core `LineagesIO` onto those extension packages beyond the existing extension boundary.
- Do not preserve repair shims as hidden compatibility fallbacks once the typed adapter owner is in place.

### How to verify

- **Manual**: inspect the extension adapter design and confirm that extension-owned handle types are carried explicitly by the typed surface contract rather than repaired after the fact.
- **Manual**: inspect the extension code and confirm that repair-only shims or overrides named above are removed, demoted to thin wrappers with no second-owner logic, or otherwise prevented from surviving as hidden architecture.
- **Automated**: add or strengthen extension tests proving that public target type and construction-handle type can differ without `Any`-based core repair, including at least one assertion that fails if the old repair shape still owns behavior.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: if this tranche changes public docs or examples, run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given a `MetaGraphsNext` typed extension path, when construction runs, then the adapter expresses its target type and handle type explicitly through the typed core rather than through a repair-only override shape.
- [ ] Given a `PhyloNetworks` typed extension path, when construction runs, then the adapter expresses rooted-network handle ownership explicitly through the typed core rather than through parent-collection repair after handle erasure.
- [ ] Given the legacy repair-only extension artifacts named above, when the tranche is complete, then they are removed, demoted to thin wrappers, or otherwise prevented from surviving as a second implementation.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 8: extension authors can declare distinct target and handle types
- User story 9: first-class `MetaGraphsNext` typed cursor support
- User story 10: first-class `PhyloNetworks` typed build-cursor support
- User story 14: tests prove typed cases are inferred
- User story 17: preserve authoritative tables and retained row references
- User story 18: green-state rules require inference-oriented verification

---

## Tranche 4: Resolve the builder-surface contract and implement the chosen builder path

**Type**: HITL
**Blocked by**: Tranche 2

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` and this tranche file before proceeding.
- Read line by line the project-owned sources that constrain this tranche: `src/fileio_integration.jl`, `src/construction.jl`, `test/core/builder_callback.jl`, `test/core/network_newick_format.jl`, `test/core/alife_format.jl`, and any additional project file whose behavior is changed.
- If the chosen builder path remains exposed through compatibility wrappers, identify and read the relevant `FileIO` checkout files line by line and comply with the contracts they define before proceeding. Module-root awareness is not sufficient.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Resolve the open builder-surface contract question from the PRD and implement the chosen architecture honestly.

This tranche is HITL because the project owner must ratify whether:

- plain `builder = fn` remains a compatibility-only surface outside the strongest typed guarantee
- or the project adopts an explicit typed builder adapter so a builder-shaped surface can be inside the typed guarantee

After that decision, implement the chosen path so the typed core no longer depends on reflective builder protocol recovery.

### Legacy artifacts to retire or demote

- `build_builder_parent_collection_sample`
- `builder_parent_argument_type`
- `collect_builder_parent_handle_types!`
- `builder_parent_argument_types`
- `has_custom_multi_parent_add_child`
- Any runtime method-table probing or fallback comparison that remains in the typed core after the builder contract is decided

If plain `builder = fn` remains supported, its allowed reduced role is a compatibility surface that does not define the strongest typed contract.

### Forbidden regressions

- Leaving the builder contract ambiguous in docs, tests, or tasking
- Presenting plain `builder = fn` as a typed-guarantee surface without a typed adapter that declares the needed types and capabilities
- Moving method-table probing behind a new helper while keeping it in the typed core
- Allowing builder compatibility logic to regrow as a second owner of core scheduling semantics

### Environment and dependency baseline

- Use the repo-local governance set and the parent PRD as controlling authorities.
- Treat the project-owner decision on the builder contract as a required input before final implementation is merged.
- Use workspace technological-context checkouts as authoritative upstream sources if compatibility-wrapper semantics depend on them.
- Do not smuggle a contract decision into code, docs, or tests without the required HITL ratification.

### How to verify

- **Manual**: record the ratified builder decision explicitly and confirm that the resulting implementation, docs, and tests all use the same classification.
- **Manual**: inspect the resulting code and confirm that reflective builder protocol recovery no longer survives in the typed core.
- **Automated**: add or strengthen tests that fail if the builder surface is classified more strongly than the implementation actually guarantees.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: if this tranche changes public docs or examples, run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given the project-owner decision on the builder contract, when the tranche is complete, then the implementation, docs, and tests all classify the builder surface consistently.
- [ ] Given the builder path chosen to be inside the typed guarantee, when construction runs, then the necessary types and capabilities are declared explicitly rather than inferred reflectively.
- [ ] Given the legacy reflective builder artifacts named above, when the tranche is complete, then they are removed from the typed core or demoted to a compatibility-only role that does not survive as a second owner.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 11: builder surface classification is explicit
- User story 12: anti-fix matrix for annotations versus ownership repair
- User story 13: diagnosis matrix distinguishes reflection from typed ownership
- User story 14: tests prove typed cases are inferred
- User story 15: negative cases are documented explicitly
- User story 16: downstream documents inherit exact typed and untyped cases
- User story 18: green-state rules require inference-oriented verification

---

## Tranche 5: Ratify and expose the public typed load API while demoting `FileIO.load(...)` to a documented compatibility boundary

**Type**: HITL
**Blocked by**: Tranche 2

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` and this tranche file before proceeding.
- Read line by line the project-owned sources that constrain this tranche: `src/fileio_integration.jl`, `src/newick_format.jl`, `src/alife_format.jl`, `README.md`, the relevant docs and example files that describe supported load surfaces, and any additional project file whose behavior is changed.
- Read line by line the relevant `FileIO` checkout files and comply with the contracts they define before proceeding. The minimum file set for this tranche is `fileio.jl/src/FileIO.jl` and `fileio.jl/src/loadsave.jl`. Add `fileio.jl/src/query.jl`, `fileio.jl/src/registry.jl`, and `fileio.jl/src/types.jl` if the design or docs depend on those contracts.
- Module-root awareness is explicitly insufficient for this tranche. File-level reading inside the `FileIO` checkout is mandatory before implementation, review, audit, or delegation proceeds.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Ratify the additive typed direct-load API and the public documentation boundary for compatibility surfaces.

This tranche is HITL because the project owner must ratify:

- the name of the additive typed direct API
- whether docs should shift the recommended happy path toward that typed direct API while keeping `FileIO.load(...)` as a compatibility surface

After that decision, implement the resulting public API and documentation so the package states its typed guarantee honestly.

### Legacy artifacts to retire or demote

- Any doc or example language that implies `FileIO.load(...)` is itself the package-owned typed guarantee boundary
- Any compatibility-wrapper logic that remains a second owner of typed load semantics instead of a thin translation layer
- Any ambiguous public-surface classification that leaves typed versus compatibility-only cases implicit

The allowed reduced role for `FileIO.load(...)` is a supported compatibility wrapper that does not claim package-owned compile-time typing across the upstream dynamic boundary.

### Forbidden regressions

- Renaming or documenting surfaces in a way that implies stronger ownership than the implementation actually provides
- Leaving `FileIO.load(...)` positioned as the typed guarantee boundary while upstream `Base.invokelatest` ownership remains in place
- Creating a second public direct-load API that duplicates ownership instead of normalizing through one typed core
- Using docs-only language to hide unresolved compatibility-boundary ambiguity

### Environment and dependency baseline

- Use the repo-local governance set and the parent PRD as controlling authorities.
- Treat the workspace `FileIO` checkout as the authoritative upstream reading source for this tranche.
- Treat the project-owner API naming and documentation-boundary decision as a required input before final implementation is merged.
- Do not vendor, fork, or patch upstream `FileIO` as a hidden workaround for this tranche without separate explicit approval.

### How to verify

- **Manual**: inspect the public API and docs and confirm that package-owned typed surfaces and compatibility-only surfaces are classified explicitly and consistently.
- **Manual**: inspect the compatibility wrapper path and confirm that it remains a thin compatibility boundary rather than a second typed-semantics owner.
- **Automated**: add or strengthen tests and docs assertions that fail if `FileIO.load(...)` is treated as the typed guarantee boundary or if the typed direct API is undocumented or misclassified.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given the project-owner decision on public API naming and docs positioning, when the tranche is complete, then the public package-owned typed API is exposed and documented consistently with that decision.
- [ ] Given `FileIO.load(...)`, when compatibility loading runs, then the wrapper remains supported while being documented explicitly as outside the strongest package-owned typed guarantee.
- [ ] Given the legacy public-surface ambiguity named above, when the tranche is complete, then it is removed, demoted, or otherwise prevented from surviving in docs, examples, or wrapper ownership.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 1: documented typed path for package-owned loads
- User story 2: honest `FileIO.load(...)` compatibility classification
- User story 3: typed package-owned alife path remains accessible publicly
- User story 4: tables-only support remains classified honestly
- User story 15: negative cases are documented explicitly
- User story 16: downstream documents inherit exact typed and untyped cases
- User story 18: green-state rules require inference-oriented verification

---

## Tranche 6: Harden verification, negative cases, and downstream pass-forward discipline

**Type**: AFK
**Blocked by**: Tranche 3, Tranche 4, and Tranche 5

### Parent PRD

`01_prd.md`

### Governance and required reading

- Read line by line and comply with `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md` before proceeding.
- Read line by line and comply with `workflow-docs/20260504T0131--type-stable-parse/01_prd.md` and this tranche file before proceeding.
- Read line by line the project-owned sources that constrain this tranche: all tranche-touched test files, relevant docs and examples, and any workflow artifacts generated for follow-on work from this effort.
- Read line by line and comply with the relevant upstream checkout files for any surface whose verification or documentation is being hardened. File-level identification is mandatory; module-root awareness is not sufficient.
- Any downstream artifact generated from this tranche must restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly. Linking to this tranche or the parent PRD is insufficient.

### What to build

Build the stabilization layer for this architecture effort:

- inference-oriented verification for every supported typed case
- negative verification for compatibility-only and unsupported cases
- documentation that classifies typed, compatibility-only, and unsupported surfaces explicitly
- downstream workflow discipline so future tasking, implementation, review, audit, and delegation artifacts keep passing forward the same reading-and-compliance obligations

This tranche is stabilization-focused.
It must ensure that the repaired ownership model cannot silently regress into fake greens, vague docs, or weakened downstream handoffs.

### Legacy artifacts to retire or demote

- Weak verification that proves only behavior runs, not that the typed contract is enforced honestly
- Missing or vague negative-case documentation for compatibility-only and unsupported surfaces
- Future workflow artifacts generated from this effort that omit the required governance and upstream file-level reading-and-compliance mandates

### Forbidden regressions

- Treating full-suite green as sufficient without inference-oriented or negative verification
- Leaving compatibility-only cases undocumented or documented only euphemistically
- Allowing downstream tasking or agent handoffs to omit the reading-and-compliance obligations that this PRD and tranche file require
- Preserving fake-green verification that would let the known bad implementation survive

### Environment and dependency baseline

- Use the repo-local governance set, the parent PRD, and this tranche file as controlling authorities.
- Use the workspace technological-context checkouts as authoritative upstream reading sources for any surface whose verification or docs depend on upstream semantics.
- Do not weaken verification, docs classification, or workflow pass-forward mandates merely to make future work look thinner or more convenient.
- Do not re-resolve dependencies or change the manifest baseline unless that becomes necessary and is explicitly approved later.

### How to verify

- **Manual**: inspect the docs, test matrix, and downstream workflow artifacts generated from this effort and confirm that typed, compatibility-only, and unsupported cases are classified explicitly and consistently.
- **Manual**: inspect the downstream workflow artifacts and confirm that they restate both the governance reading-and-compliance obligation and the file-level upstream reading-and-compliance obligation explicitly.
- **Automated**: add or strengthen verification so that at least one check fails for each known bad regression shape named in the PRD and tranche documents.
- **Automated**: run `julia --project=test test/runtests.jl`.
- **Automated**: run `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given each supported typed surface, when verification is run, then at least one inference-oriented check proves the typed contract rather than only runtime success.
- [ ] Given each compatibility-only or unsupported surface, when docs and tests are reviewed, then the classification is explicit and at least one negative check fails the dishonest or unsupported implementation shape.
- [ ] Given downstream workflow artifacts generated from this effort, when they are inspected, then they restate and pass forward both mandated reading-and-compliance obligations rather than relying on links or implied inheritance.
- [ ] Given the forbidden regression shape named above, when verification is run, then the tranche fails rather than reporting a fake green.

### User stories addressed

- User story 14: tests prove typed cases are inferred
- User story 15: negative cases are documented explicitly
- User story 16: downstream documents inherit exact typed and untyped cases
- User story 18: green-state rules require inference-oriented verification

---
