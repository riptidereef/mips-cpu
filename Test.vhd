-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture behavior of tb is
    -- Testbench signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal start : std_logic := '0';
    signal inport0_in : std_logic_vector(31 downto 0) := x"000001FF";
    signal inport0_en : std_logic := '1';
    signal inport1_in : std_logic_vector(31 downto 0) := (others => '0');
    signal inport1_en : std_logic := '0';
    signal outport : std_logic_vector(31 downto 0);

    -- Clock period (10 ns for 100 MHz clock)
    constant clk_period : time := 10 ns;
begin
    -- Instantiate the TopLevel unit under test
    uut: entity work.TopLevel
        port map (
            clk => clk,
            rst => rst,
            start => start,
            inport0_in => inport0_in,
            inport0_en => inport0_en,
            inport1_in => inport1_in,
            inport1_en => inport1_en,
            outport => outport
        );

    -- Generate clock signal
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Initial reset
        rst <= '1';
        start <= '0';
        wait for 20 ns;

        -- Release reset
        rst <= '0';
        wait for 20 ns;

        -- Start the operation
        start <= '1';
        wait for 20 ns;

        -- Disable start after 20 ns
        start <= '0';

        -- Simulate some behavior (you can add more operations here)
        wait for 100 ns;

        -- End of simulation
        assert false report "Testbench completed successfully!" severity note;
        wait;
    end process;

end behavior;
