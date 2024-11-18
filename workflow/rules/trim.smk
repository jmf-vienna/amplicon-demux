def get_sublib_config(sublib):
    return get_config()["sublibraries"][sublib[0]]


def sublib_front_barcode(sublib):
    return get_sublib_config(sublib)["front"]["barcode"]


def sublib_back_barcode(sublib):
    return Seq(get_sublib_config(sublib)["back"]["barcode"]).reverse_complement()


def sublib_front_linker(sublib):
    return get_sublib_config(sublib)["front"]["linker"]


def sublib_back_linker(sublib):
    return Seq(get_sublib_config(sublib)["back"]["linker"]).reverse_complement()


def sublib_front_primer(sublib):
    return get_sublib_config(sublib)["front"]["primer"]


def sublib_back_primer(sublib):
    return Seq(get_sublib_config(sublib)["back"]["primer"]).reverse_complement()


trim_command = (
    "cutadapt"
    " --adapter ^{params.front}...{params.back}$"
    " --cores {threads}"
    " --error-rate {params.error_rate}"
    " --rename='{{header}} {params.part}s={{match_sequence}}'"
    " --output {output.trimmed}"
    " --untrimmed-output {output.untrimmed}"
    " --json {output.report}"
    " {input}"
) + cutadapt_log_command


rule trim_barcode:
    input:
        "reads/raw/{sublib}.fastq",
    output:
        trimmed="reads/barcode_trimmed/{sublib}.fastq",
        untrimmed="reads/barcode_trimmed/{sublib}.untrimmed.fastq",
        report="reads/barcode_trimmed/{sublib}.json",
    params:
        front=sublib_front_barcode,
        back=sublib_back_barcode,
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
        front=sublib_front_linker,
        back=sublib_back_linker,
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
        front=sublib_front_primer,
        back=sublib_back_primer,
        error_rate=get_config()["trim"]["primer"]["error rate"],
        part="primer",
    log:
        "logs/{sublib}.trim_primer.log",
    threads: 1
    shell:
        trim_command
