module bootloader (
  input  wire i_clk_48m,
  output wire o_clk_48m_en,

  inout  io_usbp,
  inout  io_usbn,
  output o_usb_pu,

  output RGB0,
  output RGB1,
  output RGB2,

  input  io_miso,
  output o_cs_flash,
  output io_mosi,
  output o_sck
);
  assign RGB1 = 1;
  assign RGB2 = 1;
  // Float the clock enable by default...
  reg clock_enable = 0;
  tristate tristate_clk_en();

  // Subdivide the 48MHz clock
  wire clk_48mhz;
  assign clk_48mhz = i_clk_48m;
	reg clk_24mhz;
	reg clk_12mhz;
	always @(posedge clk_48mhz) clk_24mhz = !clk_24mhz;
	always @(posedge clk_24mhz) clk_12mhz = !clk_12mhz;

	wire clk = clk_12mhz; // quarter speed clock

  // Warmboot
  wire boot;
  SB_WARMBOOT warmboot_inst (
    .S1(1'b0),
    .S0(1'b1),
    .BOOT(boot)
  );

  // Bootloader IP
  wire usb_p_tx;
  wire usb_n_tx;
  wire usb_p_rx;
  wire usb_n_rx;
  wire usb_p_rx_io;
  wire usb_n_rx_io;
  wire usb_tx_en;

  tinyfpga_bootloader tinyfpga_bootloader_inst (
    .clk_48mhz(clk_48mhz),
    .clk(clk),
    .reset(reset),
    .usb_p_tx(usb_p_tx),
    .usb_n_tx(usb_n_tx),
    .usb_p_rx(usb_p_rx),
    .usb_n_rx(usb_n_rx),
    .usb_tx_en(usb_tx_en),
    .led(RGB0),
    .spi_miso(io_miso),
    .spi_cs(o_cs_flash),
    .spi_mosi(io_mosi),
    .spi_sck(o_sck),
    .boot(boot)
  );

  assign o_usb_pu = 1'b1;

  wire usb_p_rx_io;
  wire usb_n_rx_io;
  assign usb_p_rx = usb_tx_en ? 1'b1 : usb_p_rx_io;
  assign usb_n_rx = usb_tx_en ? 1'b0 : usb_n_rx_io;

  tristate usbn_buffer(
	.pin(io_usbn),
	.enable(usb_tx_en),
	.data_in(usb_n_rx_io),
	.data_out(usb_n_tx)
  );

  tristate usbp_buffer(
	.pin(io_usbp),
	.enable(usb_tx_en),
	.data_in(usb_p_rx_io),
	.data_out(usb_p_tx)
  );
endmodule

module tristate(
  inout pin,
  input enable,
  input data_out,
  output data_in
);
  SB_IO #(
    .PIN_TYPE(6'b1010_01) // tristatable output
  ) buffer(
    .PACKAGE_PIN(pin),
    .OUTPUT_ENABLE(enable),
    .D_IN_0(data_in),
    .D_OUT_0(data_out)
  );
endmodule
