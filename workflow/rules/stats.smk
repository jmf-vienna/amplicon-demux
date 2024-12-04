rule stats:
    input:
        expand("reads/raw/{library}.fastq", library=get_library_ids()),
        expand("reads/barcode_trimmed/{library}.fastq", library=get_library_ids()),
        expand("reads/linker_trimmed/{library}.fastq", library=get_library_ids()),
        expand("reads/primer_trimmed/{library}.fastq", library=get_library_ids()),
    output:
        "reads/seqkit_stats.tsv",
    threads: workflow.cores
    shell:
        "seqkit stats"
        " --all"
        " --tabular"
        " --threads {threads}"
        " {input}"
        " > {output}"
