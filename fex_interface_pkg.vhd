library ieee;
use ieee.std_logic_1164.all;
package fex_interface_pkg is

  type DPB_FRAME is record
    -- Extended frame after spadic interface core
    -- Frame 23 downto 0
    -- Link  26 downto 24
    data      : std_logic_vector(26  downto 0);
    valid     : std_logic;
  end record DPB_FRAME;

  type DPB_FRAME_ARRAY is array (natural range <>) of DPB_FRAME;

  type FEX_STREAM is record
    data			: std_logic_vector(15 downto 0);	-- 16
    samples			: std_logic_vector(5  downto 0);	-- 6
    charge			: std_logic_vector(15 downto 0);	-- 16
    pad				: std_logic_vector(15 downto 0);	-- 16
    ts				: std_logic_vector(6 downto 0);	-- 12
    hit_type		: std_logic_vector(1  downto 0);	-- 2
    m_hit		: std_logic;	-- 3
    -- Misc message - From Spadic Messages
    hits_lost		: std_logic_vector(7  downto 0);	-- 8
    epoch_counter 	: std_logic_vector(11 downto 0);	-- 12
    info_type		: std_logic_vector(3  downto 0);	-- 4
    info_data		: std_logic_vector(7  downto 0);	-- 8
    message_type	: std_logic_vector(3  downto 0);	-- 4 -- 107
    misc 			: std_logic_vector(20 downto 0); 	-- 21
                        -- Total  128
    -- Control
    tid				: std_logic_vector(3  downto 0);
    dest			: std_logic_vector(0 downto 0);
    valid			: std_logic;
    last			: std_logic;
  end record FEX_STREAM;

  type FEX_CONTROL is record
    fex_baseline_enable				          : std_logic;
    fex_cf_enable 					            : std_logic;
    fex_time_enable					            : std_logic;
    fex_spatial_enable				          : std_logic;
    time_full_integrator_enable 	      : std_logic;
    time_window_integrator_enable 			: std_logic;
    time_window_integrator_max          : std_logic_vector(7 downto 0);
    time_window_integrator_min          : std_logic_vector(7 downto 0);
    time_max_adc_integrator_enable			: std_logic;
    -- Enables charge correction in cluster level
    cluster_charge_correction_en	: std_logic;
    -- Timeout for fex spatial closing cluster
    fex_spatial_timeout				: std_logic_vector(15 downto 0);
    charge_correction_factor		: std_logic_vector(15 downto 0);
    -- Baseline correction
    pass_thru						: std_logic;
    enable_bin_shift				: std_logic;
    baseline_val_sel				: std_logic;
    baseline_nr_samples 			: std_logic;
    baseline_op_mode				: std_logic;
    bin_shift_value					: std_logic_vector(15 downto 0);
    ps_bin_select					: std_logic_vector(7 downto 0);
    s0_bin_select					: std_logic_vector(7 downto 0);
    s1_bin_select					: std_logic_vector(7 downto 0);
    s2_bin_select					: std_logic_vector(7 downto 0);
    s3_bin_select					: std_logic_vector(7 downto 0);
  end record FEX_CONTROL;

  type FEX_SPATIAL_PARAMS is record
    -- Used only in FEX Spatial to transport the calculated parameters
    data				: std_logic_vector(15 downto 0);	-- 16
    samples				: std_logic_vector(5  downto 0);	-- 16
    charge 				: std_logic_vector(15 downto 0);	-- 16
    pad					: std_logic_vector(15 downto 0);	-- 16
    ts					: std_logic_vector(11 downto 0);	-- 12
    hit_type			: std_logic_vector(1  downto 0);	-- 2
    stop_type			: std_logic_vector(2  downto 0);	-- 3
    hits_lost			: std_logic_vector(7  downto 0);	-- 8
    epoch_counter 		: std_logic_vector(11 downto 0);	-- 12
    info_type			: std_logic_vector(3  downto 0);	-- 4
    info_data			: std_logic_vector(7  downto 0);	-- 8
    message_type		: std_logic_vector(3  downto 0);	-- 4
    misc 				: std_logic_vector(20 downto 0); 	-- 11
                            -- Sub Total  128
    -- Spatial parameters
    charge_accumulator 	: std_logic_vector(15 downto 0); 	-- 16
    cog_dividend 		: std_logic_vector(15 downto 0); 	-- 16
    cog_divisor			: std_logic_vector(15 downto 0); 	-- 16
    time_dividend		: std_logic_vector(15 downto 0); 	-- 16
    time_divisor 		: std_logic_vector(15 downto 0); 	-- 16	
                          -- Sub Total   80
                             -- Total 208
    -- Control
    tid					: std_logic_vector(3  downto 0);
    dest				: std_logic_vector(0 downto 0);
    valid				: std_logic;
    last				: std_logic;
  end record FEX_SPATIAL_PARAMS;

  TYPE BASELINE_CORRECTION_CONTROL is record
    pass_thru			: std_logic;
    enable_bin_shift	: std_logic;
    bin_shift_value		: std_logic_vector(15 downto 0);
    ps_bin_select		: std_logic_vector(7 downto 0);
    s0_bin_select		: std_logic_vector(7 downto 0);
    s1_bin_select		: std_logic_vector(7 downto 0);
    s2_bin_select		: std_logic_vector(7 downto 0);
    s3_bin_select		: std_logic_vector(7 downto 0);
    baseline_val_sel	: std_logic;
    baseline_nr_samples : std_logic;
    baseline_op_mode	: std_logic;
  end record BASELINE_CORRECTION_CONTROL;

  type FEX_OUT_STREAM is record
    data				: std_logic_vector(63 downto 0);
    valid				: std_logic;
  end record FEX_OUT_STREAM;

  -- The SPADIC has two downlinks, therefore model an interface that emulates it
  type SPADIC_LINK is record
    l0_stream    : FEX_STREAM;
    l1_stream    : FEX_STREAM;
  end record SPADIC_LINK;

  TYPE SPADIC_LINK_READY is record
    l0_ready : std_logic;
    l1_ready : std_logic;
  end record SPADIC_LINK_READY;

  TYPE FEX_STREAM_READY is record
    l0_ready : std_logic;
    l1_ready : std_logic;
  end record FEX_STREAM_READY;

  type SPADIC_LINK_ARRAY 			is array (natural range <>) of SPADIC_LINK;
  type SPADIC_LINK_READY_ARRAY 	is array (natural range <>) of SPADIC_LINK_READY;
  type FEX_STREAM_ARRAY 			is array (natural range <>) of FEX_STREAM;
  type FEX_STREAM_READY_ARRAY 	is array (natural range <>) of FEX_STREAM_READY;

