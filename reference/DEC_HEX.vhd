--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 1  - 1o Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Decodificador Hexadecimal / 7 Segmentos => DEC_HEX.vhd
-- Rev. 0
-- Especificacoes: Entradas: Q[3..0]
-- 				    Saidas:   D[6..0]
-- Esse codigo e' um exemplo de descricao VHDL de um decodificador de codigos
-- hexadecimais em codigo para ativacao de display de 7 segmentos da disciplina
-- de Laboratorio de Sistemas Digitais II do Centro Universitario FEI.
--****************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DEC_HEX IS 			  			-- declaracao da entidade DEC_HEX
	PORT 
	(	Q 	: IN STD_LOGIC_VECTOR(3 downto 0); 		-- vetor de entrada Q[3..0]
		D  : OUT STD_LOGIC_VECTOR(6 downto 0)); 	-- vetor de saida D[6..0]
END DEC_HEX;

ARCHITECTURE SELETOR OF DEC_HEX IS      	
BEGIN
	WITH Q SELECT
		D     <=	"1000000" WHEN "0000",	-- display 0
					"1111001" WHEN "0001",	-- display 1
					"0100100" WHEN "0010",	-- display 2
					"0110000" WHEN "0011",	-- display 3
					"0011001" WHEN "0100",	-- display 4
					"0010010" WHEN "0101",	-- display 5
					"0000010" WHEN "0110",	-- display 6
					"1111000" WHEN "0111",	-- display 7
					"0000000" WHEN "1000",	-- display 8
					"0010000" WHEN "1001",	-- display 9
					"0001000" WHEN "1010",	-- display A
					"0000011" WHEN "1011",	-- display b
					"1000110" WHEN "1100",	-- display C
					"0100001" WHEN "1101",	-- display d
					"0000110" WHEN "1110",	-- display E
					"0001110" WHEN "1111",	-- display F
					"1111111" WHEN OTHERS;	-- display Apagado
END SELETOR;
