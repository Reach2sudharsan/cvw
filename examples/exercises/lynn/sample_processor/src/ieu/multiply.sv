module multiply(
        input logic [31:0] SrcAE, SrcBE,
        input logic AmsbE, BmsbE,
        input logic [1:0] ALUFunctb01E,
        output logic [31:0] productE
);


        logic signed [33:0] P0, P1, P2, P3;
        logic signed [63:0] origProduct;
        logic signed [16:0] AH, AL, BH, BL;

        logic sign;

        logic ALmsb, BLmsb, AHmsb, BHmsb;

        logic [31:0] SrcA, SrcB;


        // Low halves always unsigned (zero-extend to 17 bits)
        assign AL = {1'b0, SrcAE[15:0]};
        assign BL = {1'b0, SrcBE[15:0]};

        // High halves: sign bit only set if this operation treats it as signed
        assign AH = {AHmsb & SrcAE[31], SrcAE[31:16]};
        assign BH = {BHmsb & SrcBE[31], SrcBE[31:16]};

        assign P0 = AH * BH;
        assign P1 = AH * BL;
        assign P2 = AL * BH;
        assign P3 = AL * BL;


        always_comb begin
            case (ALUFunctb01E)
                2'b11: begin  // MULHU: unsigned × unsigned
                    AHmsb = 1'b0;
                    BHmsb = 1'b0;

                end
                2'b10: begin  // MULHSU: signed × unsigned
                    AHmsb = 1'b1;
                    BHmsb = 1'b0;
                end
                default: begin // MUL, MULH: signed × signed
                    AHmsb = 1'b1;
                    BHmsb = 1'b1;
                end
            endcase
        end

        // assign origProduct = (P0 << 32) + (P1 << 16) + (P2 << 16) + P3;
        assign origProduct = ({{32{P0[33]}}, P0} << 32) +
                         ({{32{P1[33]}}, P1} << 16) +
                         ({{32{P2[33]}}, P2} << 16) +
                          {{32{P3[33]}}, P3};

        always_comb begin
            case (ALUFunctb01E)
                2'b00: productE = origProduct[31:0]; // MUL {$signed(SrcAE) * $signed(SrcBE)}[31:0];
                default:  // MULH, MULHU, MULHSU
                    begin
                        productE = origProduct[63:32]; // productE = ($signed(SrcAE) * $signed(SrcBE)) >>> 32; // origProduct[63:32];
                    end
            endcase
        end
endmodule
