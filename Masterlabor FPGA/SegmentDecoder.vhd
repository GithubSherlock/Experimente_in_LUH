ARCHITECTURE rtl OF SegmentDecoder IS
BEGIN

process unsigned(value_in)
begin
    case unsigned(value_in) is
        when to_unsigned(0,4) =>
        hex1_out <= "1000000";
        hex0_out <= "1000000";
        when to_unsigned(1,4) =>
        hex1_out <= "1000000";
        hex0_out <= "1111001";
        when to_unsigned(2,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0100100";
        when to_unsigned(3,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0110000";
        when to_unsigned(4,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0011001";
        when to_unsigned(5,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0010010";
        when to_unsigned(6,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0000010";
        when to_unsigned(7,4) =>
        hex1_out <= "1000000";
        hex0_out <= "1111000";
        when to_unsigned(8,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0000000";
        when to_unsigned(9,4) =>
        hex1_out <= "1000000";
        hex0_out <= "0010000";
        when to_unsigned(10,4) =>
        hex1_out <= "1111001";
        hex0_out <= "1000000";
        when to_unsigned(11,4) =>
        hex1_out <= "1111001";
        hex0_out <= "1111001";
        when to_unsigned(12,4) =>
        hex1_out <= "1111001";
        hex0_out <= "0100100";
        when to_unsigned(13,4) =>
        hex1_out <= "1111001";
        hex0_out <= "0110000";
        when to_unsigned(14,4) =>
        hex1_out <= "1111001";
        hex0_out <= "0011001";
        when to_unsigned(15,4) =>
        hex1_out <= "1111001";
        hex0_out <= "0010010";
    end case;
end process;
END ARCHITECTURE rtl;