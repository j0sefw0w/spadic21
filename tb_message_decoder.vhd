library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

use work.fex_interface_pkg.all;

entity tb_message_decoder is

end tb_message_decoder;

architecture Behavioral of tb_message_decoder is
  --Signals
  signal clk                  : std_logic;
  signal rst_n                : std_logic;
  signal rst_p                : std_logic;
  signal sp_data              : std_logic_vector(23 downto 0);
  signal sp_valid             : std_logic;
  signal sp_word_ready        : std_logic;
  signal word_out             : std_logic_vector(300 downto 0);
  signal stream_out_ready     : std_logic := '1';
  signal stream_out           : FEX_STREAM;
  
  --Declare components



  -- clock period
  constant clk_period : time    := 8ns; -- 125 MHz

begin


  data_reader_I : entity work.data_reader
    port map(
      clk     => clk,
      rst     => rst_p,
      enable  => '1',
      data => sp_data,
      sp_valid => sp_valid
    );
  
  --message_decoder

  message_decoder_I : entity work.message_decoder
  port map(
    clk     => clk,
    rst_p   => rst_p,
    sp_data => sp_data,
    sp_valid => sp_valid,
    sp_word_ready => sp_word_ready,
    word_out => word_out,
    stream_out_ready => stream_out_ready,
    stream_out => stream_out
  );




  -- Clk generation
  clk_gen : process
  begin
    clk <= '1' after (clk_period/2), '0' after clk_period;
    wait for clk_period;
  end process clk_gen;


  --  Reset generation
  rst_gen: process
  begin
    rst_n <= '0';
    wait for 60 ns;
    rst_n <= '1';
    wait;
  end process rst_gen;

  rst_p <= not rst_n;

  end Behavioral;