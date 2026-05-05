import Test

mutable struct Tranche01TestNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{Tranche01TestNode}
end

function LineagesIO.add_child(
        ::Nothing,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = nothing,
        nodedata,
    )
    return Tranche01TestNode(nodekey, String(label), Tranche01TestNode[])
end

function LineagesIO.add_child(
        parent::Tranche01TestNode,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )
    child = Tranche01TestNode(nodekey, String(label), Tranche01TestNode[])
    push!(parent.child_collection, child)
    return child
end

function inferred_return_type(f, argtypes::Type{<:Tuple})
    return only(Base.return_types(f, argtypes))
end

function inferred_load_alife_table_tables_only_return_type(
        table,
        source_path,
    )
    kwargs = (; source_path = source_path)
    return only(
        Base.return_types(
            Core.kwcall,
            Tuple{typeof(kwargs), typeof(LineagesIO.load_alife_table), typeof(table)},
        ),
    )
end

function inferred_load_alife_table_node_type_return_type(
        table,
        source_path,
        ::Type{NodeT},
    ) where {NodeT}
    kwargs = (; source_path = source_path)
    return only(
        Base.return_types(
            Core.kwcall,
            Tuple{
                typeof(kwargs),
                typeof(LineagesIO.load_alife_table),
                typeof(table),
                Type{NodeT},
            },
        ),
    )
end

function newick_tranche_01_fixture()
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    text = read(fixture_path, String)
    basenodes = LineagesIO.parse_newick_source(text, fixture_path)
    graph_assets = [
        LineagesIO.build_graph_asset(basenode, graph_index, fixture_path)
            for (graph_index, basenode) in enumerate(basenodes)
    ]
    return text, fixture_path, graph_assets
end

function alife_text_tranche_01_fixture()
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))
    text = read(fixture_path, String)
    header, rows = LineagesIO.parse_alife_source(text, fixture_path)
    annotation_names = LineagesIO.collect_alife_annotation_names(header)
    components = LineagesIO.partition_alife_components(rows, fixture_path)
    graph_assets = [
        LineagesIO.build_alife_graph_asset(component, graph_index, fixture_path, annotation_names)
            for (graph_index, component) in enumerate(components)
    ]
    return text, fixture_path, graph_assets
end

function alife_table_tranche_01_fixture()
    source_path = "synthetic-table"
    table = (
        id = [0, 1, 2, 3],
        ancestor_list = [Int[], [0], [0], [1]],
        origin_time = [0.0, 1.0, 1.0, 2.0],
    )
    header, rows = LineagesIO.parse_alife_table(table, source_path)
    annotation_names = LineagesIO.collect_alife_annotation_names(header)
    components = LineagesIO.partition_alife_components(rows, source_path)
    graph_assets = [
        LineagesIO.build_alife_graph_asset(component, graph_index, source_path, annotation_names)
            for (graph_index, component) in enumerate(components)
    ]
    return table, source_path, graph_assets
end

@testset "Type-stability tranche 01 legacy-owner regression shape" begin
    _, fixture_path, graph_assets = newick_tranche_01_fixture()
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(request)

    unmaterialized_asset_type = eltype(graph_assets)
    materialized_asset_type = typeof(LineagesIO.materialize_graph(first(graph_assets), request))
    expected_legacy_return_type = Union{
        Vector{unmaterialized_asset_type},
        Vector{materialized_asset_type},
    }

    legacy_return_type = inferred_return_type(
        LineagesIO.materialize_graphs,
        Tuple{typeof(graph_assets), typeof(request)},
    )
    typed_return_type = inferred_return_type(
        LineagesIO.materialize_tranche_01_graph_assets,
        Tuple{typeof(graph_assets), typeof(surface)},
    )
    typed_store = LineagesIO.build_tranche_01_store(graph_assets, fixture_path, surface)
    legacy_store_return_type = inferred_return_type(
        LineagesIO.build_legacy_store_from_graph_assets,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(request)},
    )

    @test legacy_return_type == expected_legacy_return_type
    @test typed_return_type == Vector{materialized_asset_type}
    @test legacy_store_return_type != typeof(typed_store)
end

@testset "Type-stability tranche 01 package-owned routing default" begin
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    selected_method = which(
        LineagesIO.request_uses_tranche_01_single_parent_owner,
        Tuple{typeof(request)},
    )

    @test LineagesIO.request_uses_tranche_01_single_parent_owner(request)
    @test selected_method.module === LineagesIO
end

