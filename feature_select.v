//*********************************************************************************************
// TOP Module: Feature selection and minimum distance classification
// Author: Dwaipayan Biswas
// Email: db9g10@ecs.soton.ac.uk
// University of Southampton
// Selects the features w.r.t the cluster centroids
// Minimum distance classification
//*********************************************************************************************
`timescale 1ns / 100ps

`include "parameter.v"

 module feature_select (clk, nReset, Addr, dataIn, dataOut, nRd, nWr, nCs, Intr);

output [15:0] dataOut;

reg [15:0] data_out;

output Intr;

input [2:0] Addr;

input [15:0] dataIn;

input clk, nReset, nRd, nWr, nCs;

wire clk, nReset, nRd, nWr, nCs; reg [15:0] rf_input, cnt_input; 

reg signed [7:0] count_feat, feature_count_x, feature_count_y, feature_count_z, centroid_count, count_cent;

reg int, rf_data_rdy, cnt_data_rdy, batch_finish;

reg [1:0] group;

reg signed [`n-1:0] feature_store [0:29];

reg signed [`n-1:0] centroid_1 [0:29];

reg signed [`n-1:0] centroid_2 [0:29];

reg signed [`n-1:0] centroid_3 [0:29];

wire [`n-1:0] f_out;

reg f_finish_x,f_finish_y,f_finish_z;

wire xsel,ysel,zsel, start, int_en;

integer j2,j3;

reg [`n-1:0] input_2_x,input_2_y,input_3_x,input_3_y,input_4_x,input_4_y;

reg [`n2-1:0] mode2,mode3,mode4;

wire [`n-1:0] result_2,result_3,result_4,z_2,z_3,z_4;

wire [15:0] ctrl_reg;

reg start_reg, int_en_reg;
reg [1:0] xyz_reg;

reg [15:0] fc_reg_l;
reg [15:0] fc_reg_h;

wire [29:0] feature_code;

wire [15:0] rf_count;

feature_extractor f_e0 (f_out, f_finish, rf_input, start, clk, nReset, rf_data_rdy, rf_count);


// xyz reg
always @(posedge clk or negedge nReset)
if (!nReset)
begin
	xyz_reg [1:0] <= 0;
end
else if (!nCs && !nWr)
begin
	if (Addr == `CTRLadr)
		xyz_reg [1:0] <= dataIn [1:0];		
end


// start
always @(posedge clk or negedge nReset)
if (!nReset)
	start_reg <= 0;
else if (!int)
begin
	if (!nCs && !nWr)
	begin
		if (Addr == `CTRLadr)
		start_reg <= dataIn[15];
	end
end
else
		start_reg <= 0;		

// int_enable
always @(posedge clk or negedge nReset)
if (!nReset)
	int_en_reg <= 0;
else if (!int)
begin
	if (!nCs && !nWr)
	begin
		if (Addr == `CTRLadr)
		int_en_reg <= dataIn[2];
	end
end
else
	int_en_reg <= 0;
	
assign xsel = (xyz_reg==2'b00) ? 1'b1 : 1'b0;
assign ysel = (xyz_reg==2'b01) ? 1'b1 : 1'b0;
assign zsel = (xyz_reg[1]==1'b1) ? 1'b1 : 1'b0;
assign ctrl_reg = {start_reg,12'b0,int_en_reg,xyz_reg};
assign start = start_reg;
assign int_en = int_en_reg;

// FC reg
always @(posedge clk or negedge nReset)
if (!nReset)
begin
	fc_reg_l <= 0;
	fc_reg_h <= 0;
end
else if (!nCs && !nWr)
begin
	if (Addr[2:1] == 2'b11)
	begin
		if (Addr[0] == 0)
			fc_reg_l <= dataIn;
		else
			fc_reg_h <= dataIn;
	end		
end

assign feature_code = {fc_reg_h[13:0],fc_reg_l};

always @(posedge clk or negedge nReset)
if (!nReset)
begin
	rf_input <= 0;
	rf_data_rdy <= 0;
end
else if (!nCs && !nWr && start)
begin
	if (Addr == `RFadr)
	begin
		rf_input <= dataIn;
		rf_data_rdy <= 1;
	end
	else
		rf_data_rdy <= 0;	
