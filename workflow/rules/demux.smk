rule demux:
    input:
        reads="reads/pools/{pool}.trimmed.fastq",
        barcodes="config/barcodes.fna",
    output:
        temp("reads/pools/{pool}/unknown.fastq"),
        report=temp("reads/pools/{pool}/demux.json"),
    params:
        error_rate=get_config()["barcode"]["error rate"],
    log:
        "logs/{pool}.demux.log",
    threads: workflow.cores
    envmodules:
        "cutadapt",
    shell:
        "cutadapt"
        " --action=none"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front ^file:{input.barcodes}"
        " --output 'reads/pools/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        " > {log}"


rule post_demux_rename:
    input:
        expand("reads/pools/{pool}/unknown.fastq", pool=get_pools()),
    output:
        temp(expand("reads/raw/{library}.fastq", library=get_library_ids())),
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
