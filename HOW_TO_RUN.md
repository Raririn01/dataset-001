# How to Run the Pose Estimation Comparison Code

เอกสารนี้ใช้ส่งต่อให้ผู้ที่ต้องการรันโค้ดซ้ำ เพื่อประเมินโมเดล YOLOv8, MoveNet และ MediaPipe เทียบกับ ground truth ของชุดข้อมูล UCO Physical Rehabilitation

## ไฟล์โค้ดหลักที่ใช้

- `batch_pose_eval.py`  
  ไฟล์หลักสำหรับรันประเมินวิดีโอหลายไฟล์แบบ batch และสร้างผลลัพธ์ใน `output_comparison_results/`

- `run_comparison_pipeline.py`  
  ไฟล์เสริมสำหรับรันวิดีโอเดียว ใช้ทดสอบ pipeline หรือ demo แบบเร็ว

- `rebuild_summary.py`  
  ใช้สร้าง `batch_evaluation_summary.csv` ใหม่จากไฟล์ report รายวิดีโอที่มีอยู่แล้ว โดยไม่ต้องรันโมเดลใหม่

- `model_performance_summary.py`  
  ใช้สรุป performance จาก `output_comparison_results/batch_evaluation_summary.csv`

- `eda_analysis.py`  
  ใช้ทำ exploratory data analysis ของผลลัพธ์/dataset

## โครงสร้างข้อมูลที่ต้องมี

โฟลเดอร์ input หลัก:

```text
clips_mp4/0/
├── 01/
│   ├── cam0.mp4
│   ├── cam0_p2d.txt
│   ├── cam1.mp4
│   └── cam1_p2d.txt
├── 02/
│   └── ...
└── 15/
    └── ...
```

แต่ละวิดีโอ `camX.mp4` ต้องมี ground truth คู่กันชื่อ `camX_p2d.txt`

## โมเดลที่ต้องมี

ค่า default ในโค้ดอ้างถึง path ต่อไปนี้:

```text
c:\Homework\LAB\YOLO\yolov8n-pose.pt
C:\Users\LOQ\AppData\Local\Temp\tfhub_modules\f729a5f3231391676ca61cc7ab789993549d8bca
c:\Homework\LAB\Medie\pose_landmarker_heavy.task
```

ถ้าเครื่องอื่นเก็บโมเดลไว้คนละที่ ให้ส่ง path ใหม่ผ่าน argument ตอนรัน เช่น `--yolo-model`, `--movenet-model`, `--mediapipe-model`

## ติดตั้ง environment

แนะนำใช้ Python 3.11

### Windows PowerShell

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

ถ้า PowerShell ไม่ให้ activate environment ให้รัน:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

## รันแบบ batch ทั้ง dataset

คำสั่งหลัก:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results
```

ผลลัพธ์จะถูกสร้างใน:

```text
output_comparison_results/
```

## รันแบบเร็วเพื่อทดสอบก่อน

จำกัดจำนวนเฟรมต่อวิดีโอ เช่น 30 เฟรมแรก:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results_test --limit-frames 30
```

ไม่สร้างวิดีโอ annotated เพื่อลดเวลาและขนาดไฟล์:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results_test --limit-frames 30 --no-videos
```

ไม่สร้างกราฟรายวิดีโอ:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results_test --limit-frames 30 --no-plots
```

## เลือก CPU หรือ GPU

บังคับใช้ CPU:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results --device cpu
```

บังคับใช้ GPU:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results --device gpu
```

ถ้าไม่ใส่ `--device` โค้ดจะตรวจจับให้เอง

## การ rotate วิดีโอท่า Supine

ค่า default จะ rotate exercise ID `3,4,7,8` ก่อน inference เพราะเป็นท่าที่นอนอยู่

กำหนดเอง:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results --rotate-ids 3,4,7,8
```

ปิด rotation ทั้งหมดเพื่อ A/B test:

```powershell
python batch_pose_eval.py --dir clips_mp4/0 --output-dir output_comparison_results_no_rotate --rotate-ids ""
```

## รันวิดีโอเดียว

ใช้ `run_comparison_pipeline.py` เมื่อต้องการทดสอบวิดีโอเดียว:

```powershell
python run_comparison_pipeline.py --video clips_mp4/0/01/cam1.mp4 --gt clips_mp4/0/01/cam1_p2d.txt --output-video output_pose_comparison.mp4 --output-csv comparison_report_all.csv
```

ถ้าโมเดลอยู่คนละ path:

```powershell
python run_comparison_pipeline.py --video clips_mp4/0/01/cam1.mp4 --gt clips_mp4/0/01/cam1_p2d.txt --yolo-model "PATH\TO\yolov8n-pose.pt" --movenet-model "PATH\TO\movenet_model_folder" --mediapipe-model "PATH\TO\pose_landmarker_heavy.task"
```

## สร้าง summary ใหม่โดยไม่รันโมเดลซ้ำ

ใช้เมื่อมีไฟล์ `camX_report.csv` อยู่แล้วใน `output_comparison_results/`

```powershell
python rebuild_summary.py
```

## ผลลัพธ์ที่ได้

ใน `output_comparison_results/` จะมี:

- `batch_evaluation_summary.csv`  
  ตารางสรุป metric ของทุกวิดีโอ

- `batch_comparison_report.md`  
  รายงานสรุปแบบอ่านง่าย

- `global_model_comparison.png`  
  กราฟเปรียบเทียบภาพรวมของ YOLOv8, MoveNet และ MediaPipe

- `<exercise>/camX_report.csv`  
  ผล metric รายเฟรมของแต่ละวิดีโอ

- `<exercise>/camX_report.md`  
  สรุปผลรายวิดีโอแบบ Markdown

- `<exercise>/camX_angle_trajectory.png`  
  กราฟมุมข้อต่อเทียบกับ ground truth

- `<exercise>/camX_spatial_error.png`  
  กราฟ error ของตำแหน่งข้อต่อ

- `<exercise>/camX_annotated.mp4`  
  วิดีโอที่ overlay skeleton และมุมข้อต่อ ใช้ตรวจสอบด้วยสายตาหรือทำ demo

## ไฟล์ที่ควรส่งให้คนอื่นถ้าต้องการรันซ้ำ

อย่างน้อยควรส่ง:

```text
batch_pose_eval.py
run_comparison_pipeline.py
rebuild_summary.py
model_performance_summary.py
eda_analysis.py
requirements.txt
clips_mp4/
```

และต้องมีไฟล์โมเดล 3 ส่วน:

```text
yolov8n-pose.pt
MoveNet model folder หรือให้โค้ดดาวน์โหลดผ่าน tensorflow_hub
pose_landmarker_heavy.task
```

ถ้าจะส่งผลลัพธ์ที่รันไว้แล้ว ให้ส่ง:

```text
output_comparison_results/
```
