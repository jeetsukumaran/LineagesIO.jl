# Docstring audit — 2026-05-03

## Scope

All Julia source files tracked by git. Covers: missing docstrings on exported
names, missing docstrings on non-trivial internal names, and deficient
(minimal, stale, or misleading) docstrings on present items.

Authority: CLAUDE.md §6 ("Every function must have a docstring/doccomment"),
§2 ("Every exported function requires a docstring").

Files audited (46 total):

- `src/LineagesIO.jl`
- `src/core_types.jl`
- `src/tables.jl`
- `src/views.jl`
- `src/construction.jl`
- `src/newick_format.jl`
- `src/alife_format.jl`
- `src/fileio_integration.jl`
- `ext/MetaGraphsNextIO.jl`
- `ext/MetaGraphsNextAbstractTreesIO.jl`
- `ext/PhyloNetworksIO.jl`
- `docs/make.jl`
- `test/runtests.jl` and all test files under `test/`
- `examples/` files

## Inventory

### src/core_types.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1 | `StructureKeyType` | Exported type alias; no docstring. | Add docstring: what it represents, why `Int`, that it is the authoritative integer key for nodes and edges. |
| 3 | `EdgeWeightType` | Type alias used in public API signatures; no docstring. | Add docstring explaining the `Union{Nothing, Float64}` contract: `nothing` means no weight specified. |
| 4 | `NodePropertyValueType` | Type alias; no docstring. | Add docstring: return type of `node_property`; lists the permitted value types. |
| 5 | `EdgePropertyValueType` | Type alias; no docstring. | Add docstring: return type of `edge_property`; lists the permitted value types. |

`OptionalString` (line 2) is not exported and is a simple internal alias; acceptable without a docstring.

### src/tables.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1 | `AbstractLineageTable` | Exported abstract type (base of all five table types); no docstring. | Add docstring explaining the abstract base, Tables.jl column-access contract, and what concrete subtypes implement. |
| 53–61 | `Tables.istable`, `Tables.columnaccess`, `Tables.columns`, `Tables.schema`, `Tables.columnnames`, `Tables.getcolumn` (multiple), `Tables.materializer` | One-line method overrides implementing the Tables.jl column-access interface; no docstrings. These are well-known interface methods and brief docstrings or a group comment would suffice. | Add a single-line comment or brief docstring on the block noting that these implement the `Tables.jl` column-access interface for `AbstractLineageTable`. |
| 63–95 | `SourceTable(columns)`, `CollectionTable(columns)`, `GraphTable(columns)`, `NodeTable(columns)`, `EdgeTable(columns)` | Internal single-argument constructors; no docstrings. They enforce invariants (sequential key order, uniform column lengths) that are not visible from the type docstrings. | Add one-line docstrings noting the invariant each constructor enforces. |
| 97–183 | `SourceTable(; ...)`, `CollectionTable(; ...)`, `GraphTable(; ...)`, `NodeTable(; ...)`, `EdgeTable(; ...)` | Keyword-argument public constructors for all five table types; no docstrings. These are the primary construction surfaces; their parameters, accepted types, and normalization behavior are undocumented. | Add docstrings covering parameters, accepted element types, and normalization behavior (e.g. `normalize_optional_string_vector`, sequential key validation). |
| 185–187 | `lineagetable_nrows(::AbstractLineageTable)` | Internal helper; no docstring. | Add one-line docstring: returns row count; validates uniform column lengths. |
| 189–195 | `lineagetable_nrows(::NamedTuple)` | Internal helper; no docstring. | Add one-line docstring. |
| 197–199 | `lineage_schema` | Internal helper; no docstring. | Add one-line docstring. |
| 201–203 | `normalize_optional_string_vector` | Internal helper; no docstring. | Add one-line docstring: converts an `AbstractVector` to `Vector{OptionalString}`. |
| 205–215 | `normalize_edgeweight_vector` | Internal helper; no docstring. | Add one-line docstring: converts an `AbstractVector` to `Vector{EdgeWeightType}`. |
| 217–234 | `normalize_annotation_columns` | Internal helper; no docstring. | Add one-line docstring: validates annotation columns contain `Union{Nothing, String}` values only. |
| 236–240 | `merge_table_columns` | Internal helper; no docstring. | Add one-line docstring: merges structural and annotation column tuples, raising on name conflicts. |

