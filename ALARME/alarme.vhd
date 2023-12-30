library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- use IEEE.NUMERIC_STD.ALL;
entity alarme is
GENERIC (ck_divide: INTEGER := 200000); -- 100MHz to 500Hz LCD
PORT (clock: in STD_LOGIC;
reset : in STD_LOGIC;
ativa : in STD_LOGIC;
desat: in STD_LOGIC;
dez : in STD_LOGIC;
uni : in STD_LOGIC;
viola : in STD_LOGIC;
SB : out STD_LOGIC;
ATV: out STD_LOGIC; -- ativando
AT : out STD_LOGIC; -- ativo
TP : out STD_LOGIC; -- timer
VL : out STD_LOGIC; -- violação
ERR: out STD_LOGIC; -- codigo errado
DB: out STD_LOGIC_VECTOR (7 downto 0); -- lcd
RS, RW : out STD_LOGIC; -- lcd
E: Buffer STD_LOGIC); -- lcd
end alarme;
-------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE Behavioral of alarme is
Signal SBY, ATVV, ATT, VLL, TPP, SIRENE, ESPERA_ZERACONT, HAB_INCREMENTO, ERRO_DEZ, ERRO_UNID, ERRO: std_logic;
Signal CONTADORR, TIMER, DEZEN, UNIDAD, VERIF_UNID, VERIF_DEZ: integer range 0 to 255;
----- FSM LCD
type state is (FunctionSet, ClearDisplay, DisplayControl, EntryMode, SetAddress,
WriteData1, WriteData2, WriteData3, WriteData4, WriteData5,
WriteData6, WriteData7, WriteData8, WriteData9, WriteData10,
WriteData17, WriteData18, WriteData19, WriteData20, WriteData21,
WriteData22, WriteData23, WriteData24, WriteData25, WriteData26,
WriteData27, WriteData28, ReturnHome);
signal pr_estado, estado: state;
type lcd_data is array (0 to 31) of std_logic_vector(7 downto 0);
signal lcd: lcd_data;
----- FIM FSM LCD ---------------------------------------------------------------
signal dezena: std_logic_vector (7 downto 0);
signal unidade: std_logic_vector (7 downto 0);
signal cke : std_logic;
signal contador: integer range 0 to 100000000;
----------------------------------------------------------------------------------------
begin
process(clock,reset)
begin
if reset='0' then


SBY<='1'; ATVV<='0'; ATT<='0'; VLL<='0'; TPP<='0'; SIRENE<='0'; ESPERA_ZERACONT<='0'; HAB_INCREMENTO<='0'; ERRO_DEZ<='0'; ERRO_UNID<='0'; ERRO<='0'; -- < COLOQUE AS CONDIÇÕES INICIAIS DOS SEUS LUGARES >;
CONTADORR<=0; TIMER<=0; DEZEN<=0; UNIDAD<=0; VERIF_DEZ<=0; VERIF_UNID<=0;


