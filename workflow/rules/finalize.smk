def get_revcomp_flags(library):
    return (
        "--reverse --complement"
        if get_config()["libraries"][library]["orientation"] == "reverse"
        else ""
    )


rule finalize:
    input:
        "reads/primer_trimmed/{library}.fastq",
    output:
        "reads/final/{library}.fastq",
    params:
        revcomp_flags=lambda wildcards: get_revcomp_flags(wildcards.library),
        min_len=get_min_length(),
        max_len=get_max_length(),
    group:
        "trim"
    shell:
        "seqkit seq"
        " --seq-type dna"
        " --validate-seq"
        " --remove-gaps"
        " --min-len {params.min_len}"
        " --max-len {params.max_len}"
        " {params.revcomp_flags}"
        " {input} > {output}"
