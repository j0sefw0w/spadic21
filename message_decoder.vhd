library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

use work.fex_interface_pkg.all;

entity message_decoder is
Port(
  -- System
  clk               : in  std_logic;
  rst_p             : in  std_logic;
  -- Input spadic word
  -- sp_word           : in  DPB_FRAME;
  sp_data           : in std_logic_vector(23 downto 0);
  sp_valid          : in std_logic;
  sp_word_ready     : out std_logic;
  word_out          : out std_logic_vector(300 downto 0);
  -- Output decoded spadic messge
  stream_out        : out FEX_STREAM;
  stream_out_ready  : in  std_logic
  );
end message_decoder;

architecture Behavioral of message_decoder is
--Signal declarations

  type T_STATE is (ST_IDLE, ST_SOM, ST_RDA, ST_RDA_WAIT,
  ST_EOM, ST_EPM, ST_WAIT_FINISHED, MERGED_SOM, MERGED_RDA, 
  MERGED_RDA_WAIT);
  signal STATE : T_STATE := ST_IDLE;

  type T_STATE_2 is (STORAGE_IDLE, STORAGE_TB, STORAGE_META, STORAGE_MISC, 
  STORE_FIRST_MSG, STORE_SECOND_MSG);
  signal STORAGE_STATE : T_STATE_2 := STORAGE_IDLE;  
  signal msg_stored           : std_logic;
  signal preamble             : std_logic_vector(3 downto 0);
  signal word_en               : std_logic;
  --signal con_en               : std_logic;
  --signal con_counter          : std_logic_vector(11  downto 0);
  signal word_counter         : std_logic_vector(3  downto 0);
  signal word_buffer        : std_logic_vector(3 downto 0);
  --signal con_vec              : std_logic_vector(335 downto 0) := (others => '0');
  signal ch                   : std_logic_vector(3   downto 0);
  signal ts                   : std_logic_vector(6  downto 0);
  signal epm                  : std_logic_vector(11  downto 0);
  signal eom                  : std_logic_vector(15  downto 0);
  signal rda_som              : std_logic_vector(6  downto 0);
  signal rda_eom              : std_logic_vector(17  downto 0);
  signal rda_vec              : std_logic_vector(280  downto 0) := (others => '0');
  signal samples_ind          : std_logic_vector(1   downto 0);
  signal samples              : std_logic_vector(5 downto 0);
  signal m_hit                : std_logic;
  signal hit_type             : std_logic_vector(1   downto 0) := b"00";
  --signal elink                : std_logic_vector(3   downto 0) := x"0";
  signal ch_reg               : std_logic_vector(3   downto 0);
  signal ts_reg               : std_logic_vector(6  downto 0);
  signal epm_reg              : std_logic_vector(11  downto 0);
  signal samples_reg          : std_logic_vector(5   downto 0);
  signal hit_done             : std_logic;
  signal samples_done         :std_logic;
 -- signal misc_done            : std_logic;
  signal m_hit_reg            : std_logic := '0';
  signal hit_type_reg         : std_logic_vector(1 downto 0) := b"00";
  -- signal elink_reg            : std_logic_vector(3 downto 0) := x"0";
  signal tb_0_tmp             : std_logic_vector(8 downto 0);
  signal tb_1_tmp             : std_logic_vector(8 downto 0);
  signal tb_2_tmp             : std_logic_vector(8 downto 0);
  signal tb_3_tmp             : std_logic_vector(8 downto 0);
  signal tb_4_tmp             : std_logic_vector(8 downto 0);
  signal tb_5_tmp             : std_logic_vector(8 downto 0);
  signal tb_6_tmp             : std_logic_vector(8 downto 0);
  signal tb_7_tmp             : std_logic_vector(8 downto 0);
  signal tb_8_tmp             : std_logic_vector(8 downto 0);
  signal tb_9_tmp             : std_logic_vector(8 downto 0);
  signal tb_10_tmp            : std_logic_vector(8 downto 0);
  signal tb_11_tmp            : std_logic_vector(8 downto 0);
  signal tb_12_tmp            : std_logic_vector(8 downto 0);
  signal tb_13_tmp            : std_logic_vector(8 downto 0);
  signal tb_14_tmp            : std_logic_vector(8 downto 0);
  signal tb_15_tmp            : std_logic_vector(8 downto 0);
  signal tb_16_tmp            : std_logic_vector(8 downto 0);
  signal tb_17_tmp            : std_logic_vector(8 downto 0);
  signal tb_18_tmp            : std_logic_vector(8 downto 0);
  signal tb_19_tmp            : std_logic_vector(8 downto 0);
  signal tb_20_tmp            : std_logic_vector(8 downto 0);
  signal tb_21_tmp            : std_logic_vector(8 downto 0);
  signal tb_22_tmp            : std_logic_vector(8 downto 0);
  signal tb_23_tmp            : std_logic_vector(8 downto 0);
  signal tb_24_tmp            : std_logic_vector(8 downto 0);
  signal tb_25_tmp            : std_logic_vector(8 downto 0);
  signal tb_26_tmp            : std_logic_vector(8 downto 0);
  signal tb_27_tmp            : std_logic_vector(8 downto 0);
  signal tb_28_tmp            : std_logic_vector(8 downto 0);
  signal tb_29_tmp            : std_logic_vector(8 downto 0);
  signal tb_30_tmp            : std_logic_vector(8 downto 0);
  signal tb_31_tmp            : std_logic_vector(8 downto 0);
  -- signal merged_tb_0_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_1_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_2_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_3_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_4_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_5_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_6_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_7_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_8_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_9_tmp      : std_logic_vector(8 downto 0);
  -- signal merged_tb_10_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_11_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_12_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_13_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_14_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_15_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_16_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_17_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_18_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_19_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_20_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_21_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_22_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_23_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_24_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_25_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_26_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_27_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_28_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_29_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_30_tmp     : std_logic_vector(8 downto 0);
  -- signal merged_tb_31_tmp     : std_logic_vector(8 downto 0);
     signal rst_counters         : std_logic;
  -- signal count                : integer range 0 to 4;
   signal tb_cnt               : std_logic_vector(7 downto 0);
   signal tb_cnt_en            : std_logic;
   signal tb_cnt_rst           : std_logic;
   signal mux_payload          : std_logic_vector(8 downto 0);
   signal mux_payload_valid    : std_logic;
   signal out_fifo_s_tdest     : std_logic_vector(0  downto 0);
   signal out_fifo_s_tlast     : std_logic;
   signal meta_fifo_s_tvalid   : std_logic;
   signal payload_sign         : std_logic;
   signal meta_store_en        : std_logic;
     signal msg_counters_rst     : std_logic;
  -- signal header               : std_logic_vector(3  downto 0);
     signal data_reg             : std_logic_vector(23 downto 0);
  -- signal pad                  : std_logic_vector(11 downto 0);
  -- signal pad_reg              : std_logic_vector(11 downto 0);
  -- signal message_type         : std_logic_vector(2  downto 0);
  -- signal hits_lost            : std_logic_vector(7  downto 0);
  -- signal epoch_counter        : std_logic_vector(11 downto 0);
  -- signal info_type            : std_logic_vector(3  downto 0);
  -- signal info_data            : std_logic_vector(7  downto 0);
  -- signal message_type_reg     : std_logic_vector(2  downto 0);
  -- signal hits_lost_reg        : std_logic_vector(7  downto 0);
  -- signal epoch_counter_reg    : std_logic_vector(11 downto 0);
  -- signal info_type_reg        : std_logic_vector(3  downto 0);
  -- signal info_data_reg        : std_logic_vector(7  downto 0);
   signal misc_storage_valid   : std_logic;
   signal ostream              : FEX_STREAM;
   signal ostream_ready        : std_logic;
  -- -- Merger registers
  -- signal rda_merged           : std_logic_vector(11  downto 0);
  -- signal merged_con_counter   : std_logic_vector(11  downto 0);
  -- signal merged_con_vec       : std_logic_vector(335 downto 0) := (others => '0');
  -- signal merged_con_en        : std_logic;
  -- signal merged_msg           : std_logic;
  -- signal merged_mux_en        : std_logic;
  -- signal merged_tb_cnt        : std_logic_vector(7 downto 0);
  -- signal merged_tb_cnt_en     : std_logic;
  -- signal sample_counter       : std_logic_vector(7 downto 0);
