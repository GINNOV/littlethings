import os
import re
import json
import subprocess
import tempfile
import shutil
import random
from tqdm import tqdm
from dotenv import load_dotenv

# Load API keys and environment variables
load_dotenv()

# Configuration
SOURCES_DIR = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset"
NDK_INCLUDE = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
NDK_C_INCLUDE_1 = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_h"
NDK_C_INCLUDE_2 = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/include"
VASM_PATH = "/usr/local/bin/vasmm68k_mot"
OUTPUT_FILE = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/dataset.jsonl"

SYSTEM_PROMPT = (
    "You are AntigravityAmiga, an elite Amiga 68000 Motorola assembly programmer. "
    "Your goal is to write highly optimized, clean, and 100% compilable Motorola 68k assembly code "
    "that runs on real Commodore Amiga hardware. You support a hybrid style: both system-friendly "
    "AmigaOS library calls (Exec, Intuition, Graphics via LVOs) and direct custom chip register "
    "programming ($dff000, Copper lists, Blitter operations, custom DMA, custom interrupt routines). "
    "Always ensure your assembly routines are correct, use proper syntax, and restore system state (registers and interrupts) on exit."
)

C_SYSTEM_PROMPT = (
    "You are AntigravityAmiga, an elite Commodore Amiga C programmer. "
    "Your goal is to write highly optimized, clean, and 100% compilable Amiga C code "
    "that runs on real Commodore Amiga hardware. You support standard compiler conventions, "
    "AmigaOS library calls (Intuition, Exec, Graphics, Dos), and direct register interfaces when necessary. "
    "Always ensure your routines check returned pointers, use proper library base registers, "
    "and cleanly release allocated system resources on exit."
)

def verify_code_compiles(code_content):
    """
    Writes the assembly code to a temporary file and attempts to compile it with vasm.
    Returns (bool, str) indicating success and any compiler output/error.
    """
    if not os.path.exists(VASM_PATH):
        return False, "vasm compiler not found at " + VASM_PATH

    with tempfile.NamedTemporaryFile(suffix=".s", delete=False) as temp_file:
        temp_file.write(code_content.encode("utf-8"))
        temp_file_path = temp_file.name

    out_file_path = temp_file_path + ".o"

    # Set up the compile command
    cmd = [
        VASM_PATH,
        "-kick1hunks",
        "-Fhunkexe",
        f"-I{NDK_INCLUDE}",
        "-o", out_file_path,
        "-nosym",
        temp_file_path
    ]

    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=5
        )
        success = (result.returncode == 0)
        output = result.stdout + "\n" + result.stderr
        return success, output.strip()
    except subprocess.TimeoutExpired:
        return False, "Compilation timed out after 5 seconds"
    finally:
        # Cleanup temporary files
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        if os.path.exists(out_file_path):
            os.remove(out_file_path)

def verify_c_code(code_content):
    """
    Writes the C code to a temporary file and checks syntax using clang.
    Returns (bool, str) indicating success and any compiler output/error.
    """
    with tempfile.NamedTemporaryFile(suffix=".c", delete=False) as temp_file:
        temp_file.write(code_content.encode("utf-8"))
        temp_file_path = temp_file.name

    cmd = [
        "clang",
        "-fsyntax-only",
        "-w",  # Suppress warnings for cleaner check
        f"-I{NDK_C_INCLUDE_1}",
        f"-I{NDK_C_INCLUDE_2}",
        temp_file_path
    ]

    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=5
        )
        success = (result.returncode == 0)
        output = result.stdout + "\n" + result.stderr
        return success, output.strip()
    except subprocess.TimeoutExpired:
        return False, "C syntax check timed out after 5 seconds"
    finally:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

