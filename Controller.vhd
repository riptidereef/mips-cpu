-- Jack Ditzel
-- Section: 11610

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        ir_select: in std_logic_vector(5 downto 0); -- from Datapath
        ir_addr: in std_logic_vector(15 downto 0); -- from datapath
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
end Controller;

architecture bhv of Controller is
    type state_type is (error, init, 
                        fetch, fetch_2,
                        decode,
                        load_or_store, load_or_store_2, 
                        load, load_2, load_3,
                        store,
                        memory_read,
                        rtype,
                        rtype_completion,
                        itype, 
                        itype_2,
                        itype_3,
                        itype_completion,
                        jump,
                        halt);


    signal curr_state, next_state : state_type := init;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            curr_state <= init;
        elsif rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process;

    -- add all the signals
    process(clk, curr_state)
    begin
        PCWriteCond <= '0';
        PCWrite <= '0';
        IorD <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        MemToReg <= '0';
        IRWrite <= '0';
        JumpAndLink <= '0';
        IsSigned <= '0';
        PCSource <= "00";
        ALUOp <= "00";
        ALUSrcB <= "00";
        ALUSrcA <= '0';
        RegWrite <= '0';
        RegDst <= '0';

        case curr_state is
            when init =>

                if start = '1' then
                    next_state <= fetch;
                end if;

            when fetch =>

                MemRead <= '1';
                ALUSrcA <= '0';
                IorD <= '0';
                IRWrite <= '1';
                ALUSrcB <= "01";
                ALUOp <= "00";
                PCWrite <= '1';
                PCSource <= "00";

                next_state <= fetch_2;

            when fetch_2 =>

                MemRead <= '1';
                ALUSrcA <= '0';
                IorD <= '0';
                IRWrite <= '1';
                ALUSrcB <= "01";
                ALUOp <= "00";
                PCWrite <= '0';
                PCSource <= "00";

                next_state <= decode;

            when decode =>
                    
                ALUSrcA <= '0';
                ALUSrcB <= "11";
                ALUOp <= "00";

                case ir_select is
                    when "100011" =>
                        -- lw (before)
                        next_state <= load_or_store;

                    when "101011" =>
                        -- sw (before)
                        next_state <= load_or_store;

                    when "000000" =>
                        -- R-type
                        next_state <= rtype;

                    when "000010" =>
                        -- jump to address
                        next_state <= jump;

                    when "000011" =>
                        -- jump and link
                        next_state <= jump;

                    when "001001" | "010000" | "001100" | "001101" =>

                        next_state <= itype;

                    when "111111" =>

                        next_state <= halt;

                    when others =>

                        next_state <= error;

                end case;

            when load_or_store =>
                
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "00";

                next_state <= load_or_store_2;

            when load_or_store_2 =>

                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "00";

                if ir_select = "100011" then
                    next_state <= load;
                else
                    next_state <= store;
                end if;

            when load =>
                
                MemRead <= '1';
                IorD <= '1';

                if ir_addr = x"FFF8" then
                    next_state <= memory_read;
                else
                    next_state <= load_2;
                end if;

            when load_2 =>
                    
                MemRead <= '1';
                IorD <= '1';
                next_state <= memory_read;
            
            when store =>

                MemWrite <= '1';
                IorD <= '1';

                next_state <= fetch;

            when memory_read =>
                
                RegDst <= '0';
                RegWrite <= '1';
                MemToReg <= '1';

                next_state <= fetch;

            when rtype =>

                ALUSrcA <= '1';
                ALUSrcB <= "00";
                ALUOp <= "10";

                next_state <= rtype_completion;

            when rtype_completion =>

                RegDst <= '1';
                RegWrite <= '1';
                MemToReg <= '0';

                next_state <= fetch;

            when itype =>

                IsSigned <= '1';
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "11";
                
                next_state <= itype_2;

            
            when itype_2 =>

                IsSigned <= '1';
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "11";
                
                next_state <= itype_3;

            when itype_3 =>

                IsSigned <= '1';
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "11";
                
                next_state <= itype_completion;

            when itype_completion =>

                IsSigned <= '1';
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= "11";

                RegDst <= '0';
                RegWrite <= '1';
                MemToReg <= '0';

                next_state <= fetch;

            when jump =>
                    
                PCWrite <= '1';
                PCSource <= "10";

                next_state <= fetch;

            when error =>

            when halt =>


            when others =>

        end case;
    end process;

end bhv;