### src/views.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 27–29 | `GraphAssetIterator` | Exported struct; no docstring. The type is an opaque wrapper around the internal `graph_assets` vector, needed for lazy iteration. Its purpose, laziness guarantees, and iteration contract are completely undocumented. | Add docstring explaining it is a lazy iterator of `LineageGraphAsset` values returned from `LineageGraphStore.graphs`; document that it is not an `AbstractVector`. |
| 51–72 | `LineageGraphStore(source_table, collection_table, graph_table, graphs)` | Internal constructor; no docstring. | Add one-line docstring: constructs a `LineageGraphStore` by extracting `GraphT` and `BasenodeT` from the element type of the `GraphAssetIterator`. |
| 74–76 | `Base.IteratorSize`, `Base.length`, `Base.eltype` for `GraphAssetIterator` | Interface methods; no docstrings. Acceptable without individual docstrings but no group comment present. | Add a brief comment grouping these as the `Base` iteration interface for `GraphAssetIterator`. |
| 78–81 | `Base.iterate(::GraphAssetIterator, state::Int)` | Internal method; no docstring. | Acceptable as a simple delegation. No action required. |
| 151–160 | `node_property(node_table, nodekey, propertykey)` | Exported function; no docstring. This is a primary user-facing API for property lookup by nodekey. | Add full docstring: purpose, parameters, return type, error conditions (`ArgumentError` on missing property or out-of-range nodekey). |
| 162–167 | `node_property(nodedata::NodeRowRef, propertykey)` | Exported overload on `NodeRowRef`; no docstring. | Add docstring: delegates to the table-based overload via the row reference. |
| 169–178 | `edge_property(edge_table, edgekey, propertykey)` | Exported function; no docstring. Primary user-facing API for edge property lookup. | Add full docstring matching the `node_property` pattern. |
| 180–185 | `edge_property(edgedata::EdgeRowRef, propertykey)` | Exported overload on `EdgeRowRef`; no docstring. | Add docstring. |
| 238–240 | `has_property` | Internal helper; no docstring. | Add one-line docstring. |
| 242–251 | `normalize_propertykey` (three overloads) | Internal helpers; no docstrings. | Add one-line docstrings. |
| 254–258 | `assert_rowkey` | Internal helper; no docstring. | Add one-line docstring: validates that `rowkey` is within `[1, nrows]`. |

