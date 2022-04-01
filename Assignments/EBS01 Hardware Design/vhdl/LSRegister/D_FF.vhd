LIBRARY ieee;
USE ieee.std_logic_1164.all;
 
ENTITY d_ff IS
PORT( d, clk, rb: IN std_logic;
		q: OUT std_logic);
END d_ff;
 
ARCHITECTURE behave OF d_ff IS
BEGIN
	PROCESS (clk, rb)
	BEGIN
		IF rb = '0' THEN
			q <= '0';
		ELSIF rising_edge(clk) THEN
			q <= d;
		 END IF;
	END PROCESS;
END ARCHITECTURE behave;