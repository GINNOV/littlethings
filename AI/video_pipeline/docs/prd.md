# Product Requirements Document (PRD)

**Project Name:** Sentinel Video Analysis Pipeline
**Date:** January 2, 2026
**Version:** 1.0
**Target Hardware:** NVIDIA DGX Spark (Server) / Mac Studio M3 (Client)

## 1. Executive Summary

**Sentinel** is a high-performance, scalable video analysis pipeline designed to process terabytes of surveillance footage. It utilizes advanced Vision-Language Models (specifically `qwen2.5vl:7b` via Ollama) to automatically detect scenes and generate detailed textual descriptions of activities. The system provides a web-based dashboard for semantic search ("Show me people running"), review, and data correction.

## 2. Problem Statement

Manual review of surveillance footage is time-consuming and prone to error. Searching for specific events across thousands of hours of video is currently impossible without manual tagging. Existing scripts are fragile, unscalable, and lack state management for large datasets.

## 3. Goals & Success Metrics

* **Scalability:** Process 10+ TB of video data without system crashes.
* **Throughput:** Fully utilize DGX GPU resources to maximize frames processed per second.
* **Searchability:** Allow natural language search (e.g., "red car parking") to return relevant scenes within <1 second.
* **Robustness:** Zero data loss on crashes; automatic resume of interrupted jobs.

## 4. System Architecture

The system follows a **Producer-Consumer** pattern with a persistent state database.

* **Infrastructure:** Dockerized services running on NVIDIA DGX.
* **Database:** PostgreSQL with `pgvector` for storage and vector search.
* **Inference:** Ollama API (local) hosting `qwen2.5vl:7b` (swappable).
* **Orchestrator:** Custom Python worker queue managing `PENDING` -> `PROCESSING` -> `COMPLETED` states.
* **Frontend:** Gradio interface served from DGX, accessed via browser on Mac Studio.

## 5. Functional Requirements

### 5.1. Data Ingestion (The Watcher)

* **FR-01:** System must recursively scan defined directory paths for video files (`.mp4`, `.avi`, `.mkv`).
* **FR-02:** System must detect *new* files added to folders automatically (or via manual trigger).
* **FR-03:** System must generate unique hashes for videos to prevent duplicate processing if files are moved.

### 5.2. Video Processing (The Worker)

* **FR-04:** **Scene Detection:** Automatically split videos into logical scenes based on visual changes (using `PySceneDetect`).
* **FR-05:** **Keyframe Extraction:** Extract representative frames from each scene for AI analysis.
* **FR-06:** **AI Description:** Send frames to `qwen2.5vl` and receive a textual description of the activity.
* **FR-07:** **Embedding Generation:** Convert the generated description into a vector embedding (using `sentence-transformers`) for search.

### 5.3. Search & Review Interface (The Dashboard)

* **FR-08:** **Semantic Search:** A search bar that accepts natural language queries and returns matching video scenes ranked by relevance.
* **FR-09:** **Video Playback:** Clicking a result plays the specific scene (not the whole video) in the browser.
* **FR-10:** **Correction Mode:** Users can manually edit the AI-generated description. Edited descriptions must automatically update the search index (vector).
* **FR-11:** **Filtering:** Filter results by date, video source, or confidence score.

## 6. Non-Functional Requirements

* **NFR-01: Reliability:** If a worker crashes (OOM or power loss), the specific scene returns to `PENDING` state and is retried on reboot.
* **NFR-02: GPU Utilization:** Support running multiple concurrent workers (one per GPU on the DGX) via a `--workers` flag.
* **NFR-03: Modular Models:** The AI model string (`qwen2.5vl`) must be configurable in `.env` without code changes.

## 7. Technical Stack Specification

| Component | Technology | Reasoning |
| --- | --- | --- |
| **Language** | Python 3.10+ (managed by `uv`) | Modern standard, fast dependency resolution. |
| **Database** | **PostgreSQL + pgvector** | Required for concurrent writes (workers) and vector search. |
| **ORM** | **SQLModel** | Best-in-class type safety and ease of use. |
| **AI Runtime** | **Ollama** | Simplifies model management and GPU offloading. |
| **Model** | `qwen2.5-vl:7b` | Excellent balance of speed and visual understanding. |
| **UI Framework** | **Gradio** | Fast iteration for ML interfaces; easy remote access. |
| **Video Tools** | `FFmpeg`, `PySceneDetect` | Industry standards for media manipulation. |

## 8. Development Phases

* **Phase 1: Foundation (Day 1)**
* Setup Docker (Postgres/pgvector).
* Define SQLModel schemas.
* Build Ingestion script (Scanner).


* **Phase 2: The Core Pipeline (Day 2)**
* Build the Worker (Scene Detect -> AI Describe).
* Implement Ollama integration.


* **Phase 3: Search & Interface (Day 3)**
* Implement Vector Search logic.
* Build Gradio Dashboard.


* **Phase 4: Optimization (Day 4)**
* Tuning concurrency (workers).
* Stress testing with TB dataset.
