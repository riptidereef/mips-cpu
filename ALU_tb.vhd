-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture tb of ALU_tb is
    component ALU
        port (
            a: in std_logic_vector(31 downto 0);
            b: in std_logic_vector(31 downto 0);
            opsel: in std_logic_vector(4 downto 0);
            shamt: in std_logic_vector(4 downto 0);
            result: out std_logic_vector(31 downto 0);
            result_hi: out std_logic_vector(31 downto 0);
            branch_taken: out std_logic
        );
    end component;

    signal a, b, result, result_hi: std_logic_vector(31 downto 0);
    signal opsel: std_logic_vector(4 downto 0);
    signal shamt: std_logic_vector(4 downto 0);
    signal branch_taken: std_logic;
begin

    uut: ALU
        port map (
            a => a,
            b => b,
            opsel => opsel,
            shamt => shamt,
            result => result,
            result_hi => result_hi,
            branch_taken => branch_taken
        );

    process
    begin
        -- Test Addition (10 + 15)
        a <= std_logic_vector(to_signed(10, 32));
        b <= std_logic_vector(to_signed(15, 32));
        opsel <= "00000"; -- OP_ADD
        wait for 10 ns;

        -- Test Subtraction (25 - 10)
        a <= std_logic_vector(to_signed(25, 32));
        b <= std_logic_vector(to_signed(10, 32));
        opsel <= "00001"; -- OP_SUB
        wait for 10 ns;

        -- Test Signed Multiplication (10 * -4)
        a <= std_logic_vector(to_signed(10, 32));
        b <= std_logic_vector(to_signed(-4, 32));
        opsel <= "00010"; -- OP_MUL_SIGNED
        wait for 10 ns;

        -- Test Unsigned Multiplication (65536 * 131072)
        a <= std_logic_vector(to_unsigned(65536, 32));
        b <= std_logic_vector(to_unsigned(131072, 32));
        opsel <= "00011"; -- OP_MUL_UNSIGNED
        wait for 10 ns;

        -- Test AND (0x0000FFFF AND 0xFFFF1234)
        a <= x"0000FFFF";
        b <= x"FFFF1234";
        opsel <= "00100"; -- OP_AND
        wait for 10 ns;

        -- Test Shift Right Logical (0x0000000F >> 4)
        a <= x"0000000F";
        shamt <= "00100"; -- Shift by 4
        opsel <= "00101"; -- OP_SRL
        wait for 10 ns;

        -- Test Shift Right Arithmetic (0xF0000008 >> 1)
        a <= x"F0000008";
        shamt <= "00001"; -- Shift by 1
        opsel <= "00110"; -- OP_SRA
        wait for 10 ns;

        -- Test Shift Right Arithmetic (0x00000008 >> 1)
        a <= x"00000008";
        shamt <= "00001"; -- Shift by 1
        opsel <= "00110"; -- OP_SRA
        wait for 10 ns;

        -- Test Set Less Than (A=10, B=15)
        a <= std_logic_vector(to_signed(10, 32));
        b <= std_logic_vector(to_signed(15, 32));
        opsel <= "00111"; -- OP_SLT
        wait for 10 ns;

        -- Test Set Less Than (A=15, B=10)
        a <= std_logic_vector(to_signed(15, 32));
        b <= std_logic_vector(to_signed(10, 32));
        opsel <= "00111"; -- OP_SLT
        wait for 10 ns;

        -- Test BLEZ (A=5)
        a <= std_logic_vector(to_signed(5, 32));
        opsel <= "01000"; -- OP_BLEZ
        wait for 10 ns;

        -- Test BGTZ (A=5)
        a <= std_logic_vector(to_signed(5, 32));
        opsel <= "01001"; -- OP_BGTZ
        wait for 10 ns;

        -- End of simulation
        wait;
    end process;
end tb;
