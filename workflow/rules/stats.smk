rule stats:
    input:
        expand("reads/pool_raw/{pool}.fastq.gz", pool=get_pools()),
        expand("reads/pool_adapter_trimmed/{pool}.fastq", pool=get_pools()),
        expand("reads/raw/{library}.fastq", library=get_library_ids()),
        expand("reads/barcode_trimmed/{library}.fastq", library=get_library_ids()),
        expand("reads/linker_trimmed/{library}.fastq", library=get_library_ids()),
        expand("reads/primer_trimmed/{library}.fastq", library=get_library_ids()),
        expand("reads/final/{library}.fastq", library=get_library_ids()),
    output:
        "reads/seqkit_stats.tsv",
    threads: workflow.cores
    shell:
        "seqkit stats"
        " --seq-type dna"
        " --all"
        " --tabular"
        " --threads {threads}"
        " --quiet"
        " {input}"
        " > {output}"


rule read_length_distribution_meta:
    input:
        "reads/length_distribution/pool_raw.tsv",
        "reads/length_distribution/pool_adapter_trimmed.tsv",
        "reads/length_distribution/raw.tsv",
        "reads/length_distribution/barcode_trimmed.tsv",
        "reads/length_distribution/linker_trimmed.tsv",
        "reads/length_distribution/primer_trimmed.tsv",
        "reads/length_distribution/final.tsv",
    output:
        "reads/length_distribution.tsv",
    shell:
        "echo {input} | sed 's/ /\\n/g' > {output}"


length_command = "awk 'NR % 4 == 2 {{ print length($0) }}' {input} | sort --numeric-sort | uniq --count > {output}"
length_command_gz = "zcat {input} | awk 'NR % 4 == 2 {{ print length($0) }}' | sort --numeric-sort | uniq --count > {output}"


rule read_length_distribution_pool_gz:
    input:
        expand("reads/pool_{{step}}/{pool}.fastq.gz", pool=get_pools()),
    output:
        "reads/length_distribution/pool_{step}.tsv",
    shell:
        length_command_gz


rule read_length_distribution_pool:
    input:
        expand("reads/pool_{{step}}/{pool}.fastq", pool=get_pools()),
    output:
        "reads/length_distribution/pool_{step}.tsv",
    shell:
        length_command


rule read_length_distribution:
    input:
        expand("reads/{{step}}/{library}.fastq", library=get_library_ids()),
    output:
        "reads/length_distribution/{step}.tsv",
    shell:
        length_command
