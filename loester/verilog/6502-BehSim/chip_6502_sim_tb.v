`timescale 1ns / 1ns

`include "chip_6502_nodes.inc"

module chip_6502_sim_tb;

    //////////////////////////////////////////////////////////////////////////
    // 6502

    reg         res, phi0;
    wire        rw, sync;
    wire [15:0] ab;
    wire  [7:0] db;

    chip_6502_sim uut (
        .phi    (phi0),
        .res    (res),
        .so     (1'b0),
        .rdy    (1'b1),
        .nmi    (1'b1),
        .irq    (1'b1),
        .rw     (rw),
        .sync   (sync),
        .db     (db),
        .ab     (ab));

    //////////////////////////////////////////////////////////////////////////
    // Clock and reset

    initial begin
        phi0 = 1'b0;
        res = 1'b0;
        #4000;
        res =1'b1;
    end

    always #500 phi0 <= ~phi0;

    //////////////////////////////////////////////////////////////////////////
    // Memory

    reg [7:0] mem[0:65535];

    assign db = rw? mem[ab[15:0]] : {8{1'bz}};

    always @ (posedge phi0)
        if (res && ~rw && ~ab[15]) mem[ab[15:0]] <= db;

    //////////////////////////////////////////////////////////////////////////
    // Test code

    integer fd, i;
    reg [7:0] byte;

    task Load_Dormann;
    begin
        for (i=0; i<'hA; i=i+1) mem[i]='b0;
        fd = $fopen("../../ASM/6502_functional_tests/6502_functional_test.bin", "rb");
        for (i='hA; $fscanf(fd, "%c", byte); i=i+1) mem[i] = byte;
        $fclose(fd);
        mem[16'hFFFD]=8'h04;
        mem[16'hFFFC]=8'h00;
    end
    endtask

    task Load_AllSuiteA;
    begin
        for (i=0; i<65536; i=i+1) mem[i]='b0;
        fd = $fopen("../../ASM/6502-test-code/AllSuiteA.bin", "rb");
        for (i='h4000; $fscanf(fd, "%c", byte); i=i+1) mem[i] = byte;
        $fclose(fd);
        mem['h3FFC]='hD8; // CLD
        mem['h3FFD]='hA2; // LDX#
        mem['h3FFE]='hFF;
        mem['h3FFF]='h9A; // TXS
        mem['hFFFD]='h3F;
        mem['hFFFC]='hFC;
        while(1) @ (posedge phi0) if (ab=='h45C2) $stop;
    end
    endtask

    task Load_Decrementer;
    begin
        mem['h0FFE]='hEA;
        mem['h0FFF]='hEA;
        mem['h1000]='hD8; // CLD
        mem['h1001]='hA2; // LDX#
        mem['h1002]='hFF;
        mem['h1003]='h9A; // TXS
        mem['h1004]='hCA; // DEX
        mem['h1005]='hA9; // LDA#
        mem['h1006]='h55;
        mem['h1007]='h48; // PHA
        mem['h1008]='hD0; // BNE
        mem['h1009]='hFFE-'h100A;
        mem['hFFFD]='h10;
        mem['hFFFC]='h00;
        while(1) @ (posedge phi0) if (ab=='hFFF) $stop;
    end
    endtask

    initial begin
        //Load_Dormann();
        //Load_AllSuiteA();
        Load_Decrementer();
    end

    //////////////////////////////////////////////////////////////////////////
    // Probes

    wire SB_floating = ~|uut.mux_sb_1287.s;
    wire DB_floating = ~|uut.mux_idb_1473.s;

    wire dpc11_SBADD = uut.i[`NODE_dpc11_SBADD];   // SB --> ALUA
    wire dpc9_DBADD  = uut.i[`NODE_dpc9_DBADD];    // DB --> ALUB

    wire [15:0] pc = {
        uut.i[`NODE_pch7],
        uut.i[`NODE_pch6],
        uut.i[`NODE_pch5],
        uut.i[`NODE_pch4],
        uut.i[`NODE_pch3],
        uut.i[`NODE_pch2],
        uut.i[`NODE_pch1],
        uut.i[`NODE_pch0],
        uut.i[`NODE_pcl7],
        uut.i[`NODE_pcl6],
        uut.i[`NODE_pcl5],
        uut.i[`NODE_pcl4],
        uut.i[`NODE_pcl3],
        uut.i[`NODE_pcl2],
        uut.i[`NODE_pcl1],
        uut.i[`NODE_pcl0]
    };

    wire idl[7:0] = {
        uut.i[`NODE_idl7],
        uut.i[`NODE_idl6],
        uut.i[`NODE_idl5],
        uut.i[`NODE_idl4],
        uut.i[`NODE_idl3],
        uut.i[`NODE_idl2],
        uut.i[`NODE_idl1],
        uut.i[`NODE_idl0]
    };

    wire sb[7:0] = {
        uut.i[`NODE_sb7],
        uut.i[`NODE_sb6],
        uut.i[`NODE_sb5],
        uut.i[`NODE_sb4],
        uut.i[`NODE_sb3],
        uut.i[`NODE_sb2],
        uut.i[`NODE_sb1],
        uut.i[`NODE_sb0]
    };

    wire idb[7:0] = {
        uut.i[`NODE_idb7],
        uut.i[`NODE_idb6],
        uut.i[`NODE_idb5],
        uut.i[`NODE_idb4],
        uut.i[`NODE_idb3],
        uut.i[`NODE_idb2],
        uut.i[`NODE_idb1],
        uut.i[`NODE_idb0]
    };

    wire adl[7:0] = {
        uut.i[`NODE_adl7],
        uut.i[`NODE_adl6],
        uut.i[`NODE_adl5],
        uut.i[`NODE_adl4],
        uut.i[`NODE_adl3],
        uut.i[`NODE_adl2],
        uut.i[`NODE_adl1],
        uut.i[`NODE_adl0]
    };

    wire adh[7:0] = {
        uut.i[`NODE_adh7],
        uut.i[`NODE_adh6],
        uut.i[`NODE_adh5],
        uut.i[`NODE_adh4],
        uut.i[`NODE_adh3],
        uut.i[`NODE_adh2],
        uut.i[`NODE_adh1],
        uut.i[`NODE_adh0]
    };
/*
    wire abl[7:0] = {
        uut.i[`NODE_abl7],
        uut.i[`NODE_abl6],
        uut.i[`NODE_abl5],
        uut.i[`NODE_abl4],
        uut.i[`NODE_abl3],
        uut.i[`NODE_abl2],
        uut.i[`NODE_abl1],
        uut.i[`NODE_abl0]
    };

    wire abh[7:0] = {
        uut.i[`NODE_abh7],
        uut.i[`NODE_abh6],
        uut.i[`NODE_abh5],
        uut.i[`NODE_abh4],
        uut.i[`NODE_abh3],
        uut.i[`NODE_abh2],
        uut.i[`NODE_abh1],
        uut.i[`NODE_abh0]
    };
*/
    wire s[7:0] = {
        uut.i[`NODE_s7],
        uut.i[`NODE_s6],
        uut.i[`NODE_s5],
        uut.i[`NODE_s4],
        uut.i[`NODE_s3],
        uut.i[`NODE_s2],
        uut.i[`NODE_s1],
        uut.i[`NODE_s0]
    };

    wire a[7:0] = {
        uut.i[`NODE_a7],
        uut.i[`NODE_a6],
        uut.i[`NODE_a5],
        uut.i[`NODE_a4],
        uut.i[`NODE_a3],
        uut.i[`NODE_a2],
        uut.i[`NODE_a1],
        uut.i[`NODE_a0]
    };

    wire x[7:0] = {
        uut.i[`NODE_x7],
        uut.i[`NODE_x6],
        uut.i[`NODE_x5],
        uut.i[`NODE_x4],
        uut.i[`NODE_x3],
        uut.i[`NODE_x2],
        uut.i[`NODE_x1],
        uut.i[`NODE_x0]
    };

    wire y[7:0] = {
        uut.i[`NODE_y7],
        uut.i[`NODE_y6],
        uut.i[`NODE_y5],
        uut.i[`NODE_y4],
        uut.i[`NODE_y3],
        uut.i[`NODE_y2],
        uut.i[`NODE_y1],
        uut.i[`NODE_y0]
    };

    wire ir[7:0] = {
        uut.i[`NODE_ir7],
        uut.i[`NODE_ir6],
        uut.i[`NODE_ir5],
        uut.i[`NODE_ir4],
        uut.i[`NODE_ir3],
        uut.i[`NODE_ir2],
        uut.i[`NODE_ir1],
        uut.i[`NODE_ir0]
    };

    wire T[5:0] = {
        uut.i[`NODE_t5],
        uut.i[`NODE_t4],
        uut.i[`NODE_t3],
        uut.i[`NODE_t2],
        uut.i[`NODE_clock2],
        uut.i[`NODE_clock1]
    };

    wire alu[7:0] = {
        uut.i[`NODE_alu7],
        uut.i[`NODE_alu6],
        uut.i[`NODE_alu5],
        uut.i[`NODE_alu4],
        uut.i[`NODE_alu3],
        uut.i[`NODE_alu2],
        uut.i[`NODE_alu1],
        uut.i[`NODE_alu0]
    };

    wire alua[7:0] = {
        uut.i[`NODE_alua7],
        uut.i[`NODE_alua6],
        uut.i[`NODE_alua5],
        uut.i[`NODE_alua4],
        uut.i[`NODE_alua3],
        uut.i[`NODE_alua2],
        uut.i[`NODE_alua1],
        uut.i[`NODE_alua0]
    };

    wire alub[7:0] = {
        uut.i[`NODE_alub7],
        uut.i[`NODE_alub6],
        uut.i[`NODE_alub5],
        uut.i[`NODE_alub4],
        uut.i[`NODE_alub3],
        uut.i[`NODE_alub2],
        uut.i[`NODE_alub1],
        uut.i[`NODE_alub0]
    };

endmodule
