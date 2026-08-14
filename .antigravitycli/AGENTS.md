# AI Agent & Developer Automation Guidelines

This document provides technical instructions, structural assumptions, and domain-specific heuristics for AI Agents and automated scripts processing the UCO Physical Rehabilitation dataset.

---

## 1. Context & Domain Knowledge

[cite_start]This repository contains data from a clinical computer vision study focused on **Human Pose Estimation (HPE) for physical rehabilitation**
* [cite_start]**Target Application:** The core task is to evaluate and extract kinematic metrics—specifically the **flexion angles** of target limbs—from video frames to assess patient mobility
* [cite_start]**Ground Truth Source:** Exact 3D joint positions were captured using an infrared **OptiTrack motion capture system** (spatial accuracy of $\pm0.5$ mm) and projected to generate 2D ground truth coordinates
* [cite_start]**Biomechanical Scope:** The data targets lower-body segments (hip, knee, ankle) and upper-body segments (shoulder, elbow, wrist)
---

## 2. Anatomical Joint Ordering (Heuristics)

[cite_start]When parsing tracking files (`cam<N>_p2d.txt` and `p3d.txt`) or JSON summaries, agents must expect a strict, pre-processed row/array mapping to prevent joint misidentification

* **Upper Body Exercises (IDs 09–16):**
  * [cite_start]Index `0`: **Shoulder** [cite: 145]
  * [cite_start]Index `1`: **Elbow** [cite: 145]
  * [cite_start]Index `2`: **Wrist** [cite: 145]
* **Lower Body Exercises (IDs 01–08):**
  * [cite_start]Index `0`: **Hip** [cite: 146]
  * [cite_start]Index `1`: **Knee** [cite: 146]
  * [cite_start]Index `2`: **Ankle** [cite: 146]

> [cite_start]⚠️ **Missing Data Handling:** Some frames may contain manual 2D annotations where OptiTrack suffered from occlusion[cite: 147]. [cite_start]These frames **do not** possess valid 3D ground truth coordinates in `p3d.txt` and must be skipped or flagged during 3D evaluation[cite: 149].

---

## 3. Kinematic Angle Calculation

[cite_start]To automate rehabilitation metrics extraction (e.g., knee flexion), agents should compute the angle $\alpha$ formed by vector segments $\vec{BA}$ and $\vec{BC}$ (where $B$ is the intermediate joint, such as the knee) using the dot product formula[cite: 84, 318, 319]:

$$\alpha = \arccos\left(\frac{\vec{BA} \cdot \vec{BC}}{|\vec{BA}| \cdot |\vec{BC}|}\right)$$

[cite_start]When benchmarking automated predictions against the dataset's ground truth, evaluate performance using **Mean Absolute Error (MAE)**[cite: 317, 327]:

$$MAE = \frac{1}{N}\sum_{i=1}^{N}|\alpha_{\text{pred}, i} - \alpha_{\text{gt}, i}|$$

---

## 4. Operational Heuristics for AI Models

Agents developing or executing evaluation pipelines must respect the following paper-proven constraints:

### A. The Supine Position Challenge (90° Rotation Hack)
[cite_start]Standard HPE models (trained on general in-the-wild datasets) tend to fail dramatically when a patient is in a **supine position** (lying flat on a treatment couch, Exercises 03, 04, 07, 08)[cite: 66, 110, 111, 269].
* [cite_start]**Action:** To drastically lower coordinate and angle error, pipeline scripts must **rotate the input video frames by 90°** (clockwise or counter-clockwise) before feeding them into the 2D keypoint detector to simulate a typical upright stance[cite: 67, 270].

### B. Camera Viewpoint Bias
* [cite_start]**Cam 1 (Top-center, frontal)** and **Cam 0 (Low-center, frontal)** yield the lowest Mean Absolute Error due to minimal perspective distortion relative to the standard plane of motion[cite: 464, 484].
* [cite_start]**Cam 3** and **Cam 4** capture steep/side profiles, resulting in higher projection artifacts[cite: 485]. [cite_start]Evaluation logic should weight or prioritize frontal views for baseline comparisons[cite: 36, 554].

### C. Architecture Specifics
* [cite_start]For desktop/server processing pipelines: Use **AlphaPose** for optimal 2D stability in distorted views, or **HybrIK** for deep 3D joint mesh regression[cite: 552, 602].
* [cite_start]For lightweight, real-time cross-platform agents (Android/iOS/JS): Default to **MediaPipe** (BlazePose) due to its production readiness and steady throughput (~66 FPS)[cite: 168, 601, 648].

---

## 5. Normalization Requirements

[cite_start]To make coordinate distance comparisons scale-invariant and independent of camera proximity or resolution, agents must normalize pixel Euclidean distances[cite: 342]:
1. [cite_start]Find the projected pixel length of the **treatment couch** within the video clip[cite: 338, 354].
2. [cite_start]Divide computed pixel errors by this reference couch length[cite: 338, 354]. [cite_start]An error metric of `1.0` signifies a displacement equal to the length of the couch itself[cite: 354].