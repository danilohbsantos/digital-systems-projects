--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1º Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Gerador de Pulso de Pórtico => GERADOR_PP.vhd
-- Rev. 0
-- Especificacoes: Entradas: CLK, RST
-- 				    Saidas:   PP, LP
--                 Interface com ADXL345: SDO, SCLK, SDI, NOT_CS
-- Esse código gera pulsos equivalentes à passagem de um pórtico de um sistema 
-- de pedágio aberto com intervalos entre 0,25 seg. e 4 seg.
-- Esse código pode ser utilizado na disciplina de Laboratorio de Sistemas
-- Digitais II do Centro Universitario FEI.
--****************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY GERADOR_PP IS 					-- 	declaracao da entidade GEADORE_PP
	PORT
	(	CLK, RST: IN STD_LOGIC; 		-- sinais de controle
		PP : BUFFER STD_LOGIC; 			-- puso de pórtico 
		LP : BUFFER STD_LOGIC; 		   -- led de sinalização de frequência
		SDO: IN STD_LOGIC; 				-- entrada de dados do sensor ADXL345
		SCLK,SDI,NOT_CS: OUT STD_LOGIC);--sinais de comunicação com sensor ADXL345
END GERADOR_PP;

ARCHITECTURE ESTRUTURAL OF GERADOR_PP IS
SIGNAL DATA_READY: STD_LOGIC;
SIGNAL X: STD_LOGIC_VECTOR(3 DOWNTO 0);

COMPONENT ACELEROMETRO IS								
	PORT(
		CLK: IN STD_LOGIC; -- clock de 50 MHZ
		RST: IN STD_LOGIC; -- sinal de iniciação de registros
		SDO: IN STD_LOGIC; -- entrada de dados do sensor ADXL345
		R: IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- sinais de configuração de range
		DATA_READY: OUT STD_LOGIC; 		-- sinal de leitura de aceleração pronta
		ACC_X, ACC_Y, ACC_Z: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);-- aceleração
		SCLK, SDI, NOT_CS: OUT STD_LOGIC -- -sinais de comunicação com sensor ADXL345
		 );
END COMPONENT ACELEROMETRO;

COMPONENT DIVISOR_PP IS 		
	PORT	
	(	CLK, RST: IN STD_LOGIC; 					-- sinais de controle
		X 	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 	-- valor do ajuste do dividor 
		DATA_READY: IN STD_LOGIC;     -- sinal de leitura de aceleração pronta
		PP : OUT STD_LOGIC); 			-- puso de pórtico
END COMPONENT DIVISOR_PP;

BEGIN
SENSOR: ACELEROMETRO PORT MAP(CLK=>CLK, RST=>RST, SDO=>SDO, R=>"10", 
				DATA_READY=>DATA_READY, SCLK=>SCLK, SDI=>SDI, NOT_CS=>NOT_CS, 
				ACC_X(6 DOWNTO 3)=>X);
DIVISOR: DIVISOR_PP PORT MAP(CLK=>CLK, RST=>RST, X=>X, DATA_READY=>DATA_READY,
				PP=>PP);

PROCESS (PP, RST) 
BEGIN
	IF RST='0' THEN LP<='0';
	ELSIF RISING_EDGE(PP) THEN LP<= NOT(LP);
 	END IF;
END PROCESS;

