def get_sublib_barcodes(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["barcode"]


rule trim_barcode:
    input:
        "reads/raw/{sublib}.fastq",
    output:
        trimmed="reads/barcode_trimmed/{sublib}.fastq",
        untrimmed="reads/barcode_trimmed/{sublib}.untrimmed.fastq",
        report="reads/barcode_trimmed/{sublib}.json",
    params:
        front=get_sublib_barcodes,
        error_rate=get_config()["trim"]["barcode"]["error rate"],
    log:
        "logs/{sublib}.trim_barcode.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front {params.front}"
        " --error-rate {params.error_rate}"
        " --rename='{{header}} barcode={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        " > {log}"
