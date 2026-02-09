rule demux:
    input:
        reads="reads/pool_adapter_trimmed/{pool}.fastq",
        barcodes="config/barcodes.fna",
    output:
        temp("reads/demultiplexed/{pool}/unknown.fastq"),
        report=temp("reads/demultiplexed/{pool}/demux.json"),
    params:
        error_rate=get_config()["barcode"]["error rate"],
    log:
        "logs/{pool}.demux.log",
    group:
        "demux"
    threads: workflow.cores
    envmodules:
        "cutadapt",
    shell:
        "cutadapt"
        " --action=none"
        " --cores {threads}"
        " --error-rate {params.error_rate}"
        " --front ^file:{input.barcodes}"
        " --output 'reads/demultiplexed/{wildcards.pool}/{{name}}.fastq'"
        " --json {output.report}"
        " {input.reads}"
        " > {log}"


# Due to performance reasons, not all demux output files are currently tracked by the workflow and can therefore not be marked as temp().
rule ignore_file:
    input:
        "reads/demultiplexed/{pool}/unknown.fastq",
    output:
        "reads/demultiplexed/{pool}/.gitignore",
    group:
        "demux"
    shell:
        "echo '*.fastq' > {output}"


rule post_demux_rename:
    input:
        expand("reads/demultiplexed/{pool}/.gitignore", pool=get_pools()),
    output:
        temp(expand("reads/raw/{library}.fastq", library=get_library_ids())),
    group:
        "demux"
    run:
        for id in get_library_ids():
            parts = get_config()["libraries"][id]
            os.symlink(
                os.path.join(
                    "..",
                    "demultiplexed",
                    parts["pool"],
                    parts["front"]["barcode"] + ".fastq",
                ),
                os.path.join("reads/raw", id + ".fastq"),
            )
