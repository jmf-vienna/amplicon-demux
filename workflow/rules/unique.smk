rule library_count_table:
    input:
        "reads/final/{library}.fastq",
    output:
        temp("reads/final/{library}.tsv"),
    shell:
        "seqkit fx2tab"
        " --only-id"
        " --no-qual"
        " --seq-hash"
        " --length"
        " --threads {threads}"
        " {input} |"
        " cut --fields 2-4 |"
        " sort | uniq --count |"
        " sed -e 's/^ \\+//' -e 's/ /\t/' -e 's/$/\t{wildcards.library}/'"
        " > {output}"


rule count_table:
    input:
        expand("reads/final/{library}.tsv", library=get_library_ids()),
    output:
        "reads/counts.tsv",
    shell:
        "echo -e 'feature_ID\\tlibrary_ID\\tcount' > {output} &&"
        " awk '{{ print $4, $5, $1 }}' OFS='\t' {input} | sort >> {output}"


rule sequences_table:
    input:
        expand("reads/final/{library}.tsv", library=get_library_ids()),
    output:
        "reads/features.tsv",
    shell:
        "echo -e 'feature_ID\\tsequence\tsequence_length' > {output} &&"
        " awk '{{ print $4, $2, $3 }}' OFS='\t' {input} |"
        " sort | uniq"
        " >> {output}"


rule duplicate_reads:
    input:
        expand("reads/final/{library}.fastq", library=get_library_ids()),
    output:
        "reads/duplicate_reads.txt",
    shell:
        "seqkit fx2tab"
        " --name --only-id"
        " --threads {threads}"
        " {input} |"
        " sort | uniq --repeated"
        " > {output}"


rule duplicate_reads_check:
    input:
        "reads/duplicate_reads.txt",
    output:
        touch("reads/duplicate_reads_check.done"),
    shell:
        "diff <(echo -n) {input}"