end
else
begin
	rf_data_rdy <= 0;
end
			
always @(posedge clk or negedge nReset)
if (!nReset)
begin
	cnt_input <= 0;
	cnt_data_rdy <= 0;
end
else if (!nCs && !nWr && start)
begin
	if (Addr == `CTadr)
	begin
		cnt_input <= dataIn;
		cnt_data_rdy <= 1;
	end
	else
		cnt_data_rdy <= 0;
end
else
begin
//	cnt_input <= 0;
	cnt_data_rdy <= 0;
end

       
always @(posedge clk or negedge nReset)

if (!nReset)
begin
	for (j2=0; j2<30; j2=j2+1)	
	begin
		centroid_1[j2] <= 0;		
		centroid_2[j2] <= 0;		
		centroid_3[j2] <= 0;		
	end
	centroid_count <= 0;		
end   
else if (start)
begin	
	if (centroid_count < 30)
	begin	
		

		if (cnt_data_rdy)
		begin
		if (xsel)
		begin			
			centroid_1[centroid_count] <= cnt_input<<8;
			centroid_count <= centroid_count + 1;
		end
		else if (ysel)
		begin
			centroid_2[centroid_count] <= cnt_input<<8;
			centroid_count <= centroid_count + 1;
		end
		else if (zsel)
		begin
			centroid_3[centroid_count] <= cnt_input<<8;
			centroid_count <= centroid_count + 1;
		end
		end		
	end
	else
		centroid_count <= centroid_count;
end
else
	centroid_count <= 0;


always @(posedge clk or negedge nReset)

if (!nReset)
begin
	feature_count_x <= 0;
	feature_count_y <= 0;
	feature_count_z <= 0;
		for (j3=0; j3<30; j3=j3+1)	
		feature_store[j3] <= 0;			
end
else if (start)
	begin
		if (f_finish_x)
		begin
			if (feature_count_x <= 9)
			begin
				feature_count_x <= feature_count_x + 1;
				feature_store[feature_count_x] <= f_out;
			end
		end
		else if (f_finish_y)
		begin	
			if (feature_count_y <= 9)
			begin
				feature_count_y <= feature_count_y + 1;
				feature_store[feature_count_y+10] <= f_out;
			end
		end
		else if (f_finish_z)
		begin	
			if (feature_count_z <= 9)
			begin
				feature_count_z <= feature_count_z + 1;
				feature_store[feature_count_z+20] <= f_out;
			end
		end
	end
else if (batch_finish)
begin
	feature_count_x <= 0;
	feature_count_y <= 0;
	feature_count_z <= 0;
end	
		

always @(posedge clk or negedge nReset)

if (!nReset)
begin
	f_finish_x <= 0;
	f_finish_y <= 0;
	f_finish_z <= 0;
end
else if (start)
begin
	if ((f_finish == 1))	
	begin
		if (xsel)
			f_finish_x <= 1;	
		else if (ysel)
			f_finish_y <= 1;	
		else if (zsel)
			f_finish_z <= 1;	
	end
end		
else
begin
	f_finish_x <= 0;
	f_finish_y <= 0;
	f_finish_z <= 0;
end	


always @(posedge clk or negedge nReset)

if (!nReset)
begin			
	count_feat <= 0;	
	input_2_x <= 0;
	input_2_y <= 0;		
	mode2 <= 0;	
	input_3_x <= 0;
	input_3_y <= 0;		
	mode3 <= 0;	
	input_4_x <= 0;
	input_4_y <= 0;		
	mode4 <= 0;		
	count_cent <= 0;
end
else if (start)
begin	

	// Minimum distance classification using CORDIC
	
	if (feature_count_x > 9 && feature_count_y > 9 && feature_count_z > 9 && centroid_count > 29 && zsel)
	begin
		mode2 <= `mode_circular;
		mode3 <= `mode_circular;
		mode4 <= `mode_circular;
	
		if (count_feat <= 29)
		begin
			if (feature_code[count_feat] == 1)
			begin
				if (count_cent == 0)
				begin
					input_2_x <= 0;
					input_2_y <= (feature_store[count_feat] - centroid_1[count_cent]);		
					input_3_x <= 0;
					input_3_y <= (feature_store[count_feat] - centroid_2[count_cent]);		
					input_4_x <= 0;
					input_4_y <= (feature_store[count_feat] - centroid_3[count_cent]);		
				end
				else
				begin
					input_2_x <= result_2;
					input_2_y <= (feature_store[count_feat] - centroid_1[count_cent]);
					input_3_x <= result_3;
					input_3_y <= (feature_store[count_feat] - centroid_2[count_cent]);
					input_4_x <= result_4;
					input_4_y <= (feature_store[count_feat] - centroid_3[count_cent]);
				end			
				count_cent <= count_cent + 1;			
			end
			else
			begin
				if (count_feat == 0)
				begin
					input_2_x <= input_2_x;
					input_2_y <= input_2_y;
					input_3_x <= input_3_x;
					input_3_y <= input_3_y;
					input_4_x <= input_4_x;
					input_4_y <= input_4_y;
				end
				else
				begin
					input_2_x <= 0;
					input_2_y <= result_2;
					input_3_x <= 0;
					input_3_y <= result_3;
					input_4_x <= 0;
					input_4_y <= result_4;
				end			
			end
			count_feat <= count_feat + 1;
		end
		else
		begin
			input_2_x <= input_2_x;
			input_2_y <= input_2_y;	
			mode2 <= mode2;		
			input_3_x <= input_3_x;
			input_3_y <= input_3_y;
			mode3 <= mode3;		
			input_4_x <= input_4_x;
			input_4_y <= input_4_y;
			mode4 <= mode4;				
		end
	end
	else
	begin
		input_2_x <= input_2_x;
		input_2_y <= input_2_y;	
		mode2 <= mode2;		
		input_3_x <= input_3_x;
		input_3_y <= input_3_y;
		mode3 <= mode3;		
		input_4_x <= input_4_x;
		input_4_y <= input_4_y;
		mode4 <= mode4;			
	end	
end
else
begin			
	count_feat <= 0;	
	input_2_x <= 0;
	input_2_y <= 0;		
	mode2 <= 0;	
	input_3_x <= 0;
	input_3_y <= 0;		
	mode3 <= 0;	
	input_4_x <= 0;
	input_4_y <= 0;		
	mode4 <= 0;		
	count_cent <= 0;
end
	

always @(posedge clk or negedge nReset)

if (!nReset)
begin
	group <= 2'b00;
	batch_finish <= 0;
end
else if (start)
begin
	if (count_feat >= 30)
	begin
		if (result_2 < result_3)
		begin
			if (result_2 < result_4)
			begin
				group <= 2'b00;
				batch_finish <= 1;
			end							
			else
			begin
				group <= 2'b10;
				batch_finish <= 1;			
			end
		end
		else
		begin
			if (result_3 < result_4)	
			begin
				group <= 2'b01;
				batch_finish <= 1;		
			end
			else
			begin			
				group <= 2'b10;
				batch_finish <= 0;			
			end
		end
	end
	else
	begin
		group <= group;
		batch_finish <= batch_finish;	
	end
end
else
begin
//	group <= 2'b00;
	batch_finish <= 0;
end

always @(*)
begin
	if (!nCs && nWr && !nRd)
	begin
			case(Addr)
		
			`RFadr : data_out = rf_input;

			`CTadr : data_out = cnt_input;

			`CTRLadr : data_out = ctrl_reg;

			`DOUTadr : data_out = {14'b0,group};

			`RFCNTadr : data_out = rf_count;

			`CTCNTadr : data_out = centroid_count;

			`FCadrl : data_out = fc_reg_l;

			`FCadrh : data_out = fc_reg_h;

			default : data_out = 0;
			endcase
	end
	else
		data_out = 0;
end

assign dataOut = data_out;

cordic c2(z_2,result_2,input_2_x,input_2_y,mode2);

cordic c3(z_3,result_3,input_3_x,input_3_y,mode3);

cordic c4(z_4,result_4,input_4_x,input_4_y,mode4);


always @(posedge clk or negedge nReset)
if (!nReset)
	int <= 0;
else if (batch_finish)
	int <= 1;
else
	int <= 0;


assign Intr = (int_en == 1) ? int : 1'b0;


endmodule
