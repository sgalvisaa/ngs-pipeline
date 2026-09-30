#!/usr/bin/env bash
# NGS pipeline: quality check -> alignment -> peak calling -> gene annotation
# Inputs (not included in this repo): sample1_R1.fastq, sample1_R2.fastq,
# Homo_sapiens.GRCh38.dna.chromosome.17.fa (indexed with `bwa index`),
# Homo_sapiens.GRCh38.112.chromosome.17.gff3
set -euo pipefail

# 1. Quality check
python3 quality_check.py sample1_R1.fastq sample1_R2.fastq

# 2. Align paired-end reads to chromosome 17, then convert, sort, and index
bwa mem Homo_sapiens.GRCh38.dna.chromosome.17.fa sample1_R1.fastq sample1_R2.fastq > sample1_chr17.sam
samtools view -S -b sample1_chr17.sam > sample1_chr17.bam
samtools sort sample1_chr17.bam -o sample1_chr17_sorted.bam
samtools index sample1_chr17_sorted.bam
samtools flagstat sample1_chr17_sorted.bam

# 3. Call high-coverage regions (peaks)
macs2 callpeak -t sample1_chr17_sorted.bam -f BAM -g hs -n sample1_chr17_peaks --outdir peaks

# 4. Annotate peaks with genes and list the unique gene/transcript names
bedtools intersect -a peaks/sample1_chr17_peaks_summits.bed -b Homo_sapiens.GRCh38.112.chromosome.17.gff3 -wa -wb > intersect_output.bed
grep "Name=" intersect_output.bed | cut -d ";" -f 3 | sort | uniq > unique_genes.txt
