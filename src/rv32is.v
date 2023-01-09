
module rv32is(
	input 	clock,
	input 	reset,
	output [31:0] imemaddr,
	input  [31:0] imemdataout,
	output 	imemclk,
	output [31:0] dmemaddr,
	input  [31:0] dmemdataout,
	output [31:0] dmemdatain,
	output 	dmemrdclk,
	output	dmemwrclk,
	output [2:0] dmemop,
	output	dmemwe,
	output [31:0] dbgdata);
//add your code here

wire [4:0] rs1, rs2, rd;
wire [6:0] op;
wire [2:0] func3;
wire [6:0] func7;
assign rs1 = imemdataout[19:15];
assign rs2 = imemdataout[24:20];
assign rd = imemdataout[11:7];
assign op = imemdataout[6:0];
assign func3 = imemdataout[14:12];
assign func7 = imemdataout[31:25];

wire [31:0] next_pc;
reg [31:0] now_pc;
initial begin
	now_pc = 32'b0;
end

wire RegWr, ALUAsrc, MemtoReg, MemWr;
wire [1:0] ALUBsrc;
wire [2:0] branch, ExtOp, MemOp;
wire [3:0] ALUctr;
control mycontrol(
    .op(op),
    .func3(func3),
    .func7(func7),
    .ExtOP(ExtOp),
    .RegWr(RegWr),
    .ALUAsrc(ALUAsrc),
    .ALUBsrc(ALUBsrc),
    .ALUctr(ALUctr),
    .Branch(branch),
    .MemtoReg(MemtoReg),
    .MenWr(MemWr),
    .MemOP(MemOp)
);

wire [31:0] register_a, register_b;
wire [31:0] indata;
myreg myregfile(
    .wr(RegWr),
	.clk(clock),
	.wraddr(rd),
	.indata(indata),
	.readdr_a(rs1),
	.readdr_b(rs2),
	.outdata_a(register_a),
	.outdata_b(register_b)
);


wire [31:0] imm;
ext_imm my_imm_gen(
	.instr(imemdataout),
	.ExtOp(ExtOp),
	.imm(imm)
);


