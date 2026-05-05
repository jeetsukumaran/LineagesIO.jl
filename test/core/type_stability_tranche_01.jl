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

function newick_tranche_01_fixture()
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    text = read(fixture_path, String)
    basenodes = LineagesIO.parse_newick_source(text, fixture_path)
    graph_assets = [
        LineagesIO.build_graph_asset(basenode, graph_index, fixture_path)
            for (graph_index, basenode) in enumerate(basenodes)
    ]
    return text, fixture_path, basenodes, graph_assets
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
    return text, fixture_path, header, components, annotation_names, graph_assets
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
    return table, source_path, header, components, annotation_names, graph_assets
end

@testset "Type-stability tranche 01 legacy-owner regression shape" begin
    _, fixture_path, _, graph_assets = newick_tranche_01_fixture()
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

@testset "Type-stability tranche 01 exact asset-builder inference" begin
    _, fixture_path, basenodes, _ = newick_tranche_01_fixture()
    basenode = first(basenodes)
    newick_asset_return_type = inferred_return_type(
        LineagesIO.build_graph_asset,
        Tuple{typeof(basenode), Int, typeof(fixture_path)},
    )
    newick_asset = Test.@inferred LineagesIO.build_graph_asset(basenode, 1, fixture_path)

    _, table_source_path, _, components, annotation_names, _ = alife_table_tranche_01_fixture()
    component = first(components)
    alife_asset_return_type = inferred_return_type(
        LineagesIO.build_alife_graph_asset,
        Tuple{typeof(component), Int, typeof(table_source_path), typeof(annotation_names)},
    )
    alife_asset = Test.@inferred LineagesIO.build_alife_graph_asset(
        component,
        1,
        table_source_path,
        annotation_names,
    )

    @test !(newick_asset_return_type isa UnionAll)
    @test !(alife_asset_return_type isa UnionAll)
    @test newick_asset_return_type === typeof(newick_asset)
    @test alife_asset_return_type === typeof(alife_asset)
    @test newick_asset.node_table isa LineagesIO.NodeTable
    @test newick_asset.edge_table isa LineagesIO.EdgeTable
    @test alife_asset.node_table isa LineagesIO.NodeTable
    @test alife_asset.edge_table isa LineagesIO.EdgeTable
end

@testset "Type-stability tranche 01 exact public Newick inference" begin
    text, fixture_path, _, _ = newick_tranche_01_fixture()
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)

    tables_only_store = Test.@inferred LineagesIO.build_newick_store(text, fixture_path)
    tables_only_asset = first(tables_only_store.graphs)
    node_store = Test.@inferred LineagesIO.build_newick_store(text, fixture_path, request)
    node_asset = first(node_store.graphs)

    @test tables_only_asset.graph === nothing
    @test tables_only_asset.basenode === nothing
    @test node_asset.graph === nothing
    @test node_asset.basenode isa Tranche01TestNode
    @test length(node_asset.basenode.child_collection) == 2
end

@testset "Type-stability tranche 01 exact public alife text inference" begin
    text, fixture_path, _, _, _, _ = alife_text_tranche_01_fixture()
    request = LineagesIO.NodeTypeLoadRequest(Tranche01TestNode)

    tables_only_store = Test.@inferred LineagesIO.build_alife_store(text, fixture_path)
    tables_only_asset = first(tables_only_store.graphs)
    node_store = Test.@inferred LineagesIO.build_alife_store(text, fixture_path, request)
    node_asset = first(node_store.graphs)

    @test tables_only_asset.graph === nothing
    @test tables_only_asset.basenode === nothing
    @test node_asset.graph === nothing
    @test node_asset.basenode isa Tranche01TestNode
end

@testset "Type-stability tranche 01 exact public load_alife_table inference" begin
    table, source_path, _, _, _, _ = alife_table_tranche_01_fixture()

    tables_only_store = Test.@inferred LineagesIO.load_alife_table(
        table;
        source_path = source_path,
    )
    tables_only_asset = first(tables_only_store.graphs)
    node_store = Test.@inferred LineagesIO.load_alife_table(
        table,
        Tranche01TestNode;
        source_path = source_path,
    )
    node_asset = first(node_store.graphs)

    @test tables_only_asset.graph === nothing
    @test tables_only_asset.basenode === nothing
    @test node_asset.graph === nothing
    @test node_asset.basenode isa Tranche01TestNode
end
