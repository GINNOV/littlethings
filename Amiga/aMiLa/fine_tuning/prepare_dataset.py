import os
import re
import json
import subprocess
import tempfile
import shutil
from tqdm import tqdm
from dotenv import load_dotenv

# Load API keys and environment variables
load_dotenv()

# Configuration
SOURCES_DIR = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/amiga_sources"
NDK_INCLUDE = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/amiga_sources/amiga-dev/targets/m68k-amigaos/ndk/include_i"
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

def extract_meaningful_description(file_path, code_content):
    """
    Offline/Fallback heuristic: Extracts high-quality instructions from comments at the beginning of the file.
    """
    lines = code_content.split("\n")
    comments = []
    
    # Try to extract the first consecutive block of comments starting with ; or *
    for line in lines[:30]:
        line_strip = line.strip()
        if line_strip.startswith(";") or line_strip.startswith("*"):
            clean_comment = line_strip.lstrip(" ;*-\t")
            if clean_comment and len(clean_comment) > 5:
                comments.append(clean_comment)
        elif line_strip == "" and comments:
            continue
        elif line_strip != "" and not (line_strip.startswith(";") or line_strip.startswith("*")):
            # Stop if we hit actual code, unless we have very few comments
            if len(comments) >= 3:
                break

    base_name = os.path.basename(file_path)
    file_title = os.path.splitext(base_name)[0].replace("_", " ").replace(".", " ").title()

    if comments:
        desc = " ".join(comments)
        # Format cleanly
        return f"Generate Amiga 68k assembly code for: {file_title}. {desc}"
    else:
        # Simple structural extraction (look for labels and XDEFs)
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
        
        prompt = (
            "Analyze this Commodore Amiga Motorola 68000 assembly file and generate a high-quality, "
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
    print(f"Scanning directory: {SOURCES_DIR} for Amiga 68k Assembly sources...")
    
    asm_files = []
    for root, _, files in os.walk(SOURCES_DIR):
        # Ignore virtual env or other hidden directories
        if ".venv" in root or ".git" in root or ".antigravity" in root:
            continue
        for file in files:
            if file.lower().endswith((".s", ".asm")):
                asm_files.append(os.path.join(root, file))

    print(f"Found {len(asm_files)} assembly files. Validating and synthesizing prompts...")
    
    dataset_records = []
    compiled_count = 0
    
    # We want to curate a solid set of working examples
    for file_path in tqdm(asm_files):
        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            # Basic size filtering
            if len(content.strip()) < 50 or len(content) > 100000:
                continue

            # Verify if it compiles with vasm
            compiles, log = verify_code_compiles(content)
            
            # For fine-tuning, compilable code is GOLD
            if compiles:
                compiled_count += 1
                instruction = generate_instruction_with_gemini(content, file_path)
                
                record = {
                    "messages": [
                        {"role": "system", "content": SYSTEM_PROMPT},
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
    print(f"Validated and compiled successfully: {compiled_count} / {len(asm_files)} files.")
    print(f"Dataset generated at: {OUTPUT_FILE}")

if __name__ == "__main__":
    # Clear output file first if it exists
    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)
    
    process_sources()
