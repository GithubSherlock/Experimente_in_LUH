ARCHITECTURE rtl OF Zustanautomaten IS
signal counter : unsigned(3 downto 0);
signal counter_next : unsigned(3 downto 0);
type state_t is (Z1, Z2, Z3, Z4);
signal state, state_next : state_t;

BEGIN
    fsm_seq : process(sec_in,reset, state, state_next, counter, counter_next)
    begin -- Reset to Anfangszustand
        if reset = '0' then
            state <= Z1;
        elsif rising_edge(sec_in) then
            counter <= counter_next;
            state <= state_next;
        end if;
        
    end process;

    fsm_comb : process(key_in, state, state_next, counter, counter_next)
    begin
        state_next <= state;
        -- Standardzuweisungen
        if state /= Z1 then -- Create a counter if state is not Z1
            counter_next <= counter + 1;
        else
            counter <= 0; -- else hold the counter always at 0
        end if;
        
        case state is
            when Z1 =>
            -- Signalzuweisungen in der Dauergrünphase Z1
            HS_red <= '1'; HS_yellow <= '1'; HS_green <= '0'; -- HS always hold GREEN
            NS_red <= '0'; NS_yellow <= '1'; NS_green <= '1'; -- NS always hold RED
            
            if key_in = '0' then
                state_next <= Z2;
            end if;

            when Z2 =>
            -- Signalzuweisungen in der Zwischenphase_1 Z2 (0. second to 4. second)
            if counter >= 0 and counter < 2 then
                HS_red <= '1'; HS_yellow <= '1'; HS_green <= '0'; -- HS hold GREEN 1-2 seconds
                NS_red <= '0'; NS_yellow <= '1'; NS_green <= '1'; -- NS hold RED 1-2 seconds
                
            elsif counter = 2 then 
                HS_red <= '1'; HS_yellow <= '0'; HS_green <= '1'; -- HS hold YELLOW in 1 second
                NS_red <= '0'; NS_yellow <= '0'; NS_green <= '1'; -- NS hold YELLOW-RED in 1 second
                
            elsif counter = 3 then
                HS_red <= '0'; HS_yellow <= '1'; HS_green <= '1'; -- HS hold RED in 1 second
                NS_red <= '0'; NS_yellow <= '1'; NS_green <= '1'; -- NS hold RED in 1 second
                
            elsif counter = 4 then 
                state_next <= Z3;
            end if;

            when Z3 =>
            -- Signalzuweisungen in der Triggerphase Z3 (4. second to 7. second)
            if counter >= 4 and counter < 7 then
                HS_red <= '0'; HS_yellow <= '1'; HS_green <= '1'; -- HS hold RED in 3 seconds
                NS_red <= '1'; NS_yellow <= '1'; NS_green <= '0'; -- NS hold GREEN in 3 seconds
                
            elsif couner = 7 then
                state_next <= Z4;
            end if;

            when Z4 =>
            -- Signalzuweisungen in der Zwischenphase_2 Z4 (7. second to 9. second)
            if counter = 7 then
                HS_red <= '0'; HS_yellow <= '0'; HS_green <= '1'; -- HS hold YELLOW-RED in 1 second
                NS_red <= '1'; NS_yellow <= '0'; NS_green <= '1'; -- NS hold YELLOW in 1 second
                
            elsif counter = 8 then
                HS_red <= '0'; HS_yellow <= '1'; HS_green <= '1'; -- HS hold RED in 1 second
                NS_red <= '0'; NS_yellow <= '1'; NS_green <= '1'; -- NS hold RED in 1 second
                
            elsif counter = 9 then
                state_next <=  Z1;
                counter_next <= 0;
            end if;

        end case;
        
    end process;
END ARCHITECTURE rtl;