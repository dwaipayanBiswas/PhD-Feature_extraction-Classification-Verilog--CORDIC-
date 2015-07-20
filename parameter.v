//*********************************************************************************************
// Parameter file
// Author: Dwaipayan Biswas
// Email: db9g10@ecs.soton.ac.uk
// University of Southampton
// Defines the parameters for the CORDIC module
//*********************************************************************************************
`define z_scale 24'b000000001000000000000000
`define z_h_1 24'b000000000100011001001111
`define z_h_2 24'b000000000010000010110001
`define z_h_3 24'b000000000001000000010101
`define z_h_4 24'b000000000000100000000010
`define z_h_5 24'b000000000000010000000000
`define z_h_6 24'b000000000000001000000000
`define z_h_7 24'b000000000000000100000000
`define z_h_8 24'b000000000000000010000000
`define z_h_9 24'b000000000000000001000000
`define z_h_10 24'b000000000000000000100000
`define z_h_11 24'b000000000000000000010000
`define z_h_12 24'b000000000000000000001000
`define z_h_13 24'b000000000000000000000100
`define z_h_14 24'b000000000000000000000010
`define z_h_15 24'b000000000000000000000001
`define n 24
`define n1 48
`define n2 2
`define n3 80
`define data_count 256
`define mode_circular 2'b00
`define mode_linear 2'b01
`define mode_hyperbolic 2'b10
`define pow_14 2**14
`define pow_15 2**15 
`define divide_2 1
`define divide_16 4
`define divide_256 8
`define RFadr 3'b000
`define CTadr 3'b001
`define CTRLadr 3'b010
`define DOUTadr 3'b011
`define RFCNTadr 3'b100
`define CTCNTadr 3'b101
`define FCadrl 3'b110
`define FCadrh 3'b111
