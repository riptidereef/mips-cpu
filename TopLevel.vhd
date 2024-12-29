-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevel is
    port (
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        inport0_in: in std_logic_vector(31 downto 0);
        inport0_en: in std_logic;
        inport1_in: in std_logic_vector(31 downto 0);
        inport1_en: in std_logic;
        outport:    out std_logic_vector(31 downto 0)
    );
end TopLevel;

architecture str of TopLevel is

    signal PCWriteCond_s, PCWrite_s, IorD_s, MemRead_s, MemWrite_s, MemToReg_s: std_logic := '0';
    signal IRWrite_s, JumpAndLink_s, IsSigned_s, ALUSrcA_s, RegWrite_s, RegDst_s: std_logic := '0';
    signal PCSource_s, ALUOp_s, ALUSrcB_s: std_logic_vector(1 downto 0) := "00";
    signal ir_select_s: std_logic_vector(5 downto 0) := (others => '0');
    signal ir_addr_s: std_logic_vector(15 downto 0) := (others => '0');

    component Controller is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            ir_select: in std_logic_vector(5 downto 0);
            ir_addr: in std_logic_vector(15 downto 0);
            PCWriteCond : out std_logic;
            PCWrite : out std_logic; 
            IorD : out std_logic; 
            MemRead : out std_logic; 
            MemWrite : out std_logic; 
            MemToReg : out std_logic; 
            IRWrite : out std_logic; 
            JumpAndLink : out std_logic; 
            IsSigned : out std_logic; 
            PCSource : out std_logic_vector(1 downto 0); 
            ALUOp : out std_logic_vector(1 downto 0);
            ALUSrcB : out std_logic_vector(1 downto 0); 
            ALUSrcA : out std_logic; 
            RegWrite : out std_logic; 
            RegDst : out std_logic
        );
    end component;

    component Datapath is
        port (
            clk : in std_logic;
            rst : in std_logic;
            PCWriteCond : in std_logic;
            PCWrite : in std_logic; 
            IorD : in std_logic; 
            MemRead : in std_logic; 
            MemWrite : in std_logic; 
            MemToReg : in std_logic; 
            IRWrite : in std_logic; 
            JumpAndLink : in std_logic; 
            IsSigned : in std_logic; 
            PCSource : in std_logic_vector(1 downto 0); 
            ALUOp : in std_logic_vector(1 downto 0);
            ALUSrcB : in std_logic_vector(1 downto 0); 
            ALUSrcA : in std_logic; 
            RegWrite : in std_logic; 
            RegDst : in std_logic;
            inport0_in: in std_logic_vector(31 downto 0);
            inport0_en: in std_logic;
            inport1_in: in std_logic_vector(31 downto 0);
            inport1_en: in std_logic;
            controller_in: out std_logic_vector(5 downto 0);
            outport:    out std_logic_vector(31 downto 0);
            ir_addr: out std_logic_vector(15 downto 0)
        );
    end component;

begin

    datapath_inst: Datapath
        port map (
            clk => clk,
            rst => rst,
            PCWriteCond => PCWriteCond_s,
            PCWrite => PCWrite_s,
            IorD => IorD_s,
            MemRead => MemRead_s,
            MemWrite => MemWrite_s,
            MemToReg => MemToReg_s,
            IRWrite => IRWrite_s,
            JumpAndLink => JumpAndLink_s,
            IsSigned => IsSigned_s,
            PCSource => PCSource_s,
            ALUOp => ALUOp_s,
            ALUSrcB => ALUSrcB_s,
            ALUSrcA => ALUSrcA_s,
            RegWrite => RegWrite_s,
            RegDst => RegDst_s,
            inport0_in => inport0_in,
            inport0_en => inport0_en,
            inport1_in => inport1_in,
            inport1_en => inport1_en,
            controller_in => ir_select_s,  -- Output to Controller
            outport => outport,            -- Top-level output
            ir_addr => ir_addr_s
        );

    -- Instantiate Controller
    controller_inst: Controller
        port map (
            clk => clk,
            rst => rst,
            ir_addr => ir_addr_s,
            start => start,
            ir_select => ir_select_s,  -- Input from Datapath
            PCWriteCond => PCWriteCond_s,
            PCWrite => PCWrite_s,
            IorD => IorD_s,
            MemRead => MemRead_s,
            MemWrite => MemWrite_s,
            MemToReg => MemToReg_s,
            IRWrite => IRWrite_s,
            JumpAndLink => JumpAndLink_s,
            IsSigned => IsSigned_s,
            PCSource => PCSource_s,
            ALUOp => ALUOp_s,
            ALUSrcB => ALUSrcB_s,
            ALUSrcA => ALUSrcA_s,
            RegWrite => RegWrite_s,
            RegDst => RegDst_s
        );

    

end str;