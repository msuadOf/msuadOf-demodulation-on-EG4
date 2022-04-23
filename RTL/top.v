module top (
    input  clk,
    input  rst, 
    output wire spi_msi001_data_out,
    output wire spi_msi001_clk_out,
    output wire spi_msi001_en_out,    
	output wire debug
);
wire spi_clk;
wire [5:0] empty;
pll pll1(
  .refclk(clk),
  .reset(rst),
  .stdby(1'b0),
  .clk0_out(empty[0]),
  .clk1_out(spi_clk),
  .clk2_out(empty[1]),
  .clk3_out(empty[2]),
  .clk4_out(empty[3]),
  .extlock(empty[4])
  );
msi001_spi msi001(
    .clk(spi_clk),
    .reset(rst),
    .spi_msi001_data_in(24'b1110_1011_1010_1110_1010_1011),
    .spi_msi001_data_out(spi_msi001_data_out),
    .spi_msi001_clk_out(spi_msi001_clk_out),
    .spi_msi001_en_out(spi_msi001_en_out) ,    
	.debug(debug)   
);        


endmodule //top