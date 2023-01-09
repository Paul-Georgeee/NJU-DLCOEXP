module vga_ctrl(
 input pclk, //25MHz 时钟

 output reg [6:0] col_letter, // 提供给上层模块的当前扫描到的字符坐标
 output reg [4:0] row_letter,
 output reg [3:0] col_letter_pos_cnt,
 output reg [3:0] row_letter_pos_cnt,
 output [9:0] h_addr, // 提供给上层模块的当前扫描像素点坐标
 output [9:0] v_addr,

 output hsync, // 行同步和列同步信号
 output vsync,
 output valid // 消隐信号
 

);

 parameter h_frontporch = 96;
 parameter h_active = 144;
 parameter h_backporch = 774;
 parameter h_total = 800;

 parameter v_frontporch = 2;
 parameter v_active = 35;
 parameter v_backporch = 515;
 parameter v_total = 525;

 // 像素计数值
 reg [9:0] x_cnt;
 reg [9:0] y_cnt;
 wire h_valid;
 wire v_valid;


 always @(negedge pclk) // 行像素计数
 begin

        if (x_cnt == h_total)
            x_cnt <= 1;
        else
            x_cnt <= x_cnt + 10'd1;
        
        if((x_cnt > h_active) & (x_cnt <= h_backporch))
        begin
            if(col_letter_pos_cnt!=4'b1000)
                col_letter_pos_cnt <= col_letter_pos_cnt + 4'b1;
            else
            begin
                col_letter_pos_cnt <= 4'b0;
                if(col_letter==7'd69)
                    col_letter <= 0;
                else
                    col_letter <= col_letter + 7'b1;
            end
        end
   
 end

 always @(negedge pclk) // 列像素计数
 begin

  
        if (y_cnt == v_total & x_cnt == h_total)
            y_cnt <= 1;
        else if (x_cnt == h_total)
            y_cnt <= y_cnt + 10'd1;

        if((y_cnt > v_active) & (y_cnt <= v_backporch) &(x_cnt == h_total))
        begin
            if(row_letter_pos_cnt!=4'b1111)
                row_letter_pos_cnt<=row_letter_pos_cnt+4'b1;
            else
            begin
                row_letter_pos_cnt<=4'b0;
                if(row_letter==5'd29)
                    row_letter<=0;
                else
                    row_letter<=row_letter+5'b1;
            end
        end
    

 end
 // 生成同步信号
 assign hsync = (x_cnt > h_frontporch);
 assign vsync = (y_cnt > v_frontporch);
 // 生成消隐信号
 assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
 assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
 assign valid = h_valid & v_valid;
 // 计算当前有效像素坐标
 assign h_addr = h_valid ? (x_cnt - 10'd145) : {10{1'b0}};
 assign v_addr = v_valid ? (y_cnt - 10'd36) : {10{1'b0}};
 
endmodule


module clkgen(
 input clkin,
 input rst,
 input clken,
 output reg clkout
);
 parameter clk_freq = 1000;
 parameter countlimit = 50000000/2/clk_freq; // 自动计算计数次数

 reg[31:0] clkcount;
 always @ (posedge clkin)
    if(rst)
        begin
            clkcount <= 0;
            clkout <= 1'b0;
        end
    else
        begin
            if(clken)
            begin
                clkcount <= clkcount + 1;
            if(clkcount>=countlimit)
            begin
                clkcount <= 32'd0;
                clkout <= ~clkout;
            end
            else
                clkout <= clkout;
            end
            else
            begin
                clkcount <= clkcount;
                clkout <= clkout;
            end
        end
endmodule