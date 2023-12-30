----------------------------------------------------------------------------------
-- Company: FEI
-- Engineer: Danilo H.B. dos Santos
-- Create Date:    00:24:25 09/03/2021 
-- Design Name: 	 FD
-- Module Name:    FD - Behavioral 
-- Project Name: 	 Data Flow Controlling System
-- Revision: 01 
-- Revision 0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Data_Flow is
    Port ( 	CK 		: in STD_LOGIC;
				RESET 	: in STD_LOGIC;
				data_in 	: in STD_LOGIC_VECTOR (7 downto 0);
				data_out : out STD_LOGIC_VECTOR (7 downto 0);
				mux_en 	: in STD_LOGIC;
				regwr 	: in STD_LOGIC;
				regrd1 	: in STD_LOGIC;
				regrd2 	: in STD_LOGIC;
				reg_add 	: in STD_LOGIC_VECTOR (2 downto 0);
				ALU_op 	: in STD_LOGIC_VECTOR (2 downto 0));
end Data_Flow;

architecture Behavioral of Data_Flow is

------------------------------- Internal Signals --------------------------------
signal muxout: std_logic_vector(7 downto 0);
signal ALU_reg: std_logic_vector(7 downto 0);
type reg_type is array (0 to 7) of std_logic_vector(7 downto 0);
signal tmp_reg: reg_type;
signal rdout1: std_logic_vector(7 downto 0);
signal rdout2: std_logic_vector(7 downto 0);
-------------------------------------- MUX --------------------------------------
begin
MUX: process (mux_en, data_in, ALU_reg)
	begin
		case mux_en is
				when '0' => muxout <= data_in;
				when '1' => muxout <= ALU_reg;
				when others => NULL;
		end case;
end process;
--------------------------------------- RF --------------------------------------
REG: process (ck, reset)
	begin
		if reset='1' then -- ativo em alto
			tmp_reg <= (tmp_reg'range => "00000000");
		else
			if (ck'event and ck = '1') then
				if regwr='1' then
					tmp_reg(conv_integer(reg_add)) <= muxout;
					elsif regrd1='1' then
							rdout1 <= tmp_reg(conv_integer
(reg_add));
					elsif regrd2='1' then
							rdout2 <= tmp_reg(conv_integer
(reg_add));
				end if;
			end if;
		end if;
end process;
-------------------------------------- ALU --------------------------------------
ALU: process(ck, reset)
	begin
		if reset='1' then
			ALU_reg <="00000000";
			elsif ck'event and ck='1' then
				case ALU_op is
					when "001" => -- AND logico
							ALU_reg<=rdout1 and rdout2;
					when "010" => -- XOR logico
							ALU_reg<=rdout1 xor rdout2;
					when "011" => -- OR logico
							ALU_reg<=rdout1 or rdout2;
					when "100" => -- NOT rdout1
							ALU_reg<= not rdout1;
					when others =>
							ALU_reg <= x"00";
				end case;
		end if;
end process;
data_out<=rdout1;

end Behavioral;