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
        back=get_config()["adapter"]["back"],
        error_rate=get_config()["adapter"]["error rate"],
        part="adapter",
    shell:
        "cutadapt"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front '{params.front}...{params.back}'"
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
