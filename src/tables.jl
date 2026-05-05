abstract type AbstractLineageTable <: Tables.AbstractColumns end

const SOURCE_TABLE_COLUMN_NAMES = (
    :source_idx,
    :source_path,
    :collection_count,
    :graph_count,
)
const COLLECTION_TABLE_COLUMN_NAMES = (
    :collection_idx,
    :source_idx,
    :collection_label,
    :graph_count,
)
const GRAPH_TABLE_COLUMN_NAMES = (
    :index,
    :source_idx,
    :collection_idx,
    :collection_graph_idx,
    :collection_label,
    :graph_label,
    :node_count,
    :edge_count,
)
const NODE_TABLE_STRUCTURAL_COLUMN_NAMES = (:nodekey, :label)
const EDGE_TABLE_STRUCTURAL_COLUMN_NAMES = (
    :edgekey,
    :src_nodekey,
    :dst_nodekey,
    :edgeweight,
)

const SOURCE_TABLE_SCHEMA = Tables.Schema(
    SOURCE_TABLE_COLUMN_NAMES,
    (Int, OptionalString, Int, Int),
)
const COLLECTION_TABLE_SCHEMA = Tables.Schema(
    COLLECTION_TABLE_COLUMN_NAMES,
    (Int, Int, OptionalString, Int),
)
const GRAPH_TABLE_SCHEMA = Tables.Schema(
    GRAPH_TABLE_COLUMN_NAMES,
    (Int, Int, Int, Int, OptionalString, OptionalString, Int, Int),
)
const NODE_TABLE_STRUCTURAL_SCHEMA = Tables.Schema(
    NODE_TABLE_STRUCTURAL_COLUMN_NAMES,
    (StructureKeyType, String),
)
const EDGE_TABLE_STRUCTURAL_SCHEMA = Tables.Schema(
    EDGE_TABLE_STRUCTURAL_COLUMN_NAMES,
    (StructureKeyType, StructureKeyType, StructureKeyType, EdgeWeightType),
)

struct AnnotationColumnStore
    names::Vector{Symbol}
    columns::Vector{Vector{OptionalString}}
    index_by_name::Dict{Symbol, Int}

    function AnnotationColumnStore(
            names::Vector{Symbol},
            columns::Vector{Vector{OptionalString}},
            index_by_name::Dict{Symbol, Int},
        )
        length(names) == length(columns) == length(index_by_name) || throw(
            ArgumentError("Annotation column metadata must have matching lengths."),
        )
        isempty(columns) || lineagetable_nrows(columns...)
        return new(names, columns, index_by_name)
    end
end

struct SourceTable <: AbstractLineageTable
    source_idx::Vector{Int}
    source_path::Vector{OptionalString}
    collection_count::Vector{Int}
    graph_count::Vector{Int}

    function SourceTable(
            source_idx::Vector{Int},
            source_path::Vector{OptionalString},
            collection_count::Vector{Int},
            graph_count::Vector{Int},
        )
        lineagetable_nrows(source_idx, source_path, collection_count, graph_count)
        return new(source_idx, source_path, collection_count, graph_count)
    end
end

struct CollectionTable <: AbstractLineageTable
    collection_idx::Vector{Int}
    source_idx::Vector{Int}
    collection_label::Vector{OptionalString}
    graph_count::Vector{Int}

    function CollectionTable(
            collection_idx::Vector{Int},
            source_idx::Vector{Int},
            collection_label::Vector{OptionalString},
            graph_count::Vector{Int},
        )
        lineagetable_nrows(collection_idx, source_idx, collection_label, graph_count)
        return new(collection_idx, source_idx, collection_label, graph_count)
    end
end

struct GraphTable <: AbstractLineageTable
    index::Vector{Int}
    source_idx::Vector{Int}
    collection_idx::Vector{Int}
    collection_graph_idx::Vector{Int}
    collection_label::Vector{OptionalString}
    graph_label::Vector{OptionalString}
    node_count::Vector{Int}
    edge_count::Vector{Int}

    function GraphTable(
            index::Vector{Int},
            source_idx::Vector{Int},
            collection_idx::Vector{Int},
            collection_graph_idx::Vector{Int},
            collection_label::Vector{OptionalString},
            graph_label::Vector{OptionalString},
            node_count::Vector{Int},
            edge_count::Vector{Int},
        )
        lineagetable_nrows(
            index,
            source_idx,
            collection_idx,
            collection_graph_idx,
            collection_label,
            graph_label,
            node_count,
            edge_count,
        )
        return new(
            index,
            source_idx,
            collection_idx,
            collection_graph_idx,
            collection_label,
            graph_label,
            node_count,
            edge_count,
        )
    end
