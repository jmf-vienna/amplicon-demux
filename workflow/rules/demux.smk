def get_barcode_ids():
    barcode_ids = [record.id for record in SeqIO.parse("config/barcodes.fna", "fasta")]
    barcode_ids.append("unknown")
    return barcode_ids


rule demux:
    input:
        reads="reads/pools/{pool}.trimmed.fastq",
        barcodes="config/barcodes.fna",
    output:
        expand("reads/pools/{{pool}}/{barcode_id}.fastq", barcode_id=get_barcode_ids()),
        report="reads/pools/{pool}/demux.json",
    params:
        error_rate=get_config()["barcode"]["error rate"],
    log:
        "logs/{pool}.demux.log",
    threads: 1
    shell:
        "cutadapt"
        " --action=none"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front ^file:{input.barcodes}"
        " --output 'reads/pools/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        +cutadapt_log_command


rule post_demux_rename:
    input:
        expand(
            "reads/pools/{pool}/{barcode_id}.fastq",
            pool=get_pools(),
            barcode_id=get_barcode_ids(),
        ),
    output:
        expand("reads/raw/{library}.fastq", library=get_library_ids()),
    run:
        for id in get_library_ids():
            parts = get_config()["libraries"][id]
            os.symlink(
                os.path.join(
                    "..",
                    "pools",
                    parts["pool"],
                    parts["front"]["barcode"] + ".fastq",
                ),
                os.path.join("reads/raw", id + ".fastq"),
            )
