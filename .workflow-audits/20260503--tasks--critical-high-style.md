# Tasks — Critical and High STYLE-julia.md compliance items

Parent audit: `.workflow-audits/20260503--julia-code-style.md`

## Governance

Read each of the following line by line before making any change. Do not skim.
Do not substitute recollection for source text.

- `CONTRIBUTING.md` (repo-local)
- `STYLE-julia.md` (repo-local) — especially §1.12–§1.13 (type annotations), §5 (anti-patterns: bare `using`)
- `STYLE-architecture.md` (repo-local) — fix the owner, not the symptom site
- `STYLE-verification.md` (repo-local) — green-state gates, regression-test obligations
- `STYLE-vocabulary.md` (repo-local) — `basenode` is canonical; `tip` is proscribed

Vocabulary constraints in force:
- `basenode` (not `rootnode`, `root`, `root_node`)
- `edge` in identifiers; `branch` only in biological prose
- `leaf` / `leaves` (not `tip`)
- `vertex` / `vertices` must not appear as generic synonyms for `node`

## Required revalidation before implementation

Before touching any file:

1. Read the relevant source files in full (not excerpts).
2. Read the relevant tests in full.
3. Confirm the defect or gap matches the description. If reality differs from
   the task description, stop and raise that before changing code.
4. Confirm the test suite is green before starting — do not start from a broken
   baseline.

## Failure-oriented and positive verification

- Every task that changes behavior must have at least one test that would have
  caught the defect before the fix (fails on the old code, passes on the new).
- Absence of test failures is not confirmation of correctness. Run the full
  suite and show the output.
- Do not annotate a return type as `::Any`. Unannotated and `::Any` are not
  equivalent: unannotated lets the compiler infer; `::Any` suppresses inference.

## Design decision — `BuilderLoadRequest` return types

For `emit_*` protocol functions in `src/construction.jl` that dispatch on
`BuilderLoadRequest` or `AbstractLoadRequest`: the return type depends on
user-supplied dispatch (`add_child`, `bind_basenode!`, `builder`) that cannot
be expressed without adding a second type parameter to `BuilderLoadRequest`.
That redesign would require `Base.return_types` introspection (internal API) at
load time, or a new user-facing keyword — high cost, low benefit given that
`materialized_handles::Vector{Any}` is already in the construction hot path.

**Decision**: leave those overloads **unannotated** (not `::Any`). Only the
`NodeTypeLoadRequest{NodeT}` overload of `emit_basenode` can be annotated
`::NodeT`, because line 551 performs an `isa NodeT` check before returning.

---

## Tasks

### 1. Fix dead-branch defect in `src/views.jl` and add regression test

**Type**: WRITE + TEST
**Output**: `Base.getproperty` dot-notation column access works correctly for
`NodeRowRef` and `EdgeRowRef`; new tests in `test/core/row_references.jl` fail
on the unpatched code and pass after the fix; full test suite remains green
**Depends on**: none

`src/views.jl` lines 111–123 contain a correctness defect: both
`Base.getproperty` overloads guard with an `if nm === :table || nm === :nodekey`
/ `if nm === :table || nm === :edgekey` branch, but the else branch is identical
to the true branch — both call `getfield`. The guard was intended to short-circuit
struct field access and delegate everything else to the column accessor, but the
delegation was never written.

Apply the correct fix to both overloads:

For `NodeRowRef` (line 111):
- True branch (unchanged): `return getfield(rowref, nm)`
- Else branch (fix): `return Tables.getcolumn(getfield(rowref, :table), nm)[getfield(rowref, :nodekey)]`

For `EdgeRowRef` (line 118):
- True branch (unchanged): `return getfield(rowref, nm)`
- Else branch (fix): `return Tables.getcolumn(getfield(rowref, :table), nm)[getfield(rowref, :edgekey)]`

Do not add a return type annotation to `Base.getproperty` — the return type is
determined by the column's element type and is not statically expressible here.

In `test/core/row_references.jl`: the existing tests cover `.nodekey`,
`.edgekey` (struct fields), and explicit `Tables.getcolumn` calls, but never
test dot-notation access for a non-struct-field column. Add at least one test
for each of `NodeRowRef` and `EdgeRowRef` that accesses a data column via dot
notation (e.g., `rowref.label` or `rowref.posterior`, or whatever column names
the test fixtures already expose). The new tests must exercise the path that was
broken: if the defect is not fixed, they must fail.

---

### 2. Fix `ext/MetaGraphsNextAbstractTreesIO.jl`: bare `using` and return type annotations