### src/construction.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1 | `AbstractLoadRequest` | Abstract type; no docstring. It is the discriminated-union root for all load surfaces. | Add docstring explaining it is the sealed hierarchy root for load-surface dispatch. |
| 3 | `TablesOnlyLoadRequest` | Internal struct; no docstring. | Add one-line docstring: signals a tables-only (no construction) load. |
| 5–7 | `NodeTypeLoadRequest{NodeT}` | Internal struct; no docstring. | Add one-line docstring: carries the `NodeT` used by the `add_child(::Nothing, ...)` basenode-construction path. |
| 9–11 | `BasenodeLoadRequest{BasenodeT}` | Internal struct; no docstring. | Add one-line docstring: carries the pre-allocated basenode instance for the supplied-basenode load path. |
| 13–15 | `BuilderLoadRequest{BuilderT}` | Internal struct; no docstring. | Add one-line docstring: carries the builder callback for the `builder = fn` load path. |
| 92–107 | `graph_requires_multi_parent` (two overloads) | Internal function; no docstring. | Add one-line docstring: returns `true` if any node in the edge table has more than one incoming edge. |
| 109–143 | `materialize_graphs` (three overloads) | Internal function; no docstring. | Add one-line docstrings per overload describing dispatch and contract differences (tables-only pass-through, single-graph restriction for `BasenodeLoadRequest`, uniform-type enforcement for the general case). |
| 145–189 | `validate_materialization_request` (five overloads) | Internal function; no docstring. | Add one-line docstrings per overload. |
| 191–209 | `validate_multi_parent_node_type_request` | Internal function; no docstring. | Add one-line docstring. |
| 211–229 | `validate_multi_parent_basenode_binding_request` | Internal function; no docstring. | Add one-line docstring. |
| 231–250 | `validate_multi_parent_builder_request` | Internal function; no docstring. | Add one-line docstring. |
| 252–262 | `first_multi_parent_nodekey` | Internal function; no docstring. | Add one-line docstring: returns the first nodekey with multiple incoming edges, or `nothing`. |
| 264–288 | `build_multi_parent_protocol_sample` | Internal function; no docstring. The return type is also missing (see style audit). It returns a `NamedTuple` or `nothing`, which is non-obvious. | Add docstring: purpose (builds probe arguments for multi-parent dispatch testing), return shape (named tuple of `child_nodekey`, `label`, `edgekeys`, `edgeweights`, `edgedata`, `nodedata`), or `nothing` if no multi-parent node exists. |
| 290–311 | `materialize_graph` | Internal function; no docstring. | Add one-line docstring: materializes one `LineageGraphAsset{Nothing, Nothing, ...}` into a construction-result asset. |
| 313–408 | `materialize_graph_basenode` | Internal function; no docstring. This is the core construction dispatcher (~95 lines). | Add docstring: purpose (drives the full construction protocol for one graph asset), the two code paths (single-parent recursive descent vs. multi-parent scheduler), and what it returns. |
| 410–421 | `build_child_edgekeys` | Internal function; no docstring. | Add one-line docstring. |
| 423–459 | `construct_single_parent_descendants!` | Internal function; no docstring. | Add one-line docstring: recursively dispatches single-parent construction events depth-first. |
| 461–483 | `build_graph_structure` | Internal function; no docstring. | Add one-line docstring: builds `child_nodekeys_by_parent` and `incoming_edgekeys_by_child` vectors from the edge table. |
| 485–497 | `validate_and_find_basenodekey` | Internal function; no docstring. | Add one-line docstring: asserts exactly one node with no incoming edges at `nodekey == 1`. |
| 499–512 | `maybe_queue_ready_node!` | Internal function; no docstring. | Add one-line docstring. |
| 514–523 | `all_parents_ready` | Internal function; no docstring. | Add one-line docstring. |
| 525–533 | `throw_impossible_materialization_schedule` | Internal function; no docstring. | Add one-line docstring. |
| 535–583 | `emit_basenode` (three overloads) | Internal function; no docstring. The `BasenodeLoadRequest` and `BuilderLoadRequest` overloads (lines 555, 566) are missing return type annotations. | Add one-line docstrings per overload. |
| 585–626 | `emit_childnode` | Internal function; no docstring. Missing return type. | Add one-line docstring. |
| 628–643 | `build_parent_collection` (two overloads) | Internal function; no docstring. | Add one-line docstrings. |
| 645–812 | `emit_single_parent_childnode` (three overloads), `emit_multi_parent_childnode` (three overloads) | Internal functions; no docstrings. | Add one-line docstrings per overload. |
| 813–833 | `ensure_multi_parent_protocol_applicable` (three overloads) | Internal functions; no docstrings. | Add one-line docstrings per overload. |
| 880–883 | `ensure_constructed_handle` | Internal function; no docstring. | Add one-line docstring. |
| 885–898 | `build_builder_parent_collection_sample` | Internal function; no docstring. | Add one-line docstring: constructs a typed parent-collection sample by inspecting the builder's method signatures. |
| 900–904 | `builder_parent_argument_type` | Internal function; no docstring. | Add one-line docstring. |
| 906–931 | `collect_builder_parent_handle_types!` | Internal function; no docstring. | Add one-line docstring. |
| 933–936 | `builder_parent_argument_types` | Internal function; no docstring. | Add one-line docstring. |
| 938–974 | `has_custom_multi_parent_add_child` | Internal function; no docstring. | Add docstring: purpose (tests whether a custom `add_child` multi-parent overload exists via `which()`), why the fallback comparison works. |

