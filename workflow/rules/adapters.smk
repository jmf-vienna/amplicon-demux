rule front_adapter_trimmed:
    input:
        "in/{pool}.fastq.gz",
    output:
        "fastq/front_adapter_trimmed/{pool}.fastq",
    shell:
        "cutadapt"
        " --front {config[default][trimming][adapter][sequence]}"
        " --output {output}"
        " {input}"
