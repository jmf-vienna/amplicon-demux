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
        front_min_overlap=get_config()["adapter"]["min overlap"],
        back_min_overlap=get_config()["adapter"]["min overlap"],
        error_rate=get_config()["adapter"]["error rate"],
        part="adapter",
    log:
        "logs/{pool}.trim_adapter.log",
    threads: workflow.cores
    shell:
        "cutadapt"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front 'X{params.front};min_overlap={params.front_min_overlap}...{params.back}X;min_overlap={params.back_min_overlap}'"
        " --rename='{{header}} {params.part}s={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        +cutadapt_log_command
