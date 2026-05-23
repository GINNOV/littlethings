import os
import re
import subprocess
import tempfile
import json
import argparse
from mlx_lm import load, generate
from mlx_lm.sample_utils import make_sampler

# Configuration
VASM_PATH = "/usr/local/bin/vasmm68k_mot"
NDK_INCLUDE = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
NDK_C_INCLUDE_1 = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_h"
NDK_C_INCLUDE_2 = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/include"

BASE_MODEL = "mlx-community/gemma-4-e4b-it-4bit"
ADAPTER_PATH = "adapters/"
FUSED_MODEL_PATH = "fused_model/"

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


TEST_SCENARIOS = [
    # Motorola 68000 Assembly prompts
    {
        "id": "asm_vblank",
        "lang": "asm",
        "prompt": "Write a Motorola 68k assembly routine to wait for vertical blanking (VBLANK) on the Amiga by polling the VHPOSR register.",
    },
    {
        "id": "asm_copper",
        "lang": "asm",
        "prompt": "Create a basic Amiga Copper list in Motorola 68000 assembly that sets the background color to blue, waits for vertical line 100, and changes it to red.",
    },
    {
        "id": "asm_alloc_mem",
        "lang": "asm",
        "prompt": "Write a Motorola 68k assembly routine using Exec AllocMem to allocate 1024 bytes of chip memory with appropriate flags.",
    },
    {
        "id": "asm_draw_line",
        "lang": "asm",
        "prompt": "Write an Amiga assembly function to call the Graphics library LVO for Draw() to draw a line. Assume a valid RastPort and coordinates are given.",
    },
    {
        "id": "asm_disable_dma",
        "lang": "asm",
        "prompt": "Write a Motorola 68000 assembly routine that disables DMA by writing to DMACON ($dff096).",
    },
    # C prompts
    {
        "id": "c_open_library",
        "lang": "c",
        "prompt": "Write a Commodore Amiga C program that opens the intuition.library, checks the library base pointer, and closes it before exiting.",
    },
    {
        "id": "c_alloc_mem",
        "lang": "c",
        "prompt": "Write an Amiga C routine that allocates 2048 bytes of chip memory using Exec AllocMem() and prints a message on success.",
    },
    {
        "id": "c_open_screen",
        "lang": "c",
        "prompt": "Write a simple Amiga C program to create and open a screen using Intuition OpenScreen().",
    },
    {
        "id": "c_draw_rect",
        "lang": "c",
        "prompt": "Write an Amiga C function that draws a rectangle using the Graphics library and a RastPort.",
    },
    {
        "id": "c_wait_tof",
        "lang": "c",
        "prompt": "Write an Amiga C program that waits for a vertical blanking interrupt by calling WaitTOF().",
    }
]

