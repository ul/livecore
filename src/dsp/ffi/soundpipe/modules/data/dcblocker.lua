sptbl["dcblocker"] = {

    files = {
        module = "dcblocker.c",
        header = "dcblocker.h",
    },

    func = {
        create = "sp_dcblocker_create",
        destroy = "sp_dcblocker_destroy",
        init = "sp_dcblocker_init",
        compute = "sp_dcblocker_compute",
    },

    params = {
    },

    modtype = "module",

    description = [[A simple DC block filter]],

    ninputs = 1,
    noutputs = 1,

    inputs = {
        {
            name = "in",
            description = "Signal input"
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal output"
        },
    }

}
