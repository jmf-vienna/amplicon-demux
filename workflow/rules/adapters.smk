rule trim_adapter:
    input:
        "reads/{pool}.fastq.gz",
    output:
        trimmed="reads/adapter_trimmed/{pool}.fastq",
    params:
        front=get_config()["trimming"]["adapter"]["sequence"],
    log:
        "reads/adapter_trimmed/{pool}.qc.txt",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front {params.front}"
        " --rename='{{header}} adapter={{match_sequence}}'"
        " --output {output.trimmed}"
        " {input}"
        " > {log}"