@testset "Type-stability tranche 01 public Newick tables-only inference" begin
    text, fixture_path, graph_assets = newick_tranche_01_fixture()
    surface = LineagesIO.Tranche01TablesOnlySurface()

    typed_store_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(surface)},
    )
    public_return_type = inferred_return_type(
        LineagesIO.build_newick_store,
        Tuple{typeof(text), typeof(fixture_path)},
    )
    public_store = LineagesIO.build_newick_store(text, fixture_path)

    @test typed_store_return_type <: public_return_type
    @test typeof(public_store) <: public_return_type
    @test first(public_store.graphs).graph === nothing
    @test first(public_store.graphs).basenode === nothing
end

@testset "Type-stability tranche 01 public Newick NodeType inference" begin
    text, fixture_path, graph_assets = newick_tranche_01_fixture()
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(request)

    typed_store_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(surface)},
    )
    legacy_store_return_type = inferred_return_type(
        LineagesIO.build_legacy_store_from_graph_assets,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(request)},
    )
    public_return_type = inferred_return_type(
        LineagesIO.build_newick_store,
        Tuple{typeof(text), typeof(fixture_path), typeof(request)},
    )
    public_store = LineagesIO.build_newick_store(text, fixture_path, request)
    asset = first(public_store.graphs)

    @test typed_store_return_type <: public_return_type
    @test public_return_type != legacy_store_return_type
    @test typeof(public_store) <: public_return_type
    @test asset.graph === nothing
    @test asset.basenode isa Tranche01TestNode
    @test length(asset.basenode.child_collection) == 2
end

@testset "Type-stability tranche 01 public alife text inference" begin
    text, fixture_path, text_graph_assets = alife_text_tranche_01_fixture()
    tables_surface = LineagesIO.Tranche01TablesOnlySurface()
    node_request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    node_surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(node_request)

    text_tables_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(text_graph_assets), typeof(fixture_path), typeof(tables_surface)},
    )
    public_text_tables_return_type = inferred_return_type(
        LineagesIO.build_alife_store,
        Tuple{typeof(text), typeof(fixture_path)},
    )
    public_text_tables_store = LineagesIO.build_alife_store(text, fixture_path)

    text_node_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(text_graph_assets), typeof(fixture_path), typeof(node_surface)},
    )
    text_legacy_return_type = inferred_return_type(
        LineagesIO.build_legacy_store_from_graph_assets,
        Tuple{typeof(text_graph_assets), typeof(fixture_path), typeof(node_request)},
    )
    public_text_node_return_type = inferred_return_type(
        LineagesIO.build_alife_store,
        Tuple{typeof(text), typeof(fixture_path), typeof(node_request)},
    )
    public_text_node_store = LineagesIO.build_alife_store(text, fixture_path, node_request)

    @test text_tables_return_type <: public_text_tables_return_type
    @test typeof(public_text_tables_store) <: public_text_tables_return_type
    @test text_node_return_type <: public_text_node_return_type
    @test public_text_node_return_type != text_legacy_return_type
    @test typeof(public_text_node_store) <: public_text_node_return_type
    @test first(public_text_node_store.graphs).basenode isa Tranche01TestNode
end

@testset "Type-stability tranche 01 public load_alife_table inference" begin
    table, table_source_path, table_graph_assets = alife_table_tranche_01_fixture()
    tables_surface = LineagesIO.Tranche01TablesOnlySurface()
    node_request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    node_surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(node_request)

    table_tables_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(table_graph_assets), typeof(table_source_path), typeof(tables_surface)},
    )
    public_table_tables_return_type = inferred_load_alife_table_tables_only_return_type(
        table,
        table_source_path,
    )
    public_table_tables_store = LineagesIO.load_alife_table(table; source_path = table_source_path)

    table_node_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(table_graph_assets), typeof(table_source_path), typeof(node_surface)},
    )
    table_legacy_return_type = inferred_return_type(
        LineagesIO.build_legacy_store_from_graph_assets,
        Tuple{typeof(table_graph_assets), typeof(table_source_path), typeof(node_request)},
    )
    public_table_node_return_type = inferred_load_alife_table_node_type_return_type(
        table,
        table_source_path,
        Tranche01TestNode,
    )
    public_table_node_store = LineagesIO.load_alife_table(table, Tranche01TestNode; source_path = table_source_path)

    @test table_tables_return_type <: public_table_tables_return_type
    @test typeof(public_table_tables_store) <: public_table_tables_return_type
    @test table_node_return_type <: public_table_node_return_type
    @test public_table_node_return_type != table_legacy_return_type
    @test typeof(public_table_node_store) <: public_table_node_return_type
    @test first(public_table_node_store.graphs).basenode isa Tranche01TestNode
end
