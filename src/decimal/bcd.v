//`define SHIFTIN
//`define BITS_8
//`define BITS_12
//`define BITS_13
`define BITS_14

module bcd(
    number,
    thousands,
    hundreds,
    tens,
    ones
    );

    input [13:0] number;
    output [3:0] thousands;
    output [3:0] hundreds;
    output [3:0] tens;
    output [3:0] ones;

    `ifdef SHIFTIN
    // shifting -- HORRIBLE!
    integer i;

    always @(number)
    begin
        thousands = 0;
        hundreds = 0;
        tens = 0;
        ones = 0;

        for (i = 13; i >= 0; i = i - 1)
        begin
            if (thousands >= 5)
                thousands = thousands + 3;
            if (hundreds >= 5)
                hundreds = hundreds + 3;
            if (tens >= 5)
                tens = tens + 3;
            if (ones >= 5)
                ones = ones + 3;

            thousands = thousands << 1;
            thousands[0] = hundreds[3];
            hundreds = hundreds << 1;
            hundreds[0] = tens[3];
            tens = tens << 1;
            tens[0] = ones[3];
            ones = ones << 1;
            ones[0] = number[i];
        end
    end

    `endif

    `ifdef BITS_8
/*

       6 4 2 0
      ||||||||
     0||||||||
     |||||||||
     #c1#|||||
     |||||||||
     |#c2#||||
     |||||||||
    0||#c3#|||
    ||||||||||
    #c6##c4#||
    ||||||||||
  00|#c7##c5#|
  ||||||||||||
  \hh/\tt/\oo/
*/

    // 8bits - 256
    wire [3:0] c1,c2,c3,c4,c5,c6,c7;
    wire [3:0] d1,d2,d3,d4,d5,d6,d7;

    assign d1 = {1'b0,number[7:5]};
    assign d2 = {c1[2:0],number[4]};
    assign d3 = {c2[2:0],number[3]};
    assign d4 = {c3[2:0],number[2]};
    assign d5 = {c4[2:0],number[1]};

    assign d6 = {1'b0,c1[3],c2[3],c3[3]};
    assign d7 = {c6[2:0],c4[3]};

    add3 m1(d1,c1);
    add3 m2(d2,c2);
    add3 m3(d3,c3);
    add3 m4(d4,c4);
    add3 m5(d5,c5);
    add3 m6(d6,c6);
    add3 m7(d7,c7);

    assign ones = {c5[2:0],number[0]};
    assign tens = {c7[2:0],c5[3]};
    assign hundreds = {2'd0, c6[3],c7[3]};
    assign thousands = 0;

    `endif

    `ifdef BITS_12
/*
       1
       0 8 6 4 2 0
      ||||||||||||
     0||||||||||||
     |||||||||||||
     #c1#|||||||||
     |||||||||||||
     |#c2#||||||||
     |||||||||||||
    0||#c3#|||||||
    ||||||||||||||
    #cA##c4#||||||
    ||||||||||||||
    |#cB##c5#|||||
    ||||||||||||||
   0||#cC##c6#||||
   |||||||||||||||
   #cG##cD##c7#|||
   |||||||||||||||
   |#cH##cE##c8#||
   |||||||||||||||
  0||#cI##cF##c9#|
  ||||||||||||||||
  \TT/\hh/\tt/\oo/
*/

    // 12bits - 4096
    wire [3:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,cA,cB,cC,cD,cE,cF,cG,cH,cI;
    wire [3:0] d1,d2,d3,d4,d5,d6,d7,d8,d9,dA,dB,dC,dD,dE,dF,dG,dH,dI;

    assign d1 = {1'b0,number[11:9]};
    assign d2 = {c1[2:0],number[8]};
    assign d3 = {c2[2:0],number[7]};
    assign d4 = {c3[2:0],number[6]};
    assign d5 = {c4[2:0],number[5]};
    assign d6 = {c5[2:0],number[4]};
    assign d7 = {c6[2:0],number[3]};
    assign d8 = {c7[2:0],number[2]};
    assign d9 = {c8[2:0],number[1]};

    assign dA = {1'b0,c1[3],c2[3],c3[3]};
    assign dB = {cA[2:0],c4[3]};
    assign dC = {cB[2:0],c5[3]};
    assign dD = {cC[2:0],c6[3]};
    assign dE = {cD[2:0],c7[3]};
    assign dF = {cE[2:0],c8[3]};

    assign dG = {1'b0,cA[3],cB[3],cC[3]};
    assign dH = {cG[2:0], cD[3]};
    assign dI = {cH[2:0], cE[3]};

    add3 m1(d1,c1);
    add3 m2(d2,c2);
    add3 m3(d3,c3);
    add3 m4(d4,c4);
    add3 m5(d5,c5);
    add3 m6(d6,c6);
    add3 m7(d7,c7);
    add3 m8(d8,c8);
    add3 m9(d9,c9);
    add3 mA(dA,cA);
    add3 mB(dB,cB);
    add3 mC(dC,cC);
    add3 mD(dD,cD);
    add3 mE(dE,cE);
    add3 mF(dF,cF);
    add3 mG(dG,cG);
    add3 mH(dH,cH);
    add3 mI(dI,cI);

    assign ones = {c9[2:0],number[0]};
    assign tens = {cF[2:0],c9[3]};
    assign hundreds = {cI[2:0],cF[3]};
    assign thousands = {1'd0, cG[3],cH[3],cI[3]};

    `endif

    `ifdef BITS_13
/*
      1 1
      2 0 8 6 4 2 0
      |||||||||||||
     0|||||||||||||
     ||||||||||||||
     #c1#||||||||||
     ||||||||||||||
     |#c2#|||||||||
     ||||||||||||||
    0||#c3#||||||||
    |||||||||||||||
    #cB##c4#|||||||
    |||||||||||||||
    |#cC##c5#||||||
    |||||||||||||||
   0||#cD##c6#|||||
   ||||||||||||||||
   #cI##cE##c7#||||
   ||||||||||||||||
   |#cJ##cF##c8#|||
   ||||||||||||||||
  0||#cK##cG##c9#||
  |||||||||||||||||
  #cM##cL##cH##cA#|
  |||||||||||||||||
   \TT/\hh/\tt/\oo/
*/

    // 13bits - 8191
    wire [3:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,cA,cB,cC,cD,cE,cF,cG,cH,cI,cJ,cK,cL,cM;
    wire [3:0] d1,d2,d3,d4,d5,d6,d7,d8,d9,dA,dB,dC,dD,dE,dF,dG,dH,dI,dJ,dK,dL,dM;

    assign d1 = {1'b0,number[12:10]};
    assign d2 = {c1[2:0],number[9]};
    assign d3 = {c2[2:0],number[8]};
    assign d4 = {c3[2:0],number[7]};
    assign d5 = {c4[2:0],number[6]};
    assign d6 = {c5[2:0],number[5]};
    assign d7 = {c6[2:0],number[4]};
    assign d8 = {c7[2:0],number[3]};
    assign d9 = {c8[2:0],number[2]};
    assign dA = {c9[2:0],number[1]};

    assign dB = {1'b0,c1[3],c2[3],c3[3]};
    assign dC = {cB[2:0],c4[3]};
    assign dD = {cC[2:0],c5[3]};
    assign dE = {cD[2:0],c6[3]};
    assign dF = {cE[2:0],c7[3]};
    assign dG = {cF[2:0],c8[3]};
    assign dH = {cG[2:0],c9[3]};

    assign dI = {1'b0,cB[3],cC[3],cD[3]};
    assign dJ = {cI[2:0], cE[3]};
    assign dK = {cJ[2:0], cF[3]};
    assign dL = {cK[2:0], cG[3]};

    assign dM = {1'b0,cI[3],cJ[3],cK[3]};

    add3 m1(d1,c1);
    add3 m2(d2,c2);
    add3 m3(d3,c3);
    add3 m4(d4,c4);
    add3 m5(d5,c5);
    add3 m6(d6,c6);
    add3 m7(d7,c7);
    add3 m8(d8,c8);
    add3 m9(d9,c9);
    add3 mA(dA,cA);
    add3 mB(dB,cB);
    add3 mC(dC,cC);
    add3 mD(dD,cD);
    add3 mE(dE,cE);
    add3 mF(dF,cF);
    add3 mG(dG,cG);
    add3 mH(dH,cH);
    add3 mI(dI,cI);
    add3 mJ(dJ,cJ);
    add3 mK(dK,cK);
    add3 mL(dL,cL);
    add3 mM(dM,cM);

    assign ones = {cA[2:0],number[0]};
    assign tens = {cH[2:0],cA[3]};
    assign hundreds = {cL[2:0],cH[3]};
    assign thousands = {cM[2:0],cL[3]};

    `endif

    `ifdef BITS_14
/*
       1 1
       2 0 8 6 4 2 0
      ||||||||||||||
     0||||||||||||||
     |||||||||||||||
     #c1#|||||||||||
     |||||||||||||||
     |#c2#||||||||||
     |||||||||||||||
    0||#c3#|||||||||
    ||||||||||||||||
    #cC##c4#||||||||
    ||||||||||||||||
    |#cD##c5#|||||||
    ||||||||||||||||
   0||#cE##c6#||||||
   |||||||||||||||||
   #cK##cF##c7#|||||
   |||||||||||||||||
   |#cL##cG##c8#||||
   |||||||||||||||||
  0||#cM##cH##c9#|||
  ||||||||||||||||||
  #cP##cN##cI##cA#||
  ||||||||||||||||||
  |#cQ##cO##cJ##cB#|
  ||||||||||||||||||
    \TT/\hh/\tt/\oo/
*/

    // 14bits - 16383
    wire [3:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,cA,cB,cC,cD,cE,cF,cG,cH,cI,cJ,cK,cL,cM,cN,cO,cP,cQ;
    wire [3:0] d1,d2,d3,d4,d5,d6,d7,d8,d9,dA,dB,dC,dD,dE,dF,dG,dH,dI,dJ,dK,dL,dM,dN,dO,dP,dQ;

    assign d1 = {1'b0,number[13:11]};
    assign d2 = {c1[2:0],number[10]};
    assign d3 = {c2[2:0],number[9]};
    assign d4 = {c3[2:0],number[8]};
    assign d5 = {c4[2:0],number[7]};
    assign d6 = {c5[2:0],number[6]};
    assign d7 = {c6[2:0],number[5]};
    assign d8 = {c7[2:0],number[4]};
    assign d9 = {c8[2:0],number[3]};
    assign dA = {c9[2:0],number[2]};
    assign dB = {c9[2:0],number[1]};

    assign dC = {1'b0,c1[3],c2[3],c3[3]};
    assign dD = {cC[2:0],c4[3]};
    assign dE = {cD[2:0],c5[3]};
    assign dF = {cE[2:0],c6[3]};
    assign dG = {cF[2:0],c7[3]};
    assign dH = {cG[2:0],c8[3]};
    assign dI = {cH[2:0],c9[3]};
    assign dJ = {cI[2:0],cA[3]};

    assign dK = {1'b0,cC[3],cD[3],cE[3]};
    assign dL = {cK[2:0], cF[3]};
    assign dM = {cL[2:0], cG[3]};
    assign dN = {cM[2:0], cH[3]};
    assign dO = {cN[2:0], cI[3]};

    assign dP = {1'b0,cK[3],cL[3],cM[3]};
    assign dQ = {cP[2:0], cN[3]};

    add3 m1(d1,c1);
    add3 m2(d2,c2);
    add3 m3(d3,c3);
    add3 m4(d4,c4);
    add3 m5(d5,c5);
    add3 m6(d6,c6);
    add3 m7(d7,c7);
    add3 m8(d8,c8);
    add3 m9(d9,c9);
    add3 mA(dA,cA);
    add3 mB(dB,cB);
    add3 mC(dC,cC);
    add3 mD(dD,cD);
    add3 mE(dE,cE);
    add3 mF(dF,cF);
    add3 mG(dG,cG);
    add3 mH(dH,cH);
    add3 mI(dI,cI);
    add3 mJ(dJ,cJ);
    add3 mK(dK,cK);
    add3 mL(dL,cL);
    add3 mM(dM,cM);
    add3 mN(dN,cN);
    add3 mO(dO,cO);
    add3 mP(dP,cP);
    add3 mQ(dQ,cQ);

    assign ones = {cB[2:0],number[0]};
    assign tens = {cJ[2:0],cB[3]};
    assign hundreds = {cO[2:0],cJ[3]};
    assign thousands = {cQ[2:0],cO[3]};

    `endif

endmodule

`ifndef SHIFTIN

module add3(
    in,
    out
    );

    input [3:0] in;
    output [3:0] out;
    reg [3:0] out;

    always @ (in)
    begin
        case (in)
            4'b0000: out <= 4'b0000;
            4'b0001: out <= 4'b0001;
            4'b0010: out <= 4'b0010;
            4'b0011: out <= 4'b0011;
            4'b0100: out <= 4'b0100;
            4'b0101: out <= 4'b1000;
            4'b0110: out <= 4'b1001;
            4'b0111: out <= 4'b1010;
            4'b1000: out <= 4'b1011;
            4'b1001: out <= 4'b1100;
            default: out <= 4'b0000;
        endcase
    end
endmodule

`endif
