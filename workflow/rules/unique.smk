rule library_count_table:
    input:
        "reads/final/{library}.fastq",
    output:
        temp("reads/final/{library}.tsv"),
    shell:
        "seqkit fx2tab"
        " --seq-hash"
        " --threads {threads}"
        " {input} |"
        " cut --fields 8,10 |"
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
        " awk '{{ print $3, $4, $1 }}' OFS='\t' {input} | sort >> {output}"


rule sequences_table:
    input:
        expand("reads/final/{library}.tsv", library=get_library_ids()),
    output:
        "reads/features.tsv",
    shell:
        "echo -e 'feature_ID\\tsequence' > {output} &&"
        " awk '{{ print $3, $2 }}' OFS='\t' {input} |"
        " sort | uniq"
        " >> {output}"
