--    Note:
--    Der bereitgestellte Code implementiert eine Zustandsmaschine (Finite State Machine, FSM), die die Steuerung einer Verkehrsampel 
--    simuliert. Die FSM verwendet zwei Prozesse, fsm_seq und fsm_comb, um die zeitliche und kombinatorische Logik der Zustandsübergänge 
--    und Aktionen zu verwalten. Die Ampel durchläuft vier Hauptzustände: Z1, Z2, Z3 und Z4, wobei jeder Zustand verschiedene Bedingungen 
--    für das Umschalten und Verhalten der Ampelfarben aufweist. Die Zustände werden basierend auf einem Eingangssignal key_in und einem 
--    internen Zähler counter gesteuert. In jedem Zustand werden die Ausgangssignale für die Ampelfarben (Rot, Gelb, Grün) je nach den 
--    definierten Regeln gesetzt, um den simulierten Ablauf einer Ampelschaltung darzustellen. Der interne Zähler wird verwendet, um die 
--    Dauer jedes Zustands zu verfolgen und die Übergänge zwischen den Zuständen zu steuern. Die Implementierung ermöglicht es, das 
--    Verhalten der Ampel in verschiedenen Zuständen und Übergängen zu steuern und visuell darzustellen.

--    The provided code implements a finite state machine (FSM) that simulates the control of a traffic signal. The FSM utilizes two 
--    processes, fsm_seq and fsm_comb, to manage the temporal and combinational logic of state transitions and actions. The traffic light 
--    goes through four main states: Z1, Z2, Z3, and Z4, with each state having different conditions for switching and behavior of the 
--    light colors. The states are controlled based on an input signal key_in and an internal counter counter. In each state, the output 
--    signals for the light colors (Red, Yellow, Green) are set according to the defined rules to simulate the sequence of a traffic light 
--    operation. The internal counter is used to track the duration of each state and control the transitions between states. The 
--    implementation enables controlling and visually representing the behavior of the traffic light in different states and transitions.

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
            -- Diese Phase ist für Fußgänger zum Überqueren der Straße bestimmt.
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
