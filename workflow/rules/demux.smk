rule demux:
    input:
        reads="reads/adapter_trimmed/{pool}.fastq",
        barcodes="config/barcodes.fna",
    output:
        untrimmed="reads/{pool}/unknown.fastq",
        report="reads/{pool}/demux.json",
    params:
        error_rate=get_config()["trim"]["barcode"]["error rate"],
    log:
        "logs/{pool}.demux.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front ^file:{input.barcodes}"
        " --error-rate {params.error_rate}"
        " --action=none"
        " --output 'reads/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        " > {log}"
