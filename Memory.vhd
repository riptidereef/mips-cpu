-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        clk:        in std_logic;
        baddr:      in std_logic_vector(31 downto 0);
        data_in:    in std_logic_vector(31 downto 0);
        mem_read:   in std_logic;
        mem_write:  in std_logic;
        data_out:   out std_logic_vector(31 downto 0);
        inport0_in: in std_logic_vector(31 downto 0);
        inport0_en: in std_logic;
        inport1_in: in std_logic_vector(31 downto 0);
        inport1_en: in std_logic;
        outport:    out std_logic_vector(31 downto 0)
    );
end Memory;

architecture bhv of Memory is

    component RAM is
        port (
            address : in std_logic_vector(7 downto 0);
            clock   : in std_logic;
            data    : in std_logic_vector(31 downto 0);
            rden    : in std_logic;
            wren    : in std_logic;
            q       : out std_logic_vector(31 downto 0)
        );
    end component;

    component Reg is
        generic (
            WIDTH : integer := 8
        );
        port (
            clk : in std_logic;                            
            rst : in std_logic;                              
            en  : in std_logic;                             
            d   : in std_logic_vector(WIDTH-1 downto 0);  
            q   : out std_logic_vector(WIDTH-1 downto 0) 
        );
    end component;

    signal ram_addr                   : std_logic_vector(7 downto 0) := (others => '0');
    signal inport0_temp, inport1_temp : std_logic_vector(31 downto 0) := (others => '0');
    signal ram_out_temp               : std_logic_vector(31 downto 0) := (others => '0');
    signal ram_write, output_write    : std_logic := '0';
    signal temp_data_out              : std_logic_vector(31 downto 0) := (others => '0');

begin

    ram_addr <= baddr(9 downto 2);

    RAM_inst: RAM
        port map (
            address => ram_addr, 
            clock   => clk,
            data    => data_in, 
            rden    => mem_read, 
            wren    => ram_write, 
            q       => ram_out_temp
        );

    inport0_inst: Reg
        generic map (WIDTH => 32)
        port map (
            clk => clk,
            rst => '0',
            en  => inport0_en,
            d   => inport0_in,
            q   => inport0_temp
        );

    inport1_inst: Reg
        generic map (WIDTH => 32)
        port map (
            clk => clk,
            rst => '0',
            en  => inport1_en,
            d   => inport1_in,
            q   => inport1_temp
        );

    outport_inst: Reg
        generic map (WIDTH => 32)
        port map (
            clk => clk,
            rst => '0',
            en  => output_write,
            d   => data_in,
            q   => outport
        );

    temp_data_out <= inport0_temp when (mem_read = '1' and baddr = x"0000FFF8") else
                     inport1_temp when (mem_read = '1' and baddr = x"0000FFFC") else
                     ram_out_temp when mem_read = '1';

    data_out <= temp_data_out;

    output_write <= '1' when (mem_write = '1' and baddr = x"0000FFFC") else '0';
    ram_write    <= '1' when (mem_write = '1' and baddr /= x"0000FFFC") else '0';

end bhv;