
module key_buff (
	input rdclk,
    input wrclk,
	input [7:0] scan_code,
	input wren,
	input reen,
    input [4:0] head,
	output reg [7:0] dataout,
    output reg [4:0] tail
);
	reg [7:0] queue [31:0];
	//reg [4:0] head, tail;
	initial 
	begin
		tail = 5'b0;
	end
	
	always @(posedge wrclk) begin
		if(wren == 1'b1 & tail + 5'b1 != head)
		begin
			queue[tail] <= scan_code;
			tail <= tail + 5'b1;
		end
		
	end

    always @(posedge rdclk) begin
        if(reen == 1'b1 & head != tail)
        begin    
            dataout <= queue[head];
        end
        else
        begin
            dataout <= 8'b0;
        end
    end
endmodule


module rom_letter (
    input clk,
    input [7:0]ascii,
    input [3:0]row,
    output reg [11:0]shape_data
);
reg [11:0] letter_shape[4095:0];
initial begin
	 $readmemh("D:/myfile/Sophomore/DL_and_CO EXP/exp/exp09/letter.txt", letter_shape, 0, 4095);
end
always @(posedge clk) begin
    shape_data <= letter_shape[{ascii,row}];
end
endmodule


module video_mem (
    input rdclk,
    input wrclk,
    input [5:0]row,
    input [6:0]col,
	input [19:0]addr,
    input wren,
    input [7:0] datain,
    output reg [7:0] dataout
);
reg [7:0] letter[64 * 128]; //2的13次方 行优先 64行70列

always @(negedge rdclk) begin
    dataout <= letter[{row, col}];
end

always @(posedge wrclk) begin
    if(wren==1)
    begin       
        letter[addr[12:0]] <= datain;
    end  
end

endmodule
