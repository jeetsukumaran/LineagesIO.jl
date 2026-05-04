# STYLE-julia.md compliance audit — 2026-05-03

## Scope

All Julia source files tracked by git. Each finding cites the specific rule
section in `STYLE-julia.md` and the required fix.

Authority: `STYLE-julia.md` (LineagesIO.jl repo-local, date-revised 2026-04-24).
Section numbers below refer to that document.

Files audited (46 total): same set as the docstring audit.

## Inventory

### src/core_types.jl

| Line | Name | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 1–5 | All five `const` aliases | No type annotations on the RHS values (they are literal constants, so this is acceptable); no docstrings (covered separately in docstring audit). No style violations beyond missing docs. | — | No style action needed. |

No style violations in this file beyond missing docstrings.

### src/tables.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 55 | `Tables.columns(table)::AbstractLineageTable = table` | Return type annotation uses the abstract type `AbstractLineageTable` where the concrete type is always `typeof(table)`. Not wrong, but the declared return type is looser than necessary, losing concrete type information for callers. | §1.12 (return type annotations must be correct and informative) | Consider changing to `Tables.columns(table::T)::T where {T <: AbstractLineageTable} = table` to preserve the concrete type. |
| 63–95 | `SourceTable(columns)`, `CollectionTable(columns)`, `GraphTable(columns)`, `NodeTable(columns)`, `EdgeTable(columns)` — single-argument constructors | Return type annotations are absent on all five inner constructors. | §1.13 (non-trivial functions require explicit return type annotations) | Add return type annotations: `::SourceTable`, `::CollectionTable`, etc. |
| 185–187 | `lineagetable_nrows(::AbstractLineageTable)` | Present. Has `::Int` return type. No violation. | — | No action. |

No bare `using` violations; the file uses only types and functions already in scope from `src/tables.jl`.

### src/views.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 111–116 | `Base.getproperty(rowref::NodeRowRef, nm::Symbol)` | Dead-code branch: the `if nm === :table || nm === :nodekey` branch and the fallthrough `else`-equivalent both execute `getfield(rowref, nm)` identically. The if-body is never reached for a different code path than the else body. The branch is never executed meaningfully; the entire body is equivalent to `return getfield(rowref, nm)`. This is both a logic bug and a KISS/POLA violation. | §1.16.3 (KISS — no dead branches), §1.16.4 (POLA — surprising identity of branches) | Replace with `return getfield(rowref, nm)` unconditionally (since `nm` is always either a field name or falls through to `getfield`). If the intent was to delegate to `Tables.getcolumn` for annotation columns, the correct implementation is `nm === :table \|\| nm === :nodekey ? getfield(rowref, nm) : Tables.getcolumn(getfield(rowref, :table), nm)[getfield(rowref, :nodekey)]`. Clarify intent and implement correctly. |
| 118–123 | `Base.getproperty(rowref::EdgeRowRef, nm::Symbol)` | Same dead-branch defect as the `NodeRowRef` overload above. | §1.16.3, §1.16.4 | Same fix as above, applied to `EdgeRowRef`. |
| 151–160 | `node_property(node_table, nodekey, propertykey)` | Missing argument type annotation on `propertykey`. The type is `Symbol \| AbstractString \| other` (dispatched via `normalize_propertykey`), but the parameter has no annotation at all. | §1.12 (argument type annotations) | Add `propertykey::Union{Symbol, AbstractString}` or keep the dispatch open but annotate as `propertykey` with a note. At minimum annotate the concrete overloads of `normalize_propertykey`. |
| 169–178 | `edge_property(edge_table, edgekey, propertykey)` | Same missing `propertykey` type annotation as `node_property`. | §1.12 | Same fix. |

