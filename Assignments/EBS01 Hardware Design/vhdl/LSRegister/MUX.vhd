LIBRARY ieee;
USE ieee.std_logic_1164.all;
 
ENTITY mux IS
PORT( a, b, sel: IN std_logic;
		q: OUT std_logic);
END mux;
 
ARCHITECTURE behave OF mux IS
BEGIN
	q <= (a AND sel) OR (b AND (NOT sel));
END ARCHITECTURE behave;