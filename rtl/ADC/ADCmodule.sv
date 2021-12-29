module ADCmodule (
	input  wire		  clock,		// clock, default is 50MHz
	input  wire 	  reset,		// reset,
	    
	output wire 	  ADC_CS_N,		// ADC chip selection
	output wire 	  ADC_DIN, 		// ADC serial data in (to ADC)
	output wire 	  ADC_SCLK,		// ADC serial clock
	input  wire 	  ADC_DOUT,

	output reg [4:0]  Leds,
	output reg 	 	  ADC_CLK,
	output reg [11:0] Readed_data1
);

	reg  [9:0]	 	 counter; 	// ADC clk counter 67 posedge one valid output . 
								// 2 channel 134 cycle wait time for refreshing output data.
	wire [7:0][11:0] Data;

	initial begin
		Readed_data1 = 0;
		ADC_CLK 	 = 0;
	end

	ADC set(
		.clock		( clock		),
		.reset		( reset		),
		.ADC_CS_N	( ADC_CS_N	),
		.ADC_DIN	( ADC_DIN	),
		.ADC_DOUT	( ADC_DOUT	),
		.ADC_SCLK	( ADC_SCLK	),
		.data		( Data		)
	);
	always @(posedge clock)begin
		if(counter >= 10'd536) begin// refresh with new data
			Readed_data1 <= Data[0];
			counter 	 <= 0;
			ADC_CLK 	 <= 1'b1;
			Leds 		 <= Readed_data1[11:7];
		end else begin
			counter <= counter + 1 ;
			ADC_CLK <= 1'b0;
		end	
	end

endmodule
