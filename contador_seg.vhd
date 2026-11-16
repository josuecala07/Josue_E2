library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_seg is
    Generic (
        -- Para síntesis en FPGA: 12,000,000 ciclos = 1 segundo (con reloj de 12 MHz).
        -- Para simulación se puede sobreescribir con un valor mucho menor (ej. 5 o 10).
       LIMIT_1S : integer := 12000000
    );
    Port (
        clk_12mhz : in  STD_LOGIC;                    -- Reloj de entrada de 12 MHz
        rst       : in  STD_LOGIC;                    -- Reset asíncrono (activo en alto)
        seg       : out STD_LOGIC_VECTOR (6 downto 0);  -- Segmentos: a, b, c, d, e, f, g
        dp        : out STD_LOGIC                     -- Punto decimal
    );
end contador_seg;

architecture arch of contador_seg is

    -- Señales para el divisor de frecuencia
    signal count_div : integer range 0 to LIMIT_1S := 0;
    signal tick_1s   : std_logic := '0';
    
    -- Señal del contador decimal (0 a 9)
    signal count_dec : integer range 0 to 9 := 0;

begin

    -----------------------------------------------------------------
    -- 1. Divisor de Frecuencia (12 MHz a 1 Hz)
    -----------------------------------------------------------------
    process(clk_12mhz, rst)
    begin
        if rst = '1' then
            count_div <= 0;
            tick_1s   <= '0';
        elsif rising_edge(clk_12mhz) then
            if count_div = LIMIT_1S - 1 then
                count_div <= 0;
                tick_1s   <= '1'; -- Pulso de 1 ciclo de reloj cada 1 segundo
            else
                count_div <= count_div + 1;
                tick_1s   <= '0';
            end if;
        end if;
    end process;

    -----------------------------------------------------------------
    -- 2. Contador Decimal (0 a 9)
    -----------------------------------------------------------------
    process(clk_12mhz, rst)
    begin
        if rst = '1' then
            count_dec <= 0;
        elsif rising_edge(clk_12mhz) then
            if tick_1s = '1' then
                if count_dec = 9 then
                    count_dec <= 0;
                else
                    count_dec <= count_dec + 1;
                end if;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------
    -- 3. Decodificador de 7 Segmentos (Ánodo Común: '0' enciende)
    -- Mapeo de bits: seg(6)=a, seg(5)=b, seg(4)=c, seg(3)=d, seg(2)=e, seg(1)=f, seg(0)=g
    -----------------------------------------------------------------
    process(count_dec)
    begin
        case count_dec is
            when 0      => seg <= "0000001"; -- '0'
            when 1      => seg <= "1001111"; -- '1'
            when 2      => seg <= "0010010"; -- '2'
            when 3      => seg <= "0000110"; -- '3'
            when 4      => seg <= "1001100"; -- '4'
            when 5      => seg <= "0100100"; -- '5'
            when 6      => seg <= "0100000"; -- '6'
            when 7      => seg <= "0001111"; -- '7'
            when 8      => seg <= "0000000"; -- '8'
            when 9      => seg <= "0000100"; -- '9'
            when others => seg <= "1111111"; 
        end case;
    end process;

    dp <= '1'; -- Mantener el punto decimal apagado

end arch;