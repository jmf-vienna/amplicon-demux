rule stats:
    input:
        expand("reads/raw/{sublib}.fastq", sublib=get_sublib_ids()),
        expand("reads/barcode_trimmed/{sublib}.fastq", sublib=get_sublib_ids()),
        expand("reads/linker_trimmed/{sublib}.fastq", sublib=get_sublib_ids()),
        expand("reads/primer_trimmed/{sublib}.fastq", sublib=get_sublib_ids()),
    output:
        "reads/seqkit_stats.tsv",
    threads: 4
    shell:
        "seqkit stats"
        " --all"
        " --tabular"
        " --threads {threads}"
        " {input}"
        " > {output}"
