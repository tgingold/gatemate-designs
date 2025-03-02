library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello is
	port (
		clk_i : in std_logic;
		rst_n_i : in std_logic;
		led_o : out std_logic;
                dbg_tx_o: out std_logic;
                dbg_rx_i: in std_logic
	);
end entity;

architecture rtl of hello is

	component CC_PLL is
	generic (
		REF_CLK         : string;  -- reference input in MHz
		OUT_CLK         : string;  -- pll output frequency in MHz
		PERF_MD         : string;  -- LOWPOWER, ECONOMY, SPEED
		LOW_JITTER      : integer; -- 0: disable, 1: enable low jitter mode
		CI_FILTER_CONST : integer; -- optional CI filter constant
		CP_FILTER_CONST : integer  -- optional CP filter constant
	);
	port (
		CLK_REF             : in  std_logic;
		USR_CLK_REF         : in  std_logic;
		CLK_FEEDBACK        : in  std_logic;
		USR_LOCKED_STDY_RST : in  std_logic;
		USR_PLL_LOCKED_STDY : out std_logic;
		USR_PLL_LOCKED      : out std_logic;
		CLK0                : out std_logic;
		CLK90               : out std_logic;
		CLK180              : out std_logic;
		CLK270              : out std_logic;
		CLK_REF_OUT         : out std_logic
	);
	end component;

	signal clk0    : std_logic;
	signal counter : unsigned(26 downto 0);

        constant c_baudrate : natural := 9600;

        subtype t_baudrate is natural range 0 to (100_000_000 + c_baudrate / 2) / c_baudrate;
        signal baudgen_cnt : t_baudrate;
        signal baudgen_p : std_logic;

        signal char : std_logic_vector(8 downto 0);
        signal char_cnt : natural range 0 to 9;

        constant msg : string := "Hello GateMate" & CR & LF;
        signal msg_cnt : natural range 0 to msg'length;
begin
	socket_pll : CC_PLL
	generic map (
		REF_CLK         => "10.0",
		OUT_CLK         => "100.0",
		PERF_MD         => "ECONOMY",
		LOW_JITTER      => 1,
		CI_FILTER_CONST => 2,
		CP_FILTER_CONST => 4
	)
	port map (
		CLK_REF             => clk_i,
		USR_CLK_REF         => '0',
		CLK_FEEDBACK        => '0',
		USR_LOCKED_STDY_RST => '0',
		USR_PLL_LOCKED_STDY => open,
		USR_PLL_LOCKED      => open,
		CLK0                => clk0,
		CLK90               => open,
		CLK180              => open,
		CLK270              => open,
		CLK_REF_OUT         => open
	);

	process(clk0)
	begin
          if rising_edge(clk0) then
            if rst_n_i = '0' then
              counter <= (others => '0');
            else
              counter <= counter + 1;
            end if;
          end if;
	end process;

        process(clk0)
        begin
          if rising_edge(clk0) then
            baudgen_p <= '0';

            if rst_n_i = '0' then
              baudgen_cnt <= t_baudrate'high;
            else
              if baudgen_cnt = 0 then
                baudgen_cnt <= t_baudrate'high;
                baudgen_p <= '1';
              else
                baudgen_cnt <= baudgen_cnt - 1;
              end if;
            end if;
          end if;
        end process;

        process(clk0)
        begin
          if rising_edge(clk0) then
            if rst_n_i = '0' then
              dbg_tx_o <= '1';
              char <= (others => '1');
              char_cnt <= 0;
              msg_cnt <= 0;
            else
              if baudgen_p = '1' then
                --  Next bit
                dbg_tx_o <= char(0);
                if char_cnt = 9 then
                  --  End of the character (Start + 8b + Stop)
                  if msg_cnt < msg'length then
                    --  Next character of the message
                    char <= std_logic_vector(to_unsigned (character'pos(msg(msg_cnt + 1)), 8)) & '0';
                    msg_cnt <= msg_cnt + 1;
                    char_cnt <= 0;
                  end if;
                else
                  --  Next bit of the character
                  char_cnt <= char_cnt + 1;
                  --  Shift (and push the stop bit)
                  char <= '1' & char(8 downto 1);
                end if;
              end if;
            end if;
          end if;
        end process;

	led_o <= counter(25);
end architecture;
