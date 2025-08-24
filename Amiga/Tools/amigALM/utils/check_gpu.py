import torch

if torch.backends.mps.is_available():
    device = torch.device("mps")
    print(f"✅ Success! Apple Silicon MPS backend is available.")
    print(f"PyTorch will use this device for acceleration: {device}")
    
    # Optional: create a tensor on the MPS device
    x = torch.tensor([1.0, 2.0, 3.0], device=device)
    print("\nSuccessfully created a tensor on the MPS device:")
    print(x)

else:
    print("❌ Warning: MPS backend not found.")
    print("Please ensure you have installed the correct version of PyTorch for Apple Silicon.")