begin

  -- preamble <= sp_word.data(23 downto 20);
  preamble <= sp_data(23 downto 20);

	data_buf : process(clk)
	begin
		if rising_edge(clk) then
      -- data_reg 	<= sp_word.data;
      data_reg 	<= sp_data;
		end if;
	end process;


  -- Pad encoder always running. Output delay of 3 clock cycles. Even in messages 
  -- containing no raw data, by the time the EOM word is processed, the encoded
  -- pad should be already available
--  pad_encoder_I : entity work.pad_encoder
--    port map(
--      clk               => clk,
--      rst_p             => rst_p,
--      spadic_index      => x"00",   -- Only one row type_5 for now ;)
--      spadic_group      => gr,
--      spadic_channel    => ch,
--      pad               => pad
--    );
    decoder_fsm : process(clk)
  begin
      if rising_edge(clk) then
        if(rst_p = '1') then
          STATE               <= ST_IDLE;
          word_en              <= '0';
          hit_done            <= '0';   -- Hit message done
         -- misc_done           <= '0';   -- Misc message done
          sp_word_ready       <= '0';
           rst_counters        <= '1';
           msg_counters_rst    <= '0';
           --word_counter <= (others => '0');
          -- merged_con_en       <= '0';
          -- merged_msg          <= '0';   -- Flag a merged message, needed to merge words later
          -- sample_counter      <= x"02"; -- RDA counts as 1 or two samples 

          ch                  <= (others => '0');
          ts                  <= (others => '0');
          rda_som             <= (others => '0');
          rda_eom             <= (others => '0');
          -- rda_merged          <= (others => '0');
          eom                 <= (others => '0');
          --samples             <= (others => '0');
          epm                 <= (others => '0');
          hit_type            <= (others => '0');
          m_hit               <= '0';
         -- elink               <= (others => '0');
          -- message_type        <= (others => '0');
          -- hits_lost           <= (others => '0');
          -- epoch_counter       <= (others => '0');
          -- info_type           <= (others => '0');
          -- info_data           <= (others => '0');
        else
          word_en              <= '0';
         hit_done            <= '0';
          -- misc_done           <= '0';
          sp_word_ready       <= '0';
          rst_counters        <= '0';
          msg_counters_rst    <= '0';
          --rda_vec                 <= (others => '0');
          -- merged_con_en       <= '0';
          -- message_type        <= (others => '0');
          case STATE is
            -- IDLE
            when ST_IDLE =>
              sp_word_ready <= '1';
              -- if(sp_word.valid = '1') then
              if(sp_valid = '1') then  
                if(preamble(3) = '1') then
                  --EPM
                else
                --HIT
                  if(preamble(1) = '1') then
                    --word_en <= '1';
                    sp_word_ready <= '1';
                    -- ch <= sp_word.data(20 downto 17);
                    -- ts <= sp_word.data(16 downto 10);
                    -- m_hit <= sp_word.data(9);
                    -- hit_type <= sp_word.data(8 downto 7);
                    ch <= sp_data(20 downto 17);
                    ts <= sp_data(16 downto 10);
                    m_hit <= sp_data(9);
                    hit_type <= sp_data(8 downto 7);
                    rda_som <= sp_data(6 downto 0);
                    STATE <= ST_SOM;    
                  else
                    --error
                  end if;
                end if;
              end if;
            when ST_SOM =>
              -- if(sp_word.valid = '1') then
              if(sp_valid = '1') then  
                if(preamble(2) = '1') then
                  word_en <= '1';
                  STATE <= ST_RDA;  
                elsif(preamble(1) = '1') then
                  --unexpected, deal with later
                  STATE <= ST_SOM;
                elsif(preamble(0) = '1') then
                  word_en <= '0';
                  -- rda_vec(280 downto 273) <= sp_word.data(17 downto 0);
                  --rda_vec(280 downto 263) <= sp_data(17 downto 0);
                  rda_eom <= sp_data(17 downto 0);
                  samples_ind <= sp_data(19 downto 18);
                  STATE <= ST_EOM;
                end if;
              end if;
            when ST_RDA =>
              -- if(sp_word.valid = '1' )then 
              if(sp_valid = '1' )then 
                if(preamble(0) = '1') then
                  --DO STUFF
                  word_en <= '0';
                  rda_eom <= sp_data(17 downto 0);
                  --word_out <= rda_vec;
                  samples_ind <= sp_data(19 downto 18);
                  STATE <= ST_EOM;
                else
                  --CONTINUED DATA
                  sp_word_ready <= '1';
                  word_en        <= '1';
                end if; 
              end if;
            when ST_EOM =>
                --word_counter <= (others =>'0');
                msg_counters_rst <= '1';
                hit_done <= '1';
                STATE <= ST_WAIT_FINISHED;
            when ST_WAIT_FINISHED =>
                  if(msg_stored = '1') then
                    STATE <= ST_IDLE;
                  end if;
            when others => null;

          end case;
        end if;
      end if;
  end process;  
            

            
  word_cnt_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst_p = '1' or msg_counters_rst = '1' then
        word_counter <= (others => '0');
        
      else
        if(word_en = '1') then
          word_counter <= word_counter + 1;
        end if;
      end if;
    end if;
  end process;

  con_wrd_generate : for i in 0 to 11 generate   --20 original
  begin
    con_val : process(clk)
    begin
      if rising_edge(clk) then
        if(rst_p = '1' or rst_counters = '1') then
          --con_vec(( 335-(i*16))downto(335-((i*16)+15))) <= (others => '0');
          rda_vec( (280-(i*22)) downto (280-(i*22+21)) ) <= (others => '0');
        else
          if(word_en = '1') then       
            if(word_counter = conv_std_logic_vector(i, 8)) then
                rda_vec( (280-(i*22)) downto (280-(i*22+21)) ) <= data_reg(21 downto 0); --sp_word.data(15 downto 0);
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate con_wrd_generate;

  --DECODE NUMBER oF SAMPLES AND MAP TIMEBINS
  samples_decoder : process(clk)
  begin
    if rising_edge(clk) then
      if(rst_p = '1' or rst_counters = '1') then
        word_buffer <= (others =>'0');
        samples <= (others =>'0');
        samples_done <= '0';
        
        tb_0_tmp           <= (others =>'0');
        tb_1_tmp           <= (others =>'0');
        tb_2_tmp           <= (others =>'0');
        tb_3_tmp           <= (others =>'0');
        tb_4_tmp           <= (others =>'0');
        tb_5_tmp           <= (others =>'0');
        tb_6_tmp           <= (others =>'0');
        tb_7_tmp           <= (others =>'0');
        tb_8_tmp           <= (others =>'0');
        tb_9_tmp           <= (others =>'0');
        tb_10_tmp          <= (others =>'0');
        tb_11_tmp          <= (others =>'0');
        tb_12_tmp          <= (others =>'0');
        tb_13_tmp          <= (others =>'0');
        tb_14_tmp          <= (others =>'0');
        tb_15_tmp          <= (others =>'0');
        tb_16_tmp          <= (others =>'0');
        tb_17_tmp          <= (others =>'0');
        tb_18_tmp          <= (others =>'0');
        tb_19_tmp          <= (others =>'0');
        tb_20_tmp          <= (others =>'0');
        tb_21_tmp          <= (others =>'0');
        tb_22_tmp          <= (others =>'0');
        tb_23_tmp          <= (others =>'0');
        tb_24_tmp          <= (others =>'0');
        tb_25_tmp          <= (others =>'0');
        tb_26_tmp          <= (others =>'0');
        tb_27_tmp          <= (others =>'0');
        tb_28_tmp          <= (others =>'0');
        tb_29_tmp          <= (others =>'0');
        tb_30_tmp          <= (others =>'0');
        tb_31_tmp          <= (others =>'0');
      else

        word_buffer <= word_counter;
        if(hit_done ='1') then
          case word_buffer is
            when "0000" =>
              samples <= conv_std_logic_vector(2, 6) - samples_ind;
              tb_0_tmp <= rda_som & rda_eom(17 downto 16);
              tb_1_tmp <= rda_eom(15 downto 7);
              samples_done <= '1';
            when "0001" =>
              samples <= conv_std_logic_vector(5, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 259) & rda_eom(17 downto 11);
              tb_4_tmp <= rda_eom(10 downto 2);
              samples_done <= '1';
            when "0010" =>
              samples <= conv_std_logic_vector(7, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 237) & rda_eom(17 downto 15);
              tb_6_tmp <= rda_eom(14 downto 6);
              samples_done <= '1';
            when "0011" =>
              samples <= conv_std_logic_vector(10, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215) & rda_eom(17 downto 10);
              tb_9_tmp <= rda_eom(9 downto 1);
              samples_done <= '1';
            when "0100" =>
              samples <= conv_std_logic_vector(12, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 193) & rda_eom(17 downto 14);
              tb_11_tmp <= rda_eom(13 downto 5);
              samples_done <= '1';
            when "0101" =>
              samples <= conv_std_logic_vector(15, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_eom(17 downto 9);
              tb_14_tmp <= rda_eom(8 downto 0);
              samples_done <= '1';
            when "0110" =>
              samples <= conv_std_logic_vector(17, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 149) & rda_eom(17 downto 13);
              tb_16_tmp <= rda_eom(12 downto 4);
              samples_done <= '1';
            when "0111" =>
              samples <= conv_std_logic_vector(19, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 127) & rda_eom(17);
              tb_18_tmp <= rda_eom(16 downto 8);
              samples_done <= '1';
            when "1000" =>
              samples <= conv_std_logic_vector(22, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 126);
              tb_18_tmp <= rda_vec(125 downto 117);
              tb_19_tmp <= rda_vec(116 downto 108);
              tb_20_tmp <= rda_vec(107 downto 105) & rda_eom(17 downto 12);
              tb_21_tmp <= rda_eom(12 downto 4);
              samples_done <= '1';
            when "1001" =>
              samples <= conv_std_logic_vector(24, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 126);
              tb_18_tmp <= rda_vec(125 downto 117);
              tb_19_tmp <= rda_vec(116 downto 108);
              tb_20_tmp <= rda_vec(107 downto 99);
              tb_21_tmp <= rda_vec(98 downto 90);
              tb_22_tmp <= rda_vec(89 downto 83) & rda_eom(17 downto 16);
              tb_23_tmp <= rda_eom(15 downto 7);
              samples_done <= '1';
            when "1010" =>
              samples <= conv_std_logic_vector(27, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 126);
              tb_18_tmp <= rda_vec(125 downto 117);
              tb_19_tmp <= rda_vec(116 downto 108);
              tb_20_tmp <= rda_vec(107 downto 99);
              tb_21_tmp <= rda_vec(98 downto 90);
              tb_22_tmp <= rda_vec(89 downto 81);
              tb_23_tmp <= rda_vec(80 downto 72);
              tb_24_tmp <= rda_vec(71 downto 63);
              tb_25_tmp <= rda_vec(62 downto 61) & rda_eom(17 downto 11);
              tb_26_tmp <= rda_eom(10 downto 2);
              samples_done <= '1';
            when "1011" =>
              samples <= conv_std_logic_vector(29, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 126);
              tb_18_tmp <= rda_vec(125 downto 117);
              tb_19_tmp <= rda_vec(116 downto 108);
              tb_20_tmp <= rda_vec(107 downto 99);
              tb_21_tmp <= rda_vec(98 downto 90);
              tb_22_tmp <= rda_vec(89 downto 81);
              tb_23_tmp <= rda_vec(80 downto 72);
              tb_24_tmp <= rda_vec(71 downto 63);
              tb_25_tmp <= rda_vec(62 downto 54);
              tb_26_tmp <= rda_vec(53 downto 45);
              tb_27_tmp <= rda_vec(44 downto 39) & rda_eom(17 downto 15);
              tb_28_tmp <= rda_eom(15 downto 7);
              samples_done <= '1';
            when "1100" =>
              samples <= conv_std_logic_vector(32, 6) - samples_ind;
              tb_0_tmp <= rda_som &  rda_vec(280 downto 279);
              tb_1_tmp <= rda_vec(278 downto 270);
              tb_2_tmp <= rda_vec(269 downto 261);
              tb_3_tmp <= rda_vec(260 downto 252);
              tb_4_tmp <= rda_vec(251 downto 243);
              tb_5_tmp <= rda_vec(242 downto 234);
              tb_6_tmp <= rda_vec(233 downto 225);
              tb_7_tmp <= rda_vec(224 downto 216);
              tb_8_tmp <= rda_vec(215 downto 207);
              tb_9_tmp <= rda_vec(206 downto 198);
              tb_10_tmp <= rda_vec(197 downto 189);
              tb_11_tmp <= rda_vec(188 downto 180);
              tb_12_tmp <= rda_vec(179 downto 171);
              tb_13_tmp <= rda_vec(170 downto 162);
              tb_14_tmp <= rda_vec(161 downto 153);
              tb_15_tmp <= rda_vec(152 downto 144);
              tb_16_tmp <= rda_vec(143 downto 135);
              tb_17_tmp <= rda_vec(134 downto 126);
              tb_18_tmp <= rda_vec(125 downto 117);
              tb_19_tmp <= rda_vec(116 downto 108);
              tb_20_tmp <= rda_vec(107 downto 99);
              tb_21_tmp <= rda_vec(98 downto 90);
              tb_22_tmp <= rda_vec(89 downto 81);
              tb_23_tmp <= rda_vec(80 downto 72);
              tb_24_tmp <= rda_vec(71 downto 63);
              tb_25_tmp <= rda_vec(62 downto 54);
              tb_26_tmp <= rda_vec(53 downto 45);
              tb_27_tmp <= rda_vec(44 downto 36);
              tb_28_tmp <= rda_vec(35 downto 27);
              tb_29_tmp <= rda_vec(26 downto 18);
              tb_30_tmp <= rda_vec(17) & rda_eom(17 downto 10);
              tb_31_tmp <= rda_eom(9 downto 1);
              samples_done <= '1';
            when others =>
              samples <= (others => '0');
          end case;
          ch_reg             <= ch;
          ts_reg             <= ts;
          epm_reg            <= epm;
         -- pad_reg            <= pad;
          m_hit_reg          <= m_hit;
          hit_type_reg       <= hit_type;
          samples_reg        <= samples;
          --message_type_reg    <= message_type;
        end if;
      end if;
    end if;
  end process;   
  
   -- Once the message has been finished. Write it to the fifos!
  storage_fsm : process(clk)
  begin
    if rising_edge(clk) then
      if(rst_p='1')then
        STORAGE_STATE             <= STORAGE_IDLE;
        msg_stored                <= '0';
        meta_store_en             <= '0';
        out_fifo_s_tlast          <= '0';
        out_fifo_s_tdest          <= "0";
        tb_cnt_rst                <= '0';
        meta_fifo_s_tvalid        <= '0';
        misc_storage_valid        <= '0';
      --  merged_mux_en             <= '0';
     --   merged_tb_cnt_en          <= '0';
      else
        tb_cnt_en                 <= '0';
        msg_stored                <= '0';
        meta_store_en             <= '0';
        tb_cnt_rst                <= '0';
        out_fifo_s_tlast          <= '0';
        meta_fifo_s_tvalid        <= '0';
        misc_storage_valid        <= '0';
      --  merged_mux_en             <= '0';
      --  merged_tb_cnt_en          <= '0';
        case STORAGE_STATE is
          when STORAGE_IDLE =>
            if(samples_done = '1' and ostream_ready = '1')then
              -- Store the hit message
              -- if(merged_msg = '1') then 
              --   STORAGE_STATE       <= STORE_FIRST_MSG;
              -- else
                STORAGE_STATE       <= STORAGE_TB;
              --end if;
              out_fifo_s_tdest    <= "0";
            -- elsif(misc_done = '1')then
  					-- 	-- Store the misc message
  					-- 	STORAGE_STATE       <= STORAGE_MISC;
  					-- 	misc_storage_valid  <= '1';
  					-- 	out_fifo_s_tlast    <= '1';
  					-- 	out_fifo_s_tdest    <= "1";
  					end if;
  				when STORAGE_TB =>
  					-- Store in the output fifo
  					if(tb_cnt < samples) then
  						tb_cnt_en				  <= '1';
  						STORAGE_STATE			<= STORAGE_TB;
  					else
  						out_fifo_s_tlast		<= '1';
  						msg_stored				<= '1';   -- Message stored. Safe to take new data
  						meta_store_en			<= '1';
  						tb_cnt_rst				<= '1';
  						STORAGE_STATE			<= STORAGE_IDLE;
  					end if;
  				when STORAGE_MISC =>
            STORAGE_STATE				<= STORAGE_IDLE;

          -- when STORE_FIRST_MSG =>
          --   -- Store the first message samples
          --   if(tb_cnt < sample_counter) then -- There is no other way to know the number of samples
          --     tb_cnt_en           <= '1';
          --     STORAGE_STATE       <= STORE_FIRST_MSG;
          --   else
          --     STORAGE_STATE       <= STORE_SECOND_MSG;
          --   end if;
          -- when STORE_SECOND_MSG =>
          --   merged_mux_en         <= '1';
          --   if(merged_tb_cnt < samples) then
          --     merged_tb_cnt_en    <= '1';
          --     STORAGE_STATE       <= STORE_SECOND_MSG;
          --   else
          --     out_fifo_s_tlast    <= '1';
          --     msg_stored          <= '1';   -- Message stored. Safe to take new data
          --     meta_store_en       <= '1';
          --     tb_cnt_rst          <= '1';
          --     STORAGE_STATE       <= STORAGE_IDLE;
          --   end if;

  				when others => 
  					null;
  			end case;
  		end if;
  	end if;
	end process;
  
  	-- bin counter
	bin_counter : process(clk)
	begin
		if rising_edge(clk)then
			if rst_p = '1' or tb_cnt_rst = '1' then
				tb_cnt <= x"01";
			elsif(tb_cnt_en = '1' and tb_cnt < samples) then
				tb_cnt <= tb_cnt + 1;
			end if;
		end if;
  end process;
  
  	-- Payload mux
	payload_mux_proc : process(clk)
	begin
		if rising_edge(clk) then
      mux_payload_valid   <= tb_cnt_en;-- or merged_tb_cnt_en; -- Use a delayed signal ;)
			  case tb_cnt is
			  	when x"00" =>
            mux_payload     <= tb_0_tmp;
			  	when x"01" =>
            mux_payload     <= tb_0_tmp;
			  	when x"02" =>
            mux_payload     <= tb_1_tmp;
			  	when x"03" =>
            mux_payload     <= tb_2_tmp;
			  	when x"04" =>
            mux_payload     <= tb_3_tmp;
			  	when x"05" =>
            mux_payload     <= tb_4_tmp;
			  	when x"06" =>
            mux_payload     <= tb_5_tmp;
			  	when x"07" =>
            mux_payload     <= tb_6_tmp;
			  	when x"08" =>
            mux_payload     <= tb_7_tmp;
			  	when x"09" =>
            mux_payload     <= tb_8_tmp;
			  	when x"0a" =>
            mux_payload     <= tb_9_tmp;
			  	when x"0b" =>
            mux_payload     <= tb_10_tmp;
			  	when x"0c" =>
            mux_payload     <= tb_11_tmp;
			  	when x"0d" =>
            mux_payload     <= tb_12_tmp;
			  	when x"0e" =>
            mux_payload     <= tb_13_tmp;
			  	when x"0f" =>
            mux_payload     <= tb_14_tmp;
			  	when x"10" =>
            mux_payload     <= tb_15_tmp;
			  	when x"11" =>
            mux_payload     <= tb_16_tmp;
			  	when x"12" =>
            mux_payload     <= tb_17_tmp;
			  	when x"13" =>
            mux_payload     <= tb_18_tmp;
			  	when x"14" =>
            mux_payload     <= tb_19_tmp;
			  	when x"15" =>
            mux_payload     <= tb_20_tmp;
			  	when x"16" =>
            mux_payload     <= tb_21_tmp;
			  	when x"17" =>
            mux_payload     <= tb_22_tmp;
			  	when x"18" =>
            mux_payload     <= tb_23_tmp;
			  	when x"19" =>
            mux_payload     <= tb_24_tmp;
			  	when x"1a" =>
            mux_payload     <= tb_25_tmp;
			  	when x"1b" =>
            mux_payload     <= tb_26_tmp;
			  	when x"1c" =>
            mux_payload     <= tb_27_tmp;
			  	when x"1d" =>
            mux_payload     <= tb_28_tmp;
			  	when x"1e" =>
            mux_payload     <= tb_29_tmp;
			  	when x"1f" =>
            mux_payload     <= tb_30_tmp;
			  	when x"20" =>
            mux_payload     <= tb_31_tmp;
			  	when others =>
            mux_payload     <= tb_0_tmp;
        end case;
		end if;
	end process payload_mux_proc;

	-- Extend from 9 bits to 16 bits (signed)
  payload_sign    <= mux_payload(8);
  ostream.data    <=	payload_sign & payload_sign & payload_sign & payload_sign &
                      payload_sign & payload_sign & payload_sign & payload_sign &
                      mux_payload(7 downto 0);	-- data
	ostream.samples       <= samples_reg;
	ostream.charge        <= (others => '0');
	ostream.pad           <=  (others => '0');--x"0" & pad_reg;
	ostream.ts            <= ts_reg;
	ostream.hit_type      <= hit_type_reg;
	ostream.m_hit     <= m_hit_reg;
	ostream.hits_lost     <= (others => '0');--hits_lost_reg;
	ostream.epoch_counter <= (others => '0');--epoch_counter_reg;
	ostream.info_type     <= (others => '0');--info_type_reg;
	ostream.info_data     <= (others => '0');--info_data_reg;
	ostream.message_type  <= (others => '0');--b"0" & message_type_reg;
	ostream.misc          <= (others => '0');
	ostream.valid         <= mux_payload_valid or misc_storage_valid;
	ostream.dest          <= out_fifo_s_tdest;
	ostream.last          <= out_fifo_s_tlast;
	ostream.tid           <= (others => '0');

	out_fifo_I : entity work.fex_stream_fifo_wrapper
		port map(
			clk						=> clk,
			rst						=> rst_p,
			-- Control/override
			override_mesage_type	=> '0',
			message_type			=> x"0",
			-- Input stream
			stream_in				=> ostream,
			stream_in_ready			=> ostream_ready,
			-- Output stream
			stream_out 				=> stream_out,
			stream_out_ready		=> stream_out_ready
		);

end Behavioral;