--Practica 4 Fiables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N: positive:= 4; 
        WIDTH: positive:= 8 
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        load: in std_logic;  
        din: in std_logic_vector(WIDTH-1 downto 0);                    
        dout: out std_logic_vector(WIDTH-1 downto 0)  
    );
end entity sma_filter;

architecture rtl of sma_filter is

    function clog2(n: positive) return natural is
        variable r: natural:= 0;
        variable v: natural:= n - 1;
    begin
        while v > 0 loop
            r:= r + 1;
            v:= v / 2;
        end loop;
        return r;
    end function;

    constant SUM_WIDTH: natural:= WIDTH + clog2(N);

    type sample_array is array (0 to N-1) of unsigned(WIDTH-1 downto 0);
    signal window: sample_array:= (others =>(others =>'0'));

    signal sum_reg: unsigned(SUM_WIDTH-1 downto 0):=(others =>'0');
    signal idx: natural range 0 to N-1:= 0;
    signal avg_reg: unsigned(WIDTH-1 downto 0):=(others =>'0');

begin
    process(clk, rst)
        variable new_sum: unsigned(SUM_WIDTH-1 downto 0);
    begin
        if rst ='1' then
            window <= (others => (others =>'0'));
            sum_reg <= (others =>'0');
            idx <= 0;
            avg_reg <= (others =>'0');

        elsif rising_edge(clk) then
            new_sum := sum_reg;
            if load ='1' then
                new_sum := sum_reg - resize(window(idx), SUM_WIDTH) + resize(unsigned(din), SUM_WIDTH);
                window(idx) <= unsigned(din);
                if idx = N-1 then
                    idx<= 0;
                else
                    idx<= idx + 1;
                end if;
                sum_reg <= new_sum;
            end if;            
            avg_reg <= resize(to_unsigned(to_integer(new_sum)/N, WIDTH), WIDTH);
        end if;
    end process;
    dout <= std_logic_vector(avg_reg);
end architecture rtl;
