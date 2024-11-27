#!/usr/bin/env nextflow

workflow {
    def pools = Channel.fromPath('in/*.fastq.gz')
    def trimmed = trimAdapter(pools)
    demux(trimmed, file('config/barcodes.fna'))
}

process trimAdapter {
    input:
    path pool

    output:
    path 'trimmed.fastq'

    script:
    """
    cutadapt \
    --cores 1 \
    --error-rate 0.4 \
    --front XNNNNNNNNCCTGTACTTCGTTCAGTTACGTATTGCT...AGCAATACGTAACTGAACGAAGTACAGGX \
    --rename='{header} adapters={match_sequence}' \
    --output trimmed.fastq \
    --untrimmed-output untrimmed.fastq \
    ${pool}
    """
}

process demux {
    input:
    path pool
    path barcodes

    output:
    path "barcode_*.fastq"

    script:
    """
    cutadapt \
    --action=none \
    --cores 1 \
    --error-rate 0.1 \
    --front ^file:barcodes.fna \
    --output 'barcode_{name}.fastq' \
    ${pool} \
    """
}
