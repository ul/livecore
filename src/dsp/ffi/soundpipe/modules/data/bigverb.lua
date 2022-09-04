sptbl["bigverb"] = {

    files = {
        module = "bigverb.c",
        header = "bigverb.h",
        example = "ex_bigverb.c",
    },

    func = {
        create = "sp_bigverb_create",
        destroy = "sp_bigverb_destroy",
        init = "sp_bigverb_init",
        compute = "sp_bigverb_compute",
    },

    params = {
        optional = {
            {
                name = "feedback",
                type = "SPFLOAT",
                description = "Value between 0-1 that sets feedback value. The larger the value, the longer the decay.",
                default = 0.97
            },
            {
                name = "lpfreq",
                type = "SPFLOAT",
                description ="low pass cutoff frequency.",
                default = 10000
            },
        }
    },

    modtype = "module",

    description = [[Reverberation algorithm.]],

    ninputs = 2,
    noutputs = 2,

    inputs = {
        {
            name = "input_1",
            description = "First input."
        },
        {
            name = "input_2",
            description = "Second input."
        },
    },

    outputs = {
        {
            name = "out_1",
            description = "Channel 1 output. Most likely for the left channel."
        },
        {
            name = "out_2",
            description = "Channel 2 output. Mose likely for the right channel."
        },
    }

}