end

struct NodeTable <: AbstractLineageTable
    nodekey::Vector{StructureKeyType}
    label::Vector{String}
    annotation_store::AnnotationColumnStore

    function NodeTable(
            nodekey::Vector{StructureKeyType},
            label::Vector{String},
            annotation_store::AnnotationColumnStore,
        )
        nrows = lineagetable_nrows(nodekey, label)
        annotation_nrows = annotation_column_nrows(annotation_store)
        (annotation_nrows == 0 || annotation_nrows == nrows) || throw(
            ArgumentError("All columns in a LineagesIO table must have the same length."),
        )
        expected_nodekeys = collect(StructureKeyType(1):StructureKeyType(nrows))
        nodekey == expected_nodekeys || throw(
            ArgumentError(
                "Node table rows must follow `nodekey` order with sequential `StructureKeyType` keys starting at 1.",
            ),
        )
        assert_no_conflicting_annotation_names(
            annotation_store,
            NODE_TABLE_STRUCTURAL_COLUMN_NAMES,
            "node",
        )
        return new(nodekey, label, annotation_store)
    end
end

struct EdgeTable <: AbstractLineageTable
    edgekey::Vector{StructureKeyType}
    src_nodekey::Vector{StructureKeyType}
    dst_nodekey::Vector{StructureKeyType}
    edgeweight::Vector{EdgeWeightType}
    annotation_store::AnnotationColumnStore

    function EdgeTable(
            edgekey::Vector{StructureKeyType},
            src_nodekey::Vector{StructureKeyType},
            dst_nodekey::Vector{StructureKeyType},
            edgeweight::Vector{EdgeWeightType},
            annotation_store::AnnotationColumnStore,
        )
        nrows = lineagetable_nrows(edgekey, src_nodekey, dst_nodekey, edgeweight)
        annotation_nrows = annotation_column_nrows(annotation_store)
        (annotation_nrows == 0 || annotation_nrows == nrows) || throw(
            ArgumentError("All columns in a LineagesIO table must have the same length."),
        )
        expected_edgekeys = collect(StructureKeyType(1):StructureKeyType(nrows))
        edgekey == expected_edgekeys || throw(
            ArgumentError(
                "Edge table rows must follow `edgekey` order with sequential `StructureKeyType` keys starting at 1.",
            ),
        )
        assert_no_conflicting_annotation_names(
            annotation_store,
            EDGE_TABLE_STRUCTURAL_COLUMN_NAMES,
            "edge",
        )
        return new(edgekey, src_nodekey, dst_nodekey, edgeweight, annotation_store)
    end
end

Tables.istable(::Type{<:AbstractLineageTable}) = true
Tables.columnaccess(::Type{<:AbstractLineageTable}) = true
Tables.columns(table::AbstractLineageTable) = table
Tables.materializer(::Type{<:AbstractLineageTable}) = Tables.columntable

Tables.schema(::SourceTable) = SOURCE_TABLE_SCHEMA
Tables.schema(::CollectionTable) = COLLECTION_TABLE_SCHEMA
Tables.schema(::GraphTable) = GRAPH_TABLE_SCHEMA
Tables.columnnames(::SourceTable) = SOURCE_TABLE_COLUMN_NAMES
Tables.columnnames(::CollectionTable) = COLLECTION_TABLE_COLUMN_NAMES
Tables.columnnames(::GraphTable) = GRAPH_TABLE_COLUMN_NAMES

function Tables.schema(table::NodeTable)
    annotation_names = annotation_columnnames(getfield(table, :annotation_store))
    isempty(annotation_names) && return NODE_TABLE_STRUCTURAL_SCHEMA
    column_names = (NODE_TABLE_STRUCTURAL_COLUMN_NAMES..., annotation_names...)
    column_types = ntuple(
        index -> index == 1 ? StructureKeyType : index == 2 ? String : OptionalString,
        length(column_names),
    )
    return Tables.Schema(column_names, column_types)
