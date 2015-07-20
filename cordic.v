//***********************************************************************
// CORDIC Module
// Author: Dwaipayan Biswas
// Email: db9g10@ecs.soton.ac.uk
// University of Southampton
// 16 iterations of the CORDIC module
//***********************************************************************
`timescale 1ns / 100ps
`include "parameter.v"

module cordic(z,result_x,x,y,mode);

output [`n-1:0] z,result_x;

reg signed [`n-1:0] z,result_x;

reg signed [`n-1:0] x_0,x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8,x_9,x_10,x_11,x_12,x_13,x_14,x_15,
y_0,y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_9,y_10,y_11,y_12,y_13,y_14,y_15,
z_0,z_1,z_2,z_3,z_4,z_5,z_6,z_7,z_8,z_9,z_10,z_11,z_12,z_13,z_14;


input [`n2-1:0] mode;
input [`n-1:0] x,y;

wire [`n1-1:0] temp1, temp2;

wire [`n-1:0] X,Y;

// 9949 - 2^14
wire [`n-1:0] scale = 24'b000000000010011011011101;

assign temp1 = $signed(x)*$signed(scale);
assign temp2 = $signed(y)*$signed(scale);

assign X = temp1[37:14];
assign Y = temp2[37:14];

// Zero-th Level

always @(*)
begin	

result_x = 0;

