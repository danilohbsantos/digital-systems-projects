--********************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 1  - 1O Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Sincronizador de Pulso => SINC.vhd
-- Rev. 0
-- Especificações: Entradas: K, CK, INI
--				   	 Saidas : KS
-- SINC sincroniza o acionamento de uma chave (ativa em um) com clock
-- SINC gera um pulso de um periodo de clock na borda de ativacao da chave. 
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SINC IS
    PORT (CK	: IN STD_LOGIC;    -- clock de 50MHz
			 INI	: IN STD_LOGIC;  	 -- reset (ativo em zero)
			 K		: IN STD_LOGIC;	 -- sinal de entrada (ativo em um)
			 KS	: OUT STD_LOGIC ); -- pulso de sinal de saida (ativo em um)
END SINC;

ARCHITECTURE COMPORTAMENTAL OF SINC IS
    TYPE Nomes IS (E0,E1,E2);	-- criacao de tipos enumerados com nomes dos estados
    SIGNAL Estado: Nomes;		-- declaracao de variavel de estado

BEGIN
    PROCESS (CK,INI)				-- declaracao da sensibilidade do processo
    BEGIN
        IF (INI='0') THEN Estado <= E0; KS <= '0';-- estado de inicio do sistema
        ELSIF (RISING_EDGE(CK)) THEN  			-- detecao de borda de subida do CK
            CASE Estado IS
                WHEN E0 =>
                    IF K = '1' THEN Estado <= E1; KS <= '1';-- sinal ativado
                    ELSE Estado <= E0; KS <= '0'; 			   -- sinal desativado
                    END IF;
                WHEN E1 =>
                    IF K = '1' THEN Estado <= E2; KS <= '0';-- sinal permanece ativado
                    ELSE Estado <= E0; KS <= '0'; 				-- sinal desativado
                    END IF;
                WHEN E2 =>
                    IF K = '0' THEN Estado <= E0; KS <= '0';-- sinal desativado
                    ELSE Estado <= E2; KS <= '0'; 				-- sinal premanece ativado
                    END IF; 
				END CASE;
        END IF;
    END PROCESS;
END COMPORTAMENTAL;
