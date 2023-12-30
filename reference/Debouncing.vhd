--*****************************************************************************
-- CENTRO UNIVERSITARIO FEI
-- Sistemas Digitais II    - 1o Semestre de 2021
-- Prof. Dr. Valter F. Avelino - 01/2021
-- Componente VHDL: Debouncing de chaves => DEBOUNCING.vhd
-- Rev. 0
-- Especificações: Entradas: CK, RST, CH
-- 				    Saídas:   CH_DB (sinal CH sem oscilação)
-- Esse código é um exemplo de descrição VHDL de um circuito eliminador de 
-- trepidação de chaves mecânicas. Esse exemplo foi apresentado como exemplo
-- na quarta aula de VHDL da disciplina de Laboratório de Sistemas Digitais II 
-- do Centro Universitario FEI.
--****************************************************************************
-- Projeto VHDL do FF_D
library ieee;      				
use ieee.std_logic_1164.all;

entity flip_d is
	port 
	(d : in std_logic;      	-- q <= d (quando ff_d habilitado pelo sinal de relogio)
	 ck : in std_logic;     	-- sinal de relogio (habilita ff_d na borda de subida)
	 set : in std_logic;   		-- q <= '1'(quando set = '0')
	 rst : in std_logic;    	-- q <= '0'(quando rst = '0')
	 q, nq : out std_logic);	-- saidas q e /q 
end flip_d;

architecture comportamental of flip_d is
begin
	process (ck, set, rst)  	-- processo eh ativado com a alteracao de "ck","set" ou "rst"
	begin
		if (rst='0') then q <='0'; nq <='1';-- prioriza "rst",independente de "ck" ou "set"			
		elsif (set='0') then q <='1'; nq <='0'; -- prioriza "set",independente de "ck" 
		elsif (ck'event and ck='1') then  -- detecta a borda de subida de "ck"
			q <= d; nq <= not(d);         -- atualiza "q" e "/q" na borda de subida de "ck"
		end if;	 
	end process;
end comportamental;
--------------------------------------------------------------------------------------------
-- Projeto VHDL do LATCH_SR
library ieee;                    
use ieee.std_logic_1164.all;

entity latch_sr is
	port 
	(s : in std_logic;           -- s='1' => q='1' (quando habilitado)
	 r : in std_logic; 	         -- r='1' => q='0' (quando habilitado)
	 c : in std_logic;           -- c='1' habilita
	 q, nq : out std_logic);  	 -- saidas q e /q 
end latch_sr;

architecture comportamental of latch_sr is
	signal entradas : std_logic_vector(2 downto 0);
	signal estado: std_logic;  -- set => estado='1' / reset => estado='0'
begin
	entradas <= c & s & r;     -- concatenacao dos sinais de entrada para configurar vetor
	process (entradas)         -- processo eh ativado com a alteracao de qualquer entrada
	begin
		case entradas is
			when "110" | "111" => estado <= '1';  -- set (incluindo a condicao ilegal)
			when "101" => estado <= '0';          -- reset
			when others=> null;     	-- mantem o valor (com c='0' ou c='1" e r=s='0')	
		end case;
	end process;
	q<= estado;
	nq<=not(estado);
end comportamental;
-------------------------------------------------------------------------------------------
-- Projeto VHDL do CONTADOR_CONFIGURAVEL 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- biblioteca para operacoes com inteiros

entity contador_configuravel is
	generic
	(	contagem_min : integer := 0;    -- definicao de valores genericos
		contagem_max : integer := 10); -- para a configuracao dos limites de contagem

	port 
	(	clk		   : in std_logic;      -- clock sensivel a borda de subida
		n_inicia   : in std_logic;	    -- inicio da contagem ativo em '0'
		habilita   : in std_logic;	    -- habilitacao sincrona ativa em '1'
		sob_desc   : in std_logic;	    -- contagem crescente se "sob_desc" ='1'
		n_max      : out std_logic; 	-- contador no limite maximo, ativo em '0'
		n_min	   : out std_logic;		-- contador no limite minimo, ativo em '0'
		q 		   : out integer range contagem_min to contagem_max	);
end entity contador_configuravel;

architecture comportamental of contador_configuravel is
	signal direcao : integer;
	signal limite, inicio : integer range contagem_min to contagem_max;
		
begin
dir: process (sob_desc)		-- Configuracao da direcao da contagem e respectivo limite
	begin
		if (sob_desc = '1') then
			direcao <= 1;
			inicio <= contagem_min;
			limite <= contagem_max;
		else
			direcao <= -1;
			inicio <= contagem_max;
			limite <= contagem_min;
		end if;
	end process dir;

contador: process (clk)							-- Processo que controla a contagem
		variable contagem : integer range contagem_min to contagem_max;
		variable limite_max, limite_min : std_logic := '0';
	begin		
		if (clk'event and clk='1') then			-- Atualizacao sincrona do contador
			if (habilita = '1' and  n_inicia = '0' ) then 
				contagem := inicio;				-- Inicializa contador com valor inicial
				limite_max := '0';				-- Reinicia indicacao de limite maximo excedido
				limite_min := '0';				-- Reinicia indicacao de limitet minimo excedido
			elsif (habilita = '1' and contagem /= limite) then
				contagem := contagem + direcao;	-- Atualiza contador, se o limite
												-- nao esta excedido
				if (contagem = limite) then     -- Verifica se contagem chegou ao limite
					if direcao =1 then limite_max := '1';
					elsif direcao =-1 then limite_min:= '1';
					end if;
				else limite_max := '0'; limite_min := '0';
				end if;
			end if;
		end if;
		q <= contagem;					-- Atualiza saidas do contador com o valor atual
		n_max <= not(limite_max);
		n_min <= not (limite_min);
	end process contador;
end comportamental;
-------------------------------------------------------------------------------------------
-- Projeto DEBOUNCING (projeto principal)
library ieee;
use ieee.std_logic_1164.all;
entity debouncing is
	port 
	(ck		: in std_logic; 				  -- periodo de referencia
	 rst		: in std_logic;				  -- iniciacao da contagem
	 ch		: in std_logic;              -- sinal com oscilacao
	 ch_db 	: out std_logic);		    	  -- sinal sem oscilacao
end debouncing;

architecture estrutural of debouncing is
	component flip_d                  -- declaracao do componente FF_D
		port (d, ck, set, rst : in std_logic;  q : out std_logic);
	end component;					-- note que a saida "nq" nao foi declarada

	component latch_sr              -- declaracao do componente Latch_SR
		port (s, r, c : in std_logic;  q : buffer std_logic);
	end component;					-- note que a saida "nq" nao foi declarada		

	component contador_configuravel	-- declaracao do componente Contador 
		generic (contagem_min: integer:=0; contagem_max: integer:=1000000); 
		         -- contador configurado para debouncing de 20ms (com clk de 20ns)
		port (clk, n_inicia, habilita, sob_desc: in std_logic; 
			  n_max, n_min: out std_logic);
	end component; 					-- note que a saida "q" nao foi declarada

	signal s1, s2, s3 : std_logic;  -- sinais de interligacao dos componentes
begin
	ff1: flip_d port map(ch, ck, '1', '1', s1);
	ff2: latch_sr port map( not(s2), (not(s3)or not(rst)), ck, ch_db);
	cnt: contador_configuravel port map(ck, rst, '1', s1, s2, s3); 
end estrutural;