END ESTRUTURAL;
--============================================================================
--                 COMPONENTE ACELEROMETRO
--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Projeto de Iniciação Didática de Sistemas Digitais  
-- Autor: Rhaycen R. Prates - 04/2019
-- Revisor: Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: ACELERÔMETRO => Acelerometro.vhd
-- Rev. 0
-- Especificações: Entradas: CLK, RST, R[1..0]
-- 				    Saidas: DATA_READY, ACC_X[15..0], ACC_Y[15..0],ACC_Z[15..0]
--						 Interface com ADXL345: SDO, SCLK, SDI, NOT_CS
-- Esse código realiza a comunicação com o sensor ADXL345, permitindo o controle
-- da leitura do acelerômetro presente na placa DE10-Lite (Terasic).
-- Esse código foi desenvolvido para ser utilizado na disciplina de 
-- Laboratório de Sistemas Digitais II do Centro Universitário FEI.
--****************************************************************************
LIBRARY IEEE;				
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ACELEROMETRO IS								
	PORT(
		CLK: IN STD_LOGIC; -- CLOCK DE 50 MHZ
		SDO: IN STD_LOGIC; -- ENTRADA DE DADOS DO SENSOR ADXL345
		RST: IN STD_LOGIC; -- SINAL DE CONTROLE DE CONFIGURAÇÃO DE REGISTROS
		R: IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- SINAIS DE CONFIGURAÇÃO DE RANGE
		DATA_READY: OUT STD_LOGIC; -- SINAL DE DADOS PRONTOS
		ACC_X, ACC_Y, ACC_Z: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);-- DADOS DE ACELERAÇÃO
		SCLK, SDI, NOT_CS: OUT STD_LOGIC -- SINAIS DE COMUNICAÇÃO COM SENSOR ADXL345
		 );
END ACELEROMETRO ;

ARCHITECTURE ESTRUTURAL OF  ACELEROMETRO  IS	
SIGNAL COUNT: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RST_TEMP, CLOCK_EN,CLK_2: STD_LOGIC;
SIGNAL ACC_X0, ACC_X1, ACC_Y0, ACC_Y1, ACC_Z0, ACC_Z1: STD_LOGIC_VECTOR(16 DOWNTO 9);

COMPONENT UC3E PORT(
		CLK,RST,SDO,CLOCK_EN,CLK_2	: IN STD_LOGIC;
		NOT_CS, SCLK,RST_TEMP : OUT STD_LOGIC;
		COUNT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ACC_X0, ACC_X1, ACC_Y0, ACC_Y1, ACC_Z0, ACC_Z1: OUT STD_LOGIC_VECTOR(16 DOWNTO 9);
		SDI : OUT STD_LOGIC;
		------------------------ENTRADAS E SAÍDAS PARA CONTROLE EXTERNO--------------		
	   R: IN STD_LOGIC_VECTOR(1 DOWNTO 0);-- SELEÇÃO DE RANGE (2g A 16g)
	   DATA_READY: OUT STD_LOGIC; -- SINAL DE LEITURA DE DADOS DOS 3 EIXOS COMPLETADA
	   ACC_X, ACC_Y, ACC_Z: OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );-- DADOS DE ACELERAÇÃO 
END COMPONENT UC3E;

COMPONENT TEMPORIZADOR2  PORT(
		RST, CLK,CLOCK_EN	: IN STD_LOGIC; 
		COUNT : BUFFER STD_LOGIC_VECTOR(4 DOWNTO 0) );       
END COMPONENT TEMPORIZADOR2;

COMPONENT GERADOR_CLOCK_100K PORT(
   CLK, RST	: IN STD_LOGIC;		   
 	CLOCK_EN, CLK_2: OUT STD_LOGIC );
END COMPONENT GERADOR_CLOCK_100K;

BEGIN
	UCR : UC3E PORT MAP(	CLK=>CLK, RST=>RST, SDO=>SDO, CLOCK_EN=>CLOCK_EN, CLK_2=> CLK_2, 
			NOT_CS=>NOT_CS, SCLK=>SCLK, RST_TEMP=>RST_TEMP,	COUNT=>COUNT, SDI=>SDI, R=>R,
			ACC_X0=>ACC_X0, ACC_X1=>ACC_X1, ACC_Y0=>ACC_Y0, ACC_Y1=>ACC_Y1,ACC_Z0=>ACC_Z0, 
			ACC_Z1=>ACC_Z1, ACC_X=>ACC_X, ACC_Y=>ACC_Y,ACC_Z=>ACC_Z,DATA_READY=>DATA_READY);
   TEMP: TEMPORIZADOR2 PORT MAP(CLK=>CLK, COUNT=>COUNT,RST=>RST_TEMP,CLOCK_EN=>CLOCK_EN);
	CLOCK_2:GERADOR_CLOCK_100K PORT MAP(CLK=>CLK,RST=>RST,CLOCK_EN=>CLOCK_EN,CLK_2=>CLK_2);
	  
