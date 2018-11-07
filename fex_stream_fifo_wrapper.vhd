---------------------------------------------------------------------
-- Title      :
-- Project    : Feature Extraction
---------------------------------------------------------------------
-- File       :
-- Author     : Cruz de Jesus Garcia Chavez
-- Email      : garcia@iri.uni-frankfurt.de
-- Standard   : VHDL'93/02
---------------------------------------------------------------------
-- Description:
--
---------------------------------------------------------------------
-- Copyright (c) 2014 Cruz de Jesus Garcia Chavez
---------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std.ALL;
use work.fex_interface_pkg.all;

entity fex_stream_fifo_wrapper is
	Port(
		clk						: in  std_logic;
		rst						: in  std_logic;
		-- Control
		override_mesage_type	: in std_logic;
		message_type			: in std_logic_vector(3  downto 0);
		-- Input stream
		stream_in				: in  FEX_STREAM;
		stream_in_ready			: out std_logic;
		-- Output stream
		stream_out 				: out FEX_STREAM;
		stream_out_ready		: in  std_logic
	);
end;

architecture rtl of fex_stream_fifo_wrapper is

	-- Signals
	signal fifo_s_tdata				: std_logic_vector(127 downto 0);
	signal fifo_s_tid 				: std_logic_vector(3 downto 0);
	signal fifo_s_tdest				: std_logic_vector(0 downto 0);
	signal fifo_s_tvalid			: std_logic;
	signal fifo_s_tlast				: std_logic;
	signal fifo_s_tready			: std_logic;
	signal fifo_m_tdata				: std_logic_vector(127 downto 0);
	signal fifo_m_tid 				: std_logic_vector(3 downto 0);
	signal fifo_m_tdest				: std_logic_vector(0 downto 0);
	signal fifo_m_tvalid			: std_logic;
	signal fifo_m_tlast				: std_logic;
	signal fifo_m_tready			: std_logic;

begin


	fifo_s_tdata(15  downto  0)		<= stream_in.data;
	fifo_s_tdata(21  downto 16)		<= stream_in.samples;
	fifo_s_tdata(37  downto 22)		<= stream_in.charge;
	fifo_s_tdata(53  downto 38)		<= stream_in.pad;
	fifo_s_tdata(60  downto 54)		<= stream_in.ts;
	fifo_s_tdata(67  downto 66)		<= stream_in.hit_type;
	fifo_s_tdata(68)		        <= stream_in.m_hit;
	fifo_s_tdata(78  downto 71)		<= stream_in.hits_lost;
	fifo_s_tdata(90  downto 79)		<= stream_in.epoch_counter;
	fifo_s_tdata(94  downto 91)		<= stream_in.info_type;
	fifo_s_tdata(102 downto 95)		<= stream_in.info_data;
	fifo_s_tdata(106 downto 103)	<= stream_in.message_type;
	fifo_s_tdata(127 downto 107)	<= stream_in.misc;
	fifo_s_tvalid 					<= stream_in.valid;
	fifo_s_tlast 					<= stream_in.last;
	fifo_s_tdest 					<= stream_in.dest;
	fifo_s_tid 						<= stream_in.tid;
	stream_in_ready 				<= fifo_s_tready;

	fifo_I : entity work.w128_d128_axi4_packet
	PORT MAP (
		s_aclk			=> clk,
		s_aresetn 		=> not rst,
		-- In stream
		s_axis_tvalid	=> fifo_s_tvalid,
		s_axis_tready	=> fifo_s_tready,
		s_axis_tdata	=> fifo_s_tdata,
		s_axis_tlast	=> fifo_s_tlast,
		s_axis_tdest 	=> fifo_s_tdest,
		s_axis_tid 		=> fifo_s_tid,
		-- Out stream
		m_axis_tvalid	=> fifo_m_tvalid,
		m_axis_tready	=> fifo_m_tready,
		m_axis_tdata	=> fifo_m_tdata,
		m_axis_tlast	=> fifo_m_tlast,
		m_axis_tid 		=> fifo_m_tid,
		m_axis_tdest 	=> fifo_m_tdest
		);
	
	stream_out.data				<= fifo_m_tdata(15  downto  0);
	stream_out.samples			<= fifo_m_tdata(21  downto 16);
	stream_out.charge			<= fifo_m_tdata(37  downto 22);
	stream_out.pad				<= fifo_m_tdata(53  downto 38);
	stream_out.ts				<= fifo_m_tdata(60  downto 54);
	stream_out.hit_type			<= fifo_m_tdata(67  downto 66);
	stream_out.m_hit		    <= fifo_m_tdata(68);
	stream_out.hits_lost		<= fifo_m_tdata(78  downto 71);
	stream_out.epoch_counter	<= fifo_m_tdata(90  downto 79);
	stream_out.info_type		<= fifo_m_tdata(94  downto 91);
	stream_out.info_data		<= fifo_m_tdata(102 downto 95);
	stream_out.message_type		<= fifo_m_tdata(106 downto 103) when override_mesage_type = '0' else message_type;
	stream_out.misc				<= fifo_m_tdata(127 downto 107);
	stream_out.tid				<= fifo_m_tid;
	stream_out.dest				<= fifo_m_tdest;
	stream_out.valid			<= fifo_m_tvalid;
	stream_out.last				<= fifo_m_tlast;
	fifo_m_tready				<= stream_out_ready;
	
end rtl;
