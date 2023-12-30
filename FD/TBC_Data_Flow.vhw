--------------------------------------------------------------------------------
-- Copyright (c) 1995-2007 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 9.2i
--  \   \         Application : ISE
--  /   /         Filename : TBC_Data_Flow.vhw
-- /___/   /\     Timestamp : Fri Sep 03 02:40:43 2021
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: TBC_Data_Flow
--Device: Xilinx
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY TBC_Data_Flow IS
END TBC_Data_Flow;

ARCHITECTURE testbench_arch OF TBC_Data_Flow IS
    FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";

    COMPONENT Data_Flow
        PORT (
            CK : In std_logic;
            RESET : In std_logic;
            data_in : In std_logic_vector (7 DownTo 0);
            data_out : Out std_logic_vector (7 DownTo 0);
            mux_en : In std_logic;
            regwr : In std_logic;
            regrd1 : In std_logic;
            regrd2 : In std_logic;
            reg_add : In std_logic_vector (2 DownTo 0);
            ALU_op : In std_logic_vector (2 DownTo 0)
        );
    END COMPONENT;

    SIGNAL CK : std_logic := '0';
    SIGNAL RESET : std_logic := '0';
    SIGNAL data_in : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL data_out : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL mux_en : std_logic := '0';
    SIGNAL regwr : std_logic := '0';
    SIGNAL regrd1 : std_logic := '0';
    SIGNAL regrd2 : std_logic := '0';
    SIGNAL reg_add : std_logic_vector (2 DownTo 0) := "000";
    SIGNAL ALU_op : std_logic_vector (2 DownTo 0) := "000";

    constant PERIOD : time := 100 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET : time := 100 ns;

    BEGIN
        UUT : Data_Flow
        PORT MAP (
            CK => CK,
            RESET => RESET,
            data_in => data_in,
            data_out => data_out,
            mux_en => mux_en,
            regwr => regwr,
            regrd1 => regrd1,
            regrd2 => regrd2,
            reg_add => reg_add,
            ALU_op => ALU_op
        );

        PROCESS    -- clock process for CK
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                CK <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                CK <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS    -- Process for CK
            BEGIN
                -- -------------  Current Time:  135ns
                WAIT FOR 135 ns;
                RESET <= '1';
                data_in <= "00010111";
                reg_add <= "111";
                -- -------------------------------------
                -- -------------  Current Time:  235ns
                WAIT FOR 100 ns;
                RESET <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  335ns
                WAIT FOR 100 ns;
                regwr <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  435ns
                WAIT FOR 100 ns;
                regwr <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  535ns
                WAIT FOR 100 ns;
                regrd1 <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  635ns
                WAIT FOR 100 ns;
                regrd1 <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  835ns
                WAIT FOR 200 ns;
                data_in <= "00000111";
                reg_add <= "001";
                -- -------------------------------------
                -- -------------  Current Time:  935ns
                WAIT FOR 100 ns;
                regwr <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  1035ns
                WAIT FOR 100 ns;
                regwr <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  1135ns
                WAIT FOR 100 ns;
                regrd2 <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  1235ns
                WAIT FOR 100 ns;
                regrd2 <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  1435ns
                WAIT FOR 200 ns;
                ALU_op <= "010";
                -- -------------------------------------
                -- -------------  Current Time:  1635ns
                WAIT FOR 200 ns;
                reg_add <= "010";
                -- -------------------------------------
                -- -------------  Current Time:  1735ns
                WAIT FOR 100 ns;
                mux_en <= '1';
                regwr <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  1835ns
                WAIT FOR 100 ns;
                mux_en <= '0';
                regwr <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  2035ns
                WAIT FOR 200 ns;
                regrd1 <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  2135ns
                WAIT FOR 100 ns;
                regrd1 <= '0';
                -- -------------------------------------
                WAIT FOR 965 ns;

            END PROCESS;

    END testbench_arch;

