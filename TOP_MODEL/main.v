module main (
    inout CLK,
    input reset,

    input DCAC,
    input ADC_DOUT,

    input button_d,
    input button_u,

    output VGA_clk,
    output VGA_hSync,
    output VGA_vSync,

    output blank_n,

    output [7:0] Red,
    output [7:0] Green,
    output [7:0] Blue,

    output ADC_DIN,
    output ADC_CS_N,
    output ADC_SCLK
);

oscilloscope u_oscilloscope(
    .CLK       ( CLK       ),
    .reset     ( reset     ),

    .DCAC      ( DCAC      ),
    
    .VGA_hSync ( VGA_hSync ),
    .VGA_vSync ( VGA_vSync ),
    .VGA_clk   ( VGA_clk   ),
    
    .blank_n   ( blank_n   ),
    
    .Red       ( Red       ),
    .Blue      ( Blue      ),
    .Green     ( Green     ),
    
    .ADC_DIN   ( ADC_DIN   ),
    .ADC_CS_N  ( ADC_CS_N  ),
    .ADC_SCLK  ( ADC_SCLK  ),

    .ADC_DOUT  ( ADC_DOUT  ),
    
    .button_d  ( button_d  ),
    .button_u  ( button_u  )
);

endmodule