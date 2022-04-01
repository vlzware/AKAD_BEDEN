LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY LSRegister IS
	GENERIC (lsr_width: positive := 3);
	PORT( din: IN std_logic;
			dout: OUT std_logic;
			clk, load, reset_b: IN std_logic;
			parallel_in: IN std_logic_vector((lsr_width-1) DOWNTO 0);
			parallel_out: OUT std_logic_vector((lsr_width-1) DOWNTO 0) );
END ENTITY LSRegister;

ARCHITECTURE behave OF LSRegister IS

	-- D Flip-Flop
	COMPONENT d_ff IS
		PORT(	d, clk, rb: IN std_logic;
				q: OUT std_logic);
	END COMPONENT d_ff;

	-- 2-way multiplexer
	COMPONENT mux IS
		PORT( a, b, sel: IN std_logic;
				q: OUT std_logic);
	END COMPONENT mux;

	CONSTANT last_index: natural := lsr_width-1;
	
	-- internal signals
	SIGNAL mux_b, mux_q, d_ff_d, d_ff_q: std_logic_vector(last_index DOWNTO 0);

BEGIN
	-- serial input/output
	mux_b(0) <= din;
	dout <= d_ff_q(last_index);

	-- generate cells
	LSR:
	FOR i IN 0 TO last_index GENERATE

		gen_mux: COMPONENT mux PORT MAP(a => parallel_in(i), b => mux_b(i),
													sel => load, q => mux_q(i));
		gen_ff: COMPONENT d_ff PORT MAP(d => mux_q(i), clk => clk,
													rb => reset_b, q => d_ff_q(i));
		parallel_out(i) <= d_ff_q(i);

		next_cell: IF i > 0 GENERATE
			mux_b(i) <= d_ff_q(i-1);
		END GENERATE next_cell;

	END GENERATE LSR;

END ARCHITECTURE behave;