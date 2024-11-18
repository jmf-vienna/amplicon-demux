from Bio import SeqIO
import os


barcode_ids = [record.id for record in SeqIO.parse("config/barcodes.fna", "fasta")]
barcode_ids.append("unknown")


rule demux:
    input:
        reads="reads/adapter_trimmed/{pool}.fastq",
        barcodes="config/barcodes.fna",
    output:
        expand("reads/{{pool}}/{barcode_id}.fastq", barcode_id=barcode_ids),
        report="reads/{pool}/demux.json",
    params:
        error_rate=get_config()["trim"]["barcode"]["error rate"],
    log:
        "logs/{pool}.demux.log",
    threads: 1
    shell:
        "cutadapt"
        " --action=none"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front ^file:{input.barcodes}"
        " --output 'reads/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        +cutadapt_log_command


rule post_demux_rename:
    input:
        expand(
            "reads/{pool}/{barcode_id}.fastq", pool=get_pool(), barcode_id=barcode_ids
        ),
    output:
        expand("reads/raw/{sublib}.fastq", sublib=sublib_ids),
    run:
        for id in sublib_ids:
            parts = get_config()["sublibraries"][id]
            os.symlink(
                os.path.join(
                    "..",
                    "..",
                    "reads",
                    get_pool(),
                    parts["front"]["barcode"] + ".fastq",
                ),
                os.path.join("reads/raw", id + ".fastq"),
            )
