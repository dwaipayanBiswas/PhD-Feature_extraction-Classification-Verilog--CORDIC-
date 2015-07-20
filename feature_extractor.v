//*********************************************************************************************
// Feature extraction module
// Author: Dwaipayan Biswas
// Email: db9g10@ecs.soton.ac.uk
// University of Southampton
// Features extracted: absolute difference (max - min), standard deviation (std),
// index of dispersion (disp), kurtosis (kurt), skewness (skew), information entropy (entropy),
// jerk metric (jerk), number of peaks (perk), maximum magnitude of a peak (max_mag)
// CORDIC operated in circular mode - 	to compute square roots (rms)
// CORDIC operated in linear mode -   	to compute division (disp)
// CORDIC operated in hyperbolic mode - to compute logarithm (entropy
//*********************************************************************************************
`timescale 1ns / 100ps
`include "parameter.v"

module feature_extractor (f_out, f_finish, rf_input, start, clk, nReset, rf_data_rdy, rf_count);

output [`n-1:0] f_out;

output f_finish;

output [15:0] rf_count;

input [15:0] rf_input;

input clk, nReset, start, rf_data_rdy;

wire clk, nReset, start, rf_data_rdy;

integer j,j1;

reg signed [`n-1:0] data_store [0:`data_count-1];

reg signed [`n-1:0] rms,mean,diff,std,disp,kurt,skew,entropy,sig_max,sig_min,grad_1,grad_2,peaks,max_mag_temp,max_mag,jerk;

reg signed [9:0] count1,count2,count3;

reg signed [4:0] count_f;

reg signed [`n-1:0] feature;

reg signed [`n1-1:0] sum,ent_temp;

reg signed [`n3-1:0] sum_kurt,sum_skew,velocity,velocity_max;

reg [`n-1:0] input_0_1,input_0_2,input_1_1,input_1_2,temp,temp_new,temp1,a11,a12,a21,a22,thr1,thr2,thr3;

reg [`n2-1:0] mode0,mode1;

reg finish;

wire [`n-1:0] result_0,result_1,z_0,z_1;

wire [23:0] data_in;

assign f_finish = finish;
assign f_out = feature;

assign rf_count = count1;

assign data_in = rf_input<<8;

always @(posedge clk or negedge nReset)

if (!nReset)
begin
	for (j=0; j<`data_count; j=j+1)	
		data_store[j] <= 0;			
	count1 <= 0;	
end
else if (start)
begin
	if (rf_data_rdy) 
	begin
		if (count1 <= `data_count)
		begin
			data_store[count1] <= data_in;
			count1 <= count1 + 1;					
		end	
	end