### src/newick_format.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1–8 | `ParsedNewickOccurrence` | Internal struct; no docstring. It is the recursive intermediate representation produced by the Newick parser. | Add docstring: describes it as the intermediate parsed Newick node; documents fields. |
| 10–14 | `NewickParserState` | `mutable struct`; no docstring. | Add docstring: describes it as per-parse mutable cursor into the Newick source text. |
| 16–19 | `HybridOccurrenceState` | `mutable struct`; no docstring. | Add docstring: per-hybrid-label occurrence tracking during parse. |
| 21–34 | `NewickGraphBuildState` | `mutable struct`; no docstring. | Add docstring: mutable accumulator for the graph-build pass that emits authoritative tables. |
| 36–81 | `build_newick_store` (two overloads) | Internal function; no docstring. | Add one-line docstrings per overload. |
| 83–100+ | `build_graph_asset` | Internal function; no docstring. | Add one-line docstring. |
| All remaining functions in `newick_format.jl` | ~30 internal functions | No docstrings on any. | Add one-line docstrings to all non-trivial functions (parser helpers, annotation extraction, hybrid resolution, table emission). One-line is sufficient for pure internal mechanics. |

### src/alife_format.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1 | `ALIFE_ID_COLUMN` | Internal constant; no docstring. | Add one-line docstring or inline comment: the authoritative column name for ALife organism IDs. |
| 2 | `ALIFE_ANCESTOR_LIST_COLUMN` | Internal constant; no docstring. | Add one-line docstring. |
| 3 | `ALIFE_ANCESTOR_ID_COLUMN` | Internal constant; no docstring. | Add one-line docstring. |
| 5–10 | `ParsedAlifeRow` | Internal struct; no docstring. | Add docstring: describes intermediate representation of one parsed ALife CSV row; documents fields. |
| 12–80 | `build_alife_store` (two overloads), `build_alife_store_from_table`, `build_alife_store_from_rows` | Internal functions; no docstrings. | Add one-line docstrings per overload/function. |
| Remaining functions | All other internal functions in `alife_format.jl` | No docstrings. | Add one-line docstrings to all non-trivial internal functions (`parse_alife_source`, `parse_alife_table`, `parse_alife_row`, `collect_alife_annotation_names`, `partition_alife_components`, `build_alife_graph_asset`, etc.). |

Note: `load_alife_table` has a comprehensive docstring (good). That is the only
function in this file with adequate documentation.

### src/fileio_integration.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 1 | `NewickFormat` | Internal constant aliasing a `FileIO.DataFormat`; no docstring. | Add one-line docstring parallel to `AlifeStandardFormat`: describes `.nwk`/`.newick`/`.tree`/`.tre`/`.trees` detection. |
| 2 | `AmbiguousTextFormat` | Internal constant; no docstring. | Add one-line docstring: used internally to detect `.txt` ambiguity and raise a user-facing disambiguation error. |
| 17 | `AmbiguousCSVFormat` | Internal constant; no docstring. | Add one-line docstring: used internally to detect `.csv` ambiguity. |
| 21 | `_FILEIO_REGISTERED` | Module-level mutable `Ref`; no docstring. | Add inline comment explaining it is a registration guard preventing double-registration of FileIO formats on `__init__`. |
| 23–33 | `register_newick_format!` | Internal function; no docstring. | Add one-line docstring: registers all LineagesIO formats with FileIO; idempotent via `_FILEIO_REGISTERED` guard. |
| 35–48 | `fileio_load` (four overloads: `File{Newick}`, `Stream{Newick}`, `File{AlifeStandard}`, `Stream{AlifeStandard}`) | Internal FileIO dispatch functions; no docstrings. These are the actual entry points invoked by `FileIO.load`. | Add one-line docstrings per overload documenting which format and which source kind (`File` vs `Stream`) each handles. |
| 65–68 | `assert_supported_load_keywords` | Internal helper; no docstring. | Add one-line docstring. |
| 70–89 | `build_load_request` (four overloads) | Internal dispatch; no docstrings. | Add one-line docstrings per overload. |
| 91–97 | `normalize_source_path` (two overloads) | Internal helpers; no docstrings. | Add one-line docstrings. |
| 99–105 | `validate_extension_load_target` (two overloads) | Internal extension point; no docstrings. These stubs are overridden by extensions (MetaGraphsNextIO, PhyloNetworksIO). The absence of a docstring hides the extension contract. | Add docstring on the base stub: explains this is the extension override point for validating construction targets before materialization. |

