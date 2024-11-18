rule trim_adapter:
    input:
        "reads/{pool}.fastq.gz",
    output:
        trimmed="reads/adapter_trimmed/{pool}.fastq",
        untrimmed="reads/adapter_trimmed/{pool}.untrimmed.fastq",
        report="reads/adapter_trimmed/{pool}.json",
    params:
        front=get_config()["trim"]["adapter"]["front"],
        back=Seq(get_config()["trim"]["adapter"]["back"]).reverse_complement(),
        error_rate=get_config()["trim"]["adapter"]["error rate"],
        part="adapter",
    log:
        "logs/{pool}.trim_adapter.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front X{params.front}...{params.back}X"
        " --rename='{{header}} {params.part}s={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        +cutadapt_log_command
