
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module exp12(

	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output	 reg     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2
);



//=======================================================
//  REG/WIRE declarations
//=======================================================



//=======================================================
//  Structural coding
//=======================================================
reg reset;
reg start;
initial 
begin
	reset = 1'b1;
	start = 1'b0;
end

//reset要先置为有效一个周期，否则会从第二条指令开始执行
always @(negedge cpuclock) begin
	start <= 1'b1;
end
always @(negedge cpuclock) begin
	if(start)
		reset <= 1'b0;
end



wire [31:0] imemaddr, imemdataout, memaddr, memdatain, memdataout;
wire [2:0] memop;
wire imemclk, memreclk, memwrclk, memwe;


//---------------------------------readmem map--------------------
//读取内存时，先将所有的读出后，通过一个多路选择器选出，这里写得有点那啥qaq


wire [31:0] scancode_or_head;	
wire [31:0]	keyboard_or_rowcol;
//选出是键盘头指针还是键盘缓冲区内容
assign scancode_or_head = (memaddr[19:0] == 20'h0) ? {24'b0, kmemdataout} : {27'b0, head};

//是上面键盘有关信息还是显存的行列信息

assign keyboard_or_rowcol = (memaddr[31:20] == 12'h00a) ? rcmemdataout : scancode_or_head;

//是上面的信息还是数据存储器的信息还是时钟信息
assign memdataout = (memaddr[31:20] == 12'h001) ? dmemdataout : (memaddr[31:20] == 12'h004 ? tmemdataout : keyboard_or_rowcol);


//--------------------------------------------------------------------

wire [31:0] pc;
wire cpuclock;
clkgen #(12500000) cpuclk(CLOCK_50, 1'b0, 1'b1, cpuclock);
//assign cpuclock = KEY[0];
rv32is mycpu(
	.clock(cpuclock),
	.reset(reset),
	.imemaddr(imemaddr),
	.imemdataout(imemdataout),
	.imemclk(imemclk),
	.dmemaddr(memaddr),
	.dmemdataout(memdataout),
	.dmemdatain(memdatain),
	.dmemrdclk(memreclk),
	.dmemwrclk(memwrclk),
	.dmemop(memop),
	.dmemwe(memwe),
	.dbgdata(pc)
	);

	/*
		存储映射
	高12位 	0x000 是指令
			0x001 datamem
			0x002 videomem
			0x0030 0000 从这个地址获取键盘输入 0x0030 0004 修改键盘缓冲队列头指针
			0x0040 0000 从这个地址获取时间的值 单位 秒
			0x0040 0004 从这个地址获取时间的值 单位 毫秒
			0x0040 0008 。。。。。。			   微秒
			0x005 读取开关数据 10 bit
			0x006 LEDR 10 bit
			0x007 数码管 
			0x008 大块显存
			0x0090 0000 控制使用哪块显存
			0x00a0 0000 字符显存当前光标行号 
			0x00a0 0004 字符显存当前光标列号
			0x00a0 0008 起始行寄存器
			0x00b0 0000 LEDR
			0x00c0 0000 SW
	*/


//-------------------------------font-vga-info-------------------
//光标位置以及用当前屏幕第一行在显存中的行号
reg [4:0] row_now;
reg [5:0] row_start;
reg [6:0] col_now;
wire [31:0] rcmemdataout;
initial begin
	row_now = 5'b0;
	col_now = 7'b0;
end

always @(posedge memwrclk) begin
	if(memaddr == 32'h00a00000 & memwe)
	begin
		row_now <= memdatain[4:0];
	end
	else if(memaddr == 32'h00a00004 & memwe)
	begin
		col_now <= memdatain[6:0];
	end
	else if(memaddr == 32'h00a00008 & memwe)
	begin
		row_start <= memdatain[5:0];
	end
end

assign rcmemdataout = (memaddr[19:0] == 20'h0) ? {27'b0, row} : {25'b0, col};

// ---------------------------------instrmem---------
imem instrmem(	.address(imemaddr[17:2]),
				.clock(imemclk), 
				.q(imemdataout)
				);

//----------------------------------datamem--------------
wire [31:0] dmemdataout;
wire dmemwe;
assign dmemwe = (memaddr[31:20] == 12'h001) ? memwe : 1'b0;
dmem datamem(	.addr(memaddr), 
				.dataout(dmemdataout), 
				.datain(memdatain), 
				.rdclk(memreclk),
				.wrclk(memwrclk),
				.memop(memop), 
				.we(dmemwe)
				);


//----------------------------fontvideomem------------------
wire [5:0] row;
wire [6:0] col;
wire vmwe;
wire [7:0] vmemdataout;
video_mem vmem(	.rdclk(CLOCK_50),
				.wrclk(memwrclk),
				.row(row + row_start), 
				.col(col), 
				.addr(memaddr),
				.wren(vmwe), 
				.datain(memdatain[7:0]),
				.dataout(vmemdataout)
				);

assign vmwe = (memaddr[31:20] == 12'h002) ? memwe : 1'b0;
wire [3:0] col_cnt, row_cnt;
clkgen #(25000000) my_clk(CLOCK_50, 1'b0, 1'b1, VGA_CLK);


//-------------------------------vgactrl---------------------------
wire [9:0] h_addr, v_addr;
vga_ctrl myvga(VGA_CLK, col, row, col_cnt, row_cnt, h_addr, v_addr, VGA_HS, VGA_VS, VGA_BLANK_N);
assign VGA_SYNC_N = 0;

wire [11:0] shape;
wire data;
rom_letter lrom(CLOCK_50, vmemdataout, row_cnt, shape);
assign data = shape[col_cnt];
reg [7:0] red_in_small, blue_in_small, green_in_small;
wire flag;
clkgen #(1) flagclk(CLOCK_50, 1'b0, 1'b1, flag);

always @(row or col or row_now or col_now or flag or data) begin
	if(row == row_now & col == col_now)
	begin
		red_in_small = flag ? 8'hff : 8'h00;
		blue_in_small = flag ? 8'hff : 8'h00;
		green_in_small = flag ? 8'hff : 8'h00;
	end
	else
	begin
		red_in_small = data ? 8'h00 : 8'hff;
		blue_in_small = data ? 8'h00 : 8'hff;
		green_in_small = data ? 8'h00 : 8'hff;
	end
end



assign VGA_B = vmselector ?{ blue_in_big, 6'b0 } : blue_in_small;
assign VGA_R = vmselector ?{ red_in_big, 6'b0 } : red_in_small;
assign VGA_G = vmselector ?{ green_in_big, 6'b0 } : green_in_small;


//----------------------------keyboardmem-------------------------
wire [7:0] scan_code;
wire keybuff_we;
wire [15:0] count;
keyboard mykey(	.clk(CLOCK_50),
				.ps2_clk(PS2_CLK),
				.ps2_data(PS2_DAT),
				.scan_code(scan_code),
				.wr(keybuff_we),
				.cnt(count)			
);


wire [7:0] kmemdataout;

// 键盘头指针
reg [4:0] head;
initial begin
	head = 5'b0;
end

always @(posedge memwrclk) begin
	if(memaddr == 32'h00300004 & memwe)
	begin
		head <= memdatain[4:0];
	end
end

//键盘缓冲区
key_buff kmem(	.rdclk(memreclk),
				.wrclk(CLOCK_50),
				.scan_code(scan_code),
				.head(head),
				.wren(keybuff_we),
				.dataout(kmemdataout),
);



//-----------------------------------timemem----------------------
wire clock_s, clock_ms, clock_us;
reg [31:0] clock_time[2:0];
initial begin
	clock_time[0] = 32'b0;
	clock_time[1] = 32'b0;
	clock_time[2] = 32'b0;
end
clkgen #(1) my_clk2(CLOCK_50, 1'b0, 1'b1, clock_s);
clkgen #(1000) my_clk3(CLOCK_50, 1'b0, 1'b1, clock_ms);
clkgen #(1000000) my_clk4(CLOCK_50, 1'b0, 1'b1, clock_us);

always @(negedge clock_s) begin
	clock_time[0] <= clock_time[0] + 32'b1;
end
always @(negedge clock_ms) begin
	clock_time[1] <= clock_time[1] + 32'b1;
end
always @(negedge clock_us) begin
	clock_time[2] <= clock_time[2] + 32'b1;
end


reg [31:0] tmemdataout;
always @(posedge CLOCK_50) begin
	tmemdataout <= clock_time[memaddr[3:2]];	
end

//------------------------------LEDR-------------------------------
wire ledwe = (memaddr[31:20] == 12'h006) ? memwe : 1'b0;
 
always @(posedge memwrclk) begin
	if(ledwe)
	begin
		LEDR[memaddr[3:0]] <= memdatain[0];
	end
end


//-------------------------------7segmentmem---------------------------
reg [7:0] bcd[5:0];
integer i;
initial begin
	for (i = 0; i < 6 ; i = i + 1)
		bcd[i] = 8'b0;
end
wire bcdwe = (memaddr[31:20] == 12'h007) ? memwe : 1'b0;
 
always @(posedge memwrclk) begin
	if(bcdwe)
	begin
		bcd[memaddr[3:0]] <= memdatain[7:0];
	end
end

bcd7seg bcd0(bcd[0], HEX0);
bcd7seg bcd1(bcd[1], HEX1);
bcd7seg bcd2(bcd[2], HEX2);
bcd7seg bcd3(bcd[3], HEX3);
bcd7seg bcd4(bcd[4], HEX4);
bcd7seg bcd5(bcd[5], HEX5);


//---------------------------bigvideomem----------------------
wire [1:0] red_in_big, blue_in_big, green_in_big;
wire [6:0] bigvm_datain;
wire bigvm_wren;
assign bigvm_datain = {memdatain[23:22], memdatain[15:14], memdatain[7:6]};
assign bigvm_wren = (memaddr[31:20] == 12'h008) ? memwe : 1'b0;
vmem bigvideomem( 	.data(bigvm_datain),
					.rdaddress({h_addr, v_addr[8:0]}),
					.rdclock(~VGA_CLK),
					.wraddress(memaddr),
					.wrclock(memwrclk),
					.wren(bigvm_wren),
					.q({red_in_big, green_in_big, blue_in_big})
);

// --------------------------changevm------------------------
reg vmselector;
initial begin
	vmselector = 1'b0;
end
always @(posedge memwrclk) begin
	if(memaddr == 32'h00900000 & memwe)
	begin
		vmselector <= memdatain[0];
	end
end








endmodule

module bcd7seg(
	 input  [3:0] b,
	 output reg [6:0] h
	 
	 );
	always@(*)
	begin
	
	case(b)
	4'b0000:h=7'b1000000; 
	4'b0001:h=7'b1111001;	
	4'b0010:h=7'b0100100;
	4'b0011:h=7'b0110000;
	4'b0100:h=7'b0011001;
	4'b0101:h=7'b0010010;
	4'b0110:h=7'b0000010;
	4'b0111:h=7'b1111000;
	4'b1000:h=7'b0000000;
	4'b1001:h=7'b0010000;
   4'b1010:h=7'b0001000;
   4'b1011:h=7'b0000011;
   4'b1100:h=7'b1000110;
   4'b1101:h=7'b0100001;
   4'b1110:h=7'b0000110;
   4'b1111:h=7'b0001110;
	default:h=0;
	endcase
	end
	
endmodule

/*
module dmem(addr, dataout, datain, rdclk, wrclk, memop, we);
	input  [31:0] addr;
	output reg [31:0] dataout;
	input  [31:0] datain;
	input  rdclk;
	input  wrclk;
	input [2:0] memop;
	input we;
	
	wire [31:0] memin;
	reg  [3:0] wmask;
	wire [7:0] byteout;
	wire [15:0] wordout;
	wire [31:0] dwordout;
 

assign memin = (memop[1:0]==2'b00)?{4{datain[7:0]}}:((memop[1:0]==2'b10)?datain:{2{datain[15:0]}}) ; //lb: same for all four, lh:copy twice; lw:copy

//four memory chips	
dataram mymem(.byteena_a(wmask),.data(memin), .rdaddress(addr[16:2]), .rdclock(rdclk), .wraddress(addr[16:2]), .wrclock(wrclk), .wren(we), .q(dwordout) );
//wmask,addr[16:2]
assign wordout = (addr[1]==1'b1)? dwordout[31:16]:dwordout[15:0];

assign byteout = (addr[1]==1'b1)? ((addr[0]==1'b1)? dwordout[31:24]:dwordout[23:16]):((addr[0]==1'b1)? dwordout[15:8]:dwordout[7:0]);


always @(*)
begin
  case(memop)
  3'b000: //lb
     dataout = { {24{byteout[7]}}, byteout};
  3'b001: //lh
     dataout = { {16{wordout[15]}}, wordout};
  3'b010: //lw
     dataout = dwordout;
  3'b100: //lbu
     dataout = { 24'b0, byteout};
  3'b101: //lhu
     dataout = { 16'b0, wordout};
  default:
     dataout = dwordout;
  endcase
end

always@(*)
begin
	if(we==1'b1)
	begin
		case(memop)
			3'b000://sb
			begin
				wmask[0]=(addr[1:0]==2'b00)?1'b1:1'b0;
				wmask[1]=(addr[1:0]==2'b01)?1'b1:1'b0;
				wmask[2]=(addr[1:0]==2'b10)?1'b1:1'b0;
				wmask[3]=(addr[1:0]==2'b11)?1'b1:1'b0;
			end
			3'b001://sh
			begin
				wmask[0]=(addr[1]==1'b0)?1'b1:1'b0;
				wmask[1]=(addr[1]==1'b0)?1'b1:1'b0;
				wmask[2]=(addr[1]==1'b1)?1'b1:1'b0;
				wmask[3]=(addr[1]==1'b1)?1'b1:1'b0;
			end		
			3'b010://sw
			begin
				wmask=4'b1111;
			end
			default:
			begin
				wmask=4'b0000;
			end
		endcase
	end
	else
	begin
	   wmask=4'b0000;
	end
end

endmodule



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
    input [4:0]row,
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
*/