### ext/MetaGraphsNextIO.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 131 | `metagraph_label_type` | Internal helper; no docstring. | Add one-line docstring: extracts the `Label` type parameter from a `MetaGraph`. |
| 170–181 | `add_node_to_metagraph!(::MetaGraph{..., Nothing})` | Internal helper; no docstring. | Add one-line docstring. |
| 183–194 | `add_node_to_metagraph!(::MetaGraph{..., <:NodeRowRef})` | Internal helper; no docstring. | Add one-line docstring. |
| 203–216 | `add_edge_to_metagraph!(::MetaGraph{..., Nothing})` | Internal helper; no docstring. | Add one-line docstring. |
| 218–232 | `add_edge_to_metagraph!(::MetaGraph{..., Union{Nothing,Float64}})` | Internal helper; no docstring. | Add one-line docstring. |
| 234–248 | `add_edge_to_metagraph!(::MetaGraph{..., <:Real})` | Internal helper; no docstring. | Add one-line docstring. |
| 250–264 | `add_edge_to_metagraph!(::MetaGraph{..., <:EdgeRowRef})` | Internal helper; no docstring. | Add one-line docstring. |
| 270–295 | `LineagesIO.validate_extension_load_target` (three overloads in this extension) | Extension method overrides; no docstrings. | Add one-line docstrings per overload explaining which target type and graph-asset condition each guards. |
| 307–316 | `LineagesIO.emit_basenode(::NodeTypeLoadRequest{<:MetaGraph}, ...)` | Extension override; no docstring. The comment block above explains why this override exists; that explanation should appear in a docstring so it is visible from `?LineagesIO.emit_basenode`. | Add docstring. |
| 322–331 | `LineagesIO.bind_basenode!(::MetaGraph, ...)` | Extension override; no docstring. | Add one-line docstring. |
| 337–350 | `LineagesIO.add_child(parent::MetaGraphsNextBuildCursor, ...)` | Extension override (single-parent); no docstring. | Add one-line docstring. |
| 364–377 | `LineagesIO.add_child(::AbstractVector{<:MetaGraph}, ...)` | Probe-shim override; the function body calls `error(...)` explaining it must not be reached at runtime. That explanation should be a docstring, not just an error message. | Add docstring explaining the shim exists only to satisfy `which()` probing in `validate_multi_parent_node_type_request` and must never execute. |
| 383–404 | `LineagesIO.add_child(parents::AbstractVector{MetaGraphsNextBuildCursor}, ...)` | Extension override (multi-parent); no docstring. | Add one-line docstring. |
| 410–412 | `LineagesIO.finalize_graph!(::MetaGraphsNextBuildCursor)` | Extension override; no docstring. | Add one-line docstring: extracts and returns the completed `MetaGraph`. |
| 418–420 | `LineagesIO.graph_from_finalized(::MetaGraph)` | Extension override; no docstring. | Add one-line docstring. |
| 422 | `LineagesIO.basenode_from_finalized(::MetaGraph)` | Extension override; no docstring. | Add one-line docstring: returns `Symbol(1)` as the basenode label. |
| 431–450 | `LineagesIO.MetaGraphsNextTreeView(asset::LineageGraphAsset{<:MetaGraph, ...})` | Extension method; no docstring. | Add one-line docstring. |
| 452–472 | `LineagesIO.MetaGraphsNextTreeView(graph, node_table, edge_table)` | Extension method; no docstring. | Add one-line docstring. |

