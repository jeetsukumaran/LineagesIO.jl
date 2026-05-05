@testset "PhyloNetworks extension activation before weakdep load" begin
    @test Base.get_extension(LineagesIO, :PhyloNetworksIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path)
    asset = first(store.graphs)

    @test asset.graph === nothing
    @test asset.basenode === nothing
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
end

using PhyloNetworks

@testset "PhyloNetworks extension activation after weakdep load" begin
    extension = Base.get_extension(LineagesIO, :PhyloNetworksIO)

    @test extension !== nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)

    @test asset.graph isa PhyloNetworks.HybridNetwork
    @test asset.basenode === asset.graph.node[asset.graph.rooti]
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]

    request = LineagesIO.NodeTypeLoadRequest(PhyloNetworks.HybridNetwork)
    selected_method = which(
        LineagesIO.request_uses_tranche_01_single_parent_owner,
        Tuple{typeof(request)},
    )
    @test !LineagesIO.request_uses_tranche_01_single_parent_owner(request)
    @test selected_method.module === extension
end
