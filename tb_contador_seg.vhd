library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_contador_seg is
end tb_contador_seg;

architecture arch of tb_contador_seg is

    -- Declaración del componente bajo prueba (DUT)
    component contador_seg
        Generic (
            LIMIT_1S : integer := 12000000
        );
        Port (
            clk_12mhz : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            seg       : out STD_LOGIC_VECTOR (6 downto 0);
            dp        : out STD_LOGIC
        );
    end component;

    -- Señales de estímulo y monitoreo
    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC := '1';
    signal seg_tb : STD_LOGIC_VECTOR (6 downto 0);
    signal dp_tb  : STD_LOGIC;

    -- Período del reloj de 12 MHz -> 1 / 12,000,000 ≈ 83.33 ns
    constant CLK_PERIOD : time := 83.33 ns;

begin

    -- Instanciación del módulo contador con un límite reducido para la simulación
    uut: contador_seg
        generic map (
            LIMIT_1S => 5 -- Cambiado a 5 ciclos de reloj para verificar rápido la cuenta
        )
        port map (
            clk_12mhz => clk_tb,
            rst       => rst_tb,
            seg       => seg_tb,
            dp        => dp_tb
        );

    -- Proceso de generación del reloj de 12 MHz
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Proceso de estímulos (Reset y observación)
    stim_proc: process
    begin
        -- Aplicar reset inicial
        rst_tb <= '1';
        wait for 200 ns;
        
        -- Liberar reset para iniciar el conteo
        rst_tb <= '0';
        
        -- Dejar correr la simulación el tiempo suficiente para ver varios ciclos (0 a 9 y reinicio)
        wait for 4 us;
        
        -- Fin de la simulación
        assert false report "Simulación finalizada correctamente." severity failure;
    end process;

end arch;