def extract_meaningful_description(file_path, code_content):
    """
    Offline/Fallback heuristic: Extracts high-quality instructions from comments at the beginning of the file.
    Supports both assembly (;, *) and C (//, /*, *) comments.
    """
    is_c = file_path.lower().endswith((".c", ".h"))
    lines = code_content.split("\n")
    comments = []
    
    in_block_comment = False
    
    for line in lines[:30]:
        line_strip = line.strip()
        if not line_strip:
            continue
        
        if is_c:
            if line_strip.startswith("/*"):
                in_block_comment = True
                clean_comment = line_strip.lstrip("/*-\t ").rstrip("*/\t ")
                if clean_comment and len(clean_comment) > 5:
                    comments.append(clean_comment)
            elif in_block_comment:
                if "*/" in line_strip:
                    in_block_comment = False
                    clean_comment = line_strip.split("*/")[0].lstrip("*\t ").rstrip("\t ")
                    if clean_comment and len(clean_comment) > 5:
                        comments.append(clean_comment)
                else:
                    clean_comment = line_strip.lstrip("*\t ").rstrip("\t ")
                    if clean_comment and len(clean_comment) > 5:
                        comments.append(clean_comment)
            elif line_strip.startswith("//"):
                clean_comment = line_strip.lstrip("/\t ")
                if clean_comment and len(clean_comment) > 5:
                    comments.append(clean_comment)
            else:
                # Actual C code
                if len(comments) >= 3:
                    break
        else:
            if line_strip.startswith(";") or line_strip.startswith("*"):
                clean_comment = line_strip.lstrip(" ;*-\t")
                if clean_comment and len(clean_comment) > 5:
                    comments.append(clean_comment)
            else:
                # Actual ASM code
                if len(comments) >= 3:
                    break

    base_name = os.path.basename(file_path)
    file_title = os.path.splitext(base_name)[0].replace("_", " ").replace(".", " ").title()

    if comments:
        desc = " ".join(comments)
        if is_c:
            return f"Generate Amiga C code for: {file_title}. {desc}"
        else:
            return f"Generate Amiga 68k assembly code for: {file_title}. {desc}"
    else:
        if is_c:
            funcs = re.findall(r"^\s*\w+\s+\*?\w+\s*\([^)]*\)", code_content, re.MULTILINE)
            func_desc = ""
            if funcs:
                func_names = []
                for f in funcs[:5]:
                    m = re.search(r"(\w+)\s*\(", f)
                    if m:
                        func_names.append(m.group(1))
                if func_names:
                    func_desc = " It includes functions like: " + ", ".join(func_names) + "."
            return f"Write a Commodore Amiga C program for {file_title}.{func_desc} Ensure the code compiles cleanly using the Amiga NDK header files."
        else:
            xdefs = re.findall(r"(?:XDEF|_LVO|^\w+:)", code_content, re.MULTILINE)
            xdef_desc = ""
            if xdefs:
                funcs = [x.strip(" \t:") for x in xdefs[:5] if len(x.strip(" \t:")) > 2]
                if funcs:
                    xdef_desc = " It includes routines or entry points like: " + ", ".join(funcs) + "."
            return f"Write a Motorola 68000 Amiga assembly script for {file_title}.{xdef_desc} Ensure the assembly conforms to Amiga cross-compiling standards."

