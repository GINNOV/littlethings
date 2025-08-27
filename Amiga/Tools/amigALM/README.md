# Amiga Assembly Fine-Tuning Project

This project provides a complete pipeline for creating a specialized Large Language Model (LLM) fine-tuned for generating Amiga 68k assembly code. The process involves collecting data from GitHub repositories, local files, and PDFs, and then using the Hugging Face ecosystem (`transformers`, `peft`, `trl`) to fine-tune a Gemma 3 model.

---

💡 **Tip:** If you’re reading this on GitHub or a rendered Markdown page, scroll down to the **Final README.md Source Code** block at the bottom of this document. Use the **📋 Copy button** in the top-right corner of that block to copy the entire README source text cleanly (without broken formatting).

---

## Project Structure

-   `pyproject.toml`: Defines all project dependencies and metadata.
-   `src/amiga_lm/`: Contains the main Python scripts.
    -   `prepare_dataset.py`: Collects and processes data.
    -   `train_model.py`: Fine-tunes the model.
    -   `run_eval.py`: Generates code with the fine-tuned model.
    -   `merge_model.py`: Merges the LoRA adapter with the base model (Gemini).
-   `model_settings/repos.csv`: A list of GitHub repositories to scrape for code.
-   `model_settings/prompt1.txt`: The prompt template used for the dataset.
-   `model_settings/fine_params.txt`: Parameters for the train/test split.
-   `model_settings/code_keywords.txt`: Keywords used for extracting code from PDFs.
-   `sources/`: A folder for your local assembly source files.
-   `pdf_docs/`: A folder for your PDF documents.
-   `model_answers/`: The default output folder for generated code.

## 1. Setup & Installation

**Prerequisites:** Python 3.10+ and `uv`.

1.  **Install `uv` (if you don't have it):**
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```

2.  **Create and activate the virtual environment:**
    ```bash
    uv venv
    source .venv/bin/activate
    ```

3.  **Install the project and all dependencies:**
    This command reads the `pyproject.toml` file and installs everything needed.
    ```bash
    uv pip install -e .
    ```

4.  **Log in to Hugging Face:**
    You will need a Hugging Face account and an access token to download the Gemma 3 model. Get a token from `Settings -> Access Tokens` on the HF website.
    ```bash
    huggingface-cli login
    ```

## 2. Configuration

Before preparing the data, you must create and configure the following files in the project's root directory:

-   **`repos.csv`**: Lists the GitHub repos to scrape.
    ```csv
    repo,skip
    https://github.com/user/repo1,0
    https://github.com/user/repo2,1
    ```
-   **`prompt1.txt`**: The template for generating prompts. It must include `{task_name}`.
    ```text
    Generate a functional Amiga assembly subroutine for the task '{task_name}'.
    ```
-   **`fine_params.txt`**: The train/test split parameters.
    ```text
    test_size: 0.1
    seed: 42
    ```
-   **`code_keywords.txt`**: The list of keywords for PDF parsing.
    ```text
    move
    lea
    jsr
    ; Add one keyword per line
    ```
-   Place your local `.s` or `.asm` files inside the `sources/` folder.
-   Place your PDF documents inside the `pdf_docs/` folder.

## 3. Data Preparation

This script collects data from all configured sources and creates a Hugging Face dataset.

```bash
uv run python src/amiga_lm/prepare_dataset.py
```

## 4. Fine-Tuning the Model

This script fine-tunes the Gemma 3 model using the dataset created in the previous step.

```bash
uv run python src/amiga_lm/train_model.py
```

To monitor the process, open a new terminal and run:

```bash
tensorboard --logdir ./amiga_gemma3-270m_finetuned
```

## 5. Inference (Testing the Model)

Generate new Amiga assembly code using your fine-tuned model.

```bash
uv run python src/amiga_lm/run_eval.py
```

The generated `.s` files will be saved in the `model_answers/` directory.

## 6.Conversion for Ollama/LM Studio

Your fine-tuned model is a LoRA adapter. To use it with tools like Ollama or LM Studio, you must merge it and convert it to the GGUF format.

**Step 6a: Merge the Adapter**  
This creates a full, standalone model from your fine-tuned adapter.

```bash
uv run python src/amiga_lm/merge_model.py
```

The merged model will be saved in the `./amiga_gemma3-270m_merged` directory.

**Step 6b: Convert to GGUF format**  
This requires the `llama.cpp` tool.

1.  **Clone and build `llama.cpp` (in a separate directory):**
    The Python conversion script requires binaries that are created during this build process.

    ```bash
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    mkdir build && cd build
    cmake ..
    cmake --build .
    ```

2.  **Run the conversion script:**
    (Run this from the root of the `llama.cpp` directory)

    ```bash
    python convert-hf-to-gguf.py /path/to/your/amiga_gemma3-270m_merged --outtype f16
    ```
The final `.gguf` file can now be loaded into your preferred local LLM tool, such as LM Studio or Jan. When the model is converted, a model card is also generated inside the `amiga_gemma3-270m_finetuned` folder.

## 7. Load in Ollama
**Step 7a:**

	Make it discoverable for Ollama
`ollama create amiga-asm-model -f ./Modelfile`

**Step 7b:**

You can now chat with your specialized model by name:
`ollama run amiga-asm-model`

# Extras
The `utils` folder has useful shortcuts for repetitive tasks.

1. `cleanup.sh` removes all folders created and starts from a clean slate
2. `check_gpu.py` does exactly what it says, particularly good for Apple silicon machines
3. `build_full_model.sh` builds the model, trains it and then runs the evals
4. `build_evals.sh` builds all code present in `model_answers/*.s` and place it inside the build folder