end
else
begin
	for (j=0; j<`data_count; j=j+1)	
		data_store[j] <= 0;			
	count1 <= 0;	
end


	
always @(posedge clk or negedge nReset)

if (!nReset)
begin
		
	sum <= 0;
	input_0_1 <= 0;
	input_0_2 <= 0;	
	mode0 <= 0;
	count2 <= 0;	
	rms <= 0;
	std <= 0;	
	count3 <= 0;
	disp <= 0;
	sig_max <= 0;
	sig_min <= 0;	
	count_f <= 0;	
	feature <= 0;
	mean <= 0;
	diff <= 0;
	thr1 <= 0;
	thr2 <= 0;
	thr3 <= 0;
	kurt <= 0;
	skew <= 0;
	temp <= 0;
	temp1 <= 0;
	temp_new <= 0;
	finish <= 0;
	sum_kurt <= 0;
	sum_skew <= 0;
end
else if (start)
begin
	if (rf_data_rdy)
	begin	
		if (count1 <= `data_count-1)
		begin			
			sum <= sum + data_in;
		
			if (count1 == 0)
			begin
				sig_max <= data_in;
				sig_min <= data_in;
				
				input_0_1 <= data_store[0];
				input_0_2 <= 0;
				mode0 <= `mode_circular;
			end
			else
			begin
				input_0_1 <= result_0;
				input_0_2 <= data_store[count1-1];
				mode0 <= `mode_circular;
				
				if (data_in > sig_max)
				begin
					sig_max <= data_in;
					sig_min <= sig_min;
				end
				else
				begin
					if (data_in < sig_min)
					begin
						sig_min <= data_in;
						sig_max <= sig_max;					
					end
					else
					begin
						sig_min <= sig_min;
						sig_max <= sig_max;					
					end
				end
			end	
		end						
	end	
	
	if (count1 > `data_count-1)
	begin
		mean <= sum>>`divide_256;	
		diff <= sig_max-sig_min;	
		
						
		thr1 <= (sig_min + sig_max)>>`divide_2;
		thr2 <= (sig_min + thr1)>>`divide_2;
		thr3 <= (thr1 + sig_max)>>`divide_2;
		
		if (count2 <= `data_count)
		begin
			count2 <= count2 + 1;
			
			if (count2 == 0)
				rms <= result_0>>`divide_16;	
				
			else if(count2 == 1)
			begin				 
				input_0_1 <= 0;
				input_0_2 <= (data_store[count2-1]-mean);					
			end
			else
			begin
				rms <= rms;
				input_0_1 <= result_0;
				input_0_2 <= (data_store[count2-1]-mean);												
			end			
		end
		else
		begin
			if (count3 <= `data_count+6)
			begin
				count3 <= count3 + 1;	

				if (count3 < 1)				
					std <= result_0>>`divide_16;																						
				else
				begin
							
					if (count3 <= 2)
					begin
						input_0_1 <= mean;
						input_0_2 <= std;			
						mode0 <= `mode_linear;
						disp <= (z_0*std)/(`pow_15);	
					end
					else
					begin
						input_0_1 <= std;					
						input_0_2 <= temp_new;					
						
						if (count3 <= `data_count+2)				
							temp <= (data_store[count3-3]-mean);			
						else
							temp <= 0;
					
						if (temp[`n-1] == 1)				
							temp_new <= ((~temp)+1);			
						else				
							temp_new <= temp;
				
						if (count3 > 4)
						begin					
							sum_kurt <= sum_kurt + (z_0*z_0*z_0*z_0);	
							
							if (count3 <= `data_count+4)
								temp1 <= (data_store[count3-5]-mean);	
							else
								temp1 <= 0;
								
							if (temp1[`n-1] == 1)								
							sum_skew <= sum_skew - (z_0*z_0*z_0); 		
							else		
							sum_skew <= sum_skew + (z_0*z_0*z_0); 						
						end						
				
						if (count3 == `data_count+5)
						begin					
							kurt <= (sum_kurt)/(2**53);					
							
							temp <= 0;
							temp_new <= 0;
						end
						
						if (count3 == `data_count+6)
						begin
							skew <= (sum_skew)/(2**38);
							finish <= 1;
							temp1 <= 0;
						end					
					end
				end			
						
			end
			else
			begin
				if ((finish == 1) && (count_f <= 9))	
				begin
					count_f <= count_f + 1;	
					case (count_f)
	
						0: feature <= rms;
						1: feature <= diff;
						2: feature <= std;
						3: feature <= disp;
						4: feature <= kurt;
						5: feature <= skew;
						6: feature <= entropy;
						7: feature <= jerk;
						8: feature <= peaks;
						9: feature <= max_mag;
	
						default: feature <= 0;
					endcase
				end
				else		
					count_f <= count_f;					
			end
		end		
	end
end
else
begin
	sum <= 0;
	input_0_1 <= 0;
	input_0_2 <= 0;	
	mode0 <= 0;
	count2 <= 0;	
	rms <= 0;
	std <= 0;		
	count3 <= 0;
	disp <= 0;
	sig_max <= 0;
	sig_min <= 0;	
	count_f <= 0;
	feature <= 0;
	mean <= 0;
	diff <= 0;
	thr1 <= 0;
	thr2 <= 0;
	thr3 <= 0;
	kurt <= 0;
	skew <= 0;
	temp <= 0;
	temp1 <= 0;
	temp_new <= 0;	
	finish <= 0;
    sum_kurt <= 0;
	sum_skew <= 0;
end


always @(posedge clk or negedge nReset)

if (!nReset)
begin		
	peaks <= 0;
	max_mag_temp <= 0;
	max_mag <= 0;
	grad_1 <= 0;
	grad_2 <= 0;	
	input_1_1 <= 0;
	input_1_2 <= 0;
	mode1 <= 0;
	jerk <= 0;
	velocity <= 0;
	velocity_max <= 0;	
	a11 <= 0;
	a12 <= 0;
	a21 <= 0;
	a22 <= 0;	
	ent_temp <= 0;
	entropy <= 0;
end
else if (start)
begin
	if (rf_data_rdy)
	begin
		if (velocity > velocity_max)
			velocity_max <= velocity;
		else
			velocity_max <= velocity_max;
			
		if (max_mag_temp > max_mag)
			max_mag <= max_mag_temp;
		else
			max_mag <= max_mag;	
			
		if (count1 >=2 && count1 <= `data_count-1)
		begin			
			grad_1 <= data_store[count1-1] - data_store[count1-2];

			velocity <= velocity + (data_store[count1-1] + data_store[count1-2])/2;

			if (count1 <= `data_count-1)
			begin
				grad_2 <= data_in - data_store[count1-1];
				
				if (count1 == 3)
				begin
					mode1 <= `mode_circular;
					input_1_1 <= grad_1;
					input_1_2 <= grad_2;				
				end
				else
				begin
					mode1 <= `mode_circular;
					input_1_1 <= result_1;
					input_1_2 <= grad_2;
				end	
			end							

			if ((grad_2 < 0) && (grad_1 > 0))		
			begin
				peaks <= peaks + 1;			
				max_mag_temp <= data_store[count1-2];			
			end
		end
	end

	if (count1 > `data_count-1)
	begin
		if (count2 <= `data_count)
		begin
			if (count2 > 1)
			begin
				if (data_store[count2-1] >= sig_min && data_store[count2-1] < thr2)
					a11 <= a11 + 1;
				else if (data_store[count2-1] >= thr2 && data_store[count2-1] < thr1)
					a12 <= a12 + 1;
				else if (data_store[count2-1] >= thr1 && data_store[count2-1] < thr3)
					a21 <= a21 + 1;
				else
					a22 <= a22 + 1;	
			end
			
				
			if (count2 <= 2)
			begin		
			
					if (velocity > velocity_max)
						velocity_max <= velocity;
					else
						velocity_max <= velocity_max;
						
					if (count2 == 2)		
					begin
						mode1 <= `mode_linear;
						input_1_1 <= velocity_max/(256);
						input_1_2 <= (result_1)/(256);				
					end								
			end
			else
			begin
				if (count2 == 3)
					jerk <= z_1;
				else				
					jerk <= jerk;
			end		
		end
		else
		begin			
			jerk <= jerk;
			a11 <= a11;
			a12 <= a12;
			a21 <= a21;
			a22 <= a22;			
		
			if (count3 == 1)
			begin
				input_1_1 <= ((`pow_15) + (a11*(`pow_15))/(2**8));
				input_1_2 <= ((`pow_15) - (a11*(`pow_15))/(2**8));
				mode1 <= `mode_hyperbolic;				
			end
			else
			begin
				if (count3 == 2)
				begin
					input_1_1 <= ((`pow_15) + (a12*(`pow_15))/(2**8));
					input_1_2 <= ((`pow_15) - (a12*(`pow_15))/(2**8));
					ent_temp <= ent_temp + (a11*z_1);
					mode1 <= `mode_hyperbolic;
				end
				else
				begin
					if (count3 == 3)
					begin
						input_1_1 <= ((`pow_15) + (a21*(`pow_15))/(2**8));
						input_1_2 <= ((`pow_15) - (a21*(`pow_15))/(2**8));
						ent_temp <= ent_temp + (a12*z_1);
						mode1 <= `mode_hyperbolic;
					end
					else
					begin
						if (count3 == 4)
						begin
							input_1_1 <= ((`pow_15) + (a22*(`pow_15))/(2**8));
							input_1_2 <= ((`pow_15) - (a22*(`pow_15))/(2**8));
							ent_temp <= ent_temp + (a21*z_1);
							mode1 <= `mode_hyperbolic;
						end
						else
						begin
							if (count3 == 5)
							begin
								entropy <= ~((ent_temp + (a22*z_1))/(2**8));
								input_1_1 <= input_1_1;
								input_1_2 <= input_1_2;
								mode1 <= mode1;
								ent_temp <= ent_temp;
							end
							else
							begin
								ent_temp <= ent_temp;
								entropy <= entropy;								
							end
						end
					end
				end
			end		
		end
	end		
end 
else
begin
	peaks <= 0;
	max_mag_temp <= 0;
	max_mag <= 0;
	grad_1 <= 0;
	grad_2 <= 0;	
	input_1_1 <= 0;
	input_1_2 <= 0;
	mode1 <= 0;
	jerk <= 0;
	velocity <= 0;
	velocity_max <= 0;	
	a11 <= 0;
	a12 <= 0;
	a21 <= 0;
	a22 <= 0;	
	ent_temp <= 0;
	entropy <= 0;	
end 


cordic c0(z_0,result_0,input_0_1,input_0_2,mode0);


cordic c1(z_1,result_1,input_1_1,input_1_2,mode1);


endmodule
