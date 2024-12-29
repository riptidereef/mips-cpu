-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        opsel: in std_logic_vector(4 downto 0);
        shamt: in std_logic_vector(4 downto 0);
        result: out std_logic_vector(31 downto 0);
        result_hi: out std_logic_vector(31 downto 0);
        branch_taken: out std_logic
    );
end ALU;

architecture bhv of ALU is
    constant OP_ADD : std_logic_vector(4 downto 0) := "00000";  -- Addition
    constant OP_SUB : std_logic_vector(4 downto 0) := "00001";  -- Subtraction
    constant OP_MUL_SIGNED : std_logic_vector(4 downto 0) := "00010";  -- Signed Multiply
    constant OP_MUL_UNSIGNED : std_logic_vector(4 downto 0) := "00011";  -- Unsigned Multiply
    constant OP_AND : std_logic_vector(4 downto 0) := "00100";  -- AND
    constant OP_OR : std_logic_vector(4 downto 0) := "00101"; -- OR TODO
    constant OP_XOR : std_logic_vector(4 downto 0) := "00110"; -- XOR TODO
    constant OP_SRL : std_logic_vector(4 downto 0) := "00111";  -- Shift Right Logical
    constant OP_SLL : std_logic_vector(4 downto 0) := "01000"; -- Shift Left Logical TODO
    constant OP_SRA : std_logic_vector(4 downto 0) := "01001";  -- Shift Right Arithmetic
    constant OP_SLT : std_logic_vector(4 downto 0) := "01010";  -- Set Less Than
    constant OP_BLEZ : std_logic_vector(4 downto 0) := "01011";  -- Branch if Less or Equal to Zero
    constant OP_BGTZ : std_logic_vector(4 downto 0) := "01100";  -- Branch if Greater Than Zero
begin

    process (a, b, opsel, shamt)
        variable temp_result : std_logic_vector(63 downto 0); 
        variable shift_amount : integer range 0 to 31;
    begin
        result <= (others => '0');
        result_hi <= (others => '0');
        branch_taken <= '0';
        
        shift_amount := to_integer(unsigned(shamt(4 downto 0)));

        case opsel is
            when OP_ADD =>
                result <= std_logic_vector(unsigned(a) + unsigned(b));
            when OP_SUB =>
                result <= std_logic_vector(unsigned(a) - unsigned(b));
            when OP_MUL_SIGNED =>
                temp_result := std_logic_vector(signed(a) * signed(b));
                result <= temp_result(31 downto 0);
                result_hi <= temp_result(63 downto 32);
            when OP_MUL_UNSIGNED =>
                temp_result := std_logic_vector(unsigned(a) * unsigned(b));
                result <= temp_result(31 downto 0);
                result_hi <= temp_result(63 downto 32);
            when OP_AND =>
                result <= a and b;
            when OP_OR =>
                result <= a or b;
            when OP_XOR =>
                result <= a xor b;
            when OP_SRL =>
                result <= std_logic_vector(shift_right(unsigned(a), shift_amount));
            when OP_SLL =>
                result <= std_logic_vector(shift_left(unsigned(a), shift_amount));
            when OP_SRA =>
                result <= std_logic_vector(shift_right(signed(a), shift_amount));
            when OP_SLT =>
                if signed(a) < signed(b) then
                    result <= (others => '0');
                    result(0) <= '1';
                else
                    result <= (others => '0');
                end if;
            when OP_BLEZ =>
                if signed(a) <= 0 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            when OP_BGTZ =>
                if signed(a) > 0 then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when others =>
                --result <= (others => 'X');
                --result_hi <= (others => 'X');
                --branch_taken <= 'X';
        end case;
    end process;
end bhv;

