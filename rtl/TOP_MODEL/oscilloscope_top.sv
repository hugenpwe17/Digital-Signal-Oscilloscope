module oscilloscope(
	input  wire 	  CLK,
	input  wire 	  DCAC,
	input  wire 	  reset,
	
	output wire		  VGA_hSync, 
	output wire		  VGA_vSync, 
	output wire		  VGA_clk,
	output wire		  blank_n,
	output wire [7:0] Red,
	output wire [7:0] Blue,
	output wire [7:0] Green,

	output wire 	  ADC_DIN,
	output wire 	  ADC_CS_N,
	input  wire		  ADC_DOUT,
	output wire 	  ADC_SCLK,

	input  wire	 	  button_d,
	input  wire	 	  button_u
);

	//input SCALE;
	reg [2:0]SCALE = 3'd4;

	wire [11:0]Readed_data;
	wire ADC_CLK;
	wire [23:0]frequency;
	wire [19:0]max;
	wire [19:0]min;
	wire [19:0]mean;
	wire [19:0]Vp2p_vol;
	wire green;


	wire [11:0]TRIG; 
	wire [19:0]rms;
	wire [15:0]vol;
	wire [15:0]time1;
	wire [11:0]VGA_out;

	wire [9:0]xCount;
	wire [9:0]yCount;
	wire [7:0]Green_1;
	wire [7:0]Blue_1;
	wire [7:0]Red_1;
	wire PERIOD_FLAG;
	wire fifo_full;

	wire [7:0]rgb_text;
	wire [7:0]display;
	wire waveform;
	wire [24:0]DATA_OUT;
	wire Red_e;
	//wire [7:0]dataout;
	wire Blue_e;
	//wire [7:0]VGA_screen_print;
	wire [24:0]MEAN_OUT;
	wire [9:0]mean_out;
	wire [24:0]TRIG_OUT;
	wire [9:0]trig_out;
	wire [9:0]data_out;
	wire red_2;
	wire [7:0]RED_2;
	//assign 
	wire [7:0]RED_E;
	//assign TRIG = mean;
	assign mean_out = MEAN_OUT[9:0];
	assign trig_out = TRIG_OUT[9:0];
	//assign Blue = (waveform&(VGA_out[11:4]&yCount));
	ADCmodule ADC(
		.reset(reset),			// reset

		.ADC_CS_N(ADC_CS_N),    // ADC chip selection
		.ADC_DIN(ADC_DIN),      // ADC serial data in (to ADC)
		.ADC_SCLK(ADC_SCLK),    // ADC serial clock
		.ADC_DOUT(ADC_DOUT),	
		.ADC_CLK(ADC_CLK),		
		.Readed_data1(Readed_data)		// output digit data()
	);
		.clock(CLK),			//  clock(50MHz)

	font_gen fon(
		.clock(CLK),
		.max(max), 
		.min(min),
		.mea(mean),
		.p2p(Vp2p_vol),
		.rms(rms),
		.frq(frequency),
		.vol(vol), 
		.time1(time1),
		.mode(DCAC),
		.pixel_x(xCount), 
		.pixel_y(yCount),
		.rgb_text(rgb_text)
	);
		
	VGA VG(
		.clk(CLK),
		.VGA_clk(VGA_clk), 
		.VGA_hSync(VGA_hSync), 
		.VGA_vSync(VGA_vSync),
		.xCount(xCount),
		.yCount(yCount),
		.blank_n(blank_n),
		.Red_1(Red_1),
		.Blue_1(Blue_1),
		.Green_1(Green_1),
		.display(display), 
		.waveform(waveform)
	);

	function_block FUNC(
		.CLK(ADC_CLK),
		.RSTB(~reset), 
		.DATA_IN(Readed_data), 
		.TRIG(TRIG),
		.frequency(frequency), 
		.max_t(max), 
		.min_t(min), 
		.mean_t(mean),
		.Vp2p_vol_t(Vp2p_vol),
		.PERIOD_FLAG(PERIOD_FLAG),
		.mean_t2(rms)
	);

	Fifo memory(
		.clock(CLK),
		.ADC_CLK(ADC_CLK),
		.VGA_CLK(VGA_clk),
		.data_in(Readed_data),
		.fifo_full(fifo_full),
		.reset(reset),
		.xaxis(xCount),
		.PERIOD_FLAG(PERIOD_FLAG),
		.waveform(waveform),
		.VGA_out(VGA_out)
	);

	trigger_adjust trigger(
		.CLK(CLK), 
		.RSTB(~RSTB), 
		.button_u(button_u), 
		.button_d(button_d), 
		.TRIG(TRIG)
	);

	voltage_scale test_1(
		.CLK(CLK),
		.VGA_CLK(VGA_CLK),
		.DATA_IN(VGA_out), 
		.mean(mean), 
		.scale(SCALE),
		.DATA_OUT(DATA_OUT),
		.MEAN_OUT(MEAN_OUT),
		.TRIG(TRIG),
		.TRIG_OUT(TRIG_OUT)
	);

	assign red_2 = waveform&&(trig_out == yCount);
	assign RED_2 = {red_2,red_2,red_2,red_2,red_2,red_2,red_2,red_2};
	assign Green = (display&(rgb_text|Green_1));

	assign Blue_e =  waveform&&
	((( data_out<= (yCount + 10'd2))&&(data_out >= (yCount - 10'd2)))||
	((~DCAC)&&(( mean_out<= (yCount + 10'd2))&&(mean_out >= (yCount - 10'd2)))));
	assign Blue = {Blue_e,Blue_e,Blue_e,Blue_e,Blue_e,Blue_e,Blue_e,Blue_e};

	assign Red_e = waveform && (( mean_out<= (yCount + 10'd2))&&(mean_out >= (yCount - 10'd2)));
	assign RED_E  ={1'b0,Red_e,Red_e,Red_e,Red_e,3'b000};
	assign Red = (RED_E | RED_2);

endmodule
