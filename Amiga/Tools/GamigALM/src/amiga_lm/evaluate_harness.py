import os
import subprocess
import logging
from colorama import Fore, Style, init

init(autoreset=True)
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def run_evaluation():
    logger.info(f"{Fore.CYAN}--- Starting Automated Evaluation Harness ---{Style.RESET_ALL}")
    
    eval_results = []
    output_dir = "model_answers"
    build_dir = os.path.join(output_dir, "build")
    
    if not os.path.isdir(build_dir):
        logger.error(f"{Fore.RED}Error: Build directory '{build_dir}' not found.{Style.RESET_ALL}")
        logger.error("Please run the `build_evals.sh` script first to compile the code.")
        exit(1)
        
    compiled_files = sorted(glob.glob(os.path.join(build_dir, "*.o")))
    if not compiled_files:
        logger.error(f"{Fore.RED}Error: No compiled object files (.o) found in '{build_dir}'.{Style.RESET_ALL}")
        exit(1)
        
    logger.info(f"Found {Fore.GREEN}{len(compiled_files)}{Style.RESET_ALL} compiled files to test.")
    
    # --- Example Test Harness (can be expanded for emulator-based tests) ---
    for compiled_file in compiled_files:
        filename = os.path.basename(compiled_file)
        task_name = filename.replace(".o", "")
        
        # This is a placeholder for a more complex test
        # In a real setup, this would launch an emulator and check its state
        # The return code of vasm itself is a good initial pass/fail
        logger.info(f"Testing {Fore.YELLOW}{task_name}{Style.RESET_ALL}...")
        
        # For now, a successful compilation is a pass.
        # This is where you would integrate logic for checking against expected outputs.
        # The script `build_evals.sh` already handles vasm's return code.
        # This part of the harness would expand to run the compiled code in an emulator.
        
        result = {
            "task": task_name,
            "status": "PASS",
            "notes": "Code compiled successfully with vasm."
        }
        eval_results.append(result)
        logger.info(f"{Fore.GREEN}✅ PASSED: {task_name}{Style.RESET_ALL}")

    logger.info(f"\n{Fore.CYAN}--- Evaluation Summary ---{Style.RESET_ALL}")
    for res in eval_results:
        logger.info(f"Task: {Fore.YELLOW}{res['task']}{Style.RESET_ALL} -> Status: {Fore.GREEN}{res['status']}{Style.RESET_ALL}")

if __name__ == "__main__":
    run_evaluation()