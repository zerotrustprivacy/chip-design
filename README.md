# FPGA / SystemVerilog CI Starter


A small SystemVerilog design with a CI pipeline that checks it automatically on every push:

1. **Lint** with Verilator: catches coding mistakes and bad style
2. **Simulate** with Icarus Verilog: runs a self-checking testbench
3. **Synthesize** with Yosys: proves the design turns into real logic gates

All three tools are free and open source. The waveform from every run is saved so you can download it and see what happened.

---

## What's in here

```
.github/workflows/ci.yml   the pipeline (GitHub Actions)
rtl/counter.sv             the design: an 8-bit counter
tb/counter_tb.sv           the testbench: test code that checks the counter
Makefile                   shortcuts: make lint / make sim / make synth / make all
.gitignore                 keeps generated files out of git
```

**RTL** (register-transfer level) is what chip engineers call the design code. **TB** is the testbench.

---

## GitHub Actions in two minutes

If you know Azure DevOps Pipelines, you already know most of this. The words are just different:

| GitHub Actions | Azure DevOps | What it means |
|---|---|---|
| Workflow (`.github/workflows/*.yml`) | Pipeline (`azure-pipelines.yml`) | The whole automated process |
| `on:` | `trigger:` / `pr:` | When it runs |
| Job | Job | A set of steps that runs on one machine |
| `runs-on:` | `pool: vmImage:` | Which kind of machine |
| Runner | Agent | The machine that does the work |
| Step with `run:` | `script:` step | A shell command |
| Step with `uses:` | Marketplace task | A ready-made building block someone else wrote |
| Artifact | Pipeline artifact | Files saved from the run for you to download |

**How it works:** when you push code, GitHub reads `ci.yml`, starts a fresh Ubuntu machine, copies your repo onto it, runs each step in order, then deletes the machine. If any command exits with an error, that step turns red, the remaining steps are skipped, and the run shows a red ❌. If everything passes, you get a green ✅.

It's free for public repositories. Open `ci.yml` to read it: every line has a comment.

---

## Put it on GitHub

### Option A: with git (recommended)

1. On github.com, click **+** → **New repository**. Name it (for example `fpga-ci-starter`), make it **Public**, and **don't** add a README (this folder already has one). Click **Create repository**.
2. In a terminal, inside this folder:

```bash
git init
git add .
git commit -m "Initial commit: counter design with CI"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/fpga-ci-starter.git
git push -u origin main
```

### Option B: upload in the browser

On the new empty repo page, click **uploading an existing file** and drag the files in.

> The `.github` folder starts with a dot, so Mac and Windows **hide it**, and it's easy to miss. Without it, there's no pipeline.
> On a Mac, press **Cmd + Shift + .** in Finder to show hidden folders. On Windows, turn on **View → Hidden items**.
> If it's still missing after uploading, click **Add file → Create new file**, type `.github/workflows/ci.yml` as the name, and paste the contents in.

---

## Watch it run

1. Open your repo on GitHub and click the **Actions** tab.
2. Click the newest run, then **Lint, simulate, synthesize**.
3. Click any step to expand its output. In **Simulate** you should see:

```
Test 1: reset
Test 2: counting
Test 3: hold when disabled
Test 4: wrap-around
ALL TESTS PASSED
```

4. Scroll to the bottom of the run summary page: under **Artifacts**, download **sim-results**. It contains the waveform (`counter_tb.vcd`) and logs.

To fill in the badge at the top of this README, replace `YOUR-USERNAME/YOUR-REPO` with your own, for example `jdoe/fpga-ci-starter`.

---

## Try it: break it on purpose

This is the best way to see what CI is for.

1. On GitHub, open `rtl/counter.sv` and click the pencil icon.
2. Change this line:
   ```systemverilog
   count <= count + 1'b1;
   ```
   to:
   ```systemverilog
   count <= count + 2'd2;
   ```
3. Click **Commit changes**.
4. Go to **Actions**. Within a minute or two the run goes red ❌. Open the **Simulate** step and you'll see exactly which checks failed:
   ```
   FAIL: count on cycle 1 -- got 2, expected 1
   ...
   TIMEOUT: simulation ran too long -- the design may be stuck
   ```
   The timeout is there on purpose. Counting by 2, the counter never lands on 255, so the wrap-around test would otherwise wait forever. The testbench has a **watchdog** that stops it, and `ci.yml` has `timeout-minutes: 10` as a second safety net.
5. Change it back to `1'b1`, commit, and watch it turn green ✅ again.

---

## Look at the waveform

A waveform shows every signal in the design over time. It's the hardware version of reading logs, and it's how chip engineers debug.

- **Easiest:** open [Surfer](https://app.surfer-project.org/) in your browser and drag `counter_tb.vcd` onto it. Nothing to install.
- **Classic tool:** [GTKWave](https://gtkwave.sourceforge.net/).

Add `clk`, `rst`, `en`, `count`, and `wrap`, and you'll see the counter step up on each clock edge.

---

## Run it on your own computer (optional)

| System | Install |
|---|---|
| Ubuntu / WSL on Windows | `sudo apt-get install iverilog verilator yosys make` |
| Mac (Homebrew) | `brew install icarus-verilog verilator yosys` |

Then, in this folder:

```bash
make all     # lint + simulate + synthesize
make clean   # delete build/
```

The pipeline runs these same `make` commands, so if it passes locally it should pass on GitHub. CI uses Ubuntu 24.04 (Icarus 12, Verilator 5.020, Yosys 0.33).

---

## Next steps

- **Add your course designs.** Put the design in `rtl/` and its testbench in `tb/`, then update the `TOP`, `RTL`, and `TB` lines at the top of the `Makefile`. As the project grows, a good next exercise is to make the pipeline test several designs, using a **matrix** in GitHub Actions.
- **Write self-checking testbenches.** End with `ALL TESTS PASSED` on success and `$fatal` on failure, so CI can tell the difference. Always include a watchdog.
- **Add the FPGA build.** Once you know which board your course uses, the last stage turns the design into a file the FPGA loads (a bitstream). The open-source tools (Yosys + nextpnr) for Lattice boards run fine in CI. AMD/Xilinx Vivado and Intel Quartus are very large downloads and are usually run on your own machine or a self-hosted runner instead.
- **Learn UVM.** It's the industry-standard way to write SystemVerilog testbenches, and most design verification jobs ask for it.
