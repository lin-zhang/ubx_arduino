#!/usr/bin/env luajit

local ffi = require("ffi")
local ubx = require "ubx"
local ts = tostring

ni=ubx.node_create("testnode")

ubx.load_module(ni, "std_types/stdtypes/stdtypes.so")
ubx.load_module(ni, "std_types/testtypes/testtypes.so")
ubx.load_module(ni, "std_blocks/lfds_buffers/lfds_cyclic.so")
ubx.load_module(ni, "std_blocks/webif/webif.so")
ubx.load_module(ni, "std_blocks/logging/file_logger.so")
ubx.load_module(ni, "std_blocks/ptrig/ptrig.so")
ubx.load_module(ni, "arduino_blocks/udp_server/udp_server.so")

ubx.ffi_load_types(ni)

print("creating instance of 'webif/webif'")
webif1=ubx.block_create(ni, "webif/webif", "webif1", { port="8888" })

print("creating instance of 'lfds_buffers/cyclic'")
fifo1=ubx.block_create(ni, "lfds_buffers/cyclic", "fifo1", {buffer_len=4, type_name="unsigned int"})

print("creating instance of 'logging/file_logger'")

print("creating instance of 'udp_server/udp_server'")
udp_server1=ubx.block_create(ni, "udp_server/udp_server", "udp_server1", {udp_server_config={port=51068}})

logger_conf=[[
{
   { blockname='fifo1', portname="overruns", buff_len=1, },
   { blockname='ptrig1', portname="tstats", buff_len=3, }
}
]]

file_log1=ubx.block_create(ni, "logging/file_logger", "file_log1",
			   {filename='report.dat',
			    separator=',',
			    timestamp=1,
			    report_conf=logger_conf})

print("creating instance of 'std_triggers/ptrig'")
ptrig1=ubx.block_create(ni, "std_triggers/ptrig", "ptrig1",
			{
			   period = {sec=0, usec=5000 },
			   sched_policy="SCHED_OTHER", sched_priority=0,
			   trig_blocks={ 
					 { b=udp_server1, num_steps=1, measure=0 },	
					 { b=file_log1, num_steps=1, measure=0 }
			   } } )

-- ubx.ni_stat(ni)

print("running webif init", ubx.block_init(webif1))
print("running ptrig1 init", ubx.block_init(ptrig1))
print("running fifo1 init", ubx.block_init(fifo1))
print("running file_log1 init", ubx.block_init(file_log1))
print("running udp_server1 init", ubx.block_init(udp_server1))


print("running webif start", ubx.block_start(webif1))

ubx.block_start(ptrig1)
ubx.block_start(file_log1)
ubx.block_start(fifo1)
ubx.block_start(udp_server1)

--print(utils.tab2str(ubx.block_totab(arduino_upload1)))
print("--- demo app launched, browse to http://localhost:8888 and start ptrig1 block to start up")
io.read()

ubx.node_cleanup(ni)
os.exit(1)