--   function fex_stream_to_vector (constant sig_in : FEX_STREAM)
--     return std_logic_vector;

--   function vector_to_fex_stream(constant sig_in : std_logic_vector(127 downto 0))
--     return FEX_STREAM;

--   function fex_stream_to_fex_stream(constant sig_in : FEX_STREAM)
--     return FEX_STREAM;

--   function to_fex_stream (
--       constant vec_in : std_logic_vector(127 downto 0);
--       constant tid	: std_logic_vector(3 downto 0);
--       constant dest	: std_logic_vector(0 downto 0);
--       constant valid	: std_logic;
--       constant last	: std_logic)
--   return FEX_STREAM;

--   function to_data (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_samples (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_charge (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_pad (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_ts (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_hit_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_stop_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_hits_lost (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_epoch_counter (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_info_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_info_data (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_message_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;

--   function to_misc (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector;


end package fex_interface_pkg;

-- package body fex_interface_pkg is

--   function fex_stream_to_vector (constant sig_in : FEX_STREAM)
--     return std_logic_vector is variable sig_out : std_logic_vector(127 downto 0);
--     begin
--       sig_out(15  downto  0)		:= sig_in.data;
--       sig_out(21  downto 16)		:= sig_in.samples;
--       sig_out(37  downto 22)		:= sig_in.charge;
--       sig_out(53  downto 38)		:= sig_in.pad;
--       sig_out(65  downto 54)		:= sig_in.ts;
--       sig_out(67  downto 66)		:= sig_in.hit_type;
--       sig_out(70  downto 68)		:= sig_in.stop_type;
--       sig_out(78  downto 71)		:= sig_in.hits_lost;
--       sig_out(90  downto 79)		:= sig_in.epoch_counter;
--       sig_out(94  downto 91)		:= sig_in.info_type;
--       sig_out(102 downto 95)		:= sig_in.info_data;
--       sig_out(106 downto 103)		:= sig_in.message_type;
--       sig_out(127 downto 107)		:= sig_in.misc;
--     return sig_out;
--   end function fex_stream_to_vector;

--   function vector_to_fex_stream (constant sig_in : std_logic_vector(127 downto 0))
--     return FEX_STREAM is variable sig_out : FEX_STREAM;
--     begin
--       sig_out.data				:= sig_in(15  downto  0);
--       sig_out.samples				:= sig_in(21  downto 16);
--       sig_out.charge				:= sig_in(37  downto 22);
--       sig_out.pad					:= sig_in(53  downto 38);
--       sig_out.ts					:= sig_in(65  downto 54);
--       sig_out.hit_type			:= sig_in(67  downto 66);
--       sig_out.stop_type			:= sig_in(70  downto 68);
--       sig_out.hits_lost			:= sig_in(78  downto 71);
--       sig_out.epoch_counter		:= sig_in(90  downto 79);
--       sig_out.info_type			:= sig_in(94  downto 91);
--       sig_out.info_data			:= sig_in(102 downto 95);
--       sig_out.message_type		:= sig_in(106 downto 103);
--       sig_out.misc				:= sig_in(127 downto 107);
--     return sig_out;
--   end function vector_to_fex_stream;


--   function fex_stream_to_fex_stream (constant sig_in : FEX_STREAM)
--     return FEX_STREAM is variable sig_out : FEX_STREAM;
--     begin
--       sig_out.data				:= sig_in.data;
--       sig_out.samples				:= sig_in.samples;
--       sig_out.charge				:= sig_in.charge;
--       sig_out.pad					:= sig_in.pad;
--       sig_out.ts					:= sig_in.ts;
--       sig_out.hit_type			:= sig_in.hit_type;
--       sig_out.stop_type			:= sig_in.stop_type;
--       sig_out.hits_lost			:= sig_in.hits_lost;
--       sig_out.epoch_counter		:= sig_in.epoch_counter;
--       sig_out.info_type			:= sig_in.info_type;
--       sig_out.info_data			:= sig_in.info_data;
--       sig_out.message_type		:= sig_in.message_type;
--       sig_out.misc				:= sig_in.misc;
--     return sig_out;
--   end function fex_stream_to_fex_stream;

--   function to_fex_stream (
--       constant vec_in : std_logic_vector(127 downto 0);
--       constant tid	: std_logic_vector(3 downto 0);
--       constant dest	: std_logic_vector(0 downto 0);
--       constant valid	: std_logic;
--       constant last	: std_logic)
--     return FEX_STREAM is variable sig_out : FEX_STREAM;
--     begin
--       sig_out.data				:= to_data(vec_in);
--       sig_out.samples				:= to_samples(vec_in);
--       sig_out.charge				:= to_charge(vec_in);
--       sig_out.pad					:= to_pad(vec_in);
--       sig_out.ts					:= to_ts(vec_in);
--       sig_out.hit_type			:= to_hit_type(vec_in);
--       sig_out.stop_type			:= to_stop_type(vec_in);
--       sig_out.hits_lost			:= to_hits_lost(vec_in);
--       sig_out.epoch_counter		:= to_epoch_counter(vec_in);
--       sig_out.info_type			:= to_info_type(vec_in);
--       sig_out.info_data			:= to_info_data(vec_in);
--       sig_out.message_type		:= to_message_type(vec_in);
--       sig_out.misc				:= to_misc(vec_in);
--       sig_out.tid					:= tid;
--       sig_out.dest				:= dest;
--       sig_out.valid				:= valid;
--       sig_out.last				:= last;
--     return sig_out;	
--   end function to_fex_stream;

--   function to_data (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(15 downto 0);
--     begin
--       vec_out(15 downto 0)	:= vec_in(15 downto 0);	-- 16
--     return vec_out;	
--   end function to_data;

--   function to_samples (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(5 downto 0);
--     begin
--       vec_out(5 downto 0)		:= vec_in(21 downto 16); -- 6
--     return vec_out;
--   end function to_samples;

--   function to_charge (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(15 downto 0);
--     begin
--       vec_out(15 downto 0)	:= vec_in(37 downto 22); -- 16
--     return vec_out;
--   end function to_charge;

--   function to_pad (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(15 downto 0);
--     begin
--       vec_out(15 downto 0)	:= vec_in(53 downto 38); -- 16
--     return vec_out;
--   end function to_pad;

--   function to_ts (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(11 downto 0);
--     begin
--       vec_out(11 downto 0)	:= vec_in(65 downto 54); --12
--     return vec_out;
--   end function to_ts;

--   function to_hit_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(1 downto 0);
--     begin
--       vec_out(1 downto 0)		:= vec_in(67 downto 66); -- 2
--     return vec_out;
--   end function to_hit_type;

--   function to_stop_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(2 downto 0);
--     begin
--       vec_out(2 downto 0)		:= vec_in(70 downto 68); -- 3
--     return vec_out;
--   end function to_stop_type;

--   function to_hits_lost (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(7 downto 0);
--     begin
--       vec_out(7 downto 0)		:= vec_in(78 downto 71); -- 8
--     return vec_out;
--   end function to_hits_lost;

--   function to_epoch_counter (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(11 downto 0);
--     begin
--       vec_out(11 downto 0)	:= vec_in(90 downto 79); -- 12
--     return vec_out;
--   end function to_epoch_counter;

--   function to_info_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(3 downto 0);
--     begin
--       vec_out(3 downto 0)		:= vec_in(94 downto 91); -- 4
--     return vec_out;
--   end function to_info_type;

--   function to_info_data (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(7 downto 0);
--     begin
--       vec_out(7 downto 0)		:= vec_in(102 downto 95); -- 8
--     return vec_out;
--   end function to_info_data;

--   function to_message_type (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(3 downto 0);
--     begin
--       vec_out(3 downto 0)		:= vec_in(106 downto 103); -- 4
--     return vec_out;
--   end function to_message_type;

--   function to_misc (constant vec_in : std_logic_vector(127 downto 0))
--     return std_logic_vector is variable vec_out : std_logic_vector(20 downto 0);
--     begin
--       vec_out(20 downto 0)	:= vec_in(127 downto 107);
--     return vec_out;
--   end function to_misc;

--end package body fex_interface_pkg;
