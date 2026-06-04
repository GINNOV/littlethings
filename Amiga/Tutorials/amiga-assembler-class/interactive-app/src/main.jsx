import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  ArrowLeft,
  ArrowRight,
  BookOpen,
  Check,
  Cpu,
  Play,
  RefreshCcw,
  RotateCcw,
  TerminalSquare,
  Zap
} from "lucide-react";
import "./styles.css";

const lessons = [
  {
    id: "why-assembly",
    title: "1. What is assembly, and why 68000?",
    subtitle: "Build the mental model",
    tag: "Theory",
    goal: "Understand that assembly is direct instruction-by-instruction programming of the CPU.",
    theory: [
      "In Swift, you describe intent and the compiler translates it into machine instructions. In assembly, you write that translation yourself.",
      "Every line maps closely to one CPU action: move a value, add, compare, jump, or call a routine.",
      "The Motorola 68000 is a friendly first CPU because its instruction set is regular, readable, and close to the Amiga hardware story."
    ],
    analogy: "Think of Swift as asking `array.sort()` to solve a problem. Assembly is writing every comparison and swap yourself, including where the temporary values live.",
    keyIdea: "Computation happens inside CPU registers first. Memory is where data waits. The custom chips respond when you write to their hardware addresses.",
    code: `; Lesson 1: the smallest useful program
moveq #0,d0
rts`,
    quiz: {
      question: "In the 68000, where does computation actually happen first?",
      options: ["System memory only", "Registers", "The Copper chip", "The stack"],
      answer: 1,
      feedback: "Yes. The CPU mostly computes in registers, then stores results back to memory or hardware addresses."
    }
  },
  {
    id: "register-file",
    title: "2. The register file",
    subtitle: "D0-D7 and A0-A7",
    tag: "Core",
    goal: "Use registers as explicit variables and know the difference between data and address registers.",
    theory: [
      "The 68000 gives you eight data registers, D0 through D7, and eight address registers, A0 through A7.",
      "Use D registers for numbers. Use A registers for addresses. A7 is also the stack pointer.",
      "While learning, treat D0 as your result register so every example has one clear answer."
    ],
    analogy: "A Swift `var total = 0` becomes a deliberate register choice: `moveq #0,d0`. There is no variable name unless you give the register a role in your head.",
    keyIdea: "`move source,destination` is the rhythm. In Motorola syntax, the destination is on the right.",
    code: `; Change these numbers, then press Run
moveq #10,d0
moveq #7,d1
add.l d1,d0
subq.l #2,d0
rts`,
    quiz: {
      question: "Which register is normally used as the stack pointer?",
      options: ["D0", "A0", "A7", "D7"],
      answer: 2,
      feedback: "Correct. A7 is the stack pointer. You will also see it written as SP."
    }
  },
  {
    id: "move",
    title: "3. MOVE: your first instruction",
    subtitle: "Constants, registers, and sizes",
    tag: "Simulator",
    goal: "Load immediate values and copy values between registers.",
    theory: [
      "`MOVE` copies data. It does not destroy the source.",
      "`MOVEQ` is a compact fast form for small immediate values into data registers.",
      "Instruction suffixes matter: `.b` is byte, `.w` is word, `.l` is longword."
    ],
    analogy: "Swift hides integer width most of the time. Assembly makes width visible, because moving a byte is not the same as moving a longword.",
    keyIdea: "If you load only a byte into a register, the rest of that register may still contain old data. Clear first when you want a clean value.",
    code: `; Predict D0 before pressing Run
moveq #5,d0
move.l d0,d1
addq.l #3,d1
move.l d1,d0
rts`,
    quiz: {
      question: "After `move.l d0,d1`, what happens to D0?",
      options: ["It becomes zero", "It keeps its value", "It points to D1", "It becomes an address"],
      answer: 1,
      feedback: "Exactly. MOVE copies. It does not consume the source value."
    }
  },
  {
    id: "arithmetic",
    title: "4. Arithmetic: ADD, SUB, MULS",
    subtitle: "Do math one instruction at a time",
    tag: "Practice",
    goal: "Combine simple arithmetic instructions and inspect the register result.",
    theory: [
      "`ADD` and `SUB` modify the destination operand.",
      "`ADDQ` and `SUBQ` are quick forms for small constants from 1 to 8.",
      "`MULS` multiplies signed 16-bit values and stores a 32-bit result in a data register."
    ],
    analogy: "`score += 300` becomes `add.w #300,d0` after you have loaded score into D0.",
    keyIdea: "A register is both your workspace and your result. Always know which instruction changes which register.",
    code: `; Make the final D0 equal 42
moveq #6,d0
moveq #7,d1
muls d1,d0
rts`,
    quiz: {
      question: "Which side is changed by `add.l d1,d0`?",
      options: ["D1", "D0", "Both registers", "Neither register"],
      answer: 1,
      feedback: "Right. The destination is D0, so D0 receives D0 + D1."
    }
  },
  {
    id: "branches",
    title: "5. Branching and loops",
    subtitle: "BEQ, BNE, DBRA",
    tag: "Simulator",
    goal: "Build `if` and `while` behavior from labels and branch instructions.",
    theory: [
      "Assembly has no `if` or `while` keyword. You make control flow with labels and branches.",
      "`CMP` sets CPU flags. Conditional branches read those flags.",
      "`DBRA` decrements a data register and branches while it has not reached -1."
    ],
    analogy: "A Swift loop has a hidden test and jump. In assembly, you write the test label, the decrement, and the jump yourself.",
    keyIdea: "Branches are how code stops being a straight line.",
    code: `; Adds 5 + 4 + 3 + 2 + 1
moveq #0,d0
moveq #5,d1
loop:
add.w d1,d0
subq.w #1,d1
bne loop
rts`,
    quiz: {
      question: "What makes `bne loop` jump?",
      options: ["The previous result was not zero", "D0 is always positive", "A label stores true", "The stack is empty"],
      answer: 0,
      feedback: "Yes. BNE branches when the zero flag is clear, usually because the previous result was not zero."
    }
  },
  {
    id: "memory",
    title: "6. Memory and addressing",
    subtitle: "Labels, pointers, offsets",
    tag: "Memory",
    goal: "Understand labels as addresses and address registers as pointers.",
    theory: [
      "A label is a readable name for an address.",
      "`LEA label,A0` loads the address of the label, not the bytes stored there.",
      "Offset addressing, like `2(a0)`, means memory at address A0 plus 2."
    ],
    analogy: "A Swift array access hides address math. In 68k, `2(a0)` is the address math.",
    keyIdea: "Memory only becomes meaningful when you know its layout.",
    code: `; A tiny struct-like memory layout
player_lives equ 0
player_level equ 1
player_score equ 2

moveq #0,d0
move.w #1200,d0
add.w #300,d0
rts`,
    quiz: {
      question: "What does `lea player,a0` load?",
      options: ["The first byte of player", "The address of player", "The score field", "Zero"],
      answer: 1,
      feedback: "Correct. LEA means load effective address."
    }
  },
  {
    id: "subroutines",
    title: "7. Subroutines: JSR and RTS",
    subtitle: "Calls, returns, stack",
    tag: "Control",
    goal: "Call a small routine, return from it, and preserve borrowed registers.",
    theory: [
      "`BSR` and `JSR` call subroutines. `RTS` returns.",
      "The return address is saved on the stack, which uses A7.",
      "Subroutines need a contract: inputs, outputs, and which registers are preserved."
    ],
    analogy: "A Swift function call has a calling convention too. Assembly just makes the convention visible.",
    keyIdea: "The stack is not magic. It is memory used in last-in, first-out order.",
    code: `; Double D0 with a helper
moveq #21,d0
bsr double_d0
rts

double_d0:
add.l d0,d0
rts`,
    quiz: {
      question: "What instruction returns from a 68k subroutine?",
      options: ["RET", "END", "RTS", "BRA"],
      answer: 2,
      feedback: "Right. RTS pulls the saved return address and continues after the call."
    }
  },
  {
    id: "amiga-program",
    title: "8. Your first Amiga program",
    subtitle: "Write to hardware",
    tag: "Amiga",
    goal: "See how a CPU instruction can talk directly to Amiga custom hardware.",
    theory: [
      "The Amiga has custom chips mapped into memory. Writing to certain addresses changes hardware state.",
      "`$DFF180` is `COLOR00`, the background color register.",
      "A tiny program can write a color value there and visibly affect the display."
    ],
    analogy: "Swift calls an API. Classic Amiga code can write directly to a hardware register and the display responds.",
    keyIdea: "The CPU, Copper, Blitter, Paula, and Agnus form the Amiga personality. Assembly lets you stand close to all of them.",
    code: `; Conceptual hardware write
move.w #$0f00,$dff180
rts`,
    quiz: {
      question: "What is special about `$DFF180` on the Amiga?",
      options: ["It is D0 in memory", "It is the background color hardware register", "It starts every program", "It is the stack"],
      answer: 1,
      feedback: "Yes. COLOR00 lives at $DFF180, so writing a color word there changes the background color."
    },
    copper: true
  }
];

