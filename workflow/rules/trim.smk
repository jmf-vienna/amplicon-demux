def get_library_config(library):
    return get_config()["libraries"][library[0]]


def get_library_front_barcode(library):
    return get_library_config(library)["front"]["barcode"]


def get_library_back_barcode(library):
    return Seq(get_library_config(library)["back"]["barcode"]).reverse_complement()


def get_library_front_linker(library):
    return get_library_config(library)["front"]["linker"]


def get_library_back_linker(library):
    return Seq(get_library_config(library)["back"]["linker"]).reverse_complement()


def get_library_front_primer(library):
    return get_library_config(library)["front"]["primer"]


def get_library_back_primer(library):
    return Seq(get_library_config(library)["back"]["primer"]).reverse_complement()


trim_command = (
    "cutadapt"
    " --adapter ^{params.front}...{params.back}$"
    " --error-rate {params.error_rate}"
    " --rename='{{header}} {params.part}s={{match_sequence}}'"
    " --output {output.trimmed}"
    " --untrimmed-output {output.untrimmed}"
    " --json {output.report}"
    " {input}"
    " > {log}"
)


rule trim_barcode:
    input:
        "reads/raw/{library}.fastq",
    output:
        trimmed=temp("reads/barcode_trimmed/{library}.fastq"),
        untrimmed=temp("reads/barcode_trimmed/{library}.untrimmed.fastq"),
        report=temp("reads/barcode_trimmed/{library}.json"),
    params:
        front=get_library_front_barcode,
        back=get_library_back_barcode,
        error_rate=get_config()["barcode"]["error rate"],
        part="barcode",
    log:
        "logs/{library}.trim_barcode.log",
    group:
        "demux"
    envmodules:
        "cutadapt",
    shell:
        trim_command


rule trim_linker:
    input:
        "reads/barcode_trimmed/{library}.fastq",
    output:
        trimmed=temp("reads/linker_trimmed/{library}.fastq"),
        untrimmed=temp("reads/linker_trimmed/{library}.untrimmed.fastq"),
        report=temp("reads/linker_trimmed/{library}.json"),
    params:
        front=get_library_front_linker,
        back=get_library_back_linker,
        error_rate=get_config()["linker"]["error rate"],
        part="linker",
    log:
        "logs/{library}.trim_linker.log",
    group:
        "demux"
    envmodules:
        "cutadapt",
    shell:
        trim_command


rule trim_primer:
    input:
        "reads/linker_trimmed/{library}.fastq",
    output:
        trimmed=temp("reads/primer_trimmed/{library}.fastq"),
        untrimmed=temp("reads/primer_trimmed/{library}.untrimmed.fastq"),
        report=temp("reads/primer_trimmed/{library}.json"),
    params:
        front=get_library_front_primer,
        back=get_library_back_primer,
        error_rate=get_config()["primer"]["error rate"],
        part="primer",
    log:
        "logs/{library}.trim_primer.log",
    group:
        "demux"
    envmodules:
        "cutadapt",
    shell:
        trim_command
