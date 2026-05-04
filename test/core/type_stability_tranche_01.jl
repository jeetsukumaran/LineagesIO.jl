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

@testset "Type-stability tranche 01 tables-only shared owner" begin
    text, fixture_path, graph_assets = newick_tranche_01_fixture()
    surface = LineagesIO.Tranche01TablesOnlySurface()

    typed_store = LineagesIO.build_tranche_01_store(graph_assets, fixture_path, surface)
    typed_store_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(surface)},
    )
    public_store = LineagesIO.build_newick_store(text, fixture_path)

    @test typed_store_return_type == typeof(typed_store)
    @test typeof(public_store) == typeof(typed_store)
    @test first(typed_store.graphs).graph === nothing
    @test first(typed_store.graphs).basenode === nothing
end

@testset "Type-stability tranche 01 single-parent Newick shared owner" begin
    text, fixture_path, graph_assets = newick_tranche_01_fixture()
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(request)

    typed_store = LineagesIO.build_tranche_01_store(graph_assets, fixture_path, surface)
    typed_store_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(graph_assets), typeof(fixture_path), typeof(surface)},
    )
    public_store = LineagesIO.build_newick_store(text, fixture_path, request)
    asset = first(typed_store.graphs)

    @test typed_store_return_type == typeof(typed_store)
    @test typeof(public_store) == typeof(typed_store)
    @test asset.graph === nothing
    @test asset.basenode isa Tranche01TestNode
    @test length(asset.basenode.child_collection) == 2
end

@testset "Type-stability tranche 01 alife text and table shared owner" begin
    text, fixture_path, text_graph_assets = alife_text_tranche_01_fixture()
    table, table_source_path, table_graph_assets = alife_table_tranche_01_fixture()
    tables_surface = LineagesIO.Tranche01TablesOnlySurface()
    node_request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)
    node_surface = LineagesIO.Tranche01SingleParentNodeTypeSurface(node_request)

    text_tables_store = LineagesIO.build_tranche_01_store(text_graph_assets, fixture_path, tables_surface)
    text_tables_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(text_graph_assets), typeof(fixture_path), typeof(tables_surface)},
    )
    public_text_tables_store = LineagesIO.build_alife_store(text, fixture_path)

    text_node_store = LineagesIO.build_tranche_01_store(text_graph_assets, fixture_path, node_surface)
    text_node_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(text_graph_assets), typeof(fixture_path), typeof(node_surface)},
    )
    public_text_node_store = LineagesIO.build_alife_store(text, fixture_path, node_request)

    table_tables_store = LineagesIO.build_tranche_01_store(table_graph_assets, table_source_path, tables_surface)
    table_tables_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(table_graph_assets), typeof(table_source_path), typeof(tables_surface)},
    )
    public_table_tables_store = LineagesIO.load_alife_table(table; source_path = table_source_path)

    table_node_store = LineagesIO.build_tranche_01_store(table_graph_assets, table_source_path, node_surface)
    table_node_return_type = inferred_return_type(
        LineagesIO.build_tranche_01_store,
        Tuple{typeof(table_graph_assets), typeof(table_source_path), typeof(node_surface)},
    )
    public_table_node_store = LineagesIO.load_alife_table(table, Tranche01TestNode; source_path = table_source_path)

    @test text_tables_return_type == typeof(text_tables_store)
    @test typeof(public_text_tables_store) == typeof(text_tables_store)
    @test text_node_return_type == typeof(text_node_store)
    @test typeof(public_text_node_store) == typeof(text_node_store)

    @test table_tables_return_type == typeof(table_tables_store)
    @test typeof(public_table_tables_store) == typeof(table_tables_store)
    @test table_node_return_type == typeof(table_node_store)
    @test typeof(public_table_node_store) == typeof(table_node_store)

    @test first(text_node_store.graphs).basenode isa Tranche01TestNode
    @test first(table_node_store.graphs).basenode isa Tranche01TestNode
end
