/*
Description:
Driver for AD7928 ADC on DE1_SoC board.
See accompanying tutorial document for details.
*/

module ADC #(
	// PARAMETER DEFINE
	// range (0: 0V-5V, 1: 0V-2.5V)
	// coding (0: two's complement, 1: straight binary)
	parameter CODING = 1'b1, parameter RANGE = 1'b0
	)(
		input	wire 			clock,		// clock (50MHz) and reset
		input	wire 			reset,
		
		output	reg 			ADC_CS_N,	// ADC chip selection
		output	reg 			ADC_DIN,	// ADC serial data in (to ADC)
		output	reg 			ADC_SCLK,	// ADC serial clock
		input	wire 			ADC_DOUT,	// ADC serial data out (from ADC)
		
		output 	reg [7:0][11:0] data		// ADC data out, 8 channels(sel), 12 bits per channel
	);          

	// STATES DEFINE
	parameter QUIET0 = 3'b000, QUIET1 = 3'b001, QUIET2 = 3'b010;
	parameter CYCLE0 = 3'b100, CYCLE1 = 3'b101, CYCLE2 = 3'b110, CYCLE3 = 3'b111;
	
	// internal state holding elements
	reg [2:0] 	state;  	// present state
	reg [2:0]	addr;   	// present channel address
	reg [3:0] 	count;  	// present count
	reg [14:0] 	buffer; 	// present buffer contents
	
	// INITIAL VALUES
	initial begin
		ADC_CS_N 	<= 1'b1;
		ADC_DIN 	<= 1'b0;
		ADC_SCLK 	<= 1'b1;

		state 		<= QUIET0;
		
		addr 		<= 3'b0;
		count 		<= 4'b0;
		buffer 		<= 15'b0;
	end
	
	// intermediate values
	wire [3:0] 	count_incr; // count + 1    
	reg 		ctrl;       // present control bit
	
	// determine count_incr
	assign count_incr = count + 1'b1;
	
	// determine ctrl
	always @(*)
		case (count)
			4'b0000: // WRITE
				ctrl = 1'b1;
			4'b0001: // SEQ
				ctrl = 1'b0;
			4'b0010: // DON'T CARE
				ctrl = 1'bx;
			4'b0011: // ADD2
				ctrl = addr[2];
			4'b0100: // ADD1
				ctrl = addr[1];
			4'b0101: // ADD0
				ctrl = addr[0];
			4'b0110: // PM1
				ctrl = 1'b1;
			4'b0111: // PM0
				ctrl = 1'b1;
			4'b1000: // SHADOW
				ctrl = 1'b0;
			4'b1001: // DON'T CARE
				ctrl = 1'bx;
			4'b1010: // RANGE
				ctrl = RANGE;
			4'b1011: // CODING
				ctrl = CODING;
			default: // DON'T CARE
				ctrl = 1'bx;
		endcase
	
	// transitions for state holding elements
	always @(posedge clock) begin
		if (reset) begin
			ADC_CS_N 	<= 1'b1;
			ADC_DIN 	<= 1'b0;
			ADC_SCLK 	<= 1'b1;
			state 		<= QUIET0;
			addr 		<= 3'b0;
			count 		<= 4'b0;
			buffer 		<= 15'b0;
		end else begin
			case (state)
				QUIET0: begin						// first clock cycle of quiet period, xfer buffer to data
					state 				<= QUIET1;
					data[buffer[14:12]] <= buffer[11:0];
				end
				QUIET1: begin
					state <= QUIET2;
				end
				QUIET2: begin						// end the quiet period by bringing CS low and setting up first data bit
					state 		<= CYCLE0;
					ADC_CS_N 	<= 1'b0;
					ADC_DIN 	<= ctrl;
					count 		<= count_incr;
				end
				CYCLE0: begin						// first clock cycle of serial data xfer cycle, bring SCLK low
					state 		<= CYCLE1;
					ADC_SCLK 	<= 1'b0;
				end
				CYCLE1: begin
					state <= CYCLE2;
				end
				CYCLE2: begin						// bring SCLK high
					state 		<= CYCLE3;
					ADC_SCLK 	<= 1'b1;
				end
				CYCLE3: begin						// get data in and prepare for next cycle or transition back to quiet	
					if (count == 4'b1111) begin		// back to quiet
						state 		<= QUIET0;
						ADC_CS_N 	<= 1'b1;
						addr 		<= addr + 1'b1;
					end else begin
							state <= CYCLE0;
					end
					ADC_DIN 	<= ctrl;
					buffer 		<= {buffer[13:0], ADC_DOUT};
					count 		<= count_incr;
				end
			endcase
		end
	end
endmodule
