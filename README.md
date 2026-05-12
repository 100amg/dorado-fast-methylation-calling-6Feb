# Dorado FAST Methylation Calling Pipeline

Pipeline for Oxford Nanopore FAST basecalling, move table generation, and direct methylation calling using Dorado native modified-base calling.

---

# Overview

This workflow processes Oxford Nanopore `.pod5` raw signal files using the Dorado FAST basecalling model with native modified-base calling enabled.

The workflow performs:

* FAST basecalling
* Direct methylation calling
* Reference-guided alignment
* Move table generation
* BAM sorting and indexing

The generated BAM outputs contain:

* aligned reads
* move tables
* MM methylation tags
* ML methylation probability tags
* 5mC calls
* 5hmC calls

The workflow corresponds specifically to:

| Step | Script                            | Purpose                                       |
| ---- | --------------------------------- | --------------------------------------------- |
| 1    | `run_dorado_fast_methyl_batch.sh` | FAST basecalling + direct methylation calling |

`run_dorado_fast_methyl_batch.sh` performs FAST basecalling, direct methylation calling, reference alignment, and move-table enabled BAM generation using Dorado native modified-base calling.

---

# Repository Structure

```text
dorado-fast-methylation-pipeline/
│
├── README.md
│
├── run_dorado_fast_methyl_batch.sh
│
├── reference.fasta
│
├── reference.fasta.fai
│
└── .gitignore
```

---

# Required Input Files

The workflow requires:

* `.pod5` files
* Reference FASTA
* FASTA index (`.fai`)

Example:

```text
project/
├── pod5_files/
│   ├── sample1.pod5
│   └── sample2.pod5
├── reference.fasta
├── reference.fasta.fai
├── run_dorado_fast_methyl_batch.sh
```

---

# Dorado FAST Model Used

## FAST Basecalling Model

```text
dna_r10.4.1_e8.2_400bps_fast@v4.2.0
```

---

# Modified-Base Calling Configuration

The workflow enables methylation calling using:

```text
--modified-bases 5mCG_5hmCG
```

This activates:

* 5mC detection
* 5hmC detection
* MM/ML methylation tagging

---

# Workflow

## Step 1 — FAST Basecalling and Direct Methylation Calling

Edit the following variables inside:

```text
run_dorado_fast_methyl_batch.sh
```

Set:

```bash
POD5_DIR=
OUTPUT_DIR=
REFERENCE=
DORADO_MODELS_DIR=
```

Run:

```bash
chmod +x scripts/run_dorado_fast_methyl_batch.sh

bash scripts/run_dorado_fast_methyl_batch.sh
```

Expected outputs:

```text
dorado_fast_methylation_movefiles/
├── sample_methylation_sorted.bam
└── sample_methylation_sorted.bam.bai
```

---

# Verifying Methylation Tags

Inspect BAM contents:

```bash
samtools view sample_methylation_sorted.bam | head
```

Successful methylation calling produces tags such as:

```text
MM:Z:
ML:B:C
```

---

# Verifying Outputs

List BAM files:

```bash
ls -lh dorado_fast_methylation_movefiles/
```

Check BAM statistics:

```bash
samtools flagstat sample_methylation_sorted.bam
```

Count reads:

```bash
samtools view -c sample_methylation_sorted.bam
```

---

# Full Documentation

Detailed workflow documentation is available here:

[Google Docs Documentation](https://docs.google.com/document/d/1Wj-gkxO755uF2FdEJx0VJSViN6hjUYA6_AcrjSxTIXk/edit?tab=t.588sotzb6h8p)
