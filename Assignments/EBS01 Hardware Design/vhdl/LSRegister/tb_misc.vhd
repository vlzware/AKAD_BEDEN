LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY tb_misc IS
END ENTITY tb_misc;

ARCHITECTURE behave_d_ff OF tb_misc IS
	SIGNAL din, dout, clk, rb: std_logic:='0';
	COMPONENT d_ff IS
		PORT( d, clk, rb: IN std_logic;
				q: OUT std_logic);
	END COMPONENT d_ff;
BEGIN
	dut_d_ff: COMPONENT d_ff
		PORT MAP(d => din, q => dout, clk => clk, rb => rb);
	clk <= NOT clk AFTER 5 ns;
	din <= NOT din AFTER 7 ns;
	rb <= NOT rb AFTER 30 ns;
END ARCHITECTURE behave_d_ff;

ARCHITECTURE behave_mux OF tb_misc IS
	COMPONENT mux IS
		PORT(	a, b, sel: IN std_logic;
				q: OUT std_logic);
	END COMPONENT mux;
	SIGNAL a, b, sel, q: std_logic:='0';
BEGIN
	mux1: COMPONENT mux
			PORT MAP(a => a, b => b, sel => sel, q => q);
	sel <= NOT sel AFTER 20 ns;
	a <= NOT a AFTER 3 ns;
	b <= NOT b AFTER 12 ns;
END ARCHITECTURE behave_mux;

ARCHITECTURE behave_lsr_lauflicht OF tb_misc IS
	CONSTANT test_width: 			positive:= 4;

	CONSTANT last_index: 			natural:= test_width-1;
	SUBTYPE 	lsrvector IS 			std_logic_vector(last_index DOWNTO 0);

	-- single "tic" of the clock
	CONSTANT clocktime: 				time:= 10 ns;


	-- constants to compare to in the asserts
	CONSTANT zeros: 					lsrvector:= (others => '0');

	SIGNAL 	clk,
				dut1_din,
				dut1_dout,
				dut1_reset_b,
				dut1_load,
				dut2_din,
				dut2_dout,
				dut2_reset_b,
				dut2_load: 				std_logic:='0';
	SIGNAL 	dut1_parallel_in,
				dut1_parallel_out,
				dut2_parallel_in,
				dut2_parallel_out: 	lsrvector:= (others => '0');
	
	PROCEDURE clock_cycle(	SIGNAL 	clk: 	OUT 	std_logic;
									CONSTANT count: IN  	positive) IS
	BEGIN
		FOR i IN 0 TO count-1 LOOP
			clk <= '1';
			WAIT FOR clocktime;
			clk <= '0';
			WAIT FOR clocktime;
		END LOOP;
	END PROCEDURE clock_cycle;
	
BEGIN
	dut1: ENTITY work.LSRegister(behave)
		GENERIC MAP(lsr_width => test_width)
		PORT MAP(	dut1_din, 		dut1_dout, 			clk, 	dut1_load,
						dut1_reset_b, 	dut1_parallel_in, dut1_parallel_out);

	dut2: ENTITY work.LSRegister(behave)
		GENERIC MAP(lsr_width => test_width)
		PORT MAP(	dut2_din, 		dut2_dout, 			clk, 	dut2_load,
						dut2_reset_b, 	dut2_parallel_in, dut2_parallel_out);

	dut2_din <= dut1_dout;
	dut1_din <= dut2_dout;
		
	test: PROCESS
	BEGIN
		-- reset all
		clock_cycle(clk,1);

		-- set ready for parallel load
		dut1_reset_b 	<= '1';
		dut2_reset_b 	<= '1';
		dut1_load 		<= '1';
		dut2_load 		<= '1';
		dut1_parallel_in <= "1111";
		dut2_parallel_in <= "0000";
		WAIT FOR clocktime;

		-- check start conditions
		-- TODO!

		-- load the parallel data
		clock_cycle(clk,1);

		dut1_load <= '0';
		dut2_load <= '0';
		WAIT FOR 10 ns;
		
		clock_cycle(clk, test_width*4+3);

		WAIT;
	END PROCESS test;

END ARCHITECTURE behave_lsr_lauflicht;
