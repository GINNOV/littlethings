# **Guide: Compiling ADFlib on macOS (Apple Silicon & Universal)**

This guide provides step-by-step instructions to compile the ADFlib library from its source code on a macOS system. It covers two primary build targets:

1. **Apple Silicon Native:** Creates a library specifically optimized for M-series Macs (arm64).  
2. **Universal 2 Binary:** Creates a single library that runs natively on both Apple Silicon (arm64) and Intel (x86\_64) Macs.

## **Step 1: Install Prerequisites**

Before you begin, ensure you have the necessary development tools and libraries installed.

### **1\. Install Xcode Command Line Tools**

These tools include the Clang compiler, make, and other essentials. If you haven't installed them, open your Terminal and run:

xcode-select \--install

### **2\. Install Homebrew**

Homebrew is a package manager that simplifies installing software on macOS. If you don't have it, follow the instructions on [brew.sh](https://brew.sh/).

### **3\. Install Required Libraries via Homebrew**

ADFlib requires several tools to generate its build scripts and link against dependencies. Install them using Homebrew:

brew install autoconf automake libtool gettext zlib

* autoconf, automake, libtool, gettext: Needed to run autogen.sh.  
* zlib: A required dependency for ADFlib.

## **Step 2: Get the ADFlib Source Code**

Clone the official ADFlib repository from GitHub to get the latest source code.

git clone \[https://github.com/adflib/ADFlib.git\](https://github.com/adflib/ADFlib.git)  
cd ADFlib

## **Step 3: Generate the configure Script**

The ADFlib repository uses autogen.sh to create the configure script needed for the build process. Run it from the root of the ADFlib directory:

sh autogen.sh

If this command fails, double-check that you have successfully installed autoconf, automake, and libtool in the previous step.

## **Step 4: Configure, Compile, and Install**

Choose one of the following options based on your needs. For most users on an M-series Mac developing for themselves, **Option** A is sufficient. If you plan to distribute your software to others who might be on Intel Macs, choose **Option B**.

It's best practice to perform the build in a separate subdirectory.

mkdir build  
cd build

Now, proceed to one of the options below from *inside* this *build directory*.

### **Option A: Build for Apple Silicon Only (arm64)**

This creates a library optimized specifically for your M1/M2/M3 Mac.

1. Configure the Build:  
   Run the configure script from the parent directory, specifying the architecture and an installation prefix. The \-I and \-L flags tell it where to find Homebrew-installed libraries like zlib.  
   ../configure CFLAGS="-arch arm64 \-I/opt/homebrew/include" \\  
                LDFLAGS="-arch arm64 \-L/opt/homebrew/lib" \\  
                \--prefix=/usr/local/adflib

2. **Compile the Library:**  
   make

   To speed up compilation, you can use multiple processor cores (e.g., make \-j8).  
3. Install the Library:  
   This command copies the compiled files to the directory specified by \--prefix.  
   sudo make install

   This will install the library to /usr/local/adflib/lib and headers to /usr/local/adflib/include/adf.

### **Option B: Build a Universal 2 Binary (arm64 \+ x86\_64)**

This creates a single "fat" library that works on both Apple Silicon and Intel Macs.

1. Configure the Build:  
   The process is nearly identical, but you specify both architectures in the compiler and linker flags.  
   ../configure CFLAGS="-arch arm64 \-arch x86\_64 \-I/opt/homebrew/include" \\  
                LDFLAGS="-arch arm64 \-arch x86\_64 \-L/opt/homebrew/lib" \\  
                \--prefix=/usr/local/adflib\_universal

   *Note:* I've used a different prefix (--prefix=/usr/local/adflib\_universal) to avoid overwriting a single-architecture build if you've already done Option *A. You can use the same prefix if you only intend to have one version installed.*  
2. **Compile the Library:**  
   make

3. **Install the Library:**  
   sudo make install

4. (Optional) Verify the Universal Binary:  
   After installation, you can check that the compiled library contains both architectures using the lipo command:  
   lipo \-info /usr/local/adflib\_universal/lib/libadf.dylib

   The expected output should look like this:  
   Architectures in the fat file: /usr/local/adflib\_universal/lib/libadf.dylib are: x86\_64 arm64

## **Troubleshooting**

* **autogen.sh:** command not **found**: You are not in the root ADFlib directory. cd into it first.  
* **Errors during autogen.sh**: You are likely missing autoconf, automake, or libtool. Re-run the brew install command from Step 1\.  
* **Errors during configure (e.g., "zlib not found")**: Ensure you have run brew install zlib and that the \-I/opt/homebrew/include and \-L/opt/homebrew/lib flags are correct for your Homebrew installation path (it is /opt/homebrew by default on Apple Silicon).  
* **Permission errors during sudo make install**: Make sure you are using sudo. If you still have issues, it could be related to System Integrity Protection (SIP) if you chose a restricted directory for your \--prefix. Using /usr/local/ is standard and should work.