**Type**: WRITE
**Output**: file compiles without warnings; all `using` statements are in
selective form; all six extension-protocol overrides have return type
annotations; full test suite remains green
**Depends on**: none

**Bare `using` fix** (lines 3–5). Every access in this file is already
qualified through the module name. The minimal selective form is correct:
- `using AbstractTrees` → `using AbstractTrees: AbstractTrees`
- `using LineagesIO` → `using LineagesIO: LineagesIO`
- `using MetaGraphsNext` → `using MetaGraphsNext: MetaGraphsNext`

**Return type annotations**. All functions already have `where {ViewT <:
ConcreteMetaGraphsNextTreeView}` in their type parameter scope:
- `AbstractTrees.children(treeview::ViewT) where {ViewT <: ...}` → add `::Vector{ViewT}`
- `AbstractTrees.NodeType(::Type{ViewT}) where {ViewT <: ...}` → add `::AbstractTrees.HasNodeType`
- `AbstractTrees.nodetype(::Type{ViewT}) where {ViewT <: ...}` → add `::Type{ViewT}`
- `AbstractTrees.ChildIndexing(::Type{ViewT}) where {ViewT <: ...}` → add `::AbstractTrees.IndexedChildren`
- `AbstractTrees.childtype(::Type{ViewT}) where {ViewT <: ...}` → add `::Type{ViewT}`
- `AbstractTrees.childrentype(::Type{ViewT}) where {ViewT <: ...}` → add `::Type{Vector{ViewT}}`

---

### 3. Fix `ext/PhyloNetworksIO.jl`: bare `using` and return type annotations

**Type**: WRITE
**Output**: file compiles without warnings; all `using` statements are in
selective form; seven protocol overrides have return type annotations; full test
suite remains green
**Depends on**: none

**Bare `using` fix** (lines 3–5). All three packages are accessed only through
qualified names in this file:
- `using LineagesIO` → `using LineagesIO: LineagesIO`
- `using PhyloNetworks` → `using PhyloNetworks: PhyloNetworks`
- `using Tables` → `using Tables: Tables`

**Return type annotations**:

- `build_graph_cursor(target::TargetT, ...) where {TargetT}` (line 335):
  add `::PhyloNetworksBuildCursor{TargetT}`

- `LineagesIO.emit_basenode(::NodeTypeLoadRequest{PhyloNetworks.HybridNetwork}, ...)`
  (line 354): add `::PhyloNetworksBuildCursor{Nothing}` — this overload always
  passes `nothing` as the target argument to `build_graph_cursor`

- `LineagesIO.bind_basenode!(target::PhyloNetworks.HybridNetwork, ...)` (line 364):
  add `::PhyloNetworksBuildCursor{PhyloNetworks.HybridNetwork}`

- `child_cursor(parent::PhyloNetworksBuildCursor, ...)` (line 425): narrow
  the parameter to `parent::PhyloNetworksBuildCursor{TargetT}`, add
  `where {TargetT}` to the signature, annotate `::PhyloNetworksBuildCursor{TargetT}`

- Single-parent `LineagesIO.add_child(parent::PhyloNetworksBuildCursor, ...)`
  (line 439): same as `child_cursor` — add `{TargetT}` to the parameter type and
  `where {TargetT}` to the signature, annotate `::PhyloNetworksBuildCursor{TargetT}`

- Multi-parent `LineagesIO.add_child(parent_collection::AbstractVector{<:PhyloNetworksBuildCursor}, ...)`
  (line 620): annotate `::PhyloNetworksBuildCursor` (unparameterized). The
  collection type uses a covariant bound (`<:`) so `TargetT` cannot be extracted
  safely at the method level without narrowing dispatch. This is consistent with
  the existing `::PhyloNetworksBuildCursor` annotation on
  `ensure_shared_cursor_owner` in this file.

- `LineagesIO.finalize_graph!(cursor::PhyloNetworksBuildCursor)` (line 699):
  add `::PhyloNetworks.HybridNetwork`. Both return paths (`target === nothing`
  returns `graph`, otherwise returns `target`) return a value of type
  `PhyloNetworks.HybridNetwork`.

---

### 4. Add return type annotations to `ext/MetaGraphsNextIO.jl`

**Type**: WRITE
**Output**: eight extension-protocol overrides have return type annotations;
full test suite remains green
**Depends on**: none

Files touched: `ext/MetaGraphsNextIO.jl`.

**Annotations** (none of these functions currently have a return type
annotation):

- `LineagesIO.emit_basenode(::NodeTypeLoadRequest{<:MetaGraph}, ...)` (line 307):
  add `::MetaGraphsNextBuildCursor`. The unparameterized form is consistent with
  the existing `::MetaGraph` annotation convention already used in this file
  (e.g., `default_metagraph()::MetaGraph` at line 115).

