rule trim_adapter:
    input:
        "reads/pool_raw/{pool}.fastq.gz",
    output:
        trimmed=temp("reads/pool_adapter_trimmed/{pool}.fastq"),
        untrimmed=temp("reads/pool_adapter_trimmed/{pool}.untrimmed.fastq"),
        report=temp("reads/pool_adapter_trimmed/{pool}.trim_adapter.json"),
    log:
        "logs/{pool}.trim_adapter.log",
    envmodules:
        "cutadapt",
    threads: workflow.cores
    params:
        front=get_config()["adapter"]["front"],
        back=Seq(get_config()["adapter"]["back"]).reverse_complement(),
        front_min_overlap=get_config()["adapter"]["min overlap"],
        back_min_overlap=get_config()["adapter"]["min overlap"],
        error_rate=get_config()["adapter"]["error rate"],
        part="adapter",
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
        " > {log}"


rule already_trimmed_adapter:
    input:
        "reads/pool_adapter_trimmed/{pool}.fastq.gz",
    output:
        temp("reads/pool_adapter_trimmed/{pool}.fastq"),
    log:
        "logs/{pool}.trim_adapter.log",
    shell:
        "zcat" " {input}" " > {output}" " 2> {log}"
