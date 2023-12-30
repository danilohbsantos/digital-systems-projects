--*****************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 1  - 1O Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: FF_D => ff_d.vhd
-- Rev. 0
-- Especificações: 
--  		Entradas: d, ck, set, rst
--  		Saídas: 	 q, nq
-- Esse código é um exemplo de descrição VHDL de um Flip-Flop Tipo D com  
-- ativação assíncrona de "set" e "reset" em nível lógico zero
-- Este projeto foi desenvolvido em VHDL na disciplina do Laboratório de 
-- Sistemas Digitais II do Centro Universitário FEI.
--****************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FF_D IS
	PORT 
	(d : 	IN STD_LOGIC;      	-- dado de entrada
	 ck : IN STD_LOGIC;     	-- sinal de relógio (borda de subida)
	 set : IN STD_LOGIC;   		-- q <= '1'(quando set = '0')
	 rst : IN STD_LOGIC;    	-- q <= '0'(quando rst = '0')
	 q, nq : OUT STD_LOGIC);	-- saídas q e /q 
END FF_D;

ARCHITECTURE COMPORTAMENTAL OF FF_D IS
BEGIN
	PROCESS (ck, set, rst)  -- processo é ativado com alteração de "ck","set" ou "rst"
	BEGIN
		IF (rst='0') THEN q <='0'; nq <='1';	 -- reset assíncrono			
		ELSIF (set='0') THEN q <='1'; nq <='0'; -- set assíncrono 
		ELSIF (RISING_EDGE (ck)) THEN 	-- detecta a borda de subida de "ck"
			q <= d; nq <= NOT(d);         -- atualiza "q" e "/q" na borda de subida de "ck"
		END IF;	 
	END PROCESS;
END COMPORTAMENTAL;
