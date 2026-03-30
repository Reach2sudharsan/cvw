module hazard_unit(
                input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
                input logic [4:0] RdE, RdM, RdW,
                input logic       RegWriteM, RegWriteW,
                input logic       ResultSrcEb0, // remember to load from datapath
                input logic       PCSrcE,

                output logic [1:0] ForwardAE, ForwardBE,
                output logic    lwStall, StallF, StallD, FlushD, FlushE
        );

        always_comb begin

            if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0))
                ForwardAE = 10;
            else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0))
                ForwardAE = 01;
            else
                ForwardAE = 00;
        end

        always_comb begin

            if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0))
                ForwardBE = 10;
            else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0))
                ForwardBE = 01;
            else
                ForwardBE = 00;
        end


        // Stall Logic
        assign lwStall = ((Rs1D == RdE) || (Rs2D == RdE)) && ResultSrcEb0;
        assign StallF = lwStall;
        assign StallD = lwStall;

        // Flush Logic
        assign FlushD = PCSrcE;
        assign FlushE = lwStall || PCSrcE;


endmodule
