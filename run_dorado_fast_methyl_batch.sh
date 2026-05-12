#!/bin/bash
set -e

# Dorado model directory
export DORADO_MODELS_DIR=/Volumes/Amishi_SSD/bio_data/6Feb/dorado-1.3.1-osx-arm64/dorado_models

# Input POD5 files
POD5_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/pod5_files"

# Output directory
OUTPUT_DIR="dorado_hac_methylation_movefiles"

# Reference genome
REFERENCE="/Volumes/Amishi_SSD/bio_data/6Feb/dorado_outputs_corrupted_now/reference.fasta"

# Create output directory
mkdir -p "$OUTPUT_DIR"

for pod5 in "$POD5_DIR"/*.pod5; do

    [ -e "$pod5" ] || continue

    name=$(basename "$pod5" .pod5)

    echo "Processing: $name"

    # HAC basecalling + methylation calling + alignment
    /Volumes/Amishi_SSD/bio_data/6Feb/dorado-1.3.1-osx-arm64/bin/dorado basecaller \
        dna_r10.4.1_e8.2_400bps_hac@v5.2.0 \
        "$pod5" \
        --reference "$REFERENCE" \
        --min-qscore 9 \
        --device metal \
        --emit-moves \
        --modified-bases 5mCG_5hmCG \
        | samtools sort -o "$OUTPUT_DIR/${name}_methylation_sorted.bam"

    # Index BAM
    samtools index "$OUTPUT_DIR/${name}_methylation_sorted.bam"

    # Verify methylation tags
    MM_CHECK=$(samtools view "$OUTPUT_DIR/${name}_methylation_sorted.bam" | head -5 | grep -c "MM:Z:" || true)

    if [ "$MM_CHECK" -gt 0 ]; then
        echo "✓ MM/ML methylation tags confirmed for $name"
    else
        echo "WARNING: MM/ML tags not found for $name"
    fi

    echo "✓ Finished: $name"

done

echo "All files processed."