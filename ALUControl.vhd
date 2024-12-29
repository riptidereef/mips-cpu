-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUControl is 
    port (
        ALUOp : in std_logic_vector(1 downto 0);
        rtype_ir : in std_logic_vector(5 downto 0);
        itype_ir : in std_logic_vector(5 downto 0);
        opsel : out std_logic_vector(4 downto 0);
        hi_en : out std_logic;
        lo_en : out std_logic;
        alu_lo_hi : out std_logic_vector(1 downto 0)
    );
end ALUControl;

architecture bhv of ALUControl is
begin

    opsel <= "00000" when (rtype_ir = "100001" and ALUOp = "10") else -- x"21"
             "00001" when (rtype_ir = "100011" and ALUOp = "10") else -- x"23"
             "00010" when (rtype_ir = "011000" and ALUOp = "10") else -- x"18"
             "00011" when (rtype_ir = "011001" and ALUOp = "10") else -- x"19"
             "00100" when (rtype_ir = "100100" and ALUOp = "10") or (itype_ir = "001100" and ALUOp = "11") else -- x"24"
             "00101" when (rtype_ir = "100101" and ALUOp = "10") else -- x"25"
             "00110" when (rtype_ir = "100110" and ALUOp = "10") else -- x"26"
             "00111" when (rtype_ir = "000010" and ALUOp = "10") else -- x"02"
             "01000" when (rtype_ir = "000000" and ALUOp = "10") else -- x"00"
             "01001" when (rtype_ir = "000011" and ALUOp = "10") else -- x"03"
             "01010" when (rtype_ir = "101010" and ALUOp = "10") else -- x"2A"
             "00000" when (ALUOp = "00") else
             "11111";
    
    lo_en <= '1' when (rtype_ir = "011000" or rtype_ir = "011001") and ALUOp = "10" else '0';
    hi_en <= '1' when (rtype_ir = "011000" or rtype_ir = "011001") and ALUOp = "10" else '0';

    alu_lo_hi <= "01" when (rtype_ir = "010010") else
                 "10" when (rtype_ir = "010000") else
                 "00";

end bhv;