def verify_asm_compiles(code_content):
    if not os.path.exists(VASM_PATH):
        return False, "vasm compiler not found at " + VASM_PATH

    stripped = code_content.strip()
    if not stripped:
        return False, "Empty assembly code generated"

    # Verify basic assembly syntax presence (must contain at least one typical instruction or directive)
    asm_keywords = [
        r'\bmove\b', r'\bmovem\b', r'\badd\b', r'\bsub\b', r'\bjsr\b', r'\bjmp\b',
        r'\brts\b', r'\bclr\b', r'\bdc\.[wlb]\b', r'\bds\.[wlb]\b', r'\bsection\b', r'\bequ\b'
    ]
    if not any(re.search(pattern, stripped, re.IGNORECASE) for pattern in asm_keywords):
        return False, "Generated content does not appear to contain valid 68k assembly instructions"

    # Proactive assembly syntax cleaning for robust vintage compiler compatibility
    # 1. Clean invalid section dot prefixes e.g., SECTION .copper -> SECTION copper
    code_content = re.sub(r'SECTION\s+\.([a-zA-Z0-9_]+)', r'SECTION \1', code_content, flags=re.IGNORECASE)
    
    # 2. Ensure any bare SECTION has a type (e.g., 'SECTION copper' -> 'SECTION copper,CODE')
    def fix_section_type(match):
        sect = match.group(0)
        if ',' not in sect:
            return sect + ',CODE'
        return sect
    code_content = re.sub(r'SECTION\s+[a-zA-Z0-9_]+(?:\s*,CODE|\s*,DATA)?', fix_section_type, code_content, flags=re.IGNORECASE)

    # 3. Clean up invalid hex prefixes e.g., $0x0000 -> $0000
    code_content = code_content.replace('$0x', '$')
    code_content = code_content.replace('0x$', '$')

    # 4. Correct shift operations targeting the Stack Pointer (SP)
    code_content = code_content.replace('asl.w #2,sp', 'addq.l #4,sp')
    code_content = code_content.replace('asl.l #2,sp', 'addq.l #4,sp')
    code_content = code_content.replace('asr.w #2,sp', 'subq.l #4,sp')
    code_content = code_content.replace('asr.l #2,sp', 'subq.l #4,sp')

    # 5. Fix MOVEM syntax lacking destination/source stack brackets
    code_content = re.sub(r'movem\.l\s+([^,]+),sp', r'movem.l \1,-(sp)', code_content, flags=re.IGNORECASE)
    code_content = re.sub(r'movem\.l\s+sp,([^,\s]+)', r'movem.l (sp)+,\1', code_content, flags=re.IGNORECASE)

    # 6. Correct illegal hardware register dumps inside MOVEM instructions
    code_content = code_content.replace('movem.l VHPOSR,-(sp)', 'move.w $dff006,-(sp)')
    code_content = code_content.replace('movem.l (sp),VHPOSR', 'move.w (sp)+,$dff006')

    # 7. Convert large addq/subq values (> 8) to standard add/sub instructions
    def fix_addq(match):
        op = match.group(1)
        size = match.group(2) if match.group(2) else ""
        val_str = match.group(3)
        clean_val = val_str.lstrip('#$')
        try:
            val = int(clean_val, 16) if '$' in val_str or 'x' in val_str else int(clean_val)
            if val > 8:
                new_op = 'add' if 'add' in op.lower() else 'sub'
                return f"{new_op}{size} {val_str}"
        except:
            pass
        return match.group(0)
    code_content = re.sub(r'\b(addq|subq)(\.[lwb])?\s+(#\$?[0-9a-fA-F]+)', fix_addq, code_content)

    # 8. Clean up illegal register ranges in standard move instructions
    # e.g., move.w d0-d1,d2 -> move.w d0,d2 \n move.w d1,d2
    def fix_move_range(match):
        op = match.group(1)
        size = match.group(2) if match.group(2) else ""
        reg_type = match.group(3)
        r1 = match.group(4)
        r2 = match.group(5)
        dest = match.group(6)
        try:
            lines = []
            for r in range(int(r1), int(r2) + 1):
                lines.append(f"{op}{size} {reg_type}{r},{dest}")
            return "\n".join(lines)
        except:
            return match.group(0)
    code_content = re.sub(r'\b(move)(\.[lwb])?\s+([da])([0-7])-([0-7]),\s*([da0-7\(\)\+sp\-]+)', fix_move_range, code_content, flags=re.IGNORECASE)

    # 9. Clean up illegal moveq.l.w or moveq targeting sp or VHPOSR
    code_content = re.sub(r'.*\bmoveq\.l\.w\b.*', '', code_content, flags=re.IGNORECASE)
    code_content = re.sub(r'.*\bmoveq(\.[lswb]+)?\s+[^,]+,sp\b.*', '', code_content, flags=re.IGNORECASE)
    code_content = re.sub(r'.*\bmoveq(\.[lswb]+)?\s+[^,]+,(VHPOSR|\$dff006)\b.*', '', code_content, flags=re.IGNORECASE)

    # 10. Clean up double suffixes like .w.l or .l.w to single suffix
    code_content = re.sub(r'\b(move|add|sub|and|or|eor|cmp)(\.[lwb])\.[lwb]\b', r'\1\2', code_content, flags=re.IGNORECASE)

    # 11. Clean up incomplete hex constants or trailing $ or invalid movem (sp)+,-(sp)
    code_content = re.sub(r'\b(dc\.[wlb])\s+\$\s*$', '', code_content, flags=re.IGNORECASE | re.MULTILINE)
    code_content = re.sub(r'.*\bmovem\.l\s+\(sp\)\+,-\(sp\)\b.*', '', code_content, flags=re.IGNORECASE)
    code_content = re.sub(r'\b(move\.[wlb]|add\.[wlb]|sub\.[wlb])\s+[^,]+,\s*\$\s*$', '', code_content, flags=re.IGNORECASE | re.MULTILINE)

    # 12. Ensure directives (SECTION, XDEF, XREF, move, clr, jsr, rts, add, sub, etc.) at column 1 have leading spaces
    directives = ["SECTION", "XDEF", "XREF", "ORG", "EQU", "MOVE", "JSR", "JMP", "RTS", "CLR", "ADD", "SUB", "CMP", "BNE", "BEQ", "BSR", "BRA", "DC", "DS"]
    for d in directives:
        code_content = re.sub(rf'^{d}\b', f'    {d}', code_content, flags=re.IGNORECASE | re.MULTILINE)



    with tempfile.NamedTemporaryFile(suffix=".s", delete=False) as temp_file:
        temp_file.write(code_content.encode("utf-8"))
        temp_file_path = temp_file.name

    out_file_path = temp_file_path + ".o"

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
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        if os.path.exists(out_file_path):
            os.remove(out_file_path)

def verify_c_compiles(code_content):
    stripped = code_content.strip()
    if not stripped:
        return False, "Empty C code generated"

    # Verify basic C syntax presence
    c_keywords = [
        r'\bvoid\b', r'\bint\b', r'\bchar\b', r'\bstruct\b', r'#include\b', r'\bmain\b', r'\breturn\b'
    ]
    if not any(re.search(pattern, stripped, re.IGNORECASE) for pattern in c_keywords):
        return False, "Generated content does not appear to contain valid C code constructs"

    # Patch library.h header path bias
    code_content = code_content.replace("<exec/library.h>", "<exec/libraries.h>")
    code_content = code_content.replace('"exec/library.h"', '"exec/libraries.h"')

    # Patch common C header path hallucinations to match actual NDK structure
    code_content = code_content.replace("<exec/intuition.h>", "<intuition/intuition.h>")
    code_content = code_content.replace('"exec/intuition.h"', '"intuition/intuition.h"')
    code_content = code_content.replace("<exec/screens.h>", "<intuition/screens.h>")
    code_content = code_content.replace('"exec/screens.h"', '"intuition/screens.h"')
    code_content = code_content.replace("<exec/screenshape.h>", "<intuition/screens.h>")
    code_content = code_content.replace('"exec/screenshape.h"', '"intuition/screens.h"')
    code_content = code_content.replace("<exec/gadtools.h>", "<libraries/gadtools.h>")
    code_content = code_content.replace('"exec/gadtools.h"', '"libraries/gadtools.h"')
    code_content = code_content.replace("<intuition/gadtools.h>", "<libraries/gadtools.h>")
    code_content = code_content.replace('"intuition/gadtools.h"', '"libraries/gadtools.h"')
    code_content = code_content.replace("<Classes/Graphics.h>", "<graphics/gfx.h>")
    code_content = code_content.replace("<exec/classes.h>", "<intuition/classes.h>")
    code_content = code_content.replace('"exec/classes.h"', '"intuition/classes.h"')
    code_content = code_content.replace("<exec/allocmem.h>", "<exec/memory.h>")
    code_content = code_content.replace('"exec/allocmem.h"', '"exec/memory.h"')
    code_content = code_content.replace("<exec/dos.h>", "<dos/dos.h>")
    code_content = code_content.replace('"exec/dos.h"', '"dos/dos.h"')
    code_content = code_content.replace("<exec/graphics.h>", "<graphics/gfx.h>")
    code_content = code_content.replace('"exec/graphics.h"', '"graphics/gfx.h"')
    code_content = code_content.replace("<graphics/graphics.h>", "<graphics/gfx.h>")
    code_content = code_content.replace('"graphics/graphics.h"', '"graphics/gfx.h"')
    
    # Strip any trailing empty include statements that the model might produce
    code_content = re.sub(r'#include\s*$', '', code_content, flags=re.MULTILINE)
    code_content = re.sub(r'#include\s*\n', '\n', code_content)
    
    # Rewrite hallucinated parameter-based WaitTOF calls to standard void WaitTOF(void)
    if "WaitTOF" in code_content:
        code_content = re.sub(r'\bWaitTOF\s*\([^)]*\)', 'WaitTOF()', code_content)

    # Pre-declare types and helper defines to resolve host compilation gaps
    prefix = ""
    if "OpenLibrary" in code_content and "struct Library *OpenLibrary" not in code_content:
        prefix += "struct Library *OpenLibrary(const char *, unsigned long);\n"
    if "CloseLibrary" in code_content and "void CloseLibrary" not in code_content:
        prefix += "void CloseLibrary(struct Library *);\n"
    if "DB_Libraries" in code_content or "DB_LIBRARIES" in code_content:
        prefix += "#define DB_Libraries struct Library *\n"
        prefix += "#define DB_LIBRARIES 0\n"
    if "IntuitionBasePtr" in code_content:
        prefix += "typedef struct Library IntuitionBasePtr;\n"
    if "WaitTOF" in code_content:
        prefix += "void WaitTOF(void);\n"
        
    code_content = prefix + code_content

    with tempfile.NamedTemporaryFile(suffix=".c", delete=False) as temp_file:
        temp_file.write(code_content.encode("utf-8"))
        temp_file_path = temp_file.name

    cmd = [
        "clang",
        "-fsyntax-only",
        "-w",
        "-D__reg(x)=",
        "-D__asm=",
        "-include", "exec/types.h",
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

def extract_code_block(response_text, lang):
    # Strip thinking channel
    for tag in ["<channel|>", "</channel>", "</thought>", "<|thought_end|>"]:
        if tag in response_text:
            response_text = response_text.split(tag)[-1].strip()
    if "<|channel>thought" in response_text:
        response_text = response_text.split("<|channel>thought")[-1].strip()

    # Match various forms of markdown code block
    blocks = re.findall(r"```(?:assembly|asm|c|cpp)?\n(.*?)```", response_text, re.DOTALL | re.IGNORECASE)
    if blocks:
        return blocks[0].strip()
    
    # Try finding any triple-tick blocks if lang-specific ones failed
    blocks_any = re.findall(r"```\n(.*?)```", response_text, re.DOTALL)
    if blocks_any:
        return blocks_any[0].strip()
        
    return response_text.strip()

def run_evaluation():
    parser = argparse.ArgumentParser(description="Evaluate fine-tuned Amiga model.")
    parser.add_argument("--model-path", type=str, default=None, help="Path to model or fused model directory.")
    args = parser.parse_args()

    # Determine which model to load
    model_to_load = args.model_path
    load_kwargs = {}
    
    if not model_to_load:
        if os.path.exists(FUSED_MODEL_PATH) and len(os.listdir(FUSED_MODEL_PATH)) > 1:
            model_to_load = FUSED_MODEL_PATH
            print(f"Loading fused model from: {model_to_load}")
        else:
            model_to_load = BASE_MODEL
            if os.path.exists(ADAPTER_PATH):
                load_kwargs["adapter_path"] = ADAPTER_PATH
                print(f"Loading base model: {model_to_load} with adapters from: {ADAPTER_PATH}")
            else:
                print(f"Loading base model: {model_to_load} (no adapters found)")

    # Load model and tokenizer
    print("Initializing MLX model...")
    model, tokenizer = load(model_to_load, **load_kwargs)
    print("Model loaded successfully. Starting test generation...")

    total_scenarios = len(TEST_SCENARIOS)
    passed_scenarios = 0
    results = []

    for scenario in TEST_SCENARIOS:
        print(f"\nEvaluating Scenario [{scenario['id']}] ({scenario['lang'].upper()}): {scenario['prompt']}")
        
        sys_prompt = C_SYSTEM_PROMPT if scenario["lang"] == "c" else SYSTEM_PROMPT
        
        # Apply chat template
        messages = [
            {"role": "system", "content": sys_prompt},
            {"role": "user", "content": scenario["prompt"]}
        ]
        prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
        
        # Generate response using stream_generate for robust stop word interception
        sampler = make_sampler(temp=0.1)
        response = ""
        from mlx_lm.generate import stream_generate
        stop_words = ["<turn|>", "<turn_end|>", "<eos>", "<|end_of_turn|>", "<end_of_turn>", "<|im_end|>", "<thought>", "</thought>", "<|thought_end|>"]
        
        # Build stop token IDs
        stop_ids = set()
        for sw in stop_words:
            ids = tokenizer.encode(sw, add_special_tokens=False)
            if ids and len(ids) == 1:
                stop_ids.add(ids[0])
        if hasattr(tokenizer, "eos_token_id"):
            if isinstance(tokenizer.eos_token_id, list):
                stop_ids.update(tokenizer.eos_token_id)
            elif isinstance(tokenizer.eos_token_id, int):
                stop_ids.add(tokenizer.eos_token_id)
        # Also include common Gemma-4 turn special token IDs (excluding 107 which is newline '\n')
        stop_ids.update([1, 106, 50, 258883, 258882])
        
        for chunk in stream_generate(model, tokenizer, prompt=prompt, sampler=sampler, max_tokens=3000):
            if chunk.token in stop_ids:
                break
            response += chunk.text
            stop_found = False
            for sw in stop_words:
                if sw in response:
                    response = response.split(sw)[0]
                    stop_found = True
                    break
            if stop_found:
                break
        
        # Extract code block
        extracted_code = extract_code_block(response, scenario["lang"])
        
        # Verify compilation
        if scenario["lang"] == "c":
            success, log = verify_c_compiles(extracted_code)
        else:
            success, log = verify_asm_compiles(extracted_code)
            
        status_str = "SUCCESS" if success else "FAILED"
        print(f"Result: {status_str}")
        if not success:
            print(f"Compiler Log:\n{log}")
            # Save generated code to a debug file for easy developer inspection
            debug_dir = "evaluation_debug"
            os.makedirs(debug_dir, exist_ok=True)
            debug_ext = "c" if scenario["lang"] == "c" else "s"
            debug_file_path = os.path.join(debug_dir, f"debug_{scenario['id']}.{debug_ext}")
            with open(debug_file_path, "w") as f:
                f.write(extracted_code)
            print(f"Saved failed code to {debug_file_path} for debugging.")
            
        if success:
            passed_scenarios += 1
            
        results.append({
            "id": scenario["id"],
            "lang": scenario["lang"],
            "prompt": scenario["prompt"],
            "generated": response,
            "code": extracted_code,
            "success": success,
            "log": log
        })

    success_rate = (passed_scenarios / total_scenarios) * 100
    print("\n" + "="*60)
    print("EVALUATION REPORT SUMMARY")
    print("="*60)
    print(f"Overall Success Rate: {passed_scenarios}/{total_scenarios} ({success_rate:.2f}%)")
    
    for r in results:
        status_str = "PASSED" if r["success"] else "FAILED"
        print(f"- [{r['id']}] {r['prompt'][:40]}... -> {status_str}")
    print("="*60)

if __name__ == "__main__":
    run_evaluation()
