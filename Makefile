# Makefile -- shortcuts for the three checks.
# The CI pipeline runs these exact same commands, so if `make all` passes on
# your computer, it should pass on GitHub too.
#
#   make lint   check the code for mistakes and bad style (Verilator)
#   make sim    run the testbench (Icarus Verilog)
#   make synth  turn the design into real logic gates (Yosys)
#   make all    all three, in that order
#   make clean  delete everything in build/

TOP   := counter
RTL   := rtl/counter.sv
TB    := tb/counter_tb.sv
BUILD := build

.PHONY: all lint sim synth clean

all: lint sim synth

$(BUILD):
	mkdir -p $(BUILD)

lint:
	verilator --lint-only -Wall --top-module $(TOP) $(RTL)
	@echo "Lint passed"

sim: | $(BUILD)
	iverilog -g2012 -o $(BUILD)/$(TOP)_tb.vvp $(RTL) $(TB)
	vvp -n $(BUILD)/$(TOP)_tb.vvp | tee $(BUILD)/sim.log
	@grep -q "ALL TESTS PASSED" $(BUILD)/sim.log

synth: | $(BUILD)
	yosys -q -p "read_verilog -sv $(RTL); synth -top $(TOP); stat; write_json $(BUILD)/$(TOP).json" \
		-l $(BUILD)/synth.log
	@grep -A30 "Printing statistics" $(BUILD)/synth.log | grep -m1 "Number of cells" || true
	@echo "Synthesis passed"

clean:
	rm -rf $(BUILD)
