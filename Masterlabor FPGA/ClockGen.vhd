ARCHITECTURE rtl OF ClockGen IS
    signal clock_counter : unsigned(25 DOWNTO 0);
    signal clock_counter_next : unsigned(25 DOWNTO 0);
    signal clkEnable_out_next : std_logic;
BEGIN

process(clk_in,reset)
begin
    if reset = '1' then
        clock_counter <= (others => '0');
        clkEnable_out <= '0';
    elsif rising_edge(clk_in) then
        clock_counter <= clock_counter_next;
        clkEnable_out <= clkEnable_out_next;
    end if ;
end process;

process(clock_counter,resetValue_in)
begin
    if clock_counter = unsigned(resetValue_in) - 1 then
        clock_counter_next <= (others => '0');
        clkEnable_out_next <= '1';
    else
        clock_counter_next <= clock_counter + 1;
        clkEnable_out_next <= 0;
    end if;

end process;

clkEnable_led <= '1' when
    clock_counter <= '25000000'
ELSE '0';

END ARCHITECTURE rtl;