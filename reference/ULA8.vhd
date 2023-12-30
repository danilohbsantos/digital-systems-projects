--********************************************************************************
-- CENTRO UNIVERSITÁRIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1° Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Unidade Aritmética e Lógica com operandos de 8 bits=> ULA8.vhd
-- Rev. 0
-- Especificações: Entradas: A[7..0], B[7..0], Op[1..0]
--				       Saidas :  ALU_out[7..0], ZR, PO, NG, ES
-- A ULA realiza as operações: 
--                      Passa B (Op=00), NOT(B) (OP=01), B+A (Op=10) e B-A (Op=11)
-- A ULA gera quatro sinais de status:
--  		Resultado igual a zero (ZR=1)
--       Resultado maior que zero (PO=1)
--			Resultado menor que zero (NG=1)
--			Resultado maior que 255 (ES=1)
-- Esse componente é assíncrono. 
-- Componente para aplicação no Projeto 2 do Laboratóro de Sistemas Digitais II 
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity ULA8 is
   port
   (
      A, B		: in std_logic_vector(7 downto 0); -- vetores de entrada
      Op			: in std_logic_vector(1 downto 0); -- código de operação
      ULA_out	: out std_logic_vector(7 downto 0);-- vetor de saída
      ZR			: out std_logic; 			           -- resultado igual a zero 
      PO			: out std_logic; 						  -- resultado positivo 
      NG			: out std_logic; 						  -- resultado negativo
      ES			: out std_logic 						  -- resultado maoir que 255
   );
end entity ULA8;
 
architecture Comportamental of ULA8 is

 begin
   process(A,B,Op) is		     				-- ULA assíncrona
   
   variable Temp: std_logic_vector(9 downto 0);	-- registrador temporário 
												-- de 8 bits + bit de estouro + bit de sinal 
   begin
    case Op is
         when "00" =>       					-- Passa B
			Temp := std_logic_vector((unsigned("00" & B)));
		 when "01" =>       					   -- NOT(B)
			Temp := std_logic_vector((unsigned("00" & NOT(B))));
         when "10" => 							-- B + A
            Temp(8 downto 0) := std_logic_vector(unsigned("0" & B) + unsigned("0" & A));
            Temp(9) := '0';					-- resultado positivo
         when "11" => 							
           if (B = A) then						-- B=A, NG=0, ES=0, ZR=1
			   Temp :=(others=>'0');			-- resultado zero
           elsif (B > A) then					-- B > A, NG=0
				Temp(8 downto 0) := std_logic_vector(unsigned("0" & B) - unsigned("0" & A));
				Temp(9) := '0';					-- resultado positivo
			  else 									-- B < A, NG=1, ES=0
            Temp(7 downto 0) := std_logic_vector(unsigned(A) - unsigned(B));
				Temp(8) := '0';					-- sem estouro
            Temp(9) := '1';					-- resultado negativo
            end if;
          when others => null;				-- não faz nada com operando incorreto
    end case;
	if (Temp = "0000000000" ) then  			-- verifica se resultado é igual a zero
		ZR <= '1';
		PO <= '0';
		NG <= '0';
		ES <= '0';
	elsif Temp(8) = '1' then  					-- verifica se resultado é maior que 255
		ZR <= '0';
		PO <= '0';
		NG <= '0';
		ES <= '1';
	elsif Temp(9) = '1' then					-- verifica se resultado é negativo 
		ZR <= '0';
		PO <= '0';
		NG <= '1';
		ES <= '0';
    else 									   	-- resultado é positivo
		ZR <= '0';
		PO <= '1';
		NG <= '0';
		ES <= '0';
    end if;     
    
   ULA_out  <= Temp(7 downto 0); 			-- atualiza saída da ULA
         
   end process;
end architecture Comportamental;