--********************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1° Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Registrador de 8 bits => REG8.vhd
-- Rev. 0
-- Especificações: Entradas: CK, LD, R_in[7..0]
--				   	 Saidas  : R_out[7..0]
-- REG registra o valor da entrada na borda do clock quando LD está ativo (LD='1')
-- O componente REG8 é síncrono com o sinal CK. 
-- Componente para aplicação no Projeto 2 do Laboratóro de Sistemas Digitais II 
--********************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity REG8 is
	port (CK	: in std_logic;
			LD	: in std_logic; 								-- habilita carga
			R_in	: in std_logic_vector(7 downto 0);  -- dados de entrada
			R_out	: out std_logic_vector(7 downto 0)	-- dados de saída
		  ); 
end REG8;

architecture Comportamental of REG8 is
begin
process(CK)
begin
	if Rising_edge(CK) then
		if LD ='1' then
		R_out <= R_in;
		end if;
	end if;
end process;
end Comportamental;
