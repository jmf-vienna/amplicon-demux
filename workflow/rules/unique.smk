rule library_count_table:
    input:
        "reads/final/{library}.fastq",
    output:
        temp("reads/final/{library}.tsv"),
    shell:
        "seqkit fx2tab"
        " --threads {threads}"
        " {input} |"
        " cut --fields 8 |"
        " sort | uniq --count |"
        " sed -e 's/^ \\+//' -e 's/ /\t/' -e 's/$/\t{wildcards.library}/' |"
        " awk '{{ print $2, $3, $1 }}' OFS='\t'"
        " > {output}"


rule count_table:
    input:
        expand("reads/final/{library}.tsv", library=get_library_ids()),
    output:
        "reads/counts.tsv",
    shell:
        "echo -e 'sequence\\tlibrary_ID\\tcount' > {output} && "
        "cat {input} | sort >> {output}"


rule sequences_table:
    input:
        expand("reads/final/{library}.tsv", library=get_library_ids()),
    output:
        "reads/features.tsv",
    shell:
        "echo sequence > {output} &&"
        " cut --fields 1 {input} |"
        " sort | uniq"
        " >> {output}"