elsif clock'event and clock='1' then
	if cke='1' then -- clock enable para gerar 1 Hz
	
	-- LUGAR SBY
	
	IF (SBY='1' AND ATIVA='1') THEN SBY<='0';
		ELSIF (ESPERA_ZERACONT='1' AND TIMER<1) THEN SBY<='1';
		ELSE SBY<=SBY;
	END IF;
	
	-- LUGAR ATVV
	
	IF (SBY='1' AND ATIVA='1') THEN ATVV<='1';
		ELSIF (ATVV='1' AND CONTADORR<1) THEN ATVV<='0';
		ELSE ATVV<=ATVV;
	END IF;
	
	-- LUGAR CONTADORR
	
	IF (ATIVA='1' AND SBY='1') THEN CONTADORR<=8;
		ELSIF (CONTADORR>0) THEN CONTADORR<=CONTADORR-1;
		ELSE CONTADORR<=CONTADORR;
	END IF;
	
	-- LUGAR ATT
	
	IF (ATVV='1' AND CONTADORR<1) THEN ATT<='1';
		ELSIF (TPP='1' AND TIMER<1 AND HAB_INCREMENTO='1') THEN ATT<='0';
		ELSIF (ERRO='1' AND TPP='1') THEN ATT<='0';
		ELSIF (HAB_INCREMENTO='1' AND DEZEN>5 AND UNIDAD>0 AND VERIF_UNID<2 AND TPP='1' AND VERIF_DEZ<7 AND VLL='1' AND desat='1') THEN ATT<='0';
		ELSE ATT<=ATT;
	END IF;
	
	-- LUGAR VLL
	
	
	IF (ATT='1' AND viola='1') THEN VLL<='1';
		ELSIF (desat='1' AND DEZEN>5 AND VERIF_DEZ<7 AND TPP='1' AND ATT='1' AND HAB_INCREMENTO='1' AND UNIDAD>0) THEN VLL<='0';
		ELSE VLL<=VLL;
	END IF;
	
	-- LUGAR HAB_INCREMENTO
	
	IF (viola='1' AND HAB_INCREMENTO='0' AND ATT='1') THEN HAB_INCREMENTO<='1';
		ELSIF (ATT='1' AND TPP='1' AND TIMER<1) THEN HAB_INCREMENTO<='0';
		ELSIF (VERIF_DEZ>6 AND HAB_INCREMENTO='1' AND desat='1') THEN HAB_INCREMENTO<='0';
		ELSIF (HAB_INCREMENTO='1' AND (DEZEN<6 OR UNIDAD<1) AND desat='1') THEN HAB_INCREMENTO<='0';
		ELSIF (HAB_INCREMENTO='1' AND VERIF_UNID>1 AND desat='1') THEN HAB_INCREMENTO<='0';
		ELSIF (desat='1' AND HAB_INCREMENTO='1' AND TPP='1' AND DEZEN>5 AND VERIF_DEZ<7 AND VLL='1' AND UNIDAD>0 AND ATT='1') THEN HAB_INCREMENTO<='0';
		ELSE HAB_INCREMENTO<=HAB_INCREMENTO;
	END IF;
	
	-- LUGAR TIMER
	
	IF (viola='1' AND ATT='1' AND TIMER<1) THEN TIMER<=30;
		ELSIF (TPP='1' AND TIMER>0) THEN TIMER<=TIMER-1;
		ELSIF (TPP='0' AND TIMER>0) THEN TIMER<=TIMER-1;
		ELSE TIMER<=TIMER;
	END IF;
	
	-- LUGAR TPP
	
	IF (viola='1' AND ATT='1' AND TPP='0') THEN TPP<='1';
		ELSIF (ERRO='1' AND ATT='1' AND TPP='1') THEN TPP<='0';
		ELSIF (desat='1' AND HAB_INCREMENTO='1' AND TPP='1' AND DEZEN>5 AND VERIF_DEZ<7 AND VLL='1' AND UNIDAD>0 AND ATT='1') THEN TPP<='0';
		ELSIF (ATT='1' AND HAB_INCREMENTO='1' AND TPP='1' AND TIMER<1) THEN TPP<='0';
		ELSE TPP<=TPP;
	END IF;
	
	-- LUGAR SIRENE
	
	IF (TPP='1' AND ERRO='1' AND ATT='1') THEN SIRENE<='1';
		ELSIF (TIMER<1 AND TPP='1' AND ATT='1' AND HAB_INCREMENTO='1') THEN SIRENE<='1';
		ELSE SIRENE<=SIRENE;
	END IF;
	
	-- LUGAR ESPERA_ZERACONT
	
	IF (TIMER<1 AND ESPERA_ZERACONT='1' AND DEZEN<1 AND UNIDAD<1) THEN ESPERA_ZERACONT<='0';
		ELSIF (desat='1' AND HAB_INCREMENTO='1' AND TPP='1' AND DEZEN>5 AND VERIF_DEZ<7 AND VLL='1' AND UNIDAD>0 AND ATT='1') THEN ESPERA_ZERACONT<='1';
		ELSE ESPERA_ZERACONT<=ESPERA_ZERACONT;
	END IF;
	
	-- LUGAR DEZEN
	
	IF (ESPERA_ZERACONT='1' AND DEZEN>0) THEN DEZEN<=DEZEN-1;
		ELSIF DEZEN>8 THEN DEZEN<=0;
		ELSIF (dez='1' AND HAB_INCREMENTO='1') THEN DEZEN<=DEZEN+1;
		ELSE DEZEN<=DEZEN;
	END IF;
	
	-- LUGAR UNIDAD
		
	IF (UNIDAD>0 AND ESPERA_ZERACONT='1' AND VERIF_UNID>0) THEN VERIF_UNID<=VERIF_UNID-1;
		ELSIF(ESPERA_ZERACONT='1' AND UNIDAD>0) THEN UNIDAD<=UNIDAD-1;
		ELSIF UNIDAD>8 THEN UNIDAD<=0;
		ELSIF (uni='1' AND HAB_INCREMENTO='1') THEN UNIDAD<=UNIDAD+1;
		ELSE UNIDAD<=UNIDAD;
	END IF;
	
	-- VERIF_DEZ
	
	IF (DEZEN>0 AND ESPERA_ZERACONT='1' AND VERIF_DEZ>0) THEN VERIF_DEZ<=VERIF_DEZ-1;
		ELSIF VERIF_DEZ>8 THEN VERIF_DEZ<=0;
		ELSIF (dez='1' AND HAB_INCREMENTO='1') THEN VERIF_DEZ<=VERIF_DEZ+1;
		ELSE VERIF_DEZ<=VERIF_DEZ;
	END IF;
	
	-- VERIF_UNID
	
	IF (VERIF_UNID>0 AND UNIDAD>0 AND ESPERA_ZERACONT='1') THEN VERIF_UNID<=VERIF_UNID-1;
		ELSIF VERIF_UNID>8 THEN VERIF_UNID<=0;
		ELSIF (uni='1' AND HAB_INCREMENTO='1') THEN VERIF_UNID<=VERIF_UNID+1;
		ELSE VERIF_UNID<=VERIF_UNID;
	END IF;
	
	-- LUGAR ERRO_DEZ
	
	IF (HAB_INCREMENTO='1' AND DEZEN<6 AND ERRO_DEZ='0' AND desat='1') THEN ERRO_DEZ<='1';
		ELSIF (HAB_INCREMENTO='1' AND VERIF_DEZ>6 AND ERRO_DEZ='0' AND desat='1') THEN ERRO_DEZ<='1';
		ELSIF (ERRO='0' AND ERRO_DEZ='1') THEN ERRO_DEZ<='0';
		ELSE ERRO_DEZ<=ERRO_DEZ;
	END IF;
	
	-- LUGAR ERRO_UNID
	
	IF (HAB_INCREMENTO='1' AND UNIDAD<1 AND ERRO_UNID='0' AND desat='1') THEN ERRO_UNID<='1';
		ELSIF (HAB_INCREMENTO='1' AND VERIF_UNID>2 AND ERRO_UNID='0' AND desat='1') THEN ERRO_UNID<='1';
		ELSIF (ERRO='0' AND ERRO_DEZ='0' AND ERRO_UNID='1') THEN ERRO_UNID<='0';
		ELSE ERRO_UNID<=ERRO_UNID;
	END IF;
	
	-- LUGAR ERRO
	
	IF (ERRO_DEZ='1' AND ERRO='0') THEN ERRO<='1';
		ELSIF (ERRO_UNID='1' AND ERRO_DEZ='0') THEN ERRO<='1';
		ELSE ERRO<=ERRO;
	END IF;
	end if;
