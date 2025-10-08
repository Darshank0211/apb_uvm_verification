`define IDLE   0
`define SETUP  1
`define ACCESS 2

module apb_dut #(parameter DEPTH = 1024) (
    input  logic         pclk,
    input  logic         presetn,
    input  logic         psel,
    input  logic         pwrite,
    input  logic         penable,
    input  logic [31:0]  paddr,
    input  logic [31:0]  pwdata,
    output logic [31:0]  prdata,
    output logic         pready,
    output logic         pslverr
);

    logic [31:0] mem [0:DEPTH-1];
    logic [1:0]  _state, _next_state;

    // Sequential: reset, write, ready/error
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            _state  <= `IDLE;
            pready  <= 1'b1;
            pslverr <= 1'b0;
            for (int i = 0; i < DEPTH; i++) mem[i] <= 32'h0;
            $display("[%0t] DUT: Reset complete, memory cleared", $time);
        end else begin
            _state  <= _next_state;
            pready  <= 1'b1;  // Always ready (no wait states)
            pslverr <= 1'b0;

            // WRITE operation
            if (psel && penable && pwrite) begin
                mem[paddr[9:0]] <= pwdata;
                $display("[%0t] DUT WRITE: mem[0x%03h] <= 0x%08h", $time, paddr[9:0], pwdata);
            end
        end
    end

    // ✅ FIXED: Read data ONLY valid during ACCESS phase with pready
    always_comb begin
        if (psel && penable && !pwrite && pready) begin
            // ✅ CORRECT: Data valid only when psel=1, penable=1, pready=1
            prdata = mem[paddr[9:0]];
            $display("[%0t] DUT READ ACCESS: addr=0x%03h data=0x%08h", $time, paddr[9:0], mem[paddr[9:0]]);
        end else begin
            // ✅ CORRECT: Data invalid during SETUP, IDLE, or when not ready
            prdata = 32'h0;  // or 32'hX for simulation clarity
        end
    end

    // FSM 
    always_comb begin
        unique case (_state)
            `IDLE:   _next_state = (psel && !penable)  ? `SETUP  : `IDLE;
            `SETUP:  _next_state = (psel &&  penable)  ? `ACCESS : `SETUP;
            `ACCESS: _next_state = (!psel || !penable) ? `IDLE   : `ACCESS;
            default: _next_state = `IDLE;
        endcase
    end

    final begin
        automatic int count = 0;
        $display("\n=== FINAL DUT MEMORY ===");
        for (int i = 0; i < 64; i++) begin
            if (mem[i] != 32'h0) begin
                $display("mem[0x%02h] = 0x%08h", i, mem[i]);
                count++;
            end
        end
        if (count == 0) $display("No data stored");
        else            $display("Total entries written: %0d", count);
        $display("========================\n");
    end
endmodule

