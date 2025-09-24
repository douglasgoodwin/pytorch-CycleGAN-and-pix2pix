#!/bin/bash

# Pix2Pix Frame Extraction Script with Enhancement
# Usage: ./extract_frames.sh input_video.mp4 [output_dir] [fps] [contrast] [gamma]

# Default parameters
INPUT_VIDEO="$1"
OUTPUT_DIR="${2:-frames}"
FPS="${3:-2}"
CONTRAST="${4:-1.2}"
GAMMA="${5:-0.9}"

# Validate input
if [ -z "$INPUT_VIDEO" ]; then
    echo "Usage: $0 input_video.mp4 [output_dir] [fps] [contrast] [gamma]"
    echo "  input_video: Path to input video file"
    echo "  output_dir: Directory to save frames (default: frames)"
    echo "  fps: Frame extraction rate (default: 2)"
    echo "  contrast: Contrast adjustment (default: 1.2, range: 0.5-3.0)"
    echo "  gamma: Gamma correction (default: 0.9, range: 0.1-3.0)"
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_VIDEO" ]; then
    echo "Error: Input video file '$INPUT_VIDEO' not found!"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Processing video: $INPUT_VIDEO"
echo "Output directory: $OUTPUT_DIR"
echo "Frame rate: $FPS fps"
echo "Contrast: $CONTRAST"
echo "Gamma: $GAMMA"
echo "Target size: 256x256"

# FFmpeg command with enhancement, scaling, and cropping
ffmpeg -i "$INPUT_VIDEO" \
    -vf "eq=contrast=$CONTRAST:gamma=$GAMMA,scale=256:256:force_original_aspect_ratio=increase,crop=256:256" \
    -r "$FPS" \
    -q:v 2 \
    "$OUTPUT_DIR/frame_%04d.jpg"

echo "Frame extraction complete!"
echo "Frames saved in: $OUTPUT_DIR"

# Count extracted frames
FRAME_COUNT=$(ls -1 "$OUTPUT_DIR"/frame_*.jpg 2>/dev/null | wc -l)
echo "Total frames extracted: $FRAME_COUNT"

# Optional: Create a preview grid of first 16 frames
if command -v montage &> /dev/null && [ "$FRAME_COUNT" -gt 0 ]; then
    echo "Creating preview grid..."
    montage "$OUTPUT_DIR"/frame_000{1..16}.jpg -tile 4x4 -geometry 64x64+2+2 "$OUTPUT_DIR/preview_grid.jpg" 2>/dev/null
    if [ -f "$OUTPUT_DIR/preview_grid.jpg" ]; then
        echo "Preview grid created: $OUTPUT_DIR/preview_grid.jpg"
    fi
fi