// Zero-th Level
	
	if (mode == `mode_circular)	
	begin
		z_0 = `z_scale;
		if (Y[`n-1] == 1)
		begin
			x_0 = X - Y;
			y_0 = Y + X; 
		end
		else
		begin
			x_0 = X + Y;
			y_0 = Y - X;
		end
	end
	else if (mode == `mode_linear)
	begin		
		x_0 = x;
		z_0 = `z_scale;
		if (y[`n-1] == 1)		
			y_0 = y + x; 		
		else			
			y_0 = y - x;		
	end
	else
	begin
		x_0 = x;
		y_0 = y;
		z_0 = 0;
	end
	
	
	// First Level
	
	if (y_0[`n-1] == 1)
	begin
		y_1 = y_0 + x_0/2;		
		if (mode == `mode_circular)
		begin
			x_1 = x_0 - y_0/2;
			z_1 = z_0 - `z_scale/2;	
		end
		else if (mode == `mode_linear)
		begin
			x_1 = x_0;
			z_1 = z_0 - `z_scale/2;	
		end
		else
		begin
			x_1 = x_0 + y_0/2;
			z_1 = z_0 - `z_h_1;			
		end
	end
	else
	begin
		y_1 = y_0 - x_0/2;					
		if (mode == `mode_circular)
		begin
			x_1 = x_0 + y_0/2;
			z_1 = z_0 + `z_scale/2;	
		end
		else if (mode == `mode_linear)
		begin
			x_1 = x_0;
			z_1 = z_0 + `z_scale/2;	
		end
		else
		begin
			x_1 = x_0 - y_0/2;		
			z_1 = z_0 + `z_h_1;	
		end
			
	end
	
	
	// Second Level
	
	if (y_1[`n-1] == 1)
	begin
		y_2 = y_1 + x_1/(2**2);
		
		if (mode == `mode_circular)
		begin
			x_2 = x_1 - y_1/(2**2);
			z_2 = z_1 - `z_scale/(2**2);	
		end
		else if (mode == `mode_linear)
		begin
			x_2 = x_1;
			z_2 = z_1 - `z_scale/(2**2);	
		end
		else
		begin
			x_2 = x_1 + y_1/(2**2);		
			z_2 = z_1 - `z_h_2;				
		end
	end
	else
	begin
		y_2 = y_1 - x_1/(2**2);	
			
		if (mode == `mode_circular)
		begin
			x_2 = x_1 + y_1/(2**2);
			z_2 = z_1 + `z_scale/(2**2);		
		end
		else if (mode == `mode_linear)
		begin
			x_2 = x_1;
			z_2 = z_1 + `z_scale/(2**2);		
		end
		else
		begin
			x_2 = x_1 - y_1/(2**2);
			z_2 = z_1 + `z_h_2;					
		end
	end
	
	
	// Third Level
	
	if (y_2[`n-1] == 1)
	begin
		y_3 = y_2 + x_2/(2**3);
		
		if (mode == `mode_circular)
		begin
			x_3 = x_2 - y_2/(2**3);
			z_3 = z_2 - `z_scale/(2**3);	
		end
		else if (mode == `mode_linear)
		begin
			x_3 = x_2;
			z_3 = z_2 - `z_scale/(2**3);	
		end
		else
		begin
			x_3 = x_2 + y_2/(2**3);		
			z_3 = z_2 - `z_h_3;				
		end
	end
	else
	begin
		y_3 = y_2 - x_2/(2**3);	
				
		if (mode == `mode_circular)
		begin
			x_3 = x_2 + y_2/(2**3);
			z_3 = z_2 + `z_scale/(2**3);	
		end
		else if (mode == `mode_linear)
		begin
			x_3 = x_2;
			z_3 = z_2 + `z_scale/(2**3);	
		end
		else
		begin
			x_3 = x_2 - y_2/(2**3);		
			z_3 = z_2 + `z_h_3;				
		end
	end
		
	// Fourth Level
	
	if (y_3[`n-1] == 1)
	begin		
		y_4 = y_3 + x_3/(2**4);
		
		if (mode == 2'b00)
		begin
			x_4 = x_3 - y_3/(2**4);			
			z_4 = z_3 - `z_scale/(2**4);	
		end
		else if (mode == 2'b01)
		begin
			x_4 = x_3;			
			z_4 = z_3 - `z_scale/(2**4);	
		end
		else
		begin
			x_4 = x_3 + y_3/(2**4);						
			z_4 = z_3 - `z_h_4;	
		end
	end
	else
	begin	
		y_4 = y_3 - x_3/(2**4);	
		
		if (mode == 2'b00)
		begin
			x_4 = x_3 + y_3/(2**4);			
			z_4 = z_3 + `z_scale/(2**4);		
		end
		else if (mode == 2'b01)
		begin
			x_4 = x_3;			
			z_4 = z_3 + `z_scale/(2**4);		
		end
		else
		begin
			x_4 = x_3 - y_3/(2**4);			
			z_4 = z_3 + `z_h_4;	
		end
	end
	
	// Fourth Level - repetition for hyperbolic
	
	if (mode == 2'b10)
	begin
		if (y_4[`n-1] == 1)
		begin
			y_4 = y_4 + x_4/(2**4);
			z_4 = z_4 - `z_h_4;	
			x_4 = x_4 + y_4/(2**4);
		end
		else
		begin
			y_4 = y_4 - x_4/(2**4);
			z_4 = z_4 + `z_h_4;	
			x_4 = x_4 - y_4/(2**4);
		end
	end
	else
	begin
		x_4 = x_4;
		y_4 = y_4;
		z_4 = z_4;		
	end
	
	// Fifth Level
	
	if (y_4[`n-1] == 1)
	begin
		y_5 = y_4 + x_4/(2**5);
		
		if (mode == `mode_circular)
		begin
			x_5 = x_4 - y_4/(2**5);
			z_5 = z_4 - `z_scale/(2**5);	
		end
		else if (mode == `mode_linear)
		begin
			x_5 = x_4;
			z_5 = z_4 - `z_scale/(2**5);	
		end
		else
		begin
			x_5 = x_4 + y_4/(2**5);
			z_5 = z_4 - `z_h_5;				
		end
	end
	else
	begin
		y_5 = y_4 - x_4/(2**5);	
				
		if (mode == `mode_circular)
		begin
			x_5 = x_4 + y_4/(2**5);
			z_5 = z_4 + `z_scale/(2**5);	
		end
		else if (mode == `mode_linear)
		begin
			x_5 = x_4;		
			z_5 = z_4 + `z_scale/(2**5);	
		end
		else
		begin
			x_5 = x_4 - y_4/(2**5);		
			z_5 = z_4 + `z_h_5;				
		end
	end
		
	// Sixth Level
	
	if (y_5[`n-1] == 1)
	begin
		y_6 = y_5 + x_5/(2**6);
		
		if (mode == `mode_circular)	
		begin
			x_6 = x_5 - y_5/(2**6);
			z_6 = z_5 - `z_scale/(2**6);	
		end
		else if (mode == `mode_linear)
		begin
			x_6 = x_5;
			z_6 = z_5 - `z_scale/(2**6);	
		end
		else
		begin 
			x_6 = x_5 + y_5/(2**6);		
			z_6 = z_5 - `z_h_6;				
		end
	end
	else
	begin
		y_6 = y_5 - x_5/(2**6);	
			
		if (mode == `mode_circular)
		begin
			x_6 = x_5 + y_5/(2**6);
			z_6 = z_5 + `z_scale/(2**6);		
		end
		else if (mode == `mode_linear)
		begin
			x_6 = x_5;
			z_6 = z_5 + `z_scale/(2**6);		
		end
		else
		begin
			x_6 = x_5 - y_5/(2**6);				
			z_6 = z_5 + `z_h_6;		
		end
	end
	
	// Seventh Level
	
	if (y_6[`n-1] == 1)
	begin
		y_7 = y_6 + x_6/(2**7);
		
		if (mode == `mode_circular)
		begin
			x_7 = x_6 - y_6/(2**7);
			z_7 = z_6 - `z_scale/(2**7);	
		end
		else if (mode == `mode_linear)
		begin
			x_7 = x_6;
			z_7 = z_6 - `z_scale/(2**7);	
		end
		else
		begin
			x_7 = x_6 + y_6/(2**7);		
			z_7 = z_6 - `z_h_7;				
		end
	end
	else
	begin
		y_7 = y_6 - x_6/(2**7);	
			
		if (mode == `mode_circular)
		begin
			x_7 = x_6 + y_6/(2**7);
			z_7 = z_6 + `z_scale/(2**7);		
		end
		else if (mode == `mode_linear)
		begin
			x_7 = x_6;
			z_7 = z_6 + `z_scale/(2**7);		
		end
		else
		begin
			x_7 = x_6 - y_6/(2**7);			
			z_7 = z_6 + `z_h_7;					
		end
	end
	
	// Eighth Level
	
	if (y_7[`n-1] == 1)
	begin
		y_8 = y_7 + x_7/(2**8);
		
		if (mode == `mode_circular)
		begin
			x_8 = x_7 - y_7/(2**8);
			z_8 = z_7 - `z_scale/(2**8);	
		end
		else if (mode == `mode_linear)
		begin
			x_8 = x_7;
			z_8 = z_7 - `z_scale/(2**8);	
		end
		else
		begin
			x_8 = x_7 + y_7/(2**8);		
			z_8 = z_7 - `z_h_8;				
		end
	end
	else
	begin
		y_8 = y_7 - x_7/(2**8);	
			
		if (mode == `mode_circular)
		begin
			x_8 = x_7 + y_7/(2**8);
			z_8 = z_7 + `z_scale/(2**8);		
		end
		else if (mode == `mode_linear)
		begin
			x_8 = x_7;
			z_8 = z_7 + `z_scale/(2**8);		
		end
		else
		begin
			x_8 = x_7 - y_7/(2**8);			
			z_8 = z_7 + `z_h_8;		
		end
	end
	
	// Ninth Level
	
	if (y_8[`n-1] == 1)
	begin
		y_9 = y_8 + x_8/(2**9);
		
		if (mode == `mode_circular)
		begin
			x_9 = x_8 - y_8/(2**9);
			z_9 = z_8 - `z_scale/(2**9);	
		end
		else if (mode == `mode_linear)
		begin
			x_9 = x_8;
			z_9 = z_8 - `z_scale/(2**9);	
		end
		else
		begin
			x_9 = x_8 + y_8/(2**9);		
			z_9 = z_8 - `z_h_9;				
		end
	end
	else
	begin
		y_9 = y_8 - x_8/(2**9);	
					
		if (mode == `mode_circular)
		begin
			x_9 = x_8 + y_8/(2**9);
			z_9 = z_8 + `z_scale/(2**9);
		end
		else if (mode == `mode_linear)
		begin
			x_9 = x_8;
			z_9 = z_8 + `z_scale/(2**9);
		end
		else
		begin
			x_9 = x_8 - y_8/(2**9);				
			z_9 = z_8 + `z_h_9;
		end
	end
	
	
	// Tenth Level
	
	if (y_9[`n-1] == 1)
	begin
		y_10 = y_9 + x_9/(2**10);
		
		if (mode == `mode_circular)			
		begin
			x_10 = x_9 - y_9/(2**10);
			z_10 = z_9 - `z_scale/(2**10);	
		end
		else if (mode == `mode_linear)
		begin
			x_10 = x_9;	
			z_10 = z_9 - `z_scale/(2**10);	
		end
		else
		begin
			x_10 = x_9 + y_9/(2**10);		
			z_10 = z_9 - `z_h_10;				
		end
	end
	else
	begin
		y_10 = y_9 - x_9/(2**10);	
					
		if (mode == `mode_circular)
		begin
			x_10 = x_9 + y_9/(2**10);
			z_10 = z_9 + `z_scale/(2**10);
		end
		else if (mode == `mode_linear)
		begin
			x_10 = x_9;			
			z_10 = z_9 + `z_scale/(2**10);
		end
		else
		begin
			x_10 = x_9 - y_9/(2**10);	
			z_10 = z_9 + `z_h_10;			
		end
	end
	
	// Eleventh Level
	
	if (y_10[`n-1] == 1)
	begin
		y_11 = y_10 + x_10/(2**11);
		
		if (mode == `mode_circular)		
		begin
			x_11 = x_10 - y_10/(2**11);
			z_11 = z_10 - `z_scale/(2**11);	
		end
		else if (mode == `mode_linear)
		begin
			x_11 = x_10;
			z_11 = z_10 - `z_scale/(2**11);	
		end
		else
		begin
			x_11 = x_10 + y_10/(2**11);		
			z_11 = z_10 - `z_h_11;				
		end
	end
	else
	begin
		y_11 = y_10 - x_10/(2**11);	
		
		if (mode == `mode_circular)
		begin
			x_11 = x_10 + y_10/(2**11);
			z_11 = z_10 + `z_scale/(2**11);			
		end
		else if (mode == `mode_linear)
		begin
			x_11 = x_10;
			z_11 = z_10 + `z_scale/(2**11);			
		end
		else
		begin
			x_11 = x_10 - y_10/(2**11);				
			z_11 = z_10 + `z_h_11;						
		end
	end
	
	// Twelvth Level
	
	if (y_11[`n-1] == 1)
	begin
		y_12 = y_11 + x_11/(2**12);
		
		if (mode == `mode_circular)			
		begin
			x_12 = x_11 - y_11/(2**12);
			z_12 = z_11 - `z_scale/(2**12);	
		end
		else if (mode == `mode_linear)
		begin
			x_12 = x_11;
			z_12 = z_11 - `z_scale/(2**12);	
		end
		else
		begin
			x_12 = x_11 + y_11/(2**12);		
			z_12 = z_11 - `z_h_12;				
		end
	end
	else
	begin
		y_12 = y_11 - x_11/(2**12);	
		
		if (mode == `mode_circular)
		begin
			x_12 = x_11 + y_11/(2**12);
			z_12 = z_11 + `z_scale/(2**12);			
		end
		else if (mode == `mode_linear)
		begin
			x_12 = x_11;
			z_12 = z_11 + `z_scale/(2**12);			
		end
		else
		begin
			x_12 = x_11 - y_11/(2**12);				
			z_12 = z_11 + `z_h_12;			
		end
	end
	
	// Thirteenth Level
	
	if (y_12[`n-1] == 1)
	begin	
		y_13 = y_12 + x_12/(2**13);
		
		if (mode == 2'b00)
		begin
			x_13 = x_12 - y_12/(2**13);			
			z_13 = z_12 - `z_scale/(2**13);	
		end
		else if (mode == 2'b01)
		begin
			x_13 = x_12;			
			z_13 = z_12 - `z_scale/(2**13);	
		end
		else
		begin
			x_13 = x_12 + y_12/(2**13);				
			z_13 = z_12 - `z_h_13;				
		end
	end
	else
	begin		
		y_13 = y_12 - x_12/(2**13);	
		
		if (mode == 2'b00)
		begin
			x_13 = x_12 + y_12/(2**13);			
			z_13 = z_12 + `z_scale/(2**13);			
		end
		else if (mode == 2'b01)
		begin
			x_13 = x_12;			
			z_13 = z_12 + `z_scale/(2**13);			
		end
		else
		begin
			x_13 = x_12 - y_12/(2**13);				
			z_13 = z_12 + `z_h_13;					
		end
	end
		
	// Thirteenth Level - repetition for hyperbolic
	
	if (mode == 2'b10)
	begin
		if (y_13[`n-1] == 1)
		begin
			y_13 = y_13 + x_13/(2**13);
			z_13 = z_13 - `z_h_13;	
			x_13 = x_13 + y_13/(2**13);
		end
		else
		begin
			y_13 = y_13 - x_13/(2**13);
			z_13 = z_13 + `z_h_13;	
			x_13 = x_13 - y_13/(2**13);
		end
	end
	else
	begin
		x_13 = x_13;
		y_13 = y_13;
		z_13 = z_13;		
	end	
	
	// Fourteenth Level
	
	if (y_13[`n-1] == 1)
	begin
		y_14 = y_13 + x_13/(2**14);
		
		if (mode == `mode_circular)
		begin
			x_14 = x_13 - y_13/(2**14);
			z_14 = z_13 - `z_scale/(2**14);	
		end
		else if (mode == `mode_linear)
		begin
			x_14 = x_13;
			z_14 = z_13 - `z_scale/(2**14);	
		end
		else
		begin
			x_14 = x_13 + y_13/(2**14);		
			z_14 = z_13 - `z_h_14;				
		end
	end
	else
	begin
		y_14 = y_13 - x_13/(2**14);	
		
		if (mode == `mode_circular)
		begin
			x_14 = x_13 + y_13/(2**14);
			z_14 = z_13 + `z_scale/(2**14);			
		end
		else if (mode == `mode_linear)
		begin
			x_14 = x_13;
			z_14 = z_13 + `z_scale/(2**14);			
		end
		else
		begin
			x_14 = x_13 - y_13/(2**14);				
			z_14 = z_13 + `z_h_14;			
		end
	end
	
	// Fifteenth Level
	
	if (y_14[`n-1] == 1)
	begin
		y_15 = y_14 + x_14/(2**15);
		
		if (mode == `mode_circular)			
		begin
			result_x = x_14 - y_14/(2**15);
			z = z_14 - `z_scale/(2**15);	
		end
		else if (mode == `mode_linear)
		begin
			result_x = x_14;
			z = z_14 - `z_scale/(2**15);	
		end
		else
		begin
			x_15 = x_14 + y_14/(2**15);	
			z = (z_14 - `z_h_15)<<1;				
		end
	end
	else
	begin
		y_15 = y_14 - x_14/(2**15);	
		
		if (mode == `mode_circular)
		begin
			result_x = x_14 + y_14/(2**15);
			z = z_14 + `z_scale/(2**15);			
		end
		else if (mode == `mode_linear)
		begin
			result_x = x_14;
			z = z_14 + `z_scale/(2**15);			
		end
		else
		begin
			x_15 = x_14 - y_14/(2**15);					
			z = (z_14 + `z_h_15)<<1;			
		end
	end	
end
	
endmodule


