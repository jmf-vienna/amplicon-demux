rule trim_adapter:
    input:
        "reads/{pool}.fastq.gz",
    output:
        fastq="reads/adapter_trimmed/{pool}.fastq",
        qc="reads/adapter_trimmed/{pool}.qc.txt",
    params:
        adapters="--front {front}".format(
            front=get_config()["trimming"]["adapter"]["sequence"]
        ),
        extra=lambda wildcards: "--rename='{{header}} adapter={{match_sequence}}'".format(),
    log:
        "logs/{pool}.trim_adapter.log",
    threads: 1
    wrapper:
        "v5.0.2/bio/cutadapt/se"
