LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY tb_LSRegister IS
END ENTITY tb_LSRegister;

----------------------------
-- Serial communication test
----------------------------
ARCHITECTURE behave_lsr OF tb_LSRegister IS
	CONSTANT test_width: 			positive:= 8;
	CONSTANT simlength:				time:= 1 us;
	CONSTANT test_word:				std_logic_vector:="10111001";

	CONSTANT last_index: 			natural:= test_width-1;
	SUBTYPE 	lsrvector IS 			std_logic_vector(last_index DOWNTO 0);

	-- single "tic" of the clock
	CONSTANT clocktime: 				time:= 10 ns;
	CONSTANT word_duration:			time:= test_width*clocktime;

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
BEGIN
	dut1: ENTITY work.LSRegister(behave)
		GENERIC MAP(lsr_width => test_width)
		PORT MAP(	dut1_din, 		dut1_dout, 			clk, 	dut1_load,
						dut1_reset_b, 	dut1_parallel_in, dut1_parallel_out);

	dut2: ENTITY work.LSRegister(behave)
		GENERIC MAP(lsr_width => test_width)
		PORT MAP(	dut2_din, 		dut2_dout, 			clk, 	dut2_load,
						dut2_reset_b, 	dut2_parallel_in, dut2_parallel_out);

	-- simulate the parallel cable connection
	dut2_parallel_in <= dut1_parallel_out;

	-- a global clock
	clock: PROCESS
	BEGIN
		IF now < simlength THEN
			WAIT FOR clocktime/2;
			clk <= NOT clk;
		ELSE WAIT;
		END IF;
	END PROCESS clock;

	-- dut1: serial to parallel
	SIPO:	PROCESS
	BEGIN
		-- give time to reset
		WAIT FOR clocktime;
		-- ready for shifting
		dut1_reset_b 	<= '1';
		dut1_load 		<= '0';
		WAIT FOR clocktime;
		WHILE now < simlength LOOP
			-- load the test word
			FOR i IN 0 TO last_index LOOP
				dut1_din <= test_word(i);
				WAIT FOR clocktime;
			END LOOP;
			-- let dut2 read the test word
			dut1_din <= '0';
			WAIT FOR clocktime;
		END LOOP;
		WAIT;
	END PROCESS SIPO;

	-- dut2: parallel to serial
	PISO:	PROCESS
	BEGIN
		-- give time to reset
		WAIT FOR clocktime;
		-- ready for parallel load
		dut2_reset_b 	<= '1';
		dut2_load 		<= '1';
		WAIT FOR clocktime;
		-- wait for the first word
		WAIT FOR word_duration;
		WHILE now < simlength LOOP
			-- read the word
			WAIT FOR clocktime;
			dut2_load <= '0';
			-- output the word
			WAIT FOR word_duration;
			dut2_load <= '1';
		END LOOP;
		WAIT;
	END PROCESS PISO;

	-- error checks
	check: PROCESS
	BEGIN
		-- setup + load first word + offset
		WAIT FOR (2*clocktime + word_duration - clocktime);
		sim:
		-- the checks should stop a whole word earlier
		WHILE now < (simlength - word_duration) LOOP
			WAIT FOR clocktime;
			chkword:
			FOR i IN 0 TO last_index LOOP
				WAIT FOR clocktime;
				ASSERT dut2_dout=test_word(i)
					REPORT 	"Wrong bit at position "&integer'IMAGE(i)&
								". It is "&std_logic'IMAGE(dut2_dout)&
								", but should be:"&std_logic'IMAGE(test_word(i))&
								"." SEVERITY FAILURE;
			END LOOP chkword;
		END LOOP sim;
		WAIT;
	END PROCESS check;
END ARCHITECTURE behave_lsr;
