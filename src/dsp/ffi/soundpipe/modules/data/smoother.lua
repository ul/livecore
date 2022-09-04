sptbl["smoother"] = {

    files = {
        module = "smoother.c",
        header = "smoother.h",
        example = "ex_smoother.c",
    },

    func = {
        create = "sp_smoother_create",
        destroy = "sp_smoother_destroy",
        init = "sp_smoother_init",
        compute = "sp_smoother_compute",
        other = {
            sp_smoother_reset = {
                description = "Resets internal buffers, snapping to input value instead of ramping to it.",
                args = {
                    {
                        name = "input",
                        type = "SPFLOAT *",
                        description = "input value to snap to.",
                        default = 0.0
                    },
                }
            }
        }
    },

    params = {
        mandatory = {
        },
        optional = {
            {
                name = "smooth",
                type = "SPFLOAT",
                description = "Smooth time amount.",
                default = 0.01
            },
        },
    },

    modtype = "module",

    description = [[ Smootheramento-style control signal smoothing

    Useful for smoothing out low-resolution signals and applying glissando to filters.]],

    ninputs = 1,
    noutputs = 1,

    inputs = {
        {
            name = "in",
            description = "Signal input."
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