end

function Tables.schema(table::EdgeTable)
    annotation_names = annotation_columnnames(getfield(table, :annotation_store))
    isempty(annotation_names) && return EDGE_TABLE_STRUCTURAL_SCHEMA
    column_names = (EDGE_TABLE_STRUCTURAL_COLUMN_NAMES..., annotation_names...)
    column_types = ntuple(
        index ->
            index == 1 || index == 2 || index == 3 ? StructureKeyType :
            index == 4 ? EdgeWeightType :
            OptionalString,
        length(column_names),
    )
    return Tables.Schema(column_names, column_types)
end

function Tables.columnnames(table::NodeTable)
    annotation_names = annotation_columnnames(getfield(table, :annotation_store))
    isempty(annotation_names) && return NODE_TABLE_STRUCTURAL_COLUMN_NAMES
    return (NODE_TABLE_STRUCTURAL_COLUMN_NAMES..., annotation_names...)
end

function Tables.columnnames(table::EdgeTable)
    annotation_names = annotation_columnnames(getfield(table, :annotation_store))
    isempty(annotation_names) && return EDGE_TABLE_STRUCTURAL_COLUMN_NAMES
    return (EDGE_TABLE_STRUCTURAL_COLUMN_NAMES..., annotation_names...)
end

Tables.getcolumn(table::SourceTable, i::Int) = get_summary_table_column(table, i)
Tables.getcolumn(table::CollectionTable, i::Int) = get_summary_table_column(table, i)
Tables.getcolumn(table::GraphTable, i::Int) = get_summary_table_column(table, i)
Tables.getcolumn(table::NodeTable, i::Int) = get_node_table_column(table, i)
Tables.getcolumn(table::EdgeTable, i::Int) = get_edge_table_column(table, i)
Tables.getcolumn(table::SourceTable, nm::Symbol) = get_summary_table_column(table, nm)
Tables.getcolumn(table::CollectionTable, nm::Symbol) = get_summary_table_column(table, nm)
Tables.getcolumn(table::GraphTable, nm::Symbol) = get_summary_table_column(table, nm)
Tables.getcolumn(table::NodeTable, nm::Symbol) = get_node_table_column(table, nm)
Tables.getcolumn(table::EdgeTable, nm::Symbol) = get_edge_table_column(table, nm)
Tables.getcolumn(table::AbstractLineageTable, ::Type{T}, i::Int, nm::Symbol) where {T} = Tables.getcolumn(table, i)

function empty_annotation_column_store()::AnnotationColumnStore
    return AnnotationColumnStore(
        Symbol[],
        Vector{OptionalString}[],
        Dict{Symbol, Int}(),
    )
end

function AnnotationColumnStore(
        names::Vector{Symbol},
        columns::Vector{Vector{OptionalString}},
    )::AnnotationColumnStore
    length(names) == length(columns) || throw(
        ArgumentError("Annotation column metadata must have matching lengths."),
    )
    index_by_name = Dict{Symbol, Int}()
    for (column_index, name) in enumerate(names)
        haskey(index_by_name, name) && throw(
            ArgumentError("Duplicate annotation column name `$(name)` is not supported."),
        )
        index_by_name[name] = column_index
    end
    return AnnotationColumnStore(names, columns, index_by_name)
end

function SourceTable(columns::NamedTuple)
    lineagetable_nrows(columns)
    return SourceTable(
        source_idx = getproperty(columns, :source_idx),
        source_path = getproperty(columns, :source_path),
        collection_count = getproperty(columns, :collection_count),
        graph_count = getproperty(columns, :graph_count),
    )
end

function CollectionTable(columns::NamedTuple)
    lineagetable_nrows(columns)
    return CollectionTable(
        collection_idx = getproperty(columns, :collection_idx),
        source_idx = getproperty(columns, :source_idx),
        collection_label = getproperty(columns, :collection_label),
        graph_count = getproperty(columns, :graph_count),
    )
end