### src/construction.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 264–288 | `build_multi_parent_protocol_sample` | Missing return type annotation. The function returns either a `NamedTuple` or `nothing`, but the return type is not declared. | §1.13 | Add `::Union{Nothing, NamedTuple}` return type (or a more precise named-tuple type). |
| 555–563 | `emit_basenode(::BasenodeLoadRequest, ...)` | Missing return type annotation. The return type depends on the `bind_basenode!` contract and is always the `BasenodeT` type, but no annotation is present. | §1.13 | Add return type annotation. At minimum use the unparameterized form if the concrete type is dynamic. |
| 566–583 | `emit_basenode(::BuilderLoadRequest, ...)` | Missing return type annotation. | §1.13 | Same fix. |
| 585–626 | `emit_childnode` | Missing return type annotation. Returns the child handle, type determined by dispatch. | §1.13 | Add return type annotation. |
| 645–666 | `emit_single_parent_childnode(::NodeTypeLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 668–689 | `emit_single_parent_childnode(::BasenodeLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 691–712 | `emit_single_parent_childnode(::BuilderLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 714–745 | `emit_multi_parent_childnode(::NodeTypeLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 747–778 | `emit_multi_parent_childnode(::BasenodeLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 780–811 | `emit_multi_parent_childnode(::BuilderLoadRequest, ...)` | Missing return type annotation. | §1.13 | Add return type annotation. |
| 885–898 | `build_builder_parent_collection_sample` | Return type annotation `::AbstractVector` is present. No violation. | — | No action. |
| 900–904 | `builder_parent_argument_type` | Missing return type annotation. Returns `Any` or a type extracted from a method signature; the return type is always a `Type` value but is not annotated. | §1.13 | Add `::Any` or a more specific type annotation. |
| 933–936 | `builder_parent_argument_types` | Has `::Vector{Any}` return type annotation. No violation. | — | No action. |

### src/newick_format.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 10–14 | `mutable struct NewickParserState` | `mutable struct` used without a justification comment. The parser advances `index` in-place; mutation is deliberate but undocumented. | §1.4 (immutability by default; justify every `mutable struct`) | Add a comment above the struct explaining why mutability is required: the parser must advance `index` in-place during recursive descent. |
| 16–19 | `mutable struct HybridOccurrenceState` | `mutable struct` used without a justification comment. Both fields are incremented during parsing. | §1.4 | Add a comment explaining why mutability is required: occurrence and child-owner counts accumulate across multiple parse calls. |
| 21–34 | `mutable struct NewickGraphBuildState` | `mutable struct` used without a justification comment. All vector fields are `push!`-ed during the graph-build pass. | §1.4 | Add a comment explaining why mutability is required: the struct accumulates all node/edge data during a single traversal of the parsed Newick tree. |
| 1–8 | `struct ParsedNewickOccurrence` | Immutable struct with a `children::Vector{ParsedNewickOccurrence}` field. The outer struct is immutable (good) but the vector field is mutable. This is a common Julia pattern for recursive structures; no violation. | — | No action. |
| All functions | No return type annotations visible on any Newick-format functions in the portions read | Multiple functions throughout `newick_format.jl` lack return type annotations. At minimum the public-facing `build_newick_store` overloads have `::LineageGraphStore` annotations (good). Internal functions such as `parse_newick_source`, `parse_newick_node`, annotation extractors, and hybrid-resolution helpers do not. | §1.13 | Add `::ReturnType` annotations to all non-trivial internal functions. |

### src/alife_format.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 5–10 | `struct ParsedAlifeRow` | Immutable; all fields typed. No violation. | — | No action. |
| 12–80 | `build_alife_store`, `build_alife_store_from_table`, `build_alife_store_from_rows` | All have `::LineageGraphStore` return type annotations. No violation. | — | No action. |
| Remaining functions | Internal functions throughout `alife_format.jl` | Most internal helpers lack return type annotations. | §1.13 | Add `::ReturnType` annotations to all non-trivial internal functions. `load_alife_table` has a full docstring and return type annotation (good). |

### src/fileio_integration.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 21 | `const _FILEIO_REGISTERED = Ref(false)` | Module-level mutable state (`Ref{Bool}`) without justification. Mutation is used as a registration guard in `__init__`. This is the sole exception in an otherwise stateless module; the necessity is not documented. | §1.9 (statelessness; no global mutable state without justification) | Add an inline comment explaining why this `Ref` is necessary: it guards against double-registration of FileIO formats if `__init__` is ever called more than once (e.g., via `__precompile__` edge cases). |
| 35–48 | `fileio_load` (all four overloads) | All four overloads have `::LineageGraphStore` return type annotations. No violation. | — | No action. |
| 65–105 | `assert_supported_load_keywords`, `build_load_request` (four overloads), `normalize_source_path` (two overloads), `validate_extension_load_target` (two overloads) | All present functions have return type annotations. No violation. | — | No action. |

No bare `using` violations. The module uses `import FileIO` and `import Tables` (qualified imports, not bare `using`).

### ext/MetaGraphsNextIO.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 3–14 | `using LineagesIO: LineagesIO, EdgeRowRef, ...` | **Not a violation.** This is the correct selective-import form (`using Package: names`), compliant with §5 anti-patterns. | — | No action. |
| 13–14 | `using MetaGraphsNext: MetaGraph, MetaGraphsNext` and `using MetaGraphsNext.Graphs: SimpleDiGraph, add_edge!, add_vertex!, is_directed, nv` | **Not a violation.** Both are selective imports. | — | No action. |
| 307–316 | `LineagesIO.emit_basenode(::NodeTypeLoadRequest{<:MetaGraph}, ...)` | Missing return type annotation. The return type is always `MetaGraphsNextBuildCursor{typeof(graph)}` but is not declared. | §1.13 | Add `::MetaGraphsNextBuildCursor` return type. |
| 322–331 | `LineagesIO.bind_basenode!(::MetaGraph, ...)` | Missing return type annotation. Always returns `MetaGraphsNextBuildCursor{GraphT}`. | §1.13 | Add `::MetaGraphsNextBuildCursor{GraphT}` return type. |
| 337–350 | `LineagesIO.add_child(parent::MetaGraphsNextBuildCursor, ...)` (single-parent) | Missing return type annotation. Always returns `MetaGraphsNextBuildCursor{GraphT}`. | §1.13 | Add `::MetaGraphsNextBuildCursor{GraphT}` return type. |
| 364–377 | `LineagesIO.add_child(::AbstractVector{<:MetaGraph}, ...)` (probe shim) | Missing return type annotation. The body always calls `error(...)` so it never returns, but a return type of `Union{}` or `Nothing` should still be declared to document the intent. | §1.13 | Add `::Union{}` (or `::Nothing`) return type. |
| 383–404 | `LineagesIO.add_child(parents::AbstractVector{MetaGraphsNextBuildCursor{GraphT}}, ...)` (multi-parent) | Missing return type annotation. Always returns `MetaGraphsNextBuildCursor{GraphT}`. | §1.13 | Add `::MetaGraphsNextBuildCursor{GraphT}` return type. |
| 410–412 | `LineagesIO.finalize_graph!(::MetaGraphsNextBuildCursor)` | Missing return type annotation. Always returns the `cursor.graph` (a `GraphT <: MetaGraph`). | §1.13 | Add `::GraphT where {GraphT <: MetaGraph}` or a concrete form. |
| 431–450 | `LineagesIO.MetaGraphsNextTreeView(asset::LineageGraphAsset{<:MetaGraph, ...})` | Missing return type annotation. Always returns `ConcreteMetaGraphsNextTreeView`. | §1.13 | Add `::ConcreteMetaGraphsNextTreeView` return type. |
| 452–472 | `LineagesIO.MetaGraphsNextTreeView(graph, node_table, edge_table)` | Missing return type annotation. | §1.13 | Add `::ConcreteMetaGraphsNextTreeView` return type. |

### ext/MetaGraphsNextAbstractTreesIO.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 3 | `using AbstractTrees` | **Bare `using` — no names listed.** This imports all exported names from `AbstractTrees` into the extension module without explicit enumeration, violating the principle of least privilege. | §5 anti-patterns table ("bare `using Package` in library code"), §1.16.6 (POLP) | Replace with `using AbstractTrees: AbstractTrees, children, NodeType, nodetype, ChildIndexing, childtype, childrentype, HasNodeType, IndexedChildren` (enumerate the names actually used). |
| 4 | `using LineagesIO` | **Bare `using` — no names listed.** | §5 anti-patterns table, §1.16.6 | Replace with `using LineagesIO: LineagesIO` (only the module itself is needed; all accesses are qualified). |
| 5 | `using MetaGraphsNext` | **Bare `using` — no names listed.** | §5 anti-patterns table, §1.16.6 | Replace with `using MetaGraphsNext: MetaGraphsNext` (only qualified access via `MetaGraphsNext.code_for`, `MetaGraphsNext.label_for`, `MetaGraphsNext.Graphs.outneighbors` is needed). |
| 15–36 | `AbstractTrees.children(::ConcreteMetaGraphsNextTreeView)` | Missing return type annotation. Always returns `Vector{ViewT}`. | §1.13 | Add `::Vector{ViewT}` return type. |
| 38–42 | `AbstractTrees.NodeType`, `AbstractTrees.ChildIndexing`, `AbstractTrees.nodetype`, `AbstractTrees.childtype`, `AbstractTrees.childrentype` | Missing return type annotations on all five one-line trait methods. | §1.13 | Add return type annotations: `::AbstractTrees.HasNodeType`, `::AbstractTrees.IndexedChildren`, `::Type{ViewT}`, `::Type{ViewT}`, `::Type{Vector{ViewT}}` respectively. |

### ext/PhyloNetworksIO.jl

| Line | Name/construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|
| 3 | `using LineagesIO` | **Bare `using` — no names listed.** | §5 anti-patterns table, §1.16.6 | Replace with `using LineagesIO: LineagesIO, EdgeRowRef, EdgeWeightType, LineageGraphAsset, NodeRowRef, NodeTable, EdgeTable, StructureKeyType, ...` (enumerate all names actually used). |
| 4 | `using PhyloNetworks` | **Bare `using` — no names listed.** | §5 anti-patterns table, §1.16.6 | Replace with `using PhyloNetworks: PhyloNetworks, HybridNetwork, Node, Edge, ...` (enumerate names used). |
| 5 | `using Tables` | **Bare `using` — no names listed.** | §5 anti-patterns table, §1.16.6 | Replace with `using Tables: Tables, getcolumn, columnnames` or equivalent. |
| 7–13 | `mutable struct PhyloNetworksBuildState` | `mutable struct` used without a justification comment. All fields are mutated during construction (`ensure_edge_counts_initialized!`, `register_node!`, `register_edge!`, `edge_counts_initialized` flag). | §1.4 | Add a comment explaining why mutability is required: the struct accumulates all PhyloNetworks nodes/edges and edge-count statistics lazily during construction. |
| 335–352 | `build_graph_cursor` | Missing return type annotation. Always returns `PhyloNetworksBuildCursor`. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| 354–362 | `LineagesIO.emit_basenode(::NodeTypeLoadRequest{HybridNetwork}, ...)` | Missing return type annotation. Always returns `PhyloNetworksBuildCursor`. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| 364–372 | `LineagesIO.bind_basenode!(::HybridNetwork, ...)` | Missing return type annotation. Always returns `PhyloNetworksBuildCursor`. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| 425–437 | `child_cursor` | Missing return type annotation. Always returns `PhyloNetworksBuildCursor`. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| 439–448+ | `LineagesIO.add_child(parent::PhyloNetworksBuildCursor, ...)` (single-parent) | Missing return type annotation. Always returns `PhyloNetworksBuildCursor`. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| (multi-parent `add_child`) | `LineagesIO.add_child(parents::AbstractVector{<:PhyloNetworksBuildCursor}, ...)` | Missing return type annotation. | §1.13 | Add `::PhyloNetworksBuildCursor` return type. |
| (`finalize_graph!`) | `LineagesIO.finalize_graph!(::PhyloNetworksBuildCursor)` | Missing return type annotation. Returns a `PhyloNetworks.HybridNetwork`. | §1.13 | Add `::PhyloNetworks.HybridNetwork` return type. |
| (`graph_from_finalized`) | `LineagesIO.graph_from_finalized(::PhyloNetworks.HybridNetwork)` | Missing return type annotation. | §1.13 | Add `::PhyloNetworks.HybridNetwork` return type. |
| (`basenode_from_finalized`) | `LineagesIO.basenode_from_finalized(::PhyloNetworksBuildCursor)` | Missing return type annotation. Returns a `PhyloNetworks.Node`. | §1.13 | Add `::PhyloNetworks.Node` return type. |

### test/runtests.jl and test files

| File | Line | Construct | Transgression | STYLE-julia.md ref | Required fix |
|---|---|---|---|---|---|
| `test/runtests.jl` | 1 | `using LineagesIO` | Bare `using` with no names listed. In test context this is common practice and not strictly prohibited; however, per §5 ("bare `using Package` in library code") the strictest reading covers all `.jl` files. In test files, convention typically allows bare `using`. | §5 (if applied to test code) | Low priority. If the project decides to enforce selective imports in tests, replace with `using LineagesIO: LineagesIO, ...`. Otherwise acceptable in test context. |
| `test/runtests.jl` | 2 | `using Tables` | Bare `using`. | §5 | Same as above. Low priority in test context. |
| `test/extensions/metagraphsnext_abstracttrees.jl` | 1–2 | `using AbstractTrees`, `using MetaGraphsNext` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/metagraphsnext_network_rejection.jl` | 1 | `using MetaGraphsNext` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/metagraphsnext_simple_newick.jl` | 1 | `using MetaGraphsNext` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/metagraphsnext_supplied_basenode.jl` | 1 | `using MetaGraphsNext` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/metagraphsnext_tables_after_load.jl` | 1 | `using MetaGraphsNext` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_activation.jl` | 13 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_annotation_paths.jl` | 1 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_newick_networks.jl` | 1 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_rejection_paths.jl` | 1 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_tables_after_load.jl` | 1 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/extensions/phylonetworks_tree_compatible_newick.jl` | 1 | `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |
| `test/integration/phylonetworks_soft_release.jl` | 1–2 | `using FileIO`, `using PhyloNetworks` | Bare `using`. | §5 | Low priority in test context. |

### Example files

`examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`,
`examples/src/phylonetworks_mwe02.jl` all use bare `using LineagesIO`,
`using Tables`, `using PhyloNetworks`, etc. These are scripts, not library
modules; bare `using` in scripts is idiomatic Julia. No violations in example
scripts.

## Cross-cutting priority list

### Priority 1 — critical (library code, violates named rules)

| File | Issue |
|---|---|
| `ext/MetaGraphsNextAbstractTreesIO.jl` lines 3–5 | Three bare `using` statements in library code. |
| `ext/PhyloNetworksIO.jl` lines 3–5 | Three bare `using` statements in library code. |
| `src/views.jl` lines 111–116, 118–123 | Dead-code branches in `Base.getproperty` for `NodeRowRef` and `EdgeRowRef`. Both branches execute `getfield(rowref, nm)` identically; the if-condition is never meaningful. This is also a latent correctness bug: if the intent was to dispatch annotation lookups through `Tables.getcolumn`, the current code silently does the wrong thing. |

### Priority 2 — high (missing return type annotations on exported or extension-protocol functions)

| File | Functions |
|---|---|
| `ext/MetaGraphsNextIO.jl` | `emit_basenode`, `bind_basenode!`, `add_child` (×3), `finalize_graph!`, `MetaGraphsNextTreeView` (×2) |
| `ext/PhyloNetworksIO.jl` | `build_graph_cursor`, `emit_basenode`, `bind_basenode!`, `child_cursor`, `add_child` (×2), `finalize_graph!`, `graph_from_finalized`, `basenode_from_finalized` |
| `ext/MetaGraphsNextAbstractTreesIO.jl` | `children`, all five trait methods |
| `src/construction.jl` | `emit_basenode` (×2), `emit_childnode`, `emit_single_parent_childnode` (×3), `emit_multi_parent_childnode` (×3), `builder_parent_argument_type` |
| `src/views.jl` | `node_property` and `edge_property` missing `propertykey` argument type annotation |

### Priority 3 — medium (mutable structs without justification comments)

| File | Structs |
|---|---|
| `src/newick_format.jl` | `NewickParserState`, `HybridOccurrenceState`, `NewickGraphBuildState` |
| `ext/PhyloNetworksIO.jl` | `PhyloNetworksBuildState` |

### Priority 4 — low (module-level mutable state without justification)

| File | Name |
|---|---|
| `src/fileio_integration.jl` | `_FILEIO_REGISTERED` |

### Priority 5 — low (bare `using` in test files)

Test files uniformly use bare `using`. If project policy is to enforce
selective imports everywhere (including tests), all test `using` statements
need to be updated. Current STYLE-julia.md §5 scopes the prohibition to
"library code"; test files are a judgment call.
