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
        " --output {output}"
        " {input}"