wire [31:0] ALU_operand_a;
reg [31:0] ALU_operand_b;
assign ALU_operand_a = (ALUAsrc == 1'b0) ? register_a : now_pc;
always @(ALUBsrc or register_b or imm) begin
	if(ALUBsrc == 2'b00)
		ALU_operand_b = register_b;
	else if(ALUBsrc == 2'b01)
		ALU_operand_b = imm;
	else 
		ALU_operand_b = 32'd4;
end


wire less, zero;
wire [31:0] alu_result;
 alu my_alu(
	.dataa(ALU_operand_a),
	.datab(ALU_operand_b),
	.ALUctr(ALUctr),
	.less(less),
	.zero(zero),
	.aluresult(alu_result)
);


wire PCAsrc, PCBsrc;
jump_ctrl my_jump_ctrl(
    .branch(branch),
    .less(less),
    .zero(zero),
    .PCAsrc(PCAsrc),
    .PCBsrc(PCBsrc)
);


wire [31:0] pc_adder_op1, pc_adder_op2;
assign pc_adder_op1 = (PCAsrc == 1'b0) ? 32'd4 : imm;
assign pc_adder_op2 = (PCBsrc == 1'b1) ? register_a : now_pc;
assign next_pc = pc_adder_op1 + pc_adder_op2;
always @(negedge clock) begin
	if(reset == 1'b1)
		now_pc <= 32'b0;
	else
		now_pc <= next_pc;
end

assign imemclk = ~clock;
assign dmemaddr = alu_result;
assign dmemdatain = register_b;
assign dmemrdclk = clock;
assign dmemwrclk = ~clock;
assign dmemop = MemOp;
assign dmemwe = MemWr;
assign dbgdata = now_pc;
assign imemaddr = (reset == 1'b1) ? 32'b0: next_pc;

assign indata = MemtoReg ? dmemdataout : alu_result;


endmodule


module ext_imm (
	input [31:0] instr,
	input [2:0] ExtOp,
	output [31:0] imm
);
	wire [31:0] tmp[4:0];
	assign tmp[0] = {{20{instr[31]}}, instr[31:20]};
	assign tmp[1] = {instr[31:12], 12'b0};
	assign tmp[2] = {{20{instr[31]}}, instr[31:25], instr[11:7]};
	assign tmp[3] = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
	assign tmp[4] = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

	assign imm = tmp[ExtOp];

endmodule


module control (
    input [6:0] op,
    input [2:0] func3,
    input [6:0] func7,
    output [2:0] ExtOP,
    output RegWr,
    output ALUAsrc,
    output [1:0] ALUBsrc,
    output [3:0] ALUctr,
    output [2:0] Branch,
    output MemtoReg,
    output MenWr,
    output [2:0] MemOP
);
    assign RegWr = (op[6:2] != 5'b11000) & (op[6:2] != 5'b01000);
    assign MemtoReg = (op[6:2] == 5'b00000);
    assign MenWr = (op[6:2] == 5'b01000);

    assign MemOP[0] = (op[6:2] == 5'b00000 & (func3 == 3'b001 | func3 == 3'b101)) | (op[6:2] == 5'b01000 & func3 == 3'b001);
    assign MemOP[1] = (func3 == 3'b010) & ((op[6:2] == 5'b00000) | (op[6:2] == 5'b01000)); 
    assign MemOP[2] = (op[6:2] == 5'b00000) & (func3 == 3'b100 | func3 == 3'b101);

    assign ExtOP[2] = (op[6:2] == 5'b11011);
    assign ExtOP[1] = (op[6:2] == 5'b11000) | (op[6:2] == 5'b01000);
    assign ExtOP[0] = (op[6:2] == 5'b01101) | (op[6:2] == 5'b00101) | (op[6:2] == 5'b11000);
    
    assign Branch[2] = op[6:2] == 5'b11000;
    assign Branch[1] = (op[6:2] == 5'b11001) | (op[6:2] == 5'b11000 & (func3 == 3'b100 | func3 == 3'b101 | func3 == 3'b110 | func3 == 3'b111));
    assign Branch[0] = (op[6:2] == 5'b11011) | (op[6:2] == 5'b11000 & (func3 == 3'b001 | func3 ==3'b101 | func3 == 3'b111));

    assign ALUAsrc = (op[6:2] == 5'b00101 | op[6:2] == 5'b11011 | op[6:2] == 5'b11001);
    assign ALUBsrc[0] = (op[6:2] == 5'b00000 | op[6:2] == 5'b01000 | op[6:2] == 5'b01101 | op[6:2] == 5'b00101 | op [6:2] == 5'b00100);
    assign ALUBsrc[1] = (op[6:2] == 5'b11011 | op[6:2] == 5'b11001);
    
    wire aluctr3_grp_00100, aluctr3_grp_01100, aluctr3_grp_11000; //aluctr第3位中可能是1的op[6:2]
    assign aluctr3_grp_00100 = (func3 == 3'b011) | (func3 == 3'b101 & func7[5] == 1'b1) ;
    assign aluctr3_grp_01100 = (func3 == 3'b000 & func7[5] == 1'b1) | (func3 == 3'b101 & func7[5] == 1'b1) | (func3 == 3'b011 & func7[5] == 1'b0);
    assign aluctr3_grp_11000 = (func3 == 3'b110) | (func3 == 3'b111);
    assign ALUctr[3] = (op[6:2] == 5'b00100 & aluctr3_grp_00100 ) | (op[6:2] == 5'b01100 & aluctr3_grp_01100) | (op[6:2] == 5'b11000 & aluctr3_grp_11000);

    wire aluctr2_grp_00100, aluctr2_grp_01100;
    assign aluctr2_grp_00100 = (func3 == 3'b101) | (func3 == 3'b100) | (func3 == 3'b110) | (func3 == 3'b111);
    assign aluctr2_grp_01100 = (func3 == 3'b101) | (func3 == 3'b100 & func7[5] == 1'b0) | (func3 == 3'b110 & func7[5] == 1'b0) | (func3 == 3'b111 & func7[5] == 1'b0);
    assign ALUctr[2] = (op[6:2] == 5'b00100 & aluctr2_grp_00100) | (op[6:2] == 5'b01100 & aluctr2_grp_01100);

    wire aluctr1_grp_00100, aluctr1_grp_01100;
    assign aluctr1_grp_00100 = (func3 == 3'b010) | (func3 == 3'b011) | (func3 == 3'b110) | (func3 == 3'b111);
    assign aluctr1_grp_01100 = (func3 == 3'b010 & func7[5] == 1'b0) | (func3 == 3'b011 & func7[5] == 1'b0) | (func3 == 3'b110 & func7[5] == 1'b0) | (func3 == 3'b111 & func7[5] == 1'b0);
    assign ALUctr[1] = (op[6:2] == 5'b01101) | (op[6:2] == 5'b00100 & aluctr1_grp_00100) | (op[6:2] == 5'b01100 & aluctr1_grp_01100) | (op[6:2] == 5'b11000);

    wire aluctr0_grp_00100, aluctr0_grp_01100;
    assign aluctr0_grp_00100 = (func3 == 3'b111) | (func3 == 3'b101) | (func3 == 3'b001 & func7[5] == 1'b0);
    assign aluctr0_grp_01100 = (func3 == 3'b001 & func7[5] == 1'b0) | (func3 == 3'b101) | (func3 == 3'b111 & func7[5] == 1'b0);
    assign ALUctr[0] = (op[6:2] == 5'b01101) | (op[6:2] == 5'b00100 & aluctr0_grp_00100) | (op[6:2] == 5'b01100 & aluctr0_grp_01100);
endmodule

module jump_ctrl (
    input [2:0] branch,
    input less,
    input zero,
    output PCAsrc,
    output PCBsrc
);
    assign PCAsrc = (branch == 3'b001) | (branch == 3'b010) | (branch == 3'b100 & zero) | (branch == 3'b101 & (~zero)) | (branch == 3'b110 & less) | (branch == 3'b111 & (~less));
    assign PCBsrc = (branch == 3'b010);
endmodule


module alu(
	input [31:0] dataa,
	input [31:0] datab,
	input [3:0]  ALUctr,
	output less,
	output zero,
	output reg [31:0] aluresult
    );

//add your code here
wire al, lr, us, add_or_sub;
alu_ctr my_alu_ctr22(   .ALUctr(ALUctr),
                        .al(al),
                        .lr(lr),
                        .us(us),
                        .add_or_sub(add_or_sub)
);

wire cf, of;
wire [31:0] adder_re, cmp_re, shf_re, or_re, and_re, xor_re;
assign or_re = dataa | datab;
assign and_re = dataa & datab;
assign xor_re = dataa ^ datab;
assign cmp_re = us==1? (of^adder_re[31])&(|adder_re) : cf;
barrel myba(
            .indata(dataa),
            .shamt(datab[4:0]),
            .lr(lr),
            .al(al),
            .outdata(shf_re)
);

adder myadder(  .A(dataa),
                .B(datab),
                .subctr(add_or_sub),
                .F(adder_re),
                .cf(cf),
                .of(of)
);
assign less = cmp_re[0];
assign zero = ALUctr[2:0]==3'b010 ?~(|adder_re):~(|aluresult);
always @(*) begin
    case (ALUctr[2:0])
        3'b000: aluresult = adder_re;
        3'b001: aluresult = shf_re;
        3'b010: aluresult = cmp_re;
        3'b011: aluresult = datab;
        3'b100: aluresult = xor_re;
        3'b101: aluresult = shf_re;
        3'b110: aluresult = or_re;
        3'b111: aluresult = and_re;
        default: aluresult = 0;
    endcase

end

endmodule

module adder(A,B,subctr,F,cf,of);
input [31:0]A;
input [31:0]B;
input subctr;
output [31:0]F;
output cf,of;
wire tmp_cf;
wire [31:0]tmp;
assign tmp=({32{subctr}}^B);//如果subctr为0 结果仍为B 如果为1 则相当于取反操作
assign {tmp_cf,F}=A+tmp+subctr;
assign cf=tmp_cf^subctr;
assign of=(A[31]==tmp[31])&&(A[31]!=F[31]);
endmodule


module alu_ctr (
    input [3:0] ALUctr,
    output al,
    output lr,
    output us,
    output add_or_sub
);
    assign al = ALUctr==4'b1101;
    assign lr = ALUctr[2:0]==3'b001;
    assign us = ALUctr==4'b0010;//为1时时带符号
    assign add_or_sub = ALUctr!=4'b0000;//为1时做减法
endmodule

module barrel(input [31:0] indata,
			  input [4:0] shamt,
			  input lr, //为1时左移，为0时右移
              input al, //为1时算术移位，为0时逻辑移位
			  output reg [31:0] outdata);

//add your code here
reg [31:0] tmp[4:0];
always @(*) begin
    if(shamt[0]==0)
        tmp[0]=indata;
    else
    begin
        case ({lr,al})
            2'b00:tmp[0]={1'b0,indata[31:1]};//right logic 
            2'b01:tmp[0]={indata[31],indata[31:1]};//right al
            2'b10:tmp[0]={indata[30:0],1'b0};//left logic
            2'b11:tmp[0]={indata[30:0],1'b0};//left al 
        endcase
    end

    if(shamt[1]==0)
        tmp[1]=tmp[0];
    else
    begin
        case ({lr,al})
            2'b00:tmp[1]={2'b0,tmp[0][31:2]};//right logic 
            2'b01:tmp[1]={{2{tmp[0][31]}},tmp[0][31:2]};//right al
            2'b10:tmp[1]={tmp[0][29:0],2'b0};//left logic
            2'b11:tmp[1]={tmp[0][29:0],2'b0};//left al 
        endcase
    end
    
    if(shamt[2]==0)
        tmp[2]=tmp[1];
    else
    begin
        case ({lr,al})
            2'b00:tmp[2]={4'b0,tmp[1][31:4]};
            2'b01:tmp[2]={{4{tmp[1][31]}},tmp[1][31:4]};
            2'b10:tmp[2]={tmp[1][27:0],4'b0};
            2'b11:tmp[2]={tmp[1][27:0],4'b0};
        endcase
    end

    if(shamt[3]==0)
        tmp[3]=tmp[2];
    else
    begin
        case ({lr,al})
            2'b00:tmp[3]={8'b0,tmp[2][31:8]};
            2'b01:tmp[3]={{8{tmp[2][31]}},tmp[2][31:8]};
            2'b10:tmp[3]={tmp[2][23:0],8'b0};
            2'b11:tmp[3]={tmp[2][23:0],8'b0};
        endcase 
    end

    if(shamt[4]==0)
        tmp[4]=tmp[3];
    else
    begin
        case ({lr,al})
            2'b00:tmp[4]={16'b0,tmp[3][31:16]};
            2'b01:tmp[4]={{16{tmp[3][31]}},tmp[3][31:16]};
            2'b10:tmp[4]={tmp[3][15:0],16'b0};
            2'b11:tmp[4]={tmp[3][15:0],16'b0};
        endcase
    end
    outdata=tmp[4];
end
endmodule

module myreg (
    input wr,clk,
	input [4:0] wraddr,
	input [31:0] indata,
	input [4:0] readdr_a,
	input [4:0] readdr_b,
	output [31:0] outdata_a,
	output [31:0] outdata_b
);
integer i;
reg [31:0] regs[31:0];
initial begin
	for (i = 0; i<32 ; i = i + 1)
		regs[i] = 32'b0;
end

always @(negedge clk) begin	
    if(wr == 1'b1 & wraddr != 5'b0)
        regs[wraddr] <= indata;
end
assign outdata_a = regs[readdr_a];
assign outdata_b = regs[readdr_b];
endmodule



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



