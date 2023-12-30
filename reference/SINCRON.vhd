--********************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1o Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Sincronizador de Botoes => SINCRON.vhd
-- Rev. 0
-- Especificacoes: Entradas: KEY, CK, RST
--				       Saidas : SINC
-- SINCRON sincroniza acionamento do botao (ativo em zero) com clock
-- SINCRON gera um pulso de um periodo de clock na borda de ativacao do botao. 
--********************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SINCRON IS
    PORT (	CK		: IN STD_LOGIC;  	-- clock de 50MHz
			RST		: IN STD_LOGIC;  	-- reset (ativo em zero)
			KEY		: IN STD_LOGIC;	-- botao de entrada (ativo em zero)
			SINC	: OUT STD_LOGIC ); 	-- pulso de sinal de saida (ativo em um)
END SINCRON;

ARCHITECTURE COMPORTAMENTAL OF SINCRON IS
    TYPE Nomes IS (A,B,C);			-- criacao de tipos enumerados
    SIGNAL Estado: Nomes;			-- declaracao de variavel de estado

BEGIN
    PROCESS (CK,RST)					-- declaracao da sensibilidade do processo
    BEGIN
        IF (RST='0') THEN    Estado <= A; SINC <= '0';	-- estado de reset do sistema
        ELSIF (CK'event and CK='1') THEN  			-- detecao de borda de subida do clk
            CASE Estado IS
                WHEN A =>
                    IF KEY = '0' THEN Estado <= B; SINC <= '1';-- botao acionado
                    ELSE Estado <= A; SINC <= '0'; 				-- botao nao acionado
                    END IF;
                WHEN B =>
                    IF KEY = '0' THEN Estado <= C; SINC <= '0';-- botao permanece acionado
                    ELSE Estado <= A; SINC <= '0'; 				-- botao desativado
                    END IF;
                WHEN C =>
                    IF KEY = '0' THEN Estado <= C; SINC <= '0';-- botao permanece acionado
                    ELSE Estado <= A; SINC <= '0'; 				-- botao desativado
                    END IF; 
		END CASE;
        END IF;
    END PROCESS;
END COMPORTAMENTAL;