function GraphTable(columns::NamedTuple)
    lineagetable_nrows(columns)
    return GraphTable(
        index = getproperty(columns, :index),
        source_idx = getproperty(columns, :source_idx),
        collection_idx = getproperty(columns, :collection_idx),
        collection_graph_idx = getproperty(columns, :collection_graph_idx),
        collection_label = getproperty(columns, :collection_label),
        graph_label = getproperty(columns, :graph_label),
        node_count = getproperty(columns, :node_count),
        edge_count = getproperty(columns, :edge_count),
    )
end

function NodeTable(columns::NamedTuple)
    lineagetable_nrows(columns)
    annotation_columns = collect_annotation_columns(columns, NODE_TABLE_STRUCTURAL_COLUMN_NAMES)
    return NodeTable(
        nodekey = getproperty(columns, :nodekey),
        label = getproperty(columns, :label),
        annotation_columns = annotation_columns,
    )
end

function EdgeTable(columns::NamedTuple)
    lineagetable_nrows(columns)
    annotation_columns = collect_annotation_columns(columns, EDGE_TABLE_STRUCTURAL_COLUMN_NAMES)
    return EdgeTable(
        edgekey = getproperty(columns, :edgekey),
        src_nodekey = getproperty(columns, :src_nodekey),
        dst_nodekey = getproperty(columns, :dst_nodekey),
        edgeweight = getproperty(columns, :edgeweight),
        annotation_columns = annotation_columns,
    )
end

function SourceTable(;
        source_idx::AbstractVector{<:Integer},
        source_path::AbstractVector,
        collection_count::AbstractVector{<:Integer},
        graph_count::AbstractVector{<:Integer},
    )::SourceTable
    return SourceTable(
        Int.(source_idx),
        normalize_optional_string_vector(source_path),
        Int.(collection_count),
        Int.(graph_count),
    )
end

function CollectionTable(;
        collection_idx::AbstractVector{<:Integer},
        source_idx::AbstractVector{<:Integer},
        collection_label::AbstractVector,
        graph_count::AbstractVector{<:Integer},
    )::CollectionTable
    return CollectionTable(
        Int.(collection_idx),
        Int.(source_idx),
        normalize_optional_string_vector(collection_label),
        Int.(graph_count),
    )
end

function GraphTable(;
        index::AbstractVector{<:Integer},
        source_idx::AbstractVector{<:Integer},
        collection_idx::AbstractVector{<:Integer},
        collection_graph_idx::AbstractVector{<:Integer},
        collection_label::AbstractVector,
        graph_label::AbstractVector,
        node_count::AbstractVector{<:Integer},
        edge_count::AbstractVector{<:Integer},
    )::GraphTable
    return GraphTable(
        Int.(index),
        Int.(source_idx),
        Int.(collection_idx),
        Int.(collection_graph_idx),
        normalize_optional_string_vector(collection_label),
        normalize_optional_string_vector(graph_label),
        Int.(node_count),
        Int.(edge_count),
    )
end

function NodeTable(;
        nodekey::AbstractVector{<:Integer},
        label::AbstractVector{<:AbstractString},
        annotation_columns::NamedTuple = NamedTuple(),
    )::NodeTable
    normalized_nodekeys = StructureKeyType.(nodekey)
    normalized_labels = String.(label)
    normalized_annotations = normalize_annotation_columns(annotation_columns, "node")
    return NodeTable(
        normalized_nodekeys,
        normalized_labels,
        normalized_annotations,
    )
end

function EdgeTable(;
        edgekey::AbstractVector{<:Integer},
        src_nodekey::AbstractVector{<:Integer},
        dst_nodekey::AbstractVector{<:Integer},
        edgeweight::AbstractVector,
        annotation_columns::NamedTuple = NamedTuple(),
    )::EdgeTable
    normalized_edgekeys = StructureKeyType.(edgekey)
    normalized_src_nodekeys = StructureKeyType.(src_nodekey)
    normalized_dst_nodekeys = StructureKeyType.(dst_nodekey)
    normalized_edgeweights = normalize_edgeweight_vector(edgeweight)
    normalized_annotations = normalize_annotation_columns(annotation_columns, "edge")
    return EdgeTable(
        normalized_edgekeys,
        normalized_src_nodekeys,
        normalized_dst_nodekeys,
        normalized_edgeweights,
        normalized_annotations,
    )
