def get_sublib_barcodes(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["barcode"]


def get_sublib_linkers(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["linker"]


def get_sublib_primers(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["primer"]


trim_command = (
    "cutadapt"
    " --cores {threads}"
    " --front ^{params.front}"
    " --error-rate {params.error_rate}"
    " --rename='{{header}} {params.part}={{match_sequence}}'"
    " --output {output.trimmed}"
    " --untrimmed-output {output.untrimmed}"
    " --json {output.report}"
    " {input}"
    " | sed '/^Finished in /d' > {log}"
)


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
        part="barcode",
    log:
        "logs/{sublib}.trim_barcode.log",
    threads: 1
    shell:
        trim_command


rule trim_linker:
    input:
        "reads/barcode_trimmed/{sublib}.fastq",
    output:
        trimmed="reads/linker_trimmed/{sublib}.fastq",
        untrimmed="reads/linker_trimmed/{sublib}.untrimmed.fastq",
        report="reads/linker_trimmed/{sublib}.json",
    params:
        front=get_sublib_linkers,
        error_rate=get_config()["trim"]["linker"]["error rate"],
        part="linker",
    log:
        "logs/{sublib}.trim_linker.log",
    threads: 1
    shell:
        trim_command


rule trim_primer:
    input:
        "reads/linker_trimmed/{sublib}.fastq",
    output:
        trimmed="reads/primer_trimmed/{sublib}.fastq",
        untrimmed="reads/primer_trimmed/{sublib}.untrimmed.fastq",
        report="reads/primer_trimmed/{sublib}.json",
    params:
        front=get_sublib_primers,
        error_rate=get_config()["trim"]["primer"]["error rate"],
        part="primer",
    log:
        "logs/{sublib}.trim_primer.log",
    threads: 1
    shell:
        trim_command
