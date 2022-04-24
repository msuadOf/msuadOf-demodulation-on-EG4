module top (
    input  clk,
    input  rst, 
    output wire spi_msi001_data_out,
    output wire spi_msi001_clk_out,
    output wire spi_msi001_en_out,    
	output wire debug
);			
reg msi001_spi_completeHandleState;
wire msi001_spi_complete;
reg msi001_spi_reset;	
reg [23:0] spi_data;
parameter SPI_DATA_1=24'b1110_1011_1010_1110_1010_1011;
parameter SPI_DATA_2=24'b0000_1001_1010_1111_1010_1011;
reg [7:0] spi_count;
always @(clk or msi001_spi_complete)
	begin
		if(rst)
			begin
				spi_data<=24'b0;			
				spi_count<=8'b0;
			end
		else			
	begin				
if(msi001_spi_complete) msi001_spi_completeHandleState<=1'b1;//结束响应标志位
			if(msi001_spi_completeHandleState)		
				begin						
					case(spi_count)		
						0:				
							begin				
								spi_count<=spi_count+8'b1;							
								spi_data<=SPI_DATA_1;								
								msi001_spi_reset<=0;			
							end										
						1:								
							begin				
								spi_count<=spi_count+8'b1;							
								spi_data<=SPI_DATA_1;								
								msi001_spi_reset<=1;			
							end										
						2:							
							begin				
								spi_count<=8'b0;							
								spi_data<=SPI_DATA_1;								
								msi001_spi_reset<=0;									
								msi001_spi_completeHandleState<=1'b0;//标志位清空		
							end		
						default:				
							begin				
								spi_count<=8'b0;				
							end
					endcase

				end
end 
end

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
    .spi_msi001_data_in(spi_data),
    .spi_msi001_data_out(spi_msi001_data_out),
    .spi_msi001_clk_out(spi_msi001_clk_out),
    .spi_msi001_en_out(spi_msi001_en_out) ,      
	.complete( msi001_spi_complete), //当发送完毕，会停下，并发送一个高脉冲表示以完成     
	._reset(msi001_spi_reset),
	.debug()   
);        
assign debug=msi001_spi_complete;

endmodule //top