end

function lineagetable_nrows(table::SourceTable)::Int
    return length(getfield(table, :source_idx))
end

function lineagetable_nrows(table::CollectionTable)::Int
    return length(getfield(table, :collection_idx))
end

function lineagetable_nrows(table::GraphTable)::Int
    return length(getfield(table, :index))
end

function lineagetable_nrows(table::NodeTable)::Int
    return length(getfield(table, :nodekey))
end

function lineagetable_nrows(table::EdgeTable)::Int
    return length(getfield(table, :edgekey))
end

lineagetable_nrows() = 0

function lineagetable_nrows(first_column::AbstractVector, remaining_columns::AbstractVector...)::Int
    first_length = length(first_column)
    for column in remaining_columns
        length(column) == first_length || throw(
            ArgumentError("All columns in a LineagesIO table must have the same length."),
        )
    end
    return first_length
end

function lineagetable_nrows(columns::NamedTuple)::Int
    return lineagetable_nrows(values(columns)...)
end

function normalize_optional_string_vector(values::AbstractVector)::Vector{OptionalString}
    return OptionalString[value === nothing ? nothing : String(value) for value in values]
end

function normalize_edgeweight_vector(values::AbstractVector)::Vector{EdgeWeightType}
    normalized_values = EdgeWeightType[]
    for value in values
        if value === nothing
            push!(normalized_values, nothing)
        else
            push!(normalized_values, Float64(value))
        end
    end
    return normalized_values
end

function normalize_annotation_columns(
        annotation_columns::NamedTuple,
        scope::AbstractString,
    )::AnnotationColumnStore
    names = Symbol[name for name in keys(annotation_columns)]
    normalized_columns = Vector{Vector{OptionalString}}()
    for name in names
        raw_column = getproperty(annotation_columns, name)
        normalized_column = OptionalString[]
        for value in raw_column
            if value === nothing
                push!(normalized_column, nothing)
            elseif value isa AbstractString
                push!(normalized_column, String(value))
            else
                throw(
                    ArgumentError(
                        "Retained $(scope) annotation column `$(name)` must store `Union{Nothing, String}` values.",
                    ),
                )
            end
        end
        push!(normalized_columns, normalized_column)
    end
    return AnnotationColumnStore(names, normalized_columns)
end

function annotation_column_nrows(annotation_store::AnnotationColumnStore)::Int
    columns = getfield(annotation_store, :columns)
    isempty(columns) && return 0
    return length(first(columns))
end

function annotation_columnnames(annotation_store::AnnotationColumnStore)::Tuple
    return Tuple(getfield(annotation_store, :names))
end

function annotation_column(
        annotation_store::AnnotationColumnStore,
        column_name::Symbol,
    )::Vector{OptionalString}
    column_index = get(getfield(annotation_store, :index_by_name), column_name, 0)
    column_index == 0 && throw(
        ArgumentError("Requested table column `$(column_name)` is not present."),
    )
    return getfield(annotation_store, :columns)[column_index]
end

function annotation_column(
        annotation_store::AnnotationColumnStore,
        column_index::Int,
    )::Vector{OptionalString}
    columns = getfield(annotation_store, :columns)
    1 <= column_index <= length(columns) || throw(BoundsError(columns, column_index))
    return columns[column_index]
end

function assert_no_conflicting_annotation_names(
        annotation_store::AnnotationColumnStore,
        structural_names::Tuple,
        scope::AbstractString,
    )::Nothing
    conflicting_names = intersect(structural_names, annotation_columnnames(annotation_store))
    isempty(conflicting_names) || throw(
        ArgumentError(
            "Retained $(scope) annotation names conflict with structural $(scope) fields: $(join(string.(conflicting_names), ", ")).",
        ),
    )
    return nothing
end

function collect_annotation_columns(
        columns::NamedTuple,
        structural_names::Tuple,
    )::NamedTuple
    annotation_columns = NamedTuple()
    for column_name in keys(columns)
        column_name in structural_names && continue
        annotation_columns = merge(
            annotation_columns,
            NamedTuple{(column_name,)}((getproperty(columns, column_name),)),
        )
    end
    return annotation_columns
