// counter.sv
// A simple 8-bit up-counter -- the "hello world" of hardware design.
//
// How it behaves, on every rising edge of the clock:
//   - If rst is 1, the count goes back to 0.
//   - Otherwise, if en is 1, the count goes up by 1.
//   - When the count rolls over from 255 back to 0, `wrap` is 1 for that cycle.

module counter #(
    parameter int WIDTH = 8           // how many bits the counter has
) (
    input  logic             clk,     // clock: the heartbeat of the circuit
    input  logic             rst,     // reset: puts the counter back to 0
    input  logic             en,      // enable: count only when this is 1
    output logic [WIDTH-1:0] count,   // the current value
    output logic             wrap     // 1 for one cycle when the count rolls over
);

    // always_ff = "this describes flip-flops", i.e. memory that updates on the clock edge.
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
            wrap  <= 1'b0;
        end else if (en) begin
            count <= count + 1'b1;
            wrap  <= (count == {WIDTH{1'b1}});   // about to go from all-1s to 0
        end else begin
            wrap  <= 1'b0;
        end
    end

endmodule
