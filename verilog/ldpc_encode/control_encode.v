module control_encode(
    input clk,
    input rst_n,
    input en_start,
    input en_din,
    input read_parity,
    input parity_out_done,
    output reg en_counterROM,
    output reg en_counterOUT,
    output reg en_G,
    output reg load_g,
    output reg en_L,
    output reg done_encode,
    output reg rst_c,
    output reg en_out
);

parameter S_idle = 2'b00;
parameter S_encode = 2'b01;
parameter S_parity_out = 2'b10;

reg [1:0] cstate, nstate;

always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        cstate <= S_idle;
    else
        cstate <= nstate;

always @ (*)
    begin
        en_counterROM = 0;
        en_counterOUT = 0;
        en_G = 0;
        load_g = 0;
        en_L = 0;
        done_encode = 0;
        en_out = 0;
        rst_c = 1;

        case(cstate)
            S_idle: begin
				if(en_start)
					begin
						nstate=S_encode;
						en_G=1;
						load_g=1;
					end
				else
					nstate=S_idle;
			end
            S_encode: begin
				if(en_din)
					begin
						en_counterROM=1;
						en_L=1;
						en_G=1;
						nstate=S_encode;
					end

				else if(read_parity)
					begin
						en_out=1;
						en_counterOUT=1;
						nstate=S_parity_out;
					end
				else
					begin
						done_encode=1;
						nstate=S_encode;
					end
			   end
            S_parity_out: begin
					if(!parity_out_done)
						begin
							en_counterOUT=1;
							en_out=1;
							nstate=S_parity_out;
						end
					else
						begin
							rst_c=0;
							nstate=S_idle;
						end
				end
            default:
                nstate = S_idle;
        endcase
    end

endmodule