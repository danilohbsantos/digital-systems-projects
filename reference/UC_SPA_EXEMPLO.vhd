--********************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1° Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Unidade de Controle do Sisttema de Pedágio =>UC_SPA_EXEMPLO.vhd
-- Rev. 0
-- Especificações: entradas: CK, RT, IC, DC, RP, PP, MO, ZR, PO, NG, ES, FT
-- 			 saidas: Sel_mxa[2..0], Sel_mxb[2..0], Sel_ula[1..0],Lda, Ldb, Ldc,IT
--				 saidas externas: MFC, MEV, LDM
-- Esse código é um padrão de referência (template) para o código da UC que deve 
-- controlar o fluxo de dados do Sistema de Supervisão de Pedágio Aberto do
-- Projeto 2 do Laboratório de Sistemas Digitais II.
--********************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UC_SPA_Exemplo is
port(	CK	: in std_logic;				-- clock de 50MHz
		RT	: in std_logic;				-- reinicio total -> ativo em zero
-- Entradas Externas:
		IC	: in std_logic; 			-- incrementa credito -> ativo em um
		DC	: in std_logic; 			-- decrementa credito -> ativo em um
		RP	: in std_logic; 			-- reinicio parcial -> ativo em um
		PP	: in std_logic; 			-- passagem pelo portico -> ativo em um
		MO	: in std_logic; 			-- modo de operação -> 1= Normal, 0= Ajusta Valor
-- Sinais de Estado da ULA:
		ZR	: in std_logic;			-- resultado zero na operação da ULA
		PO	: in std_logic;			-- resultado positivo na operação da ULA
		NG	: in std_logic;			-- resultado negativo na operação da ULA
		ES	: in std_logic;			-- resultado da operação da ULA maior que 255
-- Sinais de Estado do TIMER:
		FT	: in std_logic;			-- fim da temporização de 1 segundo
-- Sinais de Saida para MUX:
		Sel_mxa : out std_logic_vector(2 downto 0); 	-- seleciona entrada de MUX_A
		Sel_mxb : out std_logic_vector(2 downto 0);	-- seleciona entrada de MUX_B
-- Sinais de Saida para ULA:
		Sel_ula : out std_logic_vector(1 downto 0);	-- seleciona operação da ULA
-- Sinais de Saida para Registradores:
		Lda	: out std_logic;		-- carrega RA
		Ldb	: out std_logic;		-- carrega RB
		Ldc	: out std_logic;		-- carrega RC
-- Sinais de Saida para TIMER:
		IT		: out std_logic;		-- inicia temporização
-- Sinais de Saida Externos:
		MEV	:  out std_logic;		-- sinaliza multa por excesso de velocidade 
		MFC	:  out std_logic;		-- sinaliza multa por falta de crédito
		SDM	:  out std_logic 		-- sinaliza limite de distância total percorrida 
	);
end UC_SPA_exemplo;
----------------------------------------------------------------------------------
architecture FSM of UC_SPA_Exemplo is
type ESTADOS_ME is (ZER_RG, CAR_CR, AJU_CR, ...

				-- COMPLETAR COM OS NOMES DOS ESTADOS DO SEU PROJETO  
						 
						 );
signal E: ESTADOS_ME;
begin
process(CK, RT)
begin
if RT='0' then E <= ZER_RG;	  						-- zera registros
			   MFC <= '0'; MEV <= '0'; SDM<='0';	-- zera multas	e sinalização 		
elsif (CK'event and CK='1') then
 case E is
	when ZER_RG =>
					E <= CAR_CR;			-- carrega CR com credito inicial
	when CAR_CR =>
					E <= AJU_CR;	 		--- espera IC e DC com MO=0 para ajustar CR
	when AJU_CR =>
				if MO = '1' and PP='1' then 
					E <= INC_DP;			-- incrementa distancia parcial
				elsif ....

				-- COMPLETAR COM AS CONDIÇOES LÓGICAS DOS ESTADOS DA SUA FSM 
				
	when others => Null;
 end case;
end if;
end process;

-- Atualização das Saídas para Fluxo de Dados (Multiplexadores, Registradores, ULA)
process(E)
begin
 case E is
	when ZER_RG => 				 					-- zera registros
				Sel_mxa <= "XXX"; Sel_mxb <= "011"; Sel_ula <= "00";  
				Ldc <= '1'; Ldb <= '1'; Lda <='1';  IT <= '1';
	when CAR_CR =>			 						-- carrega CR com Credito Inicial
				Sel_mxa <= "XXX"; Sel_mxb <= "101"; Sel_ula  <= "00";
				Ldc <= '0'; Ldb <= '0'; Lda <='1'; IT <= '1';
	when AJU_CR => 				 					-- espera IC e DC para ajustar CR
				Sel_mxa <= "XXX"; Sel_mxb <= "XXX"; Sel_ula  <= "XX";  
				Ldc <= '0'; Ldb <= '0'; Lda <='0';  IT <= '1';
	 	
				-- COMPLETAR COM OS SINAIS DE CONTROLE DO FLUXO DE DADOS DO SEU PROJETO  
	  
	  
	when others => Null;
 end case;
end process;
end FSM;
