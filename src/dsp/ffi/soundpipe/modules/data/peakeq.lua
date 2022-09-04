sptbl["peakeq"] = {

    files = {
        module = "peakeq.c",
        header = "peakeq.h",
        example = "ex_peakeq.c",
    },

    func = {
        create = "sp_peakeq_create",
        destroy = "sp_peakeq_destroy",
        init = "sp_peakeq_init",
        compute = "sp_peakeq_compute",
    },

    params = {

        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "The center frequency of the filter",
                default = 1000
            },
            {
                name = "bw",
                type = "SPFLOAT",
                description ="The peak/notch bandwidth in Hertz",
                default = 125
            },
            {
                name = "gain",
                type = "SPFLOAT",
                description ="The peak/notch gain",
                default = 2
            },
        }
    },

    modtype = "module",

    description = [[2nd order tunable equalization filter

    This provides a peak/notch filter for building parametric/graphic equalizers. With gain above 1, there will be a peak at the center frequency with a width dependent on bw. If gain is less than 1, a notch is formed around the center frequency (freq).
    ]],

    ninputs = 1,
    noutputs = 1,

    inputs = {
        {
            name = "input",
            description = "Signal input."
        },
    },

    outputs = {
        {
            name = "output",
            description = "Signal output."
        },
    }

}
