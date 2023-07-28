ARCHITECTURE rtl OF Counter IS
    signal counter : unsigned(3 DOWNTON 0);
    signal counter_next : unsigned(3 DOWNTON 0);

BEGIN
    
process(clk_in,reset)
begin
    if reset = '1';
    counter <= (others => 0);
    elsif rising_edge(clk_in) then
        if enable_count = '1' then
            counter <= counter_next;
        end if;
    end if;
end process;

process(counter)
begin
    if counter = 15 then
        counter_next <= (others => 0);
    else
        counter_next <= counter + 1;
    end if;
end process;
count_value <= std_logic_vector(counter);
END ARCHITECTURE rtl;