module Encrypt(
    input [63:0]  plaintext  ,
    input [63:0]  secretKey  ,
    output [63:0] ciphertext 
);
wire[63:0] nextstate[0:10];
wire[63:0] key[0:10];
assign key[0]=secretKey;
AddRoundKey he(.currentState(plaintext),.roundKey(key[0]),.nextState(nextstate[0]));
genvar i;
generate
    for(i=0;i<10;i=i+1) begin
        NextKey wow(.currentKey(key[i]),.nextKey(key[i+1]));
        Round m(.currentState(nextstate[i]),.roundKey(key[i+1]),.nextState(nextstate[i+1]));
    end
endgenerate
assign ciphertext=nextstate[10];
endmodule

module Round(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
wire[63:0] sboxoutput;
genvar i;
generate
    for(i=0;i<16;i=i+1) begin
        SBox hi(.in(currentState[4*i+3:4*i]),.out(sboxoutput[4*i+3:4*i]));
    end  
endgenerate
wire[63:0] shiftrowoutput;
ShiftRows l(.currentState(sboxoutput),.nextState(shiftrowoutput));
wire[63:0] finalouput;
AddRoundKey p(.currentState(shiftrowoutput),.roundKey(roundKey),.nextState(finalouput));
assign nextState=finalouput;

endmodule

module SBox(
    input [3:0]in ,
    output [3:0]out
);
assign out[0]=(~in[0]&in[2])|(~in[0]&in[1]&in[3])|(in[1]&in[2]&in[3])|(in[0]&~in[1]&~in[3]);
assign out[1]=(in[0]&~in[1])|(~in[0]&~in[1]&~in[2])|(~in[0]&~in[2]&in[3])|(~in[0]&in[1]&in[2]&~in[3]);
assign out[2]=(in[1]&~in[2]&in[3])|(in[0]&in[1]&~in[2])|(~in[1]&in[2]&in[3])|(~in[0]&~in[1]&~in[3])|(~in[0]&in[2]&~in[3]);
assign out[3]=(~in[1]&~in[2]&in[0]&~in[3])|(~in[1]&~in[2]&~in[0]&in[3])|(in[0]&in[1]&in[3])|(in[0]&in[2]&in[3])|(~in[0]&in[2]&~in[3])|(in[1]&in[2]&~in[3]);

endmodule

module NextKey(
    input  [63:0] currentKey,
    output [63:0] nextKey
);
assign nextKey={currentKey[59:0],currentKey[63:60]};
endmodule

module ShiftRows(
    input  [63:0] currentState ,
    output [63:0] nextState    
);
assign nextState[15:0]=currentState[15:0];
assign nextState[19:16]=currentState[23:20];
assign nextState[23:20]=currentState[27:24];
assign nextState[27:24]=currentState[31:28];
assign nextState[31:28]=currentState[19:16];
assign nextState[35:32]=currentState[43:40];
assign nextState[39:36]=currentState[47:44];
assign nextState[43:40]=currentState[35:32];
assign nextState[47:44]=currentState[39:36];
assign nextState[51:48]=currentState[63:60];
assign nextState[55:52]=currentState[51:48];
assign nextState[59:56]=currentState[55:52];
assign nextState[63:60]=currentState[59:56];
endmodule

module AddRoundKey(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
assign nextState=currentState^roundKey;

endmodule
