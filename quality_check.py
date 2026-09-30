"""Quality check for paired-end FASTQ files.

Reports the number of reads and the average Phred quality score per file.

Usage:
    python3 quality_check.py sample1_R1.fastq sample1_R2.fastq
"""
import sys

from Bio import SeqIO


def assess_quality(fastq_file):
    total_sequences = 0
    quality_scores = []

    for record in SeqIO.parse(fastq_file, "fastq"):
        total_sequences += 1
        quality_scores.append(record.letter_annotations["phred_quality"])

    avg_quality = sum([sum(q) / len(q) for q in quality_scores]) / total_sequences
    print(f"{fastq_file}")
    print(f"  Total sequences: {total_sequences}")
    print(f"  Average Quality Score: {avg_quality:.2f}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 quality_check.py <file1.fastq> [file2.fastq ...]")
    for path in sys.argv[1:]:
        assess_quality(path)
