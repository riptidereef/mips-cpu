-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory_tb is
end Memory_tb;

architecture test of Memory_tb is

    signal clk       : std_logic := '0';
    signal baddr     : std_logic_vector(31 downto 0) := (others => '0');
    signal data_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_read  : std_logic := '0';
    signal mem_write : std_logic := '0';
    signal data_out  : std_logic_vector(31 downto 0);
    signal inport0_in: std_logic_vector(31 downto 0) := (others => '0');
    signal inport0_en: std_logic := '0';
    signal inport1_in: std_logic_vector(31 downto 0) := (others => '0');
    signal inport1_en: std_logic := '0';
    signal outport   : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

    component Memory
        port (
            clk        : in std_logic;
            baddr      : in std_logic_vector(31 downto 0);
            data_in    : in std_logic_vector(31 downto 0);
            mem_read   : in std_logic;
            mem_write  : in std_logic;
            data_out   : out std_logic_vector(31 downto 0);
            inport0_in : in std_logic_vector(31 downto 0);
            inport0_en : in std_logic;
            inport1_in : in std_logic_vector(31 downto 0);
            inport1_en : in std_logic;
            outport    : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    DUT: Memory
        port map (
            clk        => clk,
            baddr      => baddr,
            data_in    => data_in,
            mem_read   => mem_read,
            mem_write  => mem_write,
            data_out   => data_out,
            inport0_in => inport0_in,
            inport0_en => inport0_en,
            inport1_in => inport1_in,
            inport1_en => inport1_en,
            outport    => outport
        );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test process
    test_process: process
    begin
        -- Test case 1: Write 0x0A0A0A0A to address 0x00000000
        baddr <= x"00000000";
        data_in <= x"0A0A0A0A";
        mem_write <= '1';
        wait for clk_period;
        mem_write <= '0';
        wait for clk_period;

        -- Test case 2: Write 0xF0F0F0F0 to address 0x00000004
        baddr <= x"00000004";
        data_in <= x"F0F0F0F0";
        mem_write <= '1';
        wait for clk_period;
        mem_write <= '0';
        wait for clk_period;

        -- Test case 3: Read from address 0x00000000
        baddr <= x"00000000";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        -- Test case 4: Read from address 0x00000001
        baddr <= x"00000001";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        -- Test case 5: Read from address 0x00000004
        baddr <= x"00000004";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        -- Test case 6: Read from address 0x00000005
        baddr <= x"00000005";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        -- Test case 7: Write 0x00001111 to the outport
        baddr <= x"0000FFFC";
        data_in <= x"00001111";
        mem_write <= '1';
        wait for clk_period;
        mem_write <= '0';
        wait for clk_period;

        -- Test case 8: Load 0x00010000 into inport0
        inport0_in <= x"00010000";
        inport0_en <= '1';
        wait for clk_period;
        inport0_en <= '0';
        wait for clk_period;

        -- Test case 9: Load 0x00000001 into inport1
        inport1_in <= x"00000001";
        inport1_en <= '1';
        wait for clk_period;
        inport1_en <= '0';
        wait for clk_period;

        -- Test case 10: Read from inport0
        baddr <= x"0000FFF8";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        -- Test case 11: Read from inport1
        baddr <= x"0000FFFC";
        mem_read <= '1';
        wait for clk_period;
        mem_read <= '0';
        wait for clk_period;

        wait;
    end process;

end test;
