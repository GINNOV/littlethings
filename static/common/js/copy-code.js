document.addEventListener('DOMContentLoaded', () => {
    // Syntax colorizer for 68k Assembly
    const colorizeAssembly = (codeEl) => {
        if (!codeEl || codeEl.dataset.colorized) return;
        
        // Skip if already syntax highlighted by Hugo/Chroma or not assembly
        if (codeEl.children.length > 0) return;
        const isAsm = codeEl.classList.contains('language-assembly') || 
                      codeEl.classList.contains('language-asm') ||
                      codeEl.classList.contains('language-s');
        if (!isAsm) return;

        codeEl.dataset.colorized = "true";

        let lines = codeEl.innerText.split('\n');
        let highlightedLines = lines.map(line => {
            // Handle comments
            let commentIndex = line.indexOf(';');
            let codePart = commentIndex !== -1 ? line.substring(0, commentIndex) : line;
            let commentPart = commentIndex !== -1 ? line.substring(commentIndex) : '';

            // Colorize code part
            let escapedCode = codePart
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;');

            // Mnemonics & Directives
            escapedCode = escapedCode.replace(/\b(movem?|moveq|movea|lea|pea|addq?|subq?|cmp[ai]?|clr|neg|not|tst|ext|swap|lsr|lsl|asr|asl|ror|rol|and[i]?|or[i]?|eor[i]?|btst|bset|bclr|bchg|bra|bsr|b[ea-z]{2}|rts|rte|rtr|nop|stop|dbf|dbra|equ|dc\.[wlb]|ds\.[wlb]|incbin)\b/gi, 
                '<span class="code-keyword">$1</span>');

            // Registers
            escapedCode = escapedCode.replace(/\b([da][0-7]|sp|pc|sr|ccr)\b/gi, 
                '<span class="code-register">$1</span>');

            // Hex values & Numbers
            escapedCode = escapedCode.replace(/(\$[0-9a-fA-F]+|#[0-9a-fA-F\$]+|\b[0-9]+\b)/g, 
                '<span class="code-hex">$1</span>');

            if (commentPart) {
                let escapedComment = commentPart
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');
                return escapedCode + `<span class="code-comment">${escapedComment}</span>`;
            }
            return escapedCode;
        });

        codeEl.innerHTML = highlightedLines.join('\n');
    };

    // 1. Add copy buttons and colorize code blocks
    document.querySelectorAll('pre').forEach(pre => {
        let wrapper = pre.parentElement;
        if (!wrapper || !wrapper.classList.contains('code-block-wrapper')) {
            wrapper = document.createElement('div');
            wrapper.className = 'code-block-wrapper';
            pre.parentNode.insertBefore(wrapper, pre);
            wrapper.appendChild(pre);
        }

        if (!wrapper.querySelector('.copy-code-button')) {
            const button = document.createElement('button');
            button.className = 'copy-code-button';
            button.innerHTML = '<i class="far fa-copy"></i> Copy';
            wrapper.insertBefore(button, pre);
        }

        const codeEl = pre.querySelector('code');
        if (codeEl) {
            colorizeAssembly(codeEl);
        }
    });

    // 2. Attach click listeners to all copy-code buttons
    document.querySelectorAll('.copy-code-button').forEach(button => {
        button.addEventListener('click', () => {
            const wrapper = button.closest('.code-block-wrapper');
            const pre = wrapper ? wrapper.querySelector('pre') : button.nextElementSibling;
            if (pre) {
                const code = pre.querySelector('code');
                const text = code ? code.innerText : pre.innerText;
                
                navigator.clipboard.writeText(text).then(() => {
                    const originalText = button.innerHTML;
                    button.innerHTML = '<i class="fas fa-check"></i> Copied!';
                    setTimeout(() => {
                        button.innerHTML = originalText;
                    }, 2000);
                }).catch(err => {
                    console.error('Failed to copy text: ', err);
                });
            }
        });
    });
});
