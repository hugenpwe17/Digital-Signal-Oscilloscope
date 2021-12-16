module vga(
    input sys_clk,
    input sys_rst_n,

    output vga_h_sync,
    output vga_v_sync,

    output [2:0] rgb
)
    // vga signal 640*480 @ 60Hz
    // 640 16 96 48 800
    // 480 10 2  33 525
    integer h_visible_area  = 640;
    integer h_front_porch   = 16;
    integer h_sync_pulse    = 96;
    integer h_back_proch    = 48;

    integer v_visible_area  = 480;
    integer v_front_proch   = 10;
    integer v_sync_pulse    = 2;
    integer v_back_proch    = 33;
endmodule