def generate_instruction_with_gemini(code_content, file_path):
    """
    Frontier model generator: uses Gemini API if GEMINI_API_KEY is active.
    Falls back gracefully to comments extraction if not.
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return extract_meaningful_description(file_path, code_content)

    try:
        from google import genai
        client = genai.Client(api_key=api_key)
        
        is_c = file_path.lower().endswith((".c", ".h"))
        lang_str = "C" if is_c else "Motorola 68000 assembly"
        
        prompt = (
            f"Analyze this Commodore Amiga {lang_str} file and generate a high-quality, "
            "precise user instruction (prompt) that would ask an AI model to generate EXACTLY this code. "
            "Focus on details like register usage, DMA setups, screen resolutions, copper waits, library functions, "
            "and what visual/auditory effect or utility routine this code achieves. Keep the instruction "
            "under 4 sentences.\n\n"
            f"--- Code ({os.path.basename(file_path)}) ---\n"
            f"{code_content[:6000]}"
        )
        
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        return response.text.strip()
    except Exception as e:
        print(f"Gemini API error for {file_path}: {e}. Falling back to header extraction.")
        return extract_meaningful_description(file_path, code_content)

def process_sources():
    print(f"Scanning directory: {SOURCES_DIR} for Amiga sources...")
    
    target_dirs = []
    
    # 1. Include corpus1 and corpus2 entirely if they exist
    for corpus in ["corpus1", "corpus2"]:
        corpus_path = os.path.join(SOURCES_DIR, corpus)
        if os.path.exists(corpus_path):
            target_dirs.append(corpus_path)
            
    # 2. Include specific non-SDK subdirectories of corpus3
    corpus3_path = os.path.join(SOURCES_DIR, "corpus3")
    if os.path.exists(corpus3_path):
        ignore_repos = {
            "amiga-dev", "complete-ndk39", "m68k-amigaos-gcc", "m68k-elf-gcc",
            "clib2", "vasm", "vbcc", "sdl"
        }
        for item in os.listdir(corpus3_path):
            item_path = os.path.join(corpus3_path, item)
            if os.path.isdir(item_path) and item not in ignore_repos:
                target_dirs.append(item_path)
                
    print(f"Walking {len(target_dirs)} source repositories...")
    
    source_files = []
    for target in target_dirs:
        for root, dirs, files in os.walk(target):
            # Modify dirs in-place to prune them from traversal
            dirs[:] = [d for d in dirs if d not in {".venv", ".git", ".antigravity", "amiga-dev", "complete-ndk39", "m68k-amigaos-gcc", "m68k-elf-gcc", "clib2", "vasm", "vbcc", "sdl"}]
            for file in files:
                ext = os.path.splitext(file.lower())[1]
                if ext in (".s", ".asm", ".c", ".h"):
                    source_files.append(os.path.join(root, file))

    random.seed(42)
    random.shuffle(source_files)

    print(f"Found {len(source_files)} source files. Shuffled and starting validation & synthesis...")
    
    dataset_records = []
    compiled_count = 0
    asm_compiled_count = 0
    c_compiled_count = 0
    
    MAX_ASM_EXAMPLES = 100
    MAX_C_EXAMPLES = 100
    
    # We want to curate a solid set of working examples
    for file_path in tqdm(source_files):
        if asm_compiled_count >= MAX_ASM_EXAMPLES and c_compiled_count >= MAX_C_EXAMPLES:
            print("\nReached max caps for both ASM (25) and C (25) compiled examples. Breaking early!")
            break
            
        try:
            is_c = file_path.lower().endswith((".c", ".h"))
            if is_c and c_compiled_count >= MAX_C_EXAMPLES:
                continue
            if not is_c and asm_compiled_count >= MAX_ASM_EXAMPLES:
                continue

            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            # Basic size filtering to prevent huge sequence length OOM and truncation on Apple Silicon
            if len(content.strip()) < 50 or len(content) > 3000:
                continue

            # Verify if it compiles / syntax-checks
            if is_c:
                compiles, log = verify_c_code(content)
                sys_prompt = C_SYSTEM_PROMPT
            else:
                compiles, log = verify_code_compiles(content)
                sys_prompt = SYSTEM_PROMPT
            
            # For fine-tuning, compilable code is GOLD
            if compiles:
                compiled_count += 1
                if is_c:
                    c_compiled_count += 1
                else:
                    asm_compiled_count += 1

                instruction = generate_instruction_with_gemini(content, file_path)
                
                record = {
                    "messages": [
                        {"role": "system", "content": sys_prompt},
                        {"role": "user", "content": instruction},
                        {"role": "assistant", "content": content}
                    ]
                }
                dataset_records.append(record)
                
                # Write progressively so we don't lose data
                with open(OUTPUT_FILE, "a" if os.path.exists(OUTPUT_FILE) else "w", encoding="utf-8") as out:
                    out.write(json.dumps(record) + "\n")
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    print(f"\nProcessing complete!")
    print(f"Validated and compiled successfully: {compiled_count} total (ASM: {asm_compiled_count}, C: {c_compiled_count}).")
    print(f"Dataset generated at: {OUTPUT_FILE}")

if __name__ == "__main__":
    # Clear output file first if it exists
    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)
    
    process_sources()
