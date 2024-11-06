rule front_adapter_trimmed:
    input:
        "in/{pool}.fastq.gz",
    output:
        "fastq/front_adapter_trimmed/{pool}.fastq",
    params:
        front=get_config()["trimming"]["adapter"]["sequence"],
    shell:
        "cutadapt"
        " --front {params.front}"
        " --rename='{{header}} front_adapter={{match_sequence}}'"
        " --output {output}"
        " {input}"