end

function get_summary_table_column(table::SourceTable, column_index::Int)
    column_index == 1 && return getfield(table, :source_idx)
    column_index == 2 && return getfield(table, :source_path)
    column_index == 3 && return getfield(table, :collection_count)
    column_index == 4 && return getfield(table, :graph_count)
    throw(BoundsError(table, column_index))
end

function get_summary_table_column(table::CollectionTable, column_index::Int)
    column_index == 1 && return getfield(table, :collection_idx)
    column_index == 2 && return getfield(table, :source_idx)
    column_index == 3 && return getfield(table, :collection_label)
    column_index == 4 && return getfield(table, :graph_count)
    throw(BoundsError(table, column_index))
end

function get_summary_table_column(table::GraphTable, column_index::Int)
    column_index == 1 && return getfield(table, :index)
    column_index == 2 && return getfield(table, :source_idx)
    column_index == 3 && return getfield(table, :collection_idx)
    column_index == 4 && return getfield(table, :collection_graph_idx)
    column_index == 5 && return getfield(table, :collection_label)
    column_index == 6 && return getfield(table, :graph_label)
    column_index == 7 && return getfield(table, :node_count)
    column_index == 8 && return getfield(table, :edge_count)
    throw(BoundsError(table, column_index))
end

function get_summary_table_column(table::SourceTable, column_name::Symbol)
    column_name === :source_idx && return getfield(table, :source_idx)
    column_name === :source_path && return getfield(table, :source_path)
    column_name === :collection_count && return getfield(table, :collection_count)
    column_name === :graph_count && return getfield(table, :graph_count)
    throw(ArgumentError("Requested table column `$(column_name)` is not present."))
end

function get_summary_table_column(table::CollectionTable, column_name::Symbol)
    column_name === :collection_idx && return getfield(table, :collection_idx)
    column_name === :source_idx && return getfield(table, :source_idx)
    column_name === :collection_label && return getfield(table, :collection_label)
    column_name === :graph_count && return getfield(table, :graph_count)
    throw(ArgumentError("Requested table column `$(column_name)` is not present."))
end

function get_summary_table_column(table::GraphTable, column_name::Symbol)
    column_name === :index && return getfield(table, :index)
    column_name === :source_idx && return getfield(table, :source_idx)
    column_name === :collection_idx && return getfield(table, :collection_idx)
    column_name === :collection_graph_idx && return getfield(table, :collection_graph_idx)
    column_name === :collection_label && return getfield(table, :collection_label)
    column_name === :graph_label && return getfield(table, :graph_label)
    column_name === :node_count && return getfield(table, :node_count)
    column_name === :edge_count && return getfield(table, :edge_count)
    throw(ArgumentError("Requested table column `$(column_name)` is not present."))
end

function get_node_table_column(table::NodeTable, column_index::Int)
    column_index == 1 && return getfield(table, :nodekey)
    column_index == 2 && return getfield(table, :label)
    return annotation_column(getfield(table, :annotation_store), column_index - 2)
end

function get_node_table_column(table::NodeTable, column_name::Symbol)
    column_name === :nodekey && return getfield(table, :nodekey)
    column_name === :label && return getfield(table, :label)
    return annotation_column(getfield(table, :annotation_store), column_name)
end

function get_edge_table_column(table::EdgeTable, column_index::Int)
    column_index == 1 && return getfield(table, :edgekey)
    column_index == 2 && return getfield(table, :src_nodekey)
    column_index == 3 && return getfield(table, :dst_nodekey)
    column_index == 4 && return getfield(table, :edgeweight)
    return annotation_column(getfield(table, :annotation_store), column_index - 4)
end

function get_edge_table_column(table::EdgeTable, column_name::Symbol)
    column_name === :edgekey && return getfield(table, :edgekey)
    column_name === :src_nodekey && return getfield(table, :src_nodekey)
    column_name === :dst_nodekey && return getfield(table, :dst_nodekey)
    column_name === :edgeweight && return getfield(table, :edgeweight)
    return annotation_column(getfield(table, :annotation_store), column_name)
end
