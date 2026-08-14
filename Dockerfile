# ------------------------------------------------------------------------------
# GPU-enabled environment for batch_pose_eval.py
# Base image already ships TensorFlow with CUDA/cuDNN wired up correctly,
# so MoveNet gets GPU support without fighting Windows DLL paths.
# ------------------------------------------------------------------------------
FROM tensorflow/tensorflow:2.16.1-gpu

# System libraries OpenCV needs to read/write video (headless box, no X11/display)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Install Python deps. PyTorch is pulled from the CUDA 12.1 wheel index so
# YOLOv8 (ultralytics) also gets GPU support inside this same container.
COPY requirements.txt .
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir -r requirements.txt

# Script + exercise metadata live here; mount your dataset/output dirs at runtime.
COPY batch_pose_eval.py .

ENTRYPOINT ["python", "batch_pose_eval.py"]
