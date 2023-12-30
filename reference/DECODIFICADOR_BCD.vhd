--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1º Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Decodificador BCD / 7 Segmentos => DECODIFICADOR_BCD.vhd
-- Rev. 0
-- Especificacoes: Entradas: Q[7..0]
-- 				    Saidas:   D[6..0], U[6..0]
-- Esse código converte um número binário de oito bits em 2 dígitos BCD.
-- No seguinte formato: |bcd|bcd| <= |bin|bin| (ex: |9|5| <= |5|F|)
-- Os valores BCD são representados em duas saídas para dois displays de 7
-- segmentos (Dezena e Unidade). Esse codigo pode ser aplicado  
-- no Laboratorio de Sistemas Digitais II do Centro Universitario FEI.
--****************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL; -- necessário p/ conversão de inteiro para std_logic

ENTITY DECODIFICADOR_BCD IS 	-- declaracao da entidade DECODIFICADOR_BCD
	PORT
	(	Q 	: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- vetor de 8 bits de entrada
		D, U : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); -- vetores dezena e unidade
END DECODIFICADOR_BCD;

ARCHITECTURE CoNVERSOR OF DECODIFICADOR_BCD IS
SIGNAL UNIDADE, DEZENA, CENTENA: STD_LOGIC_VECTOR(3 DOWNTO 0); -- valore BCD
     	
BEGIN
-- Algoritmo: "Desloca e Soma 3" ("double dabble"):
-- 1 - Se qualquer coluna (Centena, Dezena, Unidade) for maior que 4 (0100),  
--     adicionar  3  a  essa  coluna;
-- 2 - Deslocar todos os bits uma posição à esquerda;
-- 3 - Avaliar cada coluna BCD;
-- 4 - Voltar ao passo 1 até que oito deslocamentos tenham sido realizados. 
-- 5 - Depois de oito deslocamentos os 3 nibbles mais significativos devem
--     conter os valores dos três dígitos em BCD.

PROCESS (Q) 
VARIABLE Z: STD_LOGIC_VECTOR(17 DOWNTO 0); -- variável de conversão
	-- Converte binário de 8 bits para BCD {|F|F|(hex) => |2|5|5|(bcd) }
BEGIN
		Z := (OTHERS=>'0'); 		-- zera vetor auxiliar  z
		Z(10 DOWNTO 3) := Q; 	-- equivale a deslocar à esquerda 3 vezes
	-- Converte binário de 8 bits para BCD {|F|F|(hex) => |2|5|5|(bcd) }
		FOR I IN 0 TO 4 LOOP  -- desloca 5 vezes somando 3 se coluna BCD > 4
			IF Z(11 DOWNTO 8) > 4 THEN 			-- verifica coluna 0 BCD
				Z(11 DOWNTO 8) := Z(11 DOWNTO 8) + 3;
			END IF;
			IF Z(15 DOWNTO 12) > 4 THEN         -- verifica coluna 1 BCD
				Z(15 DOWNTO 12) := Z(15 DOWNTO 12) + 3;
			END IF;
			Z(17 DOWNTO 1) := Z(16 DOWNTO 0);   -- desloca 1 bit à esquerda
		END LOOP;
		UNIDADE <= Z(11 DOWNTO 8);					-- dígito BCD da coluna 0
		DEZENA <= Z(15 DOWNTO 12);					-- dígito BCD da coluna 1
		CENTENA <= "00" & Z(17 DOWNTO 16); 		-- dígito BCD da coluna 2 
END PROCESS;

WITH UNIDADE select
		U    <=	"1000000" when "0000",	-- display 0
					"1111001" when "0001",	-- display 1
					"0100100" when "0010",	-- display 2
					"0110000" when "0011",	-- display 3
					"0011001" when "0100",	-- display 4
					"0010010" when "0101",	-- display 5
					"0000010" when "0110",	-- display 6
					"1111000" when "0111",	-- display 7
					"0000000" when "1000",	-- display 8
					"0010000" when "1001",	-- display 9
					"1111111" when others;	-- display Apagado
					
WITH DEZENA select
		D    <=	"1000000" when "0000",	-- display 0
					"1111001" when "0001",	-- display 1
					"0100100" when "0010",	-- display 2
					"0110000" when "0011",	-- display 3
					"0011001" when "0100",	-- display 4
					"0010010" when "0101",	-- display 5
					"0000010" when "0110",	-- display 6
					"1111000" when "0111",	-- display 7
					"0000000" when "1000",	-- display 8
					"0010000" when "1001",	-- display 9
					"1111111" when others;	-- display Apagado					
END CoNVERSOR;