### ext/MetaGraphsNextAbstractTreesIO.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 15–36 | `AbstractTrees.children(::ConcreteMetaGraphsNextTreeView)` | Extension override; no docstring. | Add one-line docstring: returns child tree-view wrappers for all outgoing neighbors in the MetaGraph. |
| 38–42 | `AbstractTrees.NodeType`, `AbstractTrees.nodetype`, `AbstractTrees.ChildIndexing`, `AbstractTrees.childtype`, `AbstractTrees.childrentype` | AbstractTrees trait overrides; no docstrings. These are brief trait declarations; a group comment would suffice. | Add a comment grouping them as AbstractTrees trait implementations for `ConcreteMetaGraphsNextTreeView`. |

### ext/PhyloNetworksIO.jl

| Line | Name | Transgression | Required fix |
|---|---|---|---|
| 7–13 | `PhyloNetworksBuildState` | `mutable struct`; no docstring. | Add docstring: mutable construction accumulator tracking the HybridNetwork under construction and per-node/edge state needed for hybrid and leaf resolution. |
| 15–25 | `PhyloNetworksBuildCursor` | Internal struct; no docstring. | Add docstring: construction handle returned by `bind_basenode!` and `add_child`; carries the HybridNetwork, load target, current PhyloNetworks.Node, nodekey, and shared state. |
| 27–29 | `node_count` | Internal helper; no docstring. | Add one-line docstring. |
| 31–33 | `normalize_label` | Internal helper; no docstring. | Add one-line docstring. |
| 35–39 | `normalized_leaf_name` | Internal helper; no docstring. | Add one-line docstring: generates the `LineagesIO__unnamed_leaf__$(nodekey)` placeholder for unnamed leaf nodes required by PhyloNetworks. |
| 41–49 | `normalize_phylonetworks_node_name` | Internal helper; no docstring. | Add one-line docstring. |
| 51–56 | `normalize_edgeweight` | Internal helper; no docstring. | Add one-line docstring: maps `nothing` to `-1.0` (the PhyloNetworks sentinel for absent edge length). |
| 58–64 | `retained_edge_property_text` | Internal helper; no docstring. | Add one-line docstring. |
| 66–85 | `parse_retained_gamma_value` | Internal function; no docstring. | Add one-line docstring: parses and validates a retained `gamma` annotation value as `Float64 ∈ [0, 1]`. |
| 87–99 | `parse_retained_branch_role` | Internal function; no docstring. | Add one-line docstring. |
| 101–125 | `require_empty_hybridnetwork!` | Internal guard function; no docstring. | Add one-line docstring. |
| 127–192 | `validate_phylonetworks_graph_asset` | Internal validation function; no docstring. It enforces constraints specific to PhyloNetworks (≤2 parent edges per hybrid, gamma sum, branch-role counts). | Add docstring: what it validates, what it throws, and why these constraints exist. |
| 194–220 | `LineagesIO.validate_extension_load_target` (three overloads) | Extension overrides; no docstrings. | Add one-line docstrings per overload. |
| 222–233 | `build_phylonetworks_state` | Internal function; no docstring. | Add one-line docstring. |
| 235–248 | `ensure_edge_counts_initialized!` | Internal function; no docstring. | Add one-line docstring: lazily initializes per-node outgoing/incoming edge counts from the edge table on first call. |
| 250–255 | `node_is_leaf` | Internal helper; no docstring. | Add one-line docstring. |
| 257–262 | `node_is_hybrid` | Internal helper; no docstring. | Add one-line docstring. |
| 264–274 | `ensure_name_slot!` | Internal function; no docstring. | Add one-line docstring: ensures the `graph.names` vector is long enough to hold `node_number`. |
| 276–285 | `record_node_name!` | Internal function; no docstring. | Add one-line docstring. |
| 287–302 | `register_node!` | Internal function; no docstring. | Add one-line docstring. |
| 304–318 | `register_edge!` | Internal function; no docstring. | Add one-line docstring. |
| 320–333 | `build_basenode` | Internal function; no docstring. | Add one-line docstring. |
| 335–352 | `build_graph_cursor` | Internal function; no docstring. Return type is also missing. | Add one-line docstring: constructs the initial `PhyloNetworksBuildCursor` for the root node. |
| 354–362 | `LineagesIO.emit_basenode(::NodeTypeLoadRequest{HybridNetwork}, ...)` | Extension override; no docstring. | Add one-line docstring. |
| 364–372 | `LineagesIO.bind_basenode!(::HybridNetwork, ...)` | Extension override; no docstring. | Add one-line docstring. |
| 374–387 | `build_network_node` | Internal function; no docstring. | Add one-line docstring. |
| 389–394 | `build_tree_edge` | Internal function; no docstring. | Add one-line docstring. |
| 396–408 | `build_hybrid_edge` | Internal function; no docstring. | Add one-line docstring. |
| 410–423 | `attach_edge!` | Internal function; no docstring. | Add one-line docstring. |
| 425–437 | `child_cursor` | Internal function; no docstring. Return type also missing. | Add one-line docstring: creates a child cursor re-using the parent's graph and state with the updated node and nodekey. |
| 439–448+ | `LineagesIO.add_child(parent::PhyloNetworksBuildCursor, ...)` | Extension override (single-parent); no docstring. | Add one-line docstring. |
| (multi-parent `add_child`) | `LineagesIO.add_child(parents::AbstractVector{PhyloNetworksBuildCursor}, ...)` | Extension override (multi-parent); no docstring. | Add one-line docstring. |
| (`finalize_graph!`) | `LineagesIO.finalize_graph!(::PhyloNetworksBuildCursor)` | Extension override; no docstring. | Add one-line docstring: finalizes by wiring the `target` field (reuse) or returning the constructed `HybridNetwork`. |
| (`graph_from_finalized`, `basenode_from_finalized`) | Extension overrides; no docstrings. | Add one-line docstrings. |

