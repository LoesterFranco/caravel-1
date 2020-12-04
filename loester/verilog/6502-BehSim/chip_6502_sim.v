`include "chip_6502_nodes.inc"

module chip_6502_sim (
    input  wire        phi,
    input  wire        res,
    input  wire        so,
    input  wire        rdy,
    input  wire        nmi,
    input  wire        irq,
    inout  wire  [7:0] db,
    output wire        rw,
    output wire        sync,
    output wire [15:0] ab);

    wire [`NUM_NODES-1:0] o;
    reg  [`NUM_NODES-1:0] i;

    `include "logic_unopt.inc"  // o = f(i)

    always @* begin
        i = o; // Combinatorial loop - Simulation only

        i[`NODE_vcc ] = 1'b1;
        i[`NODE_vss ] = 1'b0;
        i[`NODE_res ] = res;
        i[`NODE_clk0] = phi;
        i[`NODE_so  ] = so;
        i[`NODE_rdy ] = rdy;
        i[`NODE_nmi ] = nmi;
        i[`NODE_irq ] = irq;

       {i[`NODE_db7],i[`NODE_db6],i[`NODE_db5],i[`NODE_db4],
        i[`NODE_db3],i[`NODE_db2],i[`NODE_db1],i[`NODE_db0]} = db;
    end

    assign db = rw? {8{1'bz}} : {
        o[`NODE_db7],o[`NODE_db6],o[`NODE_db5],o[`NODE_db4],
        o[`NODE_db3],o[`NODE_db2],o[`NODE_db1],o[`NODE_db0]};

    assign ab = {
        o[`NODE_ab15], o[`NODE_ab14], o[`NODE_ab13], o[`NODE_ab12],
        o[`NODE_ab11], o[`NODE_ab10], o[`NODE_ab9],  o[`NODE_ab8],
        o[`NODE_ab7],  o[`NODE_ab6],  o[`NODE_ab5],  o[`NODE_ab4],
        o[`NODE_ab3],  o[`NODE_ab2],  o[`NODE_ab1],  o[`NODE_ab0]};

    assign rw   = o[`NODE_rw];
    assign sync = o[`NODE_sync];

endmodule
