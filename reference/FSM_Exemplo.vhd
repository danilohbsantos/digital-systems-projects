--*****************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 1  - 1o Semestre de 2021
-- Prof. Dr. Valter F. Avelino - 02/2021
-- Componente VHDL: Exemplo de FSM => FSM_Exemplo.vhd
-- Rev. 0
-- Especificações: Entradas: CLK, CLK_EN, RST, RE, RD
-- 				    Saídas:   V[3..1]
-- Esse código é um exemplo de descrição VHDL de uma máquina de estados
-- finitos (FSM), para ser utilizada como template para o Projeto 1 da 
-- disciplina de Sistemas Digitais II do Centro Universitáio FEI.
--**************************************************************************** 
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSM_EXEMPLO IS
    PORT (	CLK, CLK_EN, RST, RE, RD: IN STD_LOGIC;-- declaração dos sinais de entrada
			V: OUT STD_LOGIC_VECTOR(3 DOWNTO 1) );  	-- declaração dos sinais de saída
END FSM_EXEMPLO;

ARCHITECTURE BEHAVIOR OF FSM_EXEMPLO IS
    TYPE type_state IS (E1,E2,E3,E4);			-- criação de tipos enumerados
    SIGNAL Estado: type_state;					-- declaração de variáveis de estado
    SIGNAL Entradas: STD_LOGIC_VECTOR(2 DOWNTO 1);  	-- declaração de vetor auxiliar
	 
BEGIN
    Entradas<= RE & RD;		-- concatenação dos sinais de entrada RE e RD como um vetor
	 
    PROCESS (CLK, CLK_EN, RST)	-- processo para definição das transições dos estados
    BEGIN
        IF (RST='0') THEN   Estado <= E1; 				  -- estado de reset do sistema
        ELSIF (CLK'event and CLK='1' and CLK_EN='1') THEN -- detecção de borda de CLK
            CASE Estado IS								  		    -- sincronização com CLK_EN
                WHEN E1 =>	
                    IF Entradas= "01" THEN Estado <= E2;    -- transição E1->E2
                    ELSIF Entradas= "10" THEN Estado <= E4; -- transição E1->E4
                    ELSIF Entradas= "00" THEN Estado <= E3; -- transição E1->E3
                    ELSE Estado <= E1;			-- essa condição não é obrigatória
                    END IF;
                WHEN E2 =>
                    IF Entradas= "11" THEN Estado <= E1;
                    ELSIF Entradas= "00" OR Entradas= "10" THEN Estado <= E3;
                    ELSE Estado <= E2;			-- essa condição não é obrigatória
                    END IF;
                WHEN E3 =>
                    IF Entradas= "01" OR Entradas= "11" THEN Estado <= E1; 
                    ELSE Estado <= E3;			-- essa condição não é obrigatória
                    END IF; 
					 WHEN E4 =>
                    IF Entradas= "00" OR Entradas= "11" THEN Estado <= E1;
                    ELSIF Entradas= "01" THEN Estado <= E3; 
                    ELSE Estado <= E4;			-- essa condição não  é obrigatória
                    END IF;
		END CASE;
        END IF;
    END PROCESS;
    
    PROCESS (Estado)			-- processo para definição das variáveis de saída
    BEGIN
           CASE Estado IS								  
                WHEN E1 =>
                    V <= "111"; 		-- atribuição das saídas para o Estado E1
                WHEN E2 =>
                    V <="011"; 	   -- atribuição das saídas para o Estado E2
                WHEN E3 =>
                    V <= "001"; 		-- atribuição das saídas para o Estado E3
                WHEN E4 =>
                    V <="110"; 		-- atribuição das saídas para o Estado E4
			END CASE;
     END PROCESS;
	  
END BEHAVIOR;