END ESTRUTURAL;

--======================================================================================
--  					COMPONENTE UNIDADE DE CONTROLE DE TRES EIXOS - UC3E
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY UC3E IS								
	PORT(
		CLK,RST,SDO,CLOCK_EN,CLK_2	: IN STD_LOGIC;
		SDI : OUT STD_LOGIC;
		SCLK : BUFFER STD_LOGIC;
		NOT_CS, RST_TEMP : OUT STD_LOGIC;
		COUNT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ACC_X0,ACC_X1,ACC_Y0,ACC_Y1,ACC_Z0,ACC_Z1 : BUFFER STD_LOGIC_VECTOR(16 DOWNTO 9);
		------------------------ENTRADAS E SAÍDAS PARA CONTROLADOR EXTERNO------------------
	   R: IN STD_LOGIC_VECTOR(1 DOWNTO 0);-- SELEÇÃO DE FAIXA DE OPERAÇÃO:2g/4g/8g/16g
	   DATA_READY: BUFFER STD_LOGIC; -- AVISO DE LEITURA DE DADOS DOS 3 EIXOS COMPLETA
	   ACC_X, ACC_Y, ACC_Z: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)-- DADOS DE ACELERAÇÃO 	
		);
END UC3E;

ARCHITECTURE FSM OF UC3E IS
SUBTYPE DADOS_SERIAIS IS STD_LOGIC;-- registro de 1 bit (subtype)
TYPE REG_SDI IS ARRAY(0 TO 16) OF DADOS_SERIAIS; -- conjunto de registros da ram 
SIGNAL MEMORY: REG_SDI;            --  array de 17 registros
 
SIGNAL SET_SCLK: STD_LOGIC; 

SUBTYPE DADOS_SERIAIS_OUT IS STD_LOGIC;-- registro de 1 bit (subtype)
TYPE REG_SDO IS ARRAY(0 TO 16) OF DADOS_SERIAIS_OUT; -- conjunto de registros da ram
SIGNAL MEMORY_OUT: REG_SDO; 		--  array de 17 registros
			
TYPE ME_STATE IS (A,B,C,D,E,FX0,GX0,HX0,IX0,FX1,GX1,HX1,IX1,FY0,GY0,HY0,IY0,FY1,GY1,
						HY1,IY1,FZ0,GZ0,HZ0,IZ0,FZ1,GZ1,HZ1,IZ1,FULL_DATA, J);
SIGNAL ST: ME_STATE; 

BEGIN
LEITURA_ACELEROMETRO: PROCESS (CLK, RST )
VARIABLE TEMP: STD_LOGIC_VECTOR(13 DOWNTO 0); -- variável de contagem de taxa de dados
BEGIN
IF RST='0' THEN ST <= A; -- reset ou mudança de resolução	
				SDI<='0'; NOT_CS<='1'; RST_TEMP<='0';SET_SCLK<='1';DATA_READY<='0';
				TEMP:="00000000000000";
				ACC_X0<="00000000";ACC_X1<="00000000";
				ACC_Y0<="00000000";ACC_Y1<="00000000";
				ACC_Z0<="00000000";ACC_Z1<="00000000";	
