#!/bin/bash
set -e

# ============================================================
# PATHS
# ============================================================

# Dorado binary
DORADO="/Volumes/Amishi_SSD/bio_data/6Feb/dorado-1.3.1-osx-arm64/bin/dorado"

# Dorado model directory
export DORADO_MODELS_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/dorado-1.3.1-osx-arm64/dorado_models"

# Input POD5 directory
POD5_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/pod5_files"

# Output directory
OUTPUT_DIR="dorado_fast_methylation"

# Reference genome
REFERENCE="/Volumes/Amishi_SSD/bio_data/6Feb/dorado_outputs_corrupted_now/reference.fasta"

# ============================================================
# MODELS
# ============================================================

# FAST basecalling model
BASE_MODEL="dna_r10.4.1_e8.2_400bps_fast@v5.2.0"

# FAST methylation model
METHYL_MODEL="dna_r10.4.1_e8.2_400bps_fast@v5.2.0_5mCG_5hmCG@v3"

# ============================================================
# CREATE OUTPUT DIRECTORY
# ============================================================

mkdir -p "$OUTPUT_DIR"

# ============================================================
# MAIN LOOP
# ============================================================

for pod5 in "$POD5_DIR"/*.pod5; do

    [ -e "$pod5" ] || continue

    name=$(basename "$pod5" .pod5)

    echo "=================================================="
    echo "Processing: $name"
    echo "=================================================="

    "$DORADO" basecaller \
        "$BASE_MODEL" \
        "$pod5" \
        --reference "$REFERENCE" \
        --modified-bases-models "$METHYL_MODEL" \
        --min-qscore 9 \
        --device metal \
        --emit-moves \
    | samtools sort -o "$OUTPUT_DIR/${name}_fast_methylation.sorted.bam"

    # ========================================================
    # INDEX BAM
    # ========================================================

    samtools index "$OUTPUT_DIR/${name}_fast_methylation.sorted.bam"

    # ========================================================
    # VERIFY MM/ML TAGS
    # ========================================================

    MM_CHECK=$(samtools view "$OUTPUT_DIR/${name}_fast_methylation.sorted.bam" \
        | head -5 \
        | grep -c "MM:Z:" || true)

    if [ "$MM_CHECK" -gt 0 ]; then
        echo "✓ MM/ML methylation tags confirmed for $name"
    else
        echo "WARNING: MM/ML tags not found for $name"
    fi

    echo "✓ Finished: $name"
    echo

done

echo "=================================================="
echo "All files processed."
echo "=================================================="