### Test and example files

Docstring/doccomment standards do not apply to test files or example scripts,
as these are not library code with public contracts. No action required in:

- `test/runtests.jl` and all `test/core/`, `test/extensions/`, `test/integration/` files
- `examples/data/pythonidae-newick-strings.jl`
- `examples/src/alife_standard_mwe.jl`
- `examples/src/phylonetworks_mwe01.jl`
- `examples/src/phylonetworks_mwe02.jl`

### docs/make.jl

Standard Documenter.jl scaffold file; no docstrings expected. No action required.

## Summary counts

| File | Exported names missing docstrings | Non-exported names missing docstrings |
|---|---|---|
| `src/core_types.jl` | 4 | 0 |
| `src/tables.jl` | 1 (abstract type) | ~14 |
| `src/views.jl` | 2 (`node_property`, `edge_property`) + 1 (`GraphAssetIterator`) | ~7 |
| `src/construction.jl` | 0 | ~35 |
| `src/newick_format.jl` | 0 | ~35 |
| `src/alife_format.jl` | 0 | ~15 |
| `src/fileio_integration.jl` | 0 | ~15 |
| `ext/MetaGraphsNextIO.jl` | 0 | ~20 |
| `ext/MetaGraphsNextAbstractTreesIO.jl` | 0 | ~6 |
| `ext/PhyloNetworksIO.jl` | 0 | ~30 |
| **Total** | **8** | **~177** |

The highest-priority gaps are the 8 exported names with no docstrings at all:
`StructureKeyType`, `EdgeWeightType`, `NodePropertyValueType`,
`EdgePropertyValueType`, `AbstractLineageTable`, `GraphAssetIterator`,
`node_property`, `edge_property`.