end if;
end process;
------------------------------------------------------------------------------------------
-- **** clock enable - cke**** base de tempo de 0,5 seg.
------------------------------------------------------------------------------------------
Process(clock, reset)
begin
if reset='0' then
cke<='0';
contador<=0;
elsif clock'event and clock='1' then
if contador=50000000 then -- *****para simulação usar o valor 2 (MUDAR PARA 50000000)
contador<=0;
cke<='1';
else
contador<=contador+1;
cke<='0';
end if;
end if;
end process;
-------------------------------------------------------------------------------
-- DECODIFICADOR PARA inteiro -> LCD
-------------------------------------------------------------------------------
Process(clock)
begin
if DEZEN=9 then dezena<="00111001"; --9
elsif DEZEN=8 then dezena<="00111000"; --8
elsif DEZEN=7 then dezena<="00110111"; --7
elsif DEZEN=6 then dezena<="00110110"; --6
elsif DEZEN=5 then dezena<="00110101"; --5
elsif DEZEN=4 then dezena<="00110100"; --4
elsif DEZEN=3 then dezena<="00110011"; --3
elsif DEZEN=2 then dezena<="00110010"; --2
elsif DEZEN=1 then dezena<="00110001"; --1
elsif DEZEN=0 then dezena<="00110000"; --0
end if;
if UNIDAD=9 then unidade<="00111001"; --9
elsif UNIDAD=8 then unidade<="00111000"; --8
elsif UNIDAD=7 then unidade<="00110111"; --7
elsif UNIDAD=6 then unidade<="00110110"; --6
elsif UNIDAD=5 then unidade<="00110101"; --5
elsif UNIDAD=4 then unidade<="00110100"; --4
elsif UNIDAD=3 then unidade<="00110011"; --3
elsif UNIDAD=2 then unidade<="00110010"; --2
elsif UNIDAD=1 then unidade<="00110001"; --1
elsif UNIDAD=0 then unidade<="00110000"; --0
end if;
end process;
-----------------------------------------------------------------------------------
-- ************** TELAS LCD ************
-----------------------------------------------------------------------------------
Process(clock)
begin
if SBY='1' and ATVV='0' and ATT='0' then -- tela entrada - DESLIGADO
lcd(1)<="01010011"; -- S
lcd(2)<="01010100"; -- T
lcd(3)<="01000001"; -- A
lcd(4)<="01001110"; -- N
lcd(5)<="01000100"; -- D
lcd(6)<="10110000"; -- -
lcd(7)<="01000010"; -- B
lcd(8)<="01011001"; -- y
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="00100000"; -- blank
lcd(18)<="00100000"; -- blank
lcd(19)<="00100000"; -- blank
lcd(20)<="00100000"; -- blank
lcd(21)<="00100000";-- blank
lcd(22)<="00100000"; -- blank
lcd(23)<="00100000"; -- blank
lcd(24)<="00100000"; -- blank
lcd(25)<="00100000"; -- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000"; -- blank
lcd(28)<="00100000"; -- blank
---fim tela de entrada
elsif ATVV='1' then -- 2a tela ATIVAÇÃO
lcd(1)<="01000001"; -- A
lcd(2)<="01010100"; -- T
lcd(3)<="01001001"; -- I
lcd(4)<="01010110"; -- V
lcd(5)<="01000001"; -- A
lcd(6)<="01001110"; -- N
lcd(7)<="01000100"; -- D
lcd(8)<="01001111"; -- O
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="00100000"; -- blank
lcd(18)<="00100000"; -- blank
lcd(19)<="00100000"; -- blank
lcd(20)<="00100000"; -- blank
lcd(21)<="00100000"; -- blank
lcd(22)<="00100000"; -- blank
lcd(23)<="00100000"; -- blank
lcd(24)<="00100000"; -- blank
lcd(25)<="00100000"; -- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000"; -- blank
lcd(28)<="00100000"; -- blank
------ fim da 2a tela
elsif ERRO='1' and ATT='0' then -- ERRO 3a tela
lcd(1)<="01000101"; -- E
lcd(2)<="01010010"; -- R
lcd(3)<="01010010"; -- R
lcd(4)<="01001111"; -- O
lcd(5)<="00100000"; -- blank
lcd(6)<="00100000"; -- blank
lcd(7)<="00100000"; -- blank
lcd(8)<="00100000"; -- blank
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="01010011"; -- S
lcd(18)<="01000101"; -- E
lcd(19)<="01001110"; -- N
lcd(20)<="01001000"; -- H
lcd(21)<="01000001"; -- A
lcd(22)<="00100000"; -- blank
lcd(23)<="00100000"; -- blank
lcd(24)<="00100000"; -- blank
lcd(25)<="00100000"; -- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000"; -- blank
lcd(28)<="00100000"; -- blank
------- fim da 3a tela
elsif ATT='1' and TPP='0' then -- 4a tela LIGADO
lcd(1)<="01000001"; -- A
lcd(2)<="01010100"; -- T
lcd(3)<="01001001"; -- I
lcd(4)<="01010110"; -- V
lcd(5)<="01001111"; -- O
lcd(6)<="00100000"; -- blank
lcd(7)<="00100000"; -- blank
lcd(8)<="00100000"; -- blank
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="01010011"; -- S
lcd(18)<="01000101"; -- E
lcd(19)<="01001110"; -- N
lcd(20)<="01001000"; -- H
lcd(21)<="01000001"; -- A
lcd(22)<="00100000"; -- blank
lcd(23)<=dezena; -- VALOR DA DEZENA
lcd(24)<=unidade; -- VALOR DA UNIDADE
lcd(25)<="00100000"; -- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000"; -- blank
lcd(28)<="00100000"; -- blank
------- fim da 4a tela
elsif ATT='1' and TPP='1' then -- VIOLAÇÃO entrada 5a tela
lcd(1)<="01010110"; -- V
lcd(2)<="01001001"; -- I
lcd(3)<="01001111"; -- O
lcd(4)<="01001100"; -- L
lcd(5)<="01000001"; -- A
lcd(6)<="01000011"; -- C
lcd(7)<="01000001"; -- A
lcd(8)<="01001111"; -- O
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="01010011"; -- S
lcd(18)<="01000101"; -- E
lcd(19)<="01001110"; -- N
lcd(20)<="01001000"; -- H
lcd(21)<="01000001"; -- A
lcd(22)<="00100000"; -- blank
lcd(23)<=dezena; -- VALOR DA DEZENA
lcd(24)<=unidade; -- VALOR DA UNIDADE
lcd(25)<="00100000"; -- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000"; -- blank
lcd(28)<="00100000"; -- blank
------fim da 5a tela
elsif VLL='1' then -- VIOLAÇÃO BLOQUEIO 6a tela
lcd(1)<="01010110"; -- V
lcd(2)<="01001001"; -- I
lcd(3)<="01001111"; -- O
lcd(4)<="01001100"; -- L
lcd(5)<="01000001"; -- A
lcd(6)<="01000011"; -- C
lcd(7)<="01000001"; -- A
lcd(8)<="01001111"; -- O
lcd(9)<="00100000"; -- blank
lcd(10)<="00100000"; -- blank
------------------------------ segunda linha
lcd(17)<="01000010"; -- B
lcd(18)<="01001100"; -- L
lcd(19)<="01001111"; -- O
lcd(20)<="01010001"; -- Q
lcd(21)<="01010101"; -- U
lcd(22)<="01000101"; -- E
lcd(23)<="01001001"; -- I
lcd(24)<="01001111"; -- O
lcd(25)<="00100000";-- blank
lcd(26)<="00100000"; -- blank
lcd(27)<="00100000";-- blank
lcd(28)<="00100000"; -- blank
------------fim da 6a tela
end if;
end process;
-------------------------------------------------------------------------------
-- Clock gerador (500Hz) para temporizar o LCD
-------------------------------------------------------------------------------
process(clock)
variable conta: integer range 0 to ck_divide;
begin
if clock'event and clock='1' then
conta:= conta+1;
if conta=ck_divide then
E<=NOT E;
conta:=0;
end if;
end if;
end process;
------------------------------------------------------------------------------
-- *** Ativa FSM ** LCD
-------------------------------------------------------------------------------
process(E)
begin
if E'event and E='1' then
if reset='0' then
pr_estado<=FunctionSet;
else
pr_estado<=estado;
end if;
end if;
end process;
-------------------------------------------------------------------------------
-- Geração de Display LCD
-------------------------------------------------------------------------------
process(pr_estado)
begin
case pr_estado is
-- Inicialização
when FunctionSet =>
RS<='0'; RW<='0'; DB<="00111000"; -- 8 bits 2 linhas 5x8
estado<=ClearDisplay;
when ClearDisplay =>
RS<='0'; RW<='0'; DB<="00000001"; -- limpa display memória 00h
estado<=DisplayControl;
when DisplayControl =>
RS<='0'; RW<='0'; DB<="00001100"; -- Display on Cursor não visível s/ blink
estado<=EntryMode;
when EntryMode =>
RS<='0'; RW<='0'; DB<="00000110"; -- Cursor move right, DDRam increase 1
estado<= WriteData1;
-- Fim inicialização
when WriteData1 =>
RS<='1'; RW<='0'; DB<=lcd(1); --
estado<=WriteData2;
when WriteData2 =>
RS<='1'; RW<='0'; DB<=lcd(2); --
estado<=WriteData3;
when WriteData3 =>
RS<='1'; RW<='0'; DB<=lcd(3); --
estado<=WriteData4;
when WriteData4 =>
RS<='1'; RW<='0'; DB<=lcd(4); --
estado<=WriteData5;
when WriteData5 =>
RS<='1'; RW<='0'; DB<=lcd(5); --
estado<=WriteData6;
when WriteData6 =>
RS<='1'; RW<='0'; DB<=lcd(6); --
estado<=WriteData7;
when WriteData7 =>
RS<='1'; RW<='0'; DB<=lcd(7); --
estado<=Writedata8;
when WriteData8 =>
RS<='1'; RW<='0'; DB<=lcd(8); --
estado<=WriteData9;
when WriteData9 =>
RS<='1'; RW<='0'; DB<=lcd(9); --
estado<=WriteData10;
when WriteData10 =>
RS<='1'; RW<='0'; DB<=lcd(10); --
estado<=SetAddress;
-- muda para linha 2 ------------------------------------------------------------
when SetAddress =>
RS<='0'; RW<='0'; DB<="11000000"; -- muda para linha 2
estado<=WriteData17;
when WriteData17 =>
RS<='1'; RW<='0'; DB<=lcd(17); -- seta ->
estado<=WriteData18;
when WriteData18 =>
RS<='1'; RW<='0'; DB<=lcd(18); --
estado<=WriteData19;
when WriteData19 =>
RS<='1'; RW<='0'; DB<=lcd(19); --
estado<=WriteData20;
when WriteData20 =>
RS<='1'; RW<='0'; DB<=lcd(20); --
estado<=WriteData21;
when WriteData21 =>
RS<='1'; RW<='0'; DB<=lcd(21); --
estado<=WriteData22;
when WriteData22=>
RS<='1'; RW<='0'; DB<=lcd(22); --
estado<=WriteData23;
when WriteData23 =>
RS<='1'; RW<='0'; DB<=lcd(23); --
estado<=WriteData24;
when WriteData24 =>
RS<='1'; RW<='0'; DB<=lcd(24); --
estado<=WriteData25;
when WriteData25 =>
RS<='1'; RW<='0'; DB<=lcd(25); --
estado<=WriteData26;
when WriteData26 =>
RS<='1'; RW<='0'; DB<=lcd(26); --
estado<=WriteData27;
when WriteData27 =>
RS<='1'; RW<='0'; DB<=lcd(27); --
estado<=WriteData28;
when WriteData28 =>
RS<='1'; RW<='0'; DB<=lcd(28); --
estado<=ReturnHome;
when ReturnHome =>
RS<='0'; RW<='0'; DB<="10000000"; -- coloca a memória na posição 00h linha 1
estado<=WriteData1;
end case;
end process;
---------------------------------------------------------------------------------Leds
SB <= SBY;
ATV <= ATVV;
AT <= ATT;
VL <= VLL;
TP <= TPP;
ERR <= ERRO;
---------------------------------------------------------------------------------
end Behavioral;