- `LineagesIO.bind_basenode!(graph::GraphT, ...) where {GraphT <: MetaGraph}`
  (line 322): add `::MetaGraphsNextBuildCursor{GraphT}`

- Single-parent `LineagesIO.add_child(parent::MetaGraphsNextBuildCursor{GraphT}, ...) where {GraphT <: MetaGraph}`
  (line 337): add `::MetaGraphsNextBuildCursor{GraphT}`

- Probe shim `LineagesIO.add_child(::AbstractVector{<:MetaGraph}, ...)`
  (line 364): **leave unannotated**. The body unconditionally calls `error(...)`;
  the function never returns. `::Union{}` would be technically correct but is
  unusual and adds no documentation value for a shim that must never execute.

- Multi-parent `LineagesIO.add_child(parents::AbstractVector{MetaGraphsNextBuildCursor{GraphT}}, ...) where {GraphT <: MetaGraph}`
  (line 383): add `::MetaGraphsNextBuildCursor{GraphT}`. This overload's
  collection type is already invariant (exact `MetaGraphsNextBuildCursor{GraphT}`,
  no `<:`), so `GraphT` is unambiguous in the where clause.

- `LineagesIO.finalize_graph!(cursor::MetaGraphsNextBuildCursor)` (line 410):
  change the parameter type to `cursor::MetaGraphsNextBuildCursor{GraphT}`, add
  `where {GraphT}` to the signature, annotate `::GraphT`. The return is
  `cursor.graph` which is of type `GraphT`.

- `LineagesIO.MetaGraphsNextTreeView(asset::LineageGraphAsset{GraphT,...})` (line 431):
  add `::ConcreteMetaGraphsNextTreeView`

- `LineagesIO.MetaGraphsNextTreeView(graph::GraphT, node_table::NodeTableT, edge_table::EdgeTableT) where {...}`
  (line 452): add `::ConcreteMetaGraphsNextTreeView`

---

### 5. Add return type annotations to `src/construction.jl`

**Type**: WRITE
**Output**: three functions have return type annotations; all other `emit_*`
functions remain unannotated (not `::Any`); full test suite remains green
**Depends on**: none

Only three functions in `construction.jl` can be annotated with a useful
concrete type without redesigning `BuilderLoadRequest`. All other `emit_*`
overloads must be left unannotated.

**Add annotations**:

- `emit_basenode(request::NodeTypeLoadRequest{NodeT}, ...) where {NodeT}` (line 535):
  add `::NodeT`. This is correct because line 551 performs
  `basenode_handle isa NodeT || throw(...)` before returning — after that check
  the return type is proven to be `NodeT`.

- `builder_parent_argument_type(method::Method)` (line 900): add `::Type`.
  Both return paths return a `Type` value: the literal `Any` (which is a
  `Type`) or `signature_parameters[2]` (also a `Type`).

- `build_multi_parent_protocol_sample(graph_asset::LineageGraphAsset)` (line 264):
  add `::Union{Nothing, NamedTuple}`. One return path returns `nothing`; the
  other returns a named tuple of construction data.

**Leave unannotated** (not `::Any`) — these dispatch to user-supplied callbacks
whose return types are not known at the library level:
- `emit_basenode(::BasenodeLoadRequest, ...)` (line 555)
- `emit_basenode(::BuilderLoadRequest, ...)` (line 566)
- `emit_childnode(::AbstractLoadRequest, ...)` (line 585)
- `emit_single_parent_childnode(::NodeTypeLoadRequest, ...)` (line 645)
- `emit_single_parent_childnode(::BasenodeLoadRequest, ...)` (line 668)
- `emit_single_parent_childnode(::BuilderLoadRequest, ...)` (line 691)
- `emit_multi_parent_childnode(::NodeTypeLoadRequest, ...)` (line 714)
- `emit_multi_parent_childnode(::BasenodeLoadRequest, ...)` (line 747)
- `emit_multi_parent_childnode(::BuilderLoadRequest, ...)` (line 780)

---

### 6. Full green-state pass

**Type**: TEST
**Output**: all tests pass
**Depends on**: 1, 2, 3, 4, 5

Run the full test suite from the test project environment:

```
julia --project=test -e 'using Pkg; Pkg.test("LineagesIO")'
```

All tests must pass, including the new `NodeRowRef`/`EdgeRowRef` dot-notation
regression tests added in task 1. Report the full output — do not summarize.
If any test fails, diagnose and fix before declaring this task done.
