/*
    ==========================================
    |                                        |
    |  clk_in must below 10MHz (SPI 3.33Mhz) |
    |                                        |
    ==========================================
*/

/*
    ===============================
    |                                       |
    |  module used to divide 10Mhz to 2.5M  |
    |                                       |
    ===============================
*/
module division_4 (
    input clk,
    output reg clk_out
);
    reg[1:0] clk_state;

//reset
  always @(posedge clk) 
  begin
      if(clk_state == 2'b11)
          clk_state <= 2'b00;
      else
          clk_state <= clk_state + 1;
  end

  always @(posedge clk) 
  begin
      case (clk_state)
          0: clk_out <= 1'b0;
          1: clk_out <= 1'b0;
          2: clk_out <= 1'b1;
          3: clk_out <= 1'b1;
      endcase
  end
endmodule //division_4

/*
  @ brief:
    main module of msi001_spi_master
*/
module msi001_spi (
    input clk,
    input reset,
    input [23:0] spi_msi001_data_in,
    output reg spi_msi001_data_out,
    output reg spi_msi001_clk_out,
    output reg spi_msi001_en_out
);
wire clk_div_4;//2.5Mhz clk
division_4 div_4(
    .clk(clk), 
    .clk_out(clk_div_4)
);

reg [5:0] count;
//reg [4:0] count_bit;
always @(posedge clk_div_4 or reset)
begin
    if(reset)
        begin
            count<=6'b0;
            spi_msi001_data_out<=1'b0;
            spi_msi001_clk_out<=1'b0;
            spi_msi001_en_out<=1'b1;     
        end   

    else
        case(count)
            0,1:
                begin
                    //count_bit=0;
                    spi_msi001_data_out<=1'b0 ;
                    spi_msi001_en_out<= 1'b1;
                    spi_msi001_clk_out<= 1'b0;
                    count <= count + 6'b1;
                end
            2 ,4 ,6 ,8 ,10,12,14,16,18,20,
            22,24,26,28,30,32,34,36,38,40,
            42,44,46,48://偶数位，clk拉低，en拉低，data发生变化
                begin
                    spi_msi001_data_out<= spi_msi001_data_in[23- (count[5:1]-1) ];
                    spi_msi001_en_out<= 1'b0;
                    spi_msi001_clk_out<= 1'b0;
                    count <= count +6'b1;
                end
            3 ,5 ,7 ,9 ,11,13,15,17,19,21,
            23,25,27,29,31,33,35,37,39,41,
            43,45,47,49://奇数位，clk拉高，en拉低，data保持上一个data状态
                begin
                    spi_msi001_data_out<= spi_msi001_data_in[23- (count[5:1]-1) ];
                    spi_msi001_en_out<= 1'b0;
                    spi_msi001_clk_out<= 1'b1;
                    count <= count + 6'b1;
                end
            50:
                begin
                    spi_msi001_data_out<= spi_msi001_data_in[23- (count[5:1]-1) ];
                    spi_msi001_en_out<= 1'b0;
                    spi_msi001_clk_out<= 1'b0;
                    count <= count + 6'b1;
                end
            51,52,53://EN拉高，锁存数据
            begin
                    spi_msi001_data_out<= spi_msi001_data_in[23- (count[5:1]-1) ];
                    spi_msi001_en_out<= 1'b1;
                    spi_msi001_clk_out<= 1'b0;
                    count <= count + 6'b1;
            end
            54:
            begin
                count<=6'b0;
            end                
default:            
count<=6'b0;
        endcase
end
endmodule //msi001_spi