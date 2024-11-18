from Bio import SeqIO
import os


barcode_ids = [record.id for record in SeqIO.parse("config/barcodes.fna", "fasta")]
barcode_ids.append("unknown")

demuxed_ids = get_config()["demux"].keys()


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
        " --cores {threads}"
        " --front ^file:{input.barcodes}"
        " --error-rate {params.error_rate}"
        " --action=none"
        " --output 'reads/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        " > {log}"


rule post_demux_rename:
    input:
        expand(
            "reads/{pool}/{barcode_id}.fastq", pool=get_pool(), barcode_id=barcode_ids
        ),
    output:
        expand("reads/raw/{demuxed_id}.fastq", demuxed_id=demuxed_ids),
    run:
        for id in demuxed_ids:
            parts = get_config()["demux"][id]
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
