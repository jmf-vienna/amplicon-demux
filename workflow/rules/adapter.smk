rule trim_adapter:
    input:
        "reads/pools/{pool}.fastq.gz",
    output:
        trimmed="reads/pools/{pool}.trimmed.fastq",
        untrimmed="reads/pools/{pool}.untrimmed.fastq",
        report="reads/pools/{pool}.trim_adapter.json",
    params:
        front=get_config()["adapter"]["front"],
        back=Seq(get_config()["adapter"]["back"]).reverse_complement(),
        error_rate=get_config()["adapter"]["error rate"],
        part="adapter",
    log:
        "logs/{pool}.trim_adapter.log",
    threads: workflow.cores
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
