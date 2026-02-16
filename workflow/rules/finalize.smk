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
    group:
        "trim"
    shell:
        "seqkit seq --seq-type dna --validate-seq --min-len 1 --remove-gaps {params.revcomp_flags} {input} > {output}"
