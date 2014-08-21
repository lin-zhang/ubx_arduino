
local ffi=require"ffi"
local lunit=require"lunit"
local ubx=require"ubx"
local utils=require"utils"
local cdata=require"cdata"

module("time_arith_test", lunit.testcase, package.seeall)

ubx_timespec=ffi.typeof("struct ubx_timespec")



-- | 1.sec | 1.nsec | 2.sec | 2.nsec | nsec wrap |
-- |-------+--------+-------+--------+-----------|
-- | POS   | POS    | POS   | POS    |           |
-- |       |        |       |        |           |
-- |       |        |       |        |           |

-- POS POS
function test_sub_pos_sec_pos_nsec()
   ts1= ubx_timespec{sec=3, nsec=2}
   ts2= ubx_timespec{sec=2, nsec=1}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(1, tsres.sec)
   assert_equal(1, tsres.nsec)
end

-- NULL POS
function test_sub_null_sec_pos_nsec()
   ts1= ubx_timespec{sec=3, nsec=1}
   ts2= ubx_timespec{sec=2, nsec=2}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(0, tsres.sec)
   assert_equal(999999999, tsres.nsec)
end

-- NULL NEG
function test_sub_null_sec_neg_nsec()
   ts1= ubx_timespec{sec=2, nsec=2}
   ts2= ubx_timespec{sec=3, nsec=1}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(0, tsres.sec)
   assert_equal(-999999999, tsres.nsec)
end

--- POS NEG
function test_sub_null_sec_pos_nsec()
   ts1= ubx_timespec{sec=4, nsec=1}
   ts2= ubx_timespec{sec=2, nsec=2}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(1, tsres.sec)
   assert_equal(999999999, tsres.nsec)
end

-- NULL NEG POS
function test_sub_neg_sec_neg_nsec()
   ts1= ubx_timespec{sec=2, nsec=2}
   ts2= ubx_timespec{sec=3, nsec=1}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(0, tsres.sec)
   assert_equal(-999999999, tsres.nsec)
end

-- NEG POS
function test_sub_neg_sec_neg_nsec()
   ts1= ubx_timespec{sec=2, nsec=2}
   ts2= ubx_timespec{sec=4, nsec=1}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(-1, tsres.sec)
   assert_equal(-999999999, tsres.nsec)
end


-- NEG NEG
function test_sub_neg_sec_neg_nsec()
   ts1= ubx_timespec{sec=2, nsec=1}
   ts2= ubx_timespec{sec=3, nsec=2}
   tsres = ubx_timespec()
   ubx.ts_sub(ts1, ts2, tsres)
   assert_equal(-1, tsres.sec)
   assert_equal(-1, tsres.nsec)
end



-- Addition
function test_add_pos_sec_pos_nsec()
   ts1= ubx_timespec{sec=2, nsec=500000000}
   ts2= ubx_timespec{sec=1, nsec=500000001}
   tsres = ubx_timespec()
   ubx.ts_add(ts1, ts2, tsres)
   assert_equal(4, tsres.sec)
   assert_equal(1, tsres.nsec)
end

-- Addition
function test_add_zero_sec_neg_nsec()
   ts1= ubx_timespec{sec=2, nsec=500000000}
   ts2= ubx_timespec{sec=0, nsec=-500000001}
   tsres = ubx_timespec()
   ubx.ts_add(ts1, ts2, tsres)
   assert_equal(1, tsres.sec)
   assert_equal(999999999, tsres.nsec)
end

-- Addition
function test_add_neg_sec_neg_nsec()
   ts1= ubx_timespec{sec=1, nsec=500000000}
   ts2= ubx_timespec{sec=-2, nsec=-500000001}
   tsres = ubx_timespec()
   ubx.ts_add(ts1, ts2, tsres)
   assert_equal(-1, tsres.sec)
   assert_equal(-1, tsres.nsec)
end
