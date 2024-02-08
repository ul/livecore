const BUNDLE = "com.github.ul.livecore".cstring
const OS_LOG_CATEGORY_POINTS_OF_INTEREST = "PointsOfInterest".cstring

proc os_log_create(bundle, category: cstring): pointer {.importc, header: "<os/log.h>".}
proc os_signpost_id_generate(log: pointer): uint64 {.importc, header: "<os/signpost.h>".}
proc os_signpost_interval_begin(log: pointer, spid: uint64, name: cstring) {.importc, header: "<os/signpost.h>".}
proc os_signpost_interval_end(log: pointer, spid: uint64, name: cstring) {.importc, header: "<os/signpost.h>".}

let logger = os_log_create(BUNDLE, OS_LOG_CATEGORY_POINTS_OF_INTEREST)
let spid = os_signpost_id_generate(logger)

proc interval_begin*(name: static[string]) = os_signpost_interval_begin(logger, spid, name.cstring)
proc interval_end*(name: static[string]) = os_signpost_interval_end(logger, spid, name.cstring)
