# LaTeX to Markdown Converter

This project is a simple tool that converts LaTeX code into equivalent Markdown code. The conversion is done via an Abstract Syntax Tree (AST), where the lexing and parsing are handled using Flex and Bison, respectively.

## Features

- **Sections**: Supports LaTeX sections (`\section{}`, `\subsection{}`, `\subsubsection{}`)
- **Horizontal rules**: Converts LaTeX horizontal rules (`\hrule`) to Markdown
- **Lists**: Supports both ordered and unordered lists
- **Text formatting**: Bold and italic text conversion (`\textbf{}` and `\textit{}`)
- **Verbatim blocks**: Handles verbatim code blocks (`\begin{verbatim} ... \end{verbatim}`)
- **Images**: Converts LaTeX images (`\includegraphics{}`) to Markdown
- **Extensibility**: Easily extensible to support more LaTeX features

## Getting Started

### Prerequisites

Make sure you have the following installed on your system:

- **Flex**: A fast lexical analyzer generator
- **Bison**: A general-purpose parser generator
- **gcc/g++**: For compiling the generated C++ code

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/latex-to-markdown.git
   cd latex-to-markdown
    ```

2. Make the project:
    ```bash
    ./run.sh input.tex output.md
    ```

### Examples

For the give input.tex

```tex
\section{Introduction}
\subsection{Purpose}
The purpose of this document is to demonstrate conversion.

\textbf{Bold Text} and \textit{Italic Text} are supported.

\includegraphics{image.png}

\hrule
```

We get the following equivalent markdown

```md
# Introduction
## Purpose
The purpose of this document is to demonstrate conversion.

**Bold Text** and *Italic Text* are supported.

![](img.png)
```

### Testing

Use the bash script to compare input and output test files: 

```bash
./test.sh
```

### Directory structure

```
latex-to-markdown/
│
├── .github             # Github workflows
│
├── src/                # Source code for the project
│   ├── scanner.l       # Flex file for lexing
│   ├── parser.y        # Bison file for parsing
│   ├── AST.cpp         # AST creation and traversal
│   └── AST.hpp         # AST header
│
├── tests/              # Test files and testing scripts
│   ├── input1.tex      # Test LaTeX file
│   ├── output1.md      # Expected Markdown output
│   └── ...
│
├── run.sh              # Script to run the program
├── Makefile            # Build instructions
└── README.md           # Project documentation
```

### LATEX specifications used for markdown conversion:

1. A single '\n' corresponds to a space and not a newline between corresponding lines.
2. In LATEX, >1 '\n' corresponds to a single newline
3. There are no newlines via 1. inside a textbf or textit. We can still use \\.

As seen from latex source code converted to PDF using overleaf.com

### Known bugs:
1. \end{verbatim} on same line as text doesn't work
2. Arbitrary textbf and textit composition may not work all the time [&check;]