const hardware = [
  { name: "68000 CPU", desc: "Runs your instructions and owns the registers.", color: "#ffe45c" },
  { name: "Copper", desc: "Video-synced coprocessor for display lists.", color: "#00d8ff" },
  { name: "Blitter", desc: "DMA engine for fast copies, fills, and masks.", color: "#ff6f91" },
  { name: "Paula", desc: "Audio channels, disk I/O, and interrupts.", color: "#8fffbd" }
];

function createRegisters() {
  const regs = {};
  for (let i = 0; i < 8; i += 1) {
    regs[`d${i}`] = 0;
    regs[`a${i}`] = 0;
  }
  return regs;
}

function parseNumber(raw) {
  const text = raw.trim().replace(/^#/, "").toLowerCase();
  if (text.startsWith("$")) return Number.parseInt(text.slice(1), 16);
  if (text.startsWith("0x")) return Number.parseInt(text.slice(2), 16);
  return Number.parseInt(text, 10);
}

function cleanLine(line) {
  return line.split(";")[0].trim();
}

function splitOperands(text) {
  return text.split(",").map((part) => part.trim().toLowerCase()).filter(Boolean);
}

function toSigned32(value) {
  return value | 0;
}

function runMini68k(source) {
  const registers = createRegisters();
  const trace = [];
  const labels = new Map();
  const instructions = [];
  const constants = new Map();
  let zero = false;
  let negative = false;
  const stack = [];

  source.split("\n").forEach((rawLine) => {
    let line = cleanLine(rawLine).toLowerCase();
    if (!line) return;
    const equMatch = line.match(/^([a-z_][\w]*)\s+equ\s+(.+)$/);
    if (equMatch) {
      constants.set(equMatch[1], parseNumber(equMatch[2]));
      return;
    }
    if (line.endsWith(":")) {
      labels.set(line.slice(0, -1), instructions.length);
      return;
    }
    const inlineLabel = line.match(/^([a-z_][\w]*):\s*(.+)$/);
    if (inlineLabel) {
      labels.set(inlineLabel[1], instructions.length);
      line = inlineLabel[2];
    }
    instructions.push(line);
  });

  function readValue(operand) {
    const normalized = operand.toLowerCase();
    if (registers[normalized] !== undefined) return registers[normalized];
    if (constants.has(normalized)) return constants.get(normalized);
    if (normalized.startsWith("#") || normalized.startsWith("$") || normalized.startsWith("0x") || /^-?\d+$/.test(normalized)) {
      return parseNumber(normalized);
    }
    if (/^\$dff[0-9a-f]+$/.test(normalized)) return parseNumber(normalized);
    throw new Error(`I can read registers, constants, and immediate numbers, not "${operand}" yet.`);
  }

  function writeValue(operand, value) {
    const normalized = operand.toLowerCase();
    if (registers[normalized] !== undefined) {
      registers[normalized] = toSigned32(value);
      return;
    }
    if (/^\$dff[0-9a-f]+$/.test(normalized)) {
      trace.push(`hardware ${normalized.toUpperCase()} <= ${formatHex(value, 4)}`);
      return;
    }
    throw new Error(`I can write to registers and simple Amiga hardware addresses, not "${operand}" yet.`);
  }

  function setFlags(value) {
    zero = toSigned32(value) === 0;
    negative = toSigned32(value) < 0;
  }

  let pc = 0;
  let steps = 0;
  while (pc < instructions.length && steps < 200) {
    const line = instructions[pc];
    steps += 1;
    const [mnemonicRaw, rest = ""] = line.split(/\s+(.+)/);
    const mnemonic = mnemonicRaw.replace(/\.(b|w|l|s)$/i, "");
    const operands = splitOperands(rest);
    trace.push(`${String(pc).padStart(2, "0")}  ${line}`);
    pc += 1;

    if (mnemonic === "rts") {
      if (stack.length > 0) {
        pc = stack.pop();
      } else {
        break;
      }
    } else if (mnemonic === "move" || mnemonic === "moveq") {
      const [src, dest] = operands;
      const value = readValue(src);
      writeValue(dest, value);
      setFlags(value);
    } else if (mnemonic === "add" || mnemonic === "addq") {
      const [src, dest] = operands;
      const value = readValue(dest) + readValue(src);
      writeValue(dest, value);
      setFlags(value);
    } else if (mnemonic === "sub" || mnemonic === "subq") {
      const [src, dest] = operands;
      const value = readValue(dest) - readValue(src);
      writeValue(dest, value);
      setFlags(value);
    } else if (mnemonic === "muls") {
      const [src, dest] = operands;
      const value = readValue(dest) * readValue(src);
      writeValue(dest, value);
      setFlags(value);
    } else if (mnemonic === "cmp" || mnemonic === "cmpi") {
      const [src, dest] = operands;
      setFlags(readValue(dest) - readValue(src));
    } else if (mnemonic === "bra") {
      pc = labels.get(operands[0]);
    } else if (mnemonic === "beq") {
      if (zero) pc = labels.get(operands[0]);
    } else if (mnemonic === "bne") {
      if (!zero) pc = labels.get(operands[0]);
    } else if (mnemonic === "bgt") {
      if (!zero && !negative) pc = labels.get(operands[0]);
    } else if (mnemonic === "ble") {
      if (zero || negative) pc = labels.get(operands[0]);
    } else if (mnemonic === "bsr" || mnemonic === "jsr") {
      stack.push(pc);
      pc = labels.get(operands[0]);
    } else if (mnemonic === "lea") {
      const [src, dest] = operands;
      writeValue(dest, constants.get(src) ?? 4096 + labels.size * 16);
    } else {
      throw new Error(`Instruction "${mnemonicRaw}" is not in this beginner simulator yet.`);
    }

    if (Number.isNaN(pc) || pc === undefined) {
      throw new Error(`Unknown label in "${line}".`);
    }
  }

  if (steps >= 200) trace.push("Stopped after 200 steps. Check for an infinite loop.");

  return { registers, trace, flags: { zero, negative } };
}

function formatHex(value, width = 8) {
  const unsigned = value >>> 0;
  return `$${unsigned.toString(16).toUpperCase().padStart(width, "0").slice(-width)}`;
}

function App() {
  const [lessonIndex, setLessonIndex] = useState(0);
  const [completed, setCompleted] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem("amiga68000-progress") || "[]");
    } catch {
      return [];
    }
  });
  const [codeByLesson, setCodeByLesson] = useState(() => Object.fromEntries(lessons.map((lesson) => [lesson.id, lesson.code])));
  const [quizAnswers, setQuizAnswers] = useState({});
  const [simResult, setSimResult] = useState(() => runMini68k(lessons[0].code));
  const [error, setError] = useState("");
  const [showCopper, setShowCopper] = useState(false);

  const lesson = lessons[lessonIndex];
  const code = codeByLesson[lesson.id];
  const progress = Math.round((completed.length / lessons.length) * 100);

  useEffect(() => {
    localStorage.setItem("amiga68000-progress", JSON.stringify(completed));
  }, [completed]);

  useEffect(() => {
    setShowCopper(false);
    runCode(lesson.code, lesson.id);
  }, [lessonIndex]);

  const selectedAnswer = quizAnswers[lesson.id];
  const isCorrect = selectedAnswer === lesson.quiz.answer;

  function runCode(source = code, id = lesson.id) {
    try {
      const result = runMini68k(source);
      setSimResult(result);
      setError("");
      setCodeByLesson((current) => ({ ...current, [id]: source }));
    } catch (runError) {
      setError(runError.message);
    }
  }

  function resetLessonCode() {
    setCodeByLesson((current) => ({ ...current, [lesson.id]: lesson.code }));
    runCode(lesson.code);
  }

  function answerQuiz(index) {
    setQuizAnswers((current) => ({ ...current, [lesson.id]: index }));
    if (index === lesson.quiz.answer && !completed.includes(lesson.id)) {
      setCompleted((current) => [...current, lesson.id]);
    }
  }

  function moveLesson(direction) {
    setLessonIndex((current) => Math.min(lessons.length - 1, Math.max(0, current + direction)));
  }

  return (
    <main className="app-shell">
      <header className="topbar">
        <div className="brand">
          <Cpu size={24} />
          <div>
            <h1>AMIGA 68000 ASSEMBLER</h1>
            <p>A hands-on class for Swift programmers, built from zero.</p>
          </div>
        </div>
        <div className="progress-card" aria-label={`Course progress ${progress}%`}>
          <span>{progress}%</span>
          <div className="progress-track">
            <div style={{ width: `${progress}%` }} />
          </div>
        </div>
      </header>

      <nav className="lesson-nav" aria-label="Lessons">
        {lessons.map((item, index) => (
          <button
            key={item.id}
            className={`lesson-pill ${index === lessonIndex ? "active" : ""} ${completed.includes(item.id) ? "done" : ""}`}
            onClick={() => setLessonIndex(index)}
          >
            {completed.includes(item.id) ? <Check size={15} /> : null}
            <span>{item.title}</span>
          </button>
        ))}
      </nav>

      <section className="workspace">
        <article className="lesson-panel">
          <div className="panel-heading">
            <span className="tag">{lesson.tag}</span>
            <p>{lesson.subtitle}</p>
            <h2>{lesson.title}</h2>
          </div>

          <div className="goal-line">
            <BookOpen size={18} />
            <span>{lesson.goal}</span>
          </div>

          <div className="lesson-copy">
            {lesson.theory.map((paragraph) => (
              <p key={paragraph}>{paragraph}</p>
            ))}
          </div>

          <div className="callout swift">
            <strong>Swift analogy</strong>
            <span>{lesson.analogy}</span>
          </div>

          <div className="callout idea">
            <strong>Key idea</strong>
            <span>{lesson.keyIdea}</span>
          </div>

          <HardwareStrip />

          {lesson.copper ? (
            <div className="copper-action">
              <button className="primary-action" onClick={() => setShowCopper((value) => !value)}>
                <Zap size={18} />
                Teach me the Copper
              </button>
              {showCopper ? (
                <div className="copper-note">
                  <strong>Copper preview</strong>
                  <p>The Copper runs a list synchronized to the video beam. Later lessons can use it to change colors mid-screen, create gradients, split displays, and trigger effects without the CPU doing every write.</p>
                </div>
              ) : null}
            </div>
          ) : null}
        </article>

        <aside className="lab-panel">
          <div className="panel-heading compact">
            <span className="tag cyan">Live lab</span>
            <h2>Micro 68k simulator</h2>
            <p>Edit the code, run it, and watch registers change.</p>
          </div>

          <div className="editor-shell">
            <div className="editor-toolbar">
              <span><TerminalSquare size={16} /> lesson source</span>
              <div>
                <button title="Reset code" onClick={resetLessonCode}>
                  <RotateCcw size={16} />
                </button>
                <button title="Run code" className="run-button" onClick={() => runCode()}>
                  <Play size={16} />
                </button>
              </div>
            </div>
            <textarea
              value={code}
              spellCheck="false"
              onChange={(event) => setCodeByLesson((current) => ({ ...current, [lesson.id]: event.target.value }))}
            />
          </div>

          {error ? <div className="error-box">{error}</div> : null}

          <RegisterGrid registers={simResult.registers} />

          <div className="trace-grid">
            <div className="trace-box">
              <h3>Trace</h3>
              <pre>{simResult.trace.join("\n")}</pre>
            </div>
            <div className="flags-box">
              <h3>Flags</h3>
              <span className={simResult.flags.zero ? "flag active" : "flag"}>Z</span>
              <span className={simResult.flags.negative ? "flag active" : "flag"}>N</span>
            </div>
          </div>

          <Quiz
            lesson={lesson}
            selectedAnswer={selectedAnswer}
            isCorrect={isCorrect}
            answerQuiz={answerQuiz}
          />
        </aside>
      </section>

      <footer className="footer-nav">
        <button disabled={lessonIndex === 0} onClick={() => moveLesson(-1)}>
          <ArrowLeft size={16} />
          Previous
        </button>
        <button className="restart" onClick={() => {
          setCompleted([]);
          setQuizAnswers({});
          setLessonIndex(0);
        }}>
          <RefreshCcw size={16} />
          Restart class
        </button>
        <button disabled={lessonIndex === lessons.length - 1} onClick={() => moveLesson(1)}>
          Next
          <ArrowRight size={16} />
        </button>
      </footer>
    </main>
  );
}

function HardwareStrip() {
  return (
    <section className="hardware-strip" aria-label="Amiga hardware picture">
      <h3>The Amiga hardware picture</h3>
      <div className="hardware-grid">
        {hardware.map((part) => (
          <div className="hardware-card" key={part.name} style={{ "--part-color": part.color }}>
            <strong>{part.name}</strong>
            <p>{part.desc}</p>
          </div>
        ))}
      </div>
      <p className="hardware-note">Custom chip registers live around <code>$DFF000</code>. Write to an address and the hardware responds.</p>
    </section>
  );
}

function RegisterGrid({ registers }) {
  const names = useMemo(() => [...Array.from({ length: 8 }, (_, i) => `d${i}`), ...Array.from({ length: 8 }, (_, i) => `a${i}`)], []);
  return (
    <section className="register-panel" aria-label="Registers">
      <div className="register-title">
        <h3>Registers</h3>
        <span>D registers hold data. A registers hold addresses.</span>
      </div>
      <div className="register-grid">
        {names.map((name) => (
          <div className="register-cell" key={name}>
            <span>{name.toUpperCase()}</span>
            <strong>{formatHex(registers[name] ?? 0)}</strong>
            <small>{registers[name] ?? 0}</small>
          </div>
        ))}
      </div>
    </section>
  );
}

function Quiz({ lesson, selectedAnswer, isCorrect, answerQuiz }) {
  return (
    <section className="quiz-panel">
      <span className="tag yellow">Quiz</span>
      <h3>{lesson.quiz.question}</h3>
      <div className="quiz-options">
        {lesson.quiz.options.map((option, index) => (
          <button
            key={option}
            className={selectedAnswer === index ? (isCorrect ? "correct" : "incorrect") : ""}
            onClick={() => answerQuiz(index)}
          >
            {option}
          </button>
        ))}
      </div>
      {selectedAnswer !== undefined ? (
        <p className={isCorrect ? "quiz-feedback ok" : "quiz-feedback"}>
          {isCorrect ? lesson.quiz.feedback : "Not quite. Trace the lesson text and try again."}
        </p>
      ) : null}
    </section>
  );
}

createRoot(document.getElementById("root")).render(<App />);

