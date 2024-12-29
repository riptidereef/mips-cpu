-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Datapath is
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
end Datapath;

-- Datapath structural architecture
architecture str of Datapath is

    component SignExtend is
        port (
            input : in std_logic_vector(15 downto 0);
            is_signed : in std_logic;
            output : out std_logic_vector(31 downto 0)
        );
    end component;

    component ShiftLeft2 is
        generic (
            WIDTH : integer := 32
        );
        port (
            input : in std_logic_vector(WIDTH - 1 downto 0);
            output : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component Concat is
        port (
            input : in std_logic_vector(27 downto 0);
            pc : in std_logic_vector(3 downto 0);
            output : out std_logic_vector(31 downto 0)
        );
    end component;

    component Memory is
        port (
            clk : in std_logic;
            baddr : in std_logic_vector(31 downto 0);
            data_in : in std_logic_vector(31 downto 0);
            mem_read : in std_logic;
            mem_write : in std_logic;
            data_out : out std_logic_vector(31 downto 0);
            inport0_in : in std_logic_vector(31 downto 0);
            inport0_en : in std_logic;
            inport1_in : in std_logic_vector(31 downto 0);
            inport1_en : in std_logic;
            outport : out std_logic_vector(31 downto 0)
        );
    end component;

    component Mux2to1 is
        generic (WIDTH : integer := 32);
        port (
            a : in std_logic_vector(WIDTH - 1 downto 0);
            b : in std_logic_vector(WIDTH - 1 downto 0);
            sel : in std_logic;
            y : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component Mux3to1 is
        generic (WIDTH : integer := 32);
        port (
            a : in std_logic_vector(WIDTH - 1 downto 0);
            b : in std_logic_vector(WIDTH - 1 downto 0);
            c : in std_logic_vector(WIDTH - 1 downto 0);
            sel : in std_logic_vector(1 downto 0);
            y : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component Mux4to1 is
        generic (WIDTH : integer := 32);
        port (
            a : in std_logic_vector(WIDTH - 1 downto 0);
            b : in std_logic_vector(WIDTH - 1 downto 0);
            c : in std_logic_vector(WIDTH - 1 downto 0);
            d : in std_logic_vector(WIDTH - 1 downto 0);
            sel : in std_logic_vector(1 downto 0);
            y : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component Reg is
        generic (
            WIDTH : integer := 32
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            d : in std_logic_vector(WIDTH - 1 downto 0);
            q : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component ALU is
        port (
            a : in std_logic_vector(31 downto 0);
            b : in std_logic_vector(31 downto 0);
            opsel : in std_logic_vector(4 downto 0);
            shamt : in std_logic_vector(4 downto 0);
            result : out std_logic_vector(31 downto 0);
            result_hi : out std_logic_vector(31 downto 0);
            branch_taken : out std_logic
        );
    end component;

    component Registerfile is
        port (
            clk : in std_logic;
            rst : in std_logic;
              
            rd_addr0 : in std_logic_vector(4 downto 0); --read reg 1
            rd_addr1 : in std_logic_vector(4 downto 0); --read reg 2
              
            wr_addr : in std_logic_vector(4 downto 0); --write register
            wr_en : in std_logic;
            wr_data : in std_logic_vector(31 downto 0); --write data
              
            rd_data0 : out std_logic_vector(31 downto 0); --read data 1
            rd_data1 : out std_logic_vector(31 downto 0); --read data 2
              --JAL
            PC_4 : in std_logic_vector(31 downto 0);
            JumpAndLink : in std_logic
        );
    end component;

    component ALUControl is 
    port (
        ALUOp : in std_logic_vector(1 downto 0);
        rtype_ir : in std_logic_vector(5 downto 0);
        itype_ir : in std_logic_vector(5 downto 0);
        opsel : out std_logic_vector(4 downto 0);
        hi_en : out std_logic;
        lo_en : out std_logic;
        alu_lo_hi : out std_logic_vector(1 downto 0)
    );
    end component;

    signal pc_in : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_out : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_en : std_logic := '0';
    signal mem_baddr : std_logic_vector(31 downto 0) := (others => '0');

    signal rega_in : std_logic_vector(31 downto 0) := (others => '0');
    signal regb_in : std_logic_vector(31 downto 0) := (others => '0');
    signal rega_out : std_logic_vector(31 downto 0) := (others => '0');
    signal regb_out : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_out : std_logic_vector(31 downto 0) := (others => '0');
    signal lo_out : std_logic_vector(31 downto 0) := (others => '0');
    signal hi_out : std_logic_vector(31 downto 0) := (others => '0');
    signal hi_en : std_logic := '0';
    signal lo_en : std_logic := '0';
    signal alu_lo_hi : std_logic_vector(1 downto 0) := (others => '0');
    
    signal ir25_0 : std_logic_vector(25 downto 0) := (others => '0');
    signal ir31_26 : std_logic_vector(5 downto 0) := (others => '0');
    signal ir25_21 : std_logic_vector(4 downto 0) := (others => '0');
    signal ir20_16 : std_logic_vector(4 downto 0) := (others => '0');
    signal ir15_11 : std_logic_vector(4 downto 0) := (others => '0');
    signal ir15_0 : std_logic_vector(15 downto 0) := (others => '0');
    signal ir5_0 : std_logic_vector(5 downto 0) := (others => '0');
    signal ir10_6 : std_logic_vector(4 downto 0) := (others => '0');
    signal ir_out : std_logic_vector(31 downto 0) := (others => '0');
    signal pc31_28 : std_logic_vector(3 downto 0) := (others => '0');

    signal mem_out : std_logic_vector(31 downto 0) := (others => '0');
    signal memreg_out : std_logic_vector(31 downto 0) := (others => '0');
    signal opsel : std_logic_vector(4 downto 0) := (others => '0');
    signal alu_res : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_res_hi : std_logic_vector(31 downto 0) := (others => '0');
    signal branch_taken : std_logic := '0';

    signal regfile_writereg : std_logic_vector(4 downto 0) := (others => '0');
    signal regfile_writedata : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_mux_out : std_logic_vector(31 downto 0) := (others => '0');
    signal sl_out : std_logic_vector(27 downto 0) := (others => '0');
    signal ir_sl_input : std_logic_vector(27 downto 0) := (others => '0');
    signal concat_out : std_logic_vector(31 downto 0) := (others => '0');
    signal signex_out : std_logic_vector(31 downto 0) := (others => '0');
    signal signex_sl_out : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_a : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_b : std_logic_vector(31 downto 0) := (others => '0');
begin

    pc_en <= (PCWrite or (branch_taken and PCWriteCond));
    pc31_28 <= pc_out(31 downto 28);
    controller_in <= ir31_26;
    ir_addr <= ir15_0;

    pc: Reg 
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => pc_en, d => pc_in, q => pc_out);

    mem_mux: Mux2to1 
        generic map (WIDTH => 32)
        port map (a => pc_out, b => alu_out, sel => IorD, y => mem_baddr);

    mem_module: Memory
        port map (
            clk => clk,
            baddr => mem_baddr,
            data_in => regb_out,
            mem_read => MemRead,
            mem_write => MemWrite,
            data_out => mem_out,
            inport0_in => inport0_in,
            inport0_en => inport0_en,
            inport1_in => inport1_in,
            inport1_en => inport1_en,
            outport => outport);

    ir: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => IRWrite, d => mem_out, q => ir_out);

    ir25_0 <= ir_out(25 downto 0);
    ir31_26 <= ir_out(31 downto 26);
    ir25_21 <= ir_out(25 downto 21);
    ir20_16 <= ir_out(20 downto 16);
    ir15_11 <= ir_out(15 downto 11);
    ir15_0 <= ir_out(15 downto 0);
    ir5_0 <= ir_out(5 downto 0);
    ir10_6 <= ir_out(10 downto 6);

    mem_data_reg: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => '1', d => mem_out, q => memreg_out);

    regfile_writereg_mux: Mux2to1
        generic map (WIDTH => 5)
        port map (a => ir20_16, b => ir15_11, sel => RegDst, y => regfile_writereg);

    regfile_writedata_mux: Mux2to1
        generic map (WIDTH => 32)
        port map (a => alu_mux_out, b => memreg_out, sel => MemToReg, y => regfile_writedata);

    regfile: Registerfile
        port map (
            clk => clk,
            rst => rst,
            rd_addr0 => ir25_21,
            rd_addr1 => ir20_16,
            wr_addr => regfile_writereg,
            wr_en => RegWrite,
            wr_data => regfile_writedata,
            rd_data0 => rega_in,
            rd_data1 => regb_in,
            PC_4 => (others => '0'),
            JumpAndLink => '0'
        );

    reg_a: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => '1', d => rega_in, q => rega_out);

    reg_b: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => '1', d => regb_in, q => regb_out);

    alu_mux0: Mux2to1
        generic map (WIDTH => 32)
        port map (a => pc_out, b => rega_out, sel => ALUSrcA, y => alu_a);

    alu_mux1: Mux4to1
        generic map (WIDTH => 32)
        port map (a => regb_out, 
                  b => x"00000004", 
                  c => signex_out, 
                  d => signex_sl_out, 
                  sel => ALUSrcB,
                  y => alu_b);

    alu_main: ALU
        port map (
            a => alu_a,
            b => alu_b,
            opsel => opsel,
            shamt => ir10_6,
            result => alu_res,
            result_hi => alu_res_hi,
            branch_taken => branch_taken
        );

    alu_out_reg: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => '1', d => alu_res, q => alu_out);

    lo_reg: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => lo_en, d => alu_res, q => lo_out);

    hi_reg: Reg
        generic map (WIDTH => 32)
        port map (clk => clk, rst => rst, en => hi_en, d => alu_res_hi, q => hi_out);

    alu_out_mux: Mux3to1
        generic map (WIDTH => 32)
        port map (a => alu_out, b => lo_out, c => hi_out, sel => alu_lo_hi, y => alu_mux_out);

    pc_mux: Mux3to1
        generic map (WIDTH => 32)
        port map (a => alu_res, b => alu_out, c => concat_out, sel => PCSource, y => pc_in);

    sign_ext: SignExtend port map (input => ir15_0, is_signed => IsSigned, output => signex_out);

    sign_ext_sl: ShiftLeft2 
        generic map (WIDTH => 32)
        port map (input => signex_out, output => signex_sl_out);

    ir_sl_input <= "00" & ir25_0;
    ir_sl: ShiftLeft2 
        generic map (WIDTH => 28)
        port map (input => ir_sl_input, output => sl_out);

    ir_concat: Concat
        port map (input => sl_out, pc => pc31_28, output => concat_out);
    
    alu_control: ALUControl
        port map (
            ALUOp => ALUOp,
            rtype_ir => ir5_0,
            itype_ir => ir31_26,
            opsel => opsel,
            hi_en => hi_en,
            lo_en => lo_en,
            alu_lo_hi => alu_lo_hi
        );

end str;






library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SignExtend is
    port (
        input : in std_logic_vector(15 downto 0);
        is_signed : in std_logic;
        output : out std_logic_vector(31 downto 0)
    );
end SignExtend;

architecture bhv of SignExtend is
begin
    output <= std_logic_vector(resize(unsigned(input), 32)) when is_signed = '0' else
              std_logic_vector(resize(signed(input), 32));
end bhv;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftLeft2 is
    generic (
        WIDTH : integer := 32
    );
    port (
        input : in std_logic_vector(WIDTH - 1 downto 0);
        output : out std_logic_vector(WIDTH - 1 downto 0)
    );
end ShiftLeft2;

architecture bhv of ShiftLeft2 is
begin
    output <= input(WIDTH - 3 downto 0) & "00";
end bhv;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Concat is
    port (
        input : in std_logic_vector(27 downto 0);
        pc : in std_logic_vector(3 downto 0);
        output : out std_logic_vector(31 downto 0)
    );
end Concat;

architecture bhv of Concat is
begin
    output <= pc & input;
end bhv;

