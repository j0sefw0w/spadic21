library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity data_reader is
  port(
    clk         : in std_logic;
    rst         : in std_logic;
    enable      : in std_logic;
    data        : out std_logic_vector(23 downto 0);
    sp_valid    : out std_logic
  );
end;

architecture behav of data_reader is
  signal line_data      : std_logic_vector(23 downto 0);
  signal valid          : std_logic;

  file file_SP_DATA : text; 

  begin
     file_open(file_SP_DATA, "sp_data.txt", read_mode);
     read_file: process(clk)
       variable d_line  : line;
       variable s       : std_logic_vector(23 downto 0);
       --variable s       : string(24 downto 1);
     begin
       
       if rising_edge(clk) then
         if(rst = '1') then
           line_data <= (others => '0');
           s := (others => '0');
           valid     <= '0';
         elsif(not endfile(file_SP_DATA)) then
           readline(file_SP_DATA, d_line);
           read(d_line, s);
           line_data <= s;
           valid <= '1';
         elsif(endfile(file_SP_DATA)) then
           valid <= '0';
         end if;
         data <= line_data;
         sp_valid <= valid;
       end if;
   end process read_file;
  
  end behav;