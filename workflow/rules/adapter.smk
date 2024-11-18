rule trim_adapter:
    input:
        "reads/{pool}.fastq.gz",
    output:
        trimmed="reads/adapter_trimmed/{pool}.fastq",
        untrimmed="reads/adapter_trimmed/{pool}.untrimmed.fastq",
        report="reads/adapter_trimmed/{pool}.json",
    params:
        front=get_config()["trim"]["adapter"]["sequence"],
        error_rate=get_config()["trim"]["adapter"]["error rate"],
    log:
        "logs/{pool}.trim_adapter.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front {params.front}"
        " --error-rate {params.error_rate}"
        " --rename='{{header}} adapter={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        +cutadapt_log_command