ELSIF (CLK'EVENT AND CLK='1' AND CLOCK_EN='1') THEN
 CASE ST IS
 
 -- SEQUÊNCIA DE ESTADOS PARA ESCRITA NO ACELERÔMETRO

	WHEN A =>  ST<=B;
	        	SDI<='0'; RST_TEMP<='1'; SET_SCLK<='1'; NOT_CS<='0';
				MEMORY(0)<= '0';	--W/R   
				MEMORY(1)<=	'1';	--MB
				MEMORY(2)<=	'1';	--A5
			   MEMORY(3)<=	'0';	--A4 CONFIGURAÇÃO DO REGISTRADOR 0X2C(44): OUTPUT DATA RATE
		      MEMORY(4)<=	'1';	--A3
	         MEMORY(5)<=	'1';	--A2
            MEMORY(6)<=	'0';	--A1
            MEMORY(7)<=	'0';	--A0
            MEMORY(8)<=	'0';	--D7
            MEMORY(9)<=	'0';	--D6
            MEMORY(10)<='0';	--D5
            MEMORY(11)<='0';	--D4
            MEMORY(12)<='1';	--D3 TAXA DE COMUNICAÇÃO DE DADOS DE  100 HZ (1010)
            MEMORY(13)<='0';	--D2
            MEMORY(14)<='1';	--D1
            MEMORY(15)<='0';  --D0
				MEMORY(16)<='0';  --BIT NÃO UTILIZADO
			  
	WHEN B => IF COUNT="01111" THEN ST<=C;
	          ELSE ST<=B;
				 END IF; 
				 SDI<= MEMORY(conv_integer(unsigned(COUNT))); 
             SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
	
	WHEN C => ST<=D;
				 SDI<='0';  RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1';
 		 
 -- SEQUÊNCIA DE ESTADOS PARA ESCRITA NO ACELERÔMETRO
 
	WHEN D => ST<=E;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY(0)<= '0';	--W/R   
				MEMORY(1)<=	'1';	--MB
				MEMORY(2)<=	'1';	--A5
			   MEMORY(3)<=	'1';	--A4 CONFIGURAÇÃO DO REGISTRADOR 0X31(49) PARA DATA_FORMAT
		      MEMORY(4)<=	'0';	--A3
	         MEMORY(5)<=	'0';	--A2
            MEMORY(6)<=	'0';	--A1
            MEMORY(7)<=	'1';	--A0
            MEMORY(8)<=	'0';	--D7
            MEMORY(9)<=	'0';	--D6 COMUNICAÇÃO EM 4 FIOS (SPI 4-WIRE)
            MEMORY(10)<='0';	--D5
            MEMORY(11)<='0';	--D4
            MEMORY(12)<='0';	--D3
            MEMORY(13)<='0';	--D2
            MEMORY(14)<=R(1);	--D1 DEFINIÇÃO DO RANGE (±2g A ±16g)
            MEMORY(15)<=R(0); --D0
				MEMORY(16)<='0';	--BIT NÃO UTILIZADO

	WHEN E => IF COUNT="01111"  THEN ST<=FX0;
	          ELSE ST<=E;
				 END IF; 
             SDI<= MEMORY(conv_integer(unsigned(COUNT))); 
             SET_SCLK<='0';NOT_CS<='0'; RST_TEMP<='1';
				  
	WHEN FX0 => ST<=GX0;
				 SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1'; DATA_READY<='0';
			  
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAX0		
			
	WHEN GX0 =>  ST<=HX0;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY_OUT(0)<='1';  --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X32(50) PARA DATAX0
	         MEMORY_OUT(5)<='0';	--A2
            MEMORY_OUT(6)<='1';	--A1
            MEMORY_OUT(7)<='0';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
           			  
	WHEN HX0 => IF COUNT="00111" THEN ST<=IX0;
	          ELSE ST<=HX0;
				 END IF; 
				 SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
             SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
	
	WHEN IX0 => IF COUNT="10000" THEN ST<=FX1;
				 ELSE ST<=IX0;
				 END IF;	
				 ACC_X0(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
				 
	WHEN FX1 => ST<=GX1;
				  SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1';		
		
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAX1		
			
	WHEN GX1=>  ST<=HX1;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY_OUT(0)<='1'; --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X33(51) PARA DATAX1
	         MEMORY_OUT(5)<='0';	--A2
            MEMORY_OUT(6)<='1';	--A1
            MEMORY_OUT(7)<='1';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
            			  
	WHEN HX1 => IF COUNT="00111" THEN ST<=IX1;
	          ELSE ST<=HX1;
				 END IF; 
            SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
            SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
			  
	WHEN IX1 => IF COUNT="10000"   THEN ST<=FY0;
				 ELSE ST<=IX1;
				 END IF;	
				 ACC_X1(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
		
	WHEN FY0 => ST<=GY0;
				 SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1'; 
			  
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAY0		
			
	WHEN GY0 =>  ST<=HY0;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY_OUT(0)<='1';  --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X34(52) PARA DATAY0
	         MEMORY_OUT(5)<='1';	--A2
            MEMORY_OUT(6)<='0';	--A1
            MEMORY_OUT(7)<='0';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
           			  
	WHEN HY0 => IF COUNT="00111" THEN ST<=IY0;
	          ELSE ST<=HY0;
				 END IF; 
				 SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
             SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
	
	WHEN IY0 => IF COUNT="10000" THEN ST<=FY1;
				 ELSE ST<=IY0;
				 END IF;	
				 ACC_Y0(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
				 
	WHEN FY1 => ST<=GY1;
				  SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1';		
		
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAY1		
			
	WHEN GY1=>  ST<=HY1;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY_OUT(0)<='1'; --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X35(53) PARA DATAY1
	         MEMORY_OUT(5)<='1';	--A2
            MEMORY_OUT(6)<='0';	--A1
            MEMORY_OUT(7)<='1';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
            			  
	WHEN HY1 => IF COUNT="00111" THEN ST<=IY1;
	          ELSE ST<=HY1;
				 END IF; 
            SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
            SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
			  
	WHEN IY1 => IF COUNT="10000"   THEN ST<=FZ0;
				 ELSE ST<=IY1;
				 END IF;	
				 ACC_Y1(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
		
	WHEN FZ0 => ST<=GZ0;
				 SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1'; 
			  
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAZ0		
			
	WHEN GZ0 =>  ST<=HZ0;
	        	RST_TEMP<='1'; NOT_CS<='1';SET_SCLK<='1';
				MEMORY_OUT(0)<='1';  --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X36(54) PARA DATAZ0
	         MEMORY_OUT(5)<='1';	--A2
            MEMORY_OUT(6)<='1';	--A1
            MEMORY_OUT(7)<='0';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
           			  
	WHEN HZ0 => IF COUNT="00111" THEN ST<=IZ0;
	          ELSE ST<=HZ0;
				 END IF; 
				 SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
             SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
	
	WHEN IZ0 => IF COUNT="10000" THEN ST<=FZ1;
				 ELSE ST<=IZ0;
				 END IF;	
				 ACC_Z0(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
				 
	WHEN FZ1 => ST<=GZ1;
				  SDI<='0'; RST_TEMP<='0'; SET_SCLK<='1'; NOT_CS<='1';	
		
-- SEQUÊNCIA DE ESTADOS PARA LEITURA DOS DADOS DE ACELERAÇÃO DATAZ1		
			
	WHEN GZ1=>  ST<=HZ1;
	        	RST_TEMP<='1'; NOT_CS<='0';SET_SCLK<='1';
				MEMORY_OUT(0)<='1'; --W/R	   
				MEMORY_OUT(1)<='1';	--MB
				MEMORY_OUT(2)<='1';	--A5
			   MEMORY_OUT(3)<='1';	--A4
		      MEMORY_OUT(4)<='0';	--A3  CONFIGURAÇÃO DO REGISTRADOR 0X37(55) PARA DATAZ1
	         MEMORY_OUT(5)<='1';	--A2
            MEMORY_OUT(6)<='1';	--A1
            MEMORY_OUT(7)<='1';	--A0
				MEMORY_OUT(8)<='0';  --BIT NÃO UTILIZADO
            			  
	WHEN HZ1 => IF COUNT="00111" THEN ST<=IZ1;
	          ELSE ST<=HZ1;
				 END IF; 
            SDI<= MEMORY_OUT(conv_integer(unsigned(COUNT))); 
            SET_SCLK<='0';NOT_CS<='0';RST_TEMP<='1';
				  
	WHEN IZ1 => IF COUNT="10000" THEN ST<=FULL_DATA;
				 ELSE ST<=IZ1;
				 END IF;	
				 ACC_Z1(conv_integer(unsigned(COUNT)))<=SDO;
             SDI<='0';  RST_TEMP<='1'; SET_SCLK<='0'; NOT_CS<='0';
				 
   WHEN FULL_DATA => ST<=J;  
				 SDI<='0'; RST_TEMP<='0';SET_SCLK<='1';DATA_READY<='1';NOT_CS<='1';
	
	WHEN J => IF TEMP< "00001110000100" THEN TEMP:= TEMP+1;ST<=J; --CONTA ATÉ 900
				 ELSE TEMP:="00000000000000"; ST<=FX0;
				 END IF;	
				 DATA_READY<='0';
					   	
	WHEN OTHERS => NULL;
 END CASE;
END IF;
END PROCESS LEITURA_ACELEROMETRO;

-- CONFIGURAÇÃO DO SCLK:
 
PROCESS(CLK_2,SET_SCLK)
BEGIN
IF SET_SCLK='1' THEN SCLK<='1';
ELSIF (CLK_2'event and CLK_2='1') THEN SCLK<=NOT(SCLK);
END IF;
END PROCESS;

-- CARGA DOS DADOS NOS REGISTROS DE SAÍDA:

CARREGAR_DADOS: PROCESS(DATA_READY,RST)
BEGIN
IF RST='0' THEN ACC_X<="0000000000000000";
					 ACC_Y<="0000000000000000";
					 ACC_Z<="0000000000000000";
ELSIF DATA_READY='1' THEN 
	ACC_X(7)<=ACC_X0(9);  ACC_X(15)<=ACC_X1(9);  
	ACC_X(6)<=ACC_X0(10); ACC_X(14)<=ACC_X1(10); 
	ACC_X(5)<=ACC_X0(11); ACC_X(13)<=ACC_X1(11); 
	ACC_X(4)<=ACC_X0(12); ACC_X(12)<=ACC_X1(12); 
	ACC_X(3)<=ACC_X0(13); ACC_X(11)<=ACC_X1(13); 
	ACC_X(2)<=ACC_X0(14); ACC_X(10)<=ACC_X1(14); 
	ACC_X(1)<=ACC_X0(15); ACC_X(9) <=ACC_X1(15); 
	ACC_X(0)<=ACC_X0(16); ACC_X(8) <=ACC_X1(16); 
	ACC_Y(7)<=ACC_Y0(9);  ACC_Y(15)<=ACC_Y1(9);  
	ACC_Y(6)<=ACC_Y0(10); ACC_Y(14)<=ACC_Y1(10); 
	ACC_Y(5)<=ACC_Y0(11); ACC_Y(13)<=ACC_Y1(11); 
	ACC_Y(4)<=ACC_Y0(12); ACC_Y(12)<=ACC_Y1(12); 
	ACC_Y(3)<=ACC_Y0(13); ACC_Y(11)<=ACC_Y1(13); 
	ACC_Y(2)<=ACC_Y0(14); ACC_Y(10)<=ACC_Y1(14); 
	ACC_Y(1)<=ACC_Y0(15); ACC_Y(9) <=ACC_Y1(15);  
	ACC_Y(0)<=ACC_Y0(16); ACC_Y(8) <=ACC_Y1(16);  
	ACC_Z(7)<=ACC_Z0(9);  ACC_Z(15)<=ACC_Z1(9);
	ACC_Z(6)<=ACC_Z0(10); ACC_Z(14)<=ACC_Z1(10);
	ACC_Z(5)<=ACC_Z0(11); ACC_Z(13)<=ACC_Z1(11);
	ACC_Z(4)<=ACC_Z0(12); ACC_Z(12)<=ACC_Z1(12);
	ACC_Z(3)<=ACC_Z0(13); ACC_Z(11)<=ACC_Z1(13);
	ACC_Z(2)<=ACC_Z0(14); ACC_Z(10)<=ACC_Z1(14);
	ACC_Z(1)<=ACC_Z0(15); ACC_Z(9) <=ACC_Z1(15);
	ACC_Z(0)<=ACC_Z0(16); ACC_Z(8) <=ACC_Z1(16);
END IF; 
END PROCESS CARREGAR_DADOS;
   						
END FSM;

--======================================================================================
--  		COMPONENTE TEMPORIZADOR PARA CONTAGEM DE DADOS TRANSFERIDOS - TEMPORIZADOR2
LIBRARY IEEE;				
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Temporizador2 IS								
	PORT(
		RST, CLK,CLOCK_EN	: IN STD_LOGIC; 
		COUNT : BUFFER STD_LOGIC_VECTOR(4 DOWNTO 0));
END Temporizador2;

ARCHITECTURE FSM OF Temporizador2 IS

BEGIN
PROCESS( CLK, RST )  		 				
	BEGIN
		IF RST ='0' THEN COUNT <="00000"; 
		ELSIF ( RISING_EDGE(CLK) AND CLOCK_EN='1') THEN
			IF COUNT < "10000" THEN
				COUNT(0) <= NOT COUNT(0);
				COUNT(1) <= COUNT(0) XOR COUNT(1);
				COUNT(2) <= ( COUNT(0) AND COUNT(1) ) XOR COUNT(2);
				COUNT(3) <= ( COUNT(0) AND COUNT(1) AND COUNT(2) ) XOR COUNT(3);
				COUNT(4) <= ( COUNT(0) AND COUNT(1) AND COUNT(2) AND COUNT(3)) XOR COUNT(4);
			END IF;
		END IF;
END PROCESS;

END FSM;

--======================================================================================
--  		COMPONENTE GERADOR DE CLOCK DE TRANSMISSÃO DE DADOS - GERADOR_CLOCK_100K
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY GERADOR_CLOCK_100K IS PORT(
   CLK		: IN STD_LOGIC;		   
 	RST		: IN STD_LOGIC;
  	CLOCK_EN, CLK_2  : OUT STD_LOGIC);
END GERADOR_CLOCK_100K ;
   
ARCHITECTURE COMPORTAMENTAL OF GERADOR_CLOCK_100K  IS
SIGNAL temp: STD_LOGIC_VECTOR( 8 DOWNTO 0 ); 

BEGIN
GERANDO_CLK_2: PROCESS( CLK, RST )  		 				
	BEGIN
		IF RST ='0'  THEN
			temp <="000000000"  ; -- carrega valor inicial: 0
		ELSIF rising_edge(ClK) THEN
			IF temp < "111110011" THEN -- verifica se temp < 499
			temp(0) <= NOT temp(0);
			temp(1) <= temp(0) XOR temp(1);
			temp(2) <= ( temp(0) AND temp(1) ) XOR temp(2);
 			temp(3) <= ( temp(0) AND temp(1) AND temp(2) ) XOR temp(3);
			temp(4) <= ( temp(0) AND temp(1) AND temp(2) AND temp(3)) XOR temp(4);
			temp(5) <= ( temp(0) AND temp(1) AND temp(2) AND temp(3) AND temp(4))
						XOR temp(5);
			temp(6) <= ( temp(0) AND temp(1) AND temp(2) AND temp(3) AND temp(4)
						 AND temp(5))XOR temp(6);
			temp(7) <= ( temp(0) AND temp(1) AND temp(2) AND temp(3) AND temp(4)
						 AND temp(5) AND temp(6))XOR temp(7);
			temp(8) <= ( temp(0) AND temp(1) AND temp(2) AND temp(3) AND temp(4)
						 AND temp(5) AND temp(6) AND temp(7))XOR temp(8);
			ELSE 	temp <="000000000";
			END IF;		
		END IF;
END PROCESS;

-- Atualiza saida de CLK_2 (200 KHz) para gerar SCLK de 100 KHz:
CLK_2<= temp(7);

-- Atualiza pulso de clock enable:
CLOCK_EN <= '1' WHEN temp = "111110011"  ELSE '0';		 
	
END COMPORTAMENTAL;
--======================================================================================
--  		COMPONENTE DIVISOR PARA GERAR PULSO DE PÓRTICO - DIVISOR_PP
--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II  -  Projeto 2  - 1º Semestre de 2021
-- Prof. Valter F. Avelino - 01/2021
-- Componente VHDL: Divisor para gerar Pulso de Pórtico => DIVISOR_PP.vhd
-- Rev. 0
-- Especificacoes: Entradas: CLK, RST, X[3..0]
-- 				    Saidas:   PP
-- Esse código é um divisor da frequência de 50MHz para obtenção de pulsos com
-- frequências de 0,25 Hz a 4 Hz, simulando pulsos equivalentes à passagem 
-- por pórticos (PP) em um sistema de pedágio aberto (intervalo: 4s e 0,25s)
-- Esse código pode ser utilizado na disciplina de Laboratorio de Sistemas
-- Digitais II do Centro Universitario FEI.
--****************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DIVISOR_PP IS 		-- declaracao da entidade DIVISOR_PP
	PORT	
	(	CLK, RST: IN STD_LOGIC; 		 -- sinais de controle
		X 	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- valor do ajuste do dividor 
		DATA_READY: IN STD_LOGIC;      -- sinal de leitura de aceleração pronta
		PP : OUT STD_LOGIC); 			 -- puso de pórtico
END DIVISOR_PP;

ARCHITECTURE RTL OF DIVISOR_PP IS
SIGNAL MAX: STD_LOGIC_VECTOR(27 DOWNTO 0);  -- valor limite de contagem

BEGIN

PROCESS (DATA_READY, RST) -- seletor de valor máximo de contagem
BEGIN
  IF RST='0' THEN MAX<= X"5F5E100";
  ELSIF DATA_READY='1' THEN
		-- Ajusta Limite de Contagem (4 SEG a 0,25 SEG) 
	CASE X IS
		WHEN "1000" => MAX <= X"BEBC200";	-- 200E6   (4,0  SEG)
		WHEN "1001"	=> MAX <= X"B2D05E0";	-- 187,5E6 (3,75 SEG)
		WHEN "1010"	=> MAX <= X"A6E49C0";	-- 175E6   (3,5  SEG)
		WHEN "1011"	=> MAX <= X"9AF8DA0";	-- 162,5E6 (3,25 SEG)
		WHEN "1100"	=> MAX <= X"8F0D180";	-- 150E6   (3,0  SEG)
		WHEN "1101" => MAX <= X"8321560"; 	-- 137,5E6 (2,75 SEG)
		WHEN "1110" => MAX <= X"7735940"; 	-- 125E6   (2,5  SEG)
		WHEN "1111" => MAX <= X"6B49D20"; 	-- 112,5E6 (2,25 SEG)
		WHEN "0000" => MAX <= X"5F5E100"; 	-- 100E6  (2,0  SEG)
		WHEN "0001" => MAX <= X"53724E0"; 	-- 87,5E6 (1,75 SEG)
		WHEN "0010" =>	MAX <= X"47868C0";   -- 75E6   (1,5  SEG)
		WHEN "0011" => MAX <= X"3B9ACA0";	-- 62,5E6 (1,25 SEG)
		WHEN "0100" => MAX <= X"2FAF080"; 	-- 50E6 	 (1,0  SEG)
		WHEN "0101" => MAX <= X"23C3460"; 	-- 37,5E6 (0,75 SEG)
		WHEN "0110" => MAX <= X"17D7840"; 	-- 25E6   (0,5  SEG)
		WHEN "0111" => MAX <= X"0BEFC20"; 	-- 12,5E6 (0,25 SEG)
		WHEN OTHERS	=> MAX <= X"5F5E100";	-- 100E6  (2,0  SEG)
	END CASE;
  END IF;
END PROCESS;

PROCESS (CLK, RST) 	-- contador de pulsos de clock (temporizador)
VARIABLE TEMP: STD_LOGIC_VECTOR(27 DOWNTO 0); -- variável de contagem
	
BEGIN
	IF RST='0' THEN TEMP:= (OTHERS=>'0'); PP<='0';
	ELSIF CLK'EVENT AND CLK='1' THEN
 		IF TEMP< MAX THEN  TEMP:=TEMP+1;PP<='0';
		ELSE TEMP:= (OTHERS=>'0'); PP<='1';
		END  IF;
	END IF;
END PROCESS;

END RTL;
--======================================================================================