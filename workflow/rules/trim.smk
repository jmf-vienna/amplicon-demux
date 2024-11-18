def get_sublib_barcodes(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["barcode"]


def get_sublib_linkers(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["linker"]


def get_sublib_primers(sublib):
    return get_config()["sublibraries"][sublib.pop()]["front"]["primer"]


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
        " --front ^{params.front}"
        " --error-rate {params.error_rate}"
        " --rename='{{header}} barcode={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        " > {log}"


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
    log:
        "logs/{sublib}.trim_linker.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front ^{params.front}"
        " --error-rate {params.error_rate}"
        " --rename='{{header}} linker={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        " > {log}"


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
    log:
        "logs/{sublib}.trim_primer.log",
    threads: 1
    shell:
        "cutadapt"
        " --cores {threads}"
        " --front ^{params.front}"
        " --error-rate {params.error_rate}"
        " --rename='{{header}} primer={{match_sequence}}'"
        " --output {output.trimmed}"
        " --untrimmed-output {output.untrimmed}"
        " --json {output.report}"
        " {input}"
        " > {log}"
