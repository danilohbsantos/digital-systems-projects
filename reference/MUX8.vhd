--********************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1° Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Multiplexador de 8 vias de 8 bits => MUX8.vhd
-- Rev. 0
-- Especificações: Entradas: Da[7..0], Db[7..0], Dc[7..0], Dd[7..0], 
-- 								  De[7..0], Df[7..0], Dg[7..0], Dh[7..0], S[2..0]
--				   	 Saidas  : MX_out[7..0]
-- O MUX seleciona um dos oito vetores de entrada em função do código de S:
--			S=000 => seleciona Da
--			S=001 => seleciona Db
--			S=010 => seleciona Dc
--			S=011 => seleciona Dd
--			S=100 => seleciona De
--			S=101 => seleciona Df
--			S=110 => seleciona Dg
--			S=111 => seleciona Dh
-- O componente MUX é um seletor assíncrono. 
-- Componente para aplicação no Projeto 2 do Laboratóro de Sistemas Digitais II 
--********************************************************************************
library ieee;
use ieee.std_logic_1164.all;
entity MUX8 is
	port(Da		: in std_logic_vector(7 downto 0);
		  Db		: in std_logic_vector(7 downto 0);
		  Dc		: in std_logic_vector(7 downto 0);
		  Dd		: in std_logic_vector(7 downto 0);
		  De		: in std_logic_vector(7 downto 0);
		  Df		: in std_logic_vector(7 downto 0);
		  Dg		: in std_logic_vector(7 downto 0);
		  Dh		: in std_logic_vector(7 downto 0);
		  S		: in std_logic_vector(2 downto 0);
		  MX_out	: out std_logic_vector(7 downto 0)
			);
end MUX8;

architecture Comportamental of MUX8 is
begin
process(Da, Db, Dc, Dd, De, Df, Dg, Dh, S)
begin
case S is
	when "000" => MX_out <= Da;
	when "001" => MX_out <= Db;
	when "010" => MX_out <= Dc;
	when "011" => MX_out <= Dd;
	when "100" => MX_out <= De;
	when "101" => MX_out <= Df;
	when "110" => MX_out <= Dg;
	when "111" => MX_out <= Dh;
	when others => null;
end case;
end process;
end Comportamental;