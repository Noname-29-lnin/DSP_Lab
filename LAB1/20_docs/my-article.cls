\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{my-article}[2025/08/11 HCMUT Report Class - Layout Only]

% =====================
% Options & Base Class
% =====================
\LoadClass[12pt,a4paper]{article}

% =====================
% Packages for layout
% =====================
% --- Font and Math Packages
\RequirePackage{anyfontsize}    % Allow arbitrary font sizes beyond the standard classes
\RequirePackage{amsmath}        % Enhanced mathematical typesetting (align, cases, etc.)
\RequirePackage{amssymb}        % Additional mathematical symbols (e.g., \mathbb, \leqslant)
% --- Page Layout and Spacing
\RequirePackage{geometry}       % Control page dimensions and margins
\RequirePackage{hyperref}       % Hyperlinks in the document and bookmarks in the PDF
\RequirePackage{indentfirst}    % Indent the first paragraph of each section
\RequirePackage{setspace}       % Control line spacing (single, 1.5, double spacing)
% --- Custom secction titles
\RequirePackage{titlesec}       % Custom section titles
% --- Figures and Graphics
\RequirePackage{graphicx}       % Include external images (e.g., PNG, PDF, EPS)
% --- Tables
\RequirePackage{array}          % Extended array and tabular environments
\RequirePackage{booktabs}       % Professional-quality tables with \toprule, \midrule, \bottomrule
\RequirePackage{tabularx}       % Tables with adjustable-width columns (X column type)
\RequirePackage{tabulary}       % Advanced tables with automatic column type adjustment
\RequirePackage{longtable}      % Tables that span multiple pages
\RequirePackage{multirow}       % Cells that span multiple rows
\RequirePackage{multicol}       % Support for multiple columns in text
% --- Captions
\RequirePackage[center]{caption} % Customize figure/table captions and center them
% --- Headers and Footers
\RequirePackage{fancyhdr}       % Custom headers and footers
% --- References and Citations
\RequirePackage[super,square,sort]{natbib} 
%    Citation style:
%      - super  : superscripted citations (e.g., text^1)
%      - square : use square brackets [ ]
%      - sort   : sort multiple citations
% --- Page Counting
\RequirePackage{lastpage}       % Reference the last page
% --- Conditional Processing
\RequirePackage{ifthen}         % Use conditional expressions (\ifthenelse)

\RequirePackage{enumerate}      % support enumerate with custom labels
\RequirePackage{enumitem}       % support itemize with custom labels and spacing
% =====================
% Section & TOC settings
% =====================
\setcounter{secnumdepth}{3} % Numbering depth for sections
\setcounter{tocdepth}{3}    % Depth for TOC % Number equations, tables, figures by section
\AtBeginDocument{\counterwithin{equation}{section}}
\AtBeginDocument{\counterwithin{table}{section}}
\AtBeginDocument{\counterwithin{figure}{section}}
\AtBeginDocument{\renewcommand*\bibname{References}}

% --- Section ---
\titleformat{\section} % command
  {\normalfont\Large\bfseries} % format (font, size, bold)
  {\thesection} % label
  {1em} % sep
  {} % before-code
  [] % after-code

% --- Subsection ---
\titleformat{\subsection}
  {\normalfont\large\bfseries}
  {\thesubsection}
  {0.75em}
  {}

% --- Subsubsection ---
\titleformat{\subsubsection}
  {\normalfont\fontsize{13}{14}\selectfont\itshape}
  {\thesubsubsection}
  {0.5em}
  {}
\titleformat{\section}
            {\normalfont\Large\bfseries}
            {Chapter \thesection. }{1em}{}
% =====================
% Setup page
% =====================
% --- Page geometry
\geometry{
  paper=a4paper,
  left=2cm,
  right=2cm,
  vmargin=2cm,
  includeheadfoot=true,
  headheight=30pt
}
% --- Hyperref setup
\hypersetup{
    unicode,                % hỗ trợ tiếng Việt trong bookmark
    bookmarks=true,         % bật bookmark
    bookmarksopen=true,     % mở bookmark theo cây
    bookmarksnumbered=true, % thêm số chương/mục vào bookmark
    pdfborder={0 0 0},      % bỏ khung đỏ quanh link
    colorlinks=true,        % dùng màu thay vì khung
    linkcolor=black,        % màu link nội bộ
    citecolor=black,        % màu link trích dẫn
    urlcolor=magenta        % màu link URL
}

% --- Text spacing & layout
\onehalfspacing                   % 1.5 line spacing
\raggedbottom                     % No stretching between paragraphs
\setlength{\parindent}{1cm}       % Indent first line
\renewcommand{\arraystretch}{1.2} % Table row spacing

\pagestyle{fancy}
\fancyhf{}

% =====================
% My custom macros
% =====================
\newcommand{\MychapterAbstract}[1]{
  {\centering \section*{Abstract}}
  \addcontentsline{toc}{section}{Abstract}
  \input{#1}
}
\newcommand{\MychapterAcknowledgement}[1]{
  {\centering \section*{Acknowledgement}}
  \addcontentsline{toc}{section}{Acknowledgement}
  \input{#1}
}

% New command to switch page numbering style
\newcommand{\MycountPages}[1]{%
    \ifthenelse{\equal{#1}{roman}}{%
        \renewcommand{\thepage}{\roman{page}}%
        \setcounter{page}{1}%
        \fancyfoot{}
        \renewcommand{\headrulewidth}{0pt}
        \renewcommand{\footrulewidth}{0pt}
        \fancyfoot[C]{\thepage}%
    }{%
        \ifthenelse{\equal{#1}{number}}{%
            \renewcommand{\thepage}{\arabic{page}}%
            \setcounter{page}{1}%
            \fancyfoot{}
            \renewcommand{\headrulewidth}{0.3pt}
            \renewcommand{\footrulewidth}{0.3pt}
            \fancyfoot[R]{Page \thepage\ |\ \pageref{LastPage}}%
        }{%
            \ClassWarning{my-article}{Invalid argument for \MycountPages: use 'roman' or 'number'}
        }%
    }%
}

% =====================
% Recommand to setup
% =====================
% ===================== Table example =====================
% \begin{table}[h] % or [t], [b], [!ht], etc.
% \centering
% \caption{Caption}
% \vspace{0.5em} % khoảng cách sau caption
% \begin{tabular}{|>{\centering\arraybackslash}m{1cm}
%                 |>{\centering\arraybackslash}m{2.5cm}
%                 |>{\centering\arraybackslash}m{4cm}
%                 |>{\raggedright\arraybackslash}m{6cm}
%                 |>{\centering\arraybackslash}m{2cm}|}
%     \hline
% \end{tabular}
% \end{table}
% ===================== Long table example =====================
% \begin{longtable}{|c|c|c|}
% \caption{Example of a long table} \label{tab:long} \\  % caption ở đây, khác với table
% \hline
% Header1 & Header2 & Header3 \\ 
% \hline
% \endfirsthead   % Phần header lặp lại cho trang tiếp theo
% \multicolumn{3}{c}%
% {\tablename\ \thetable\ -- continued from previous page} \\
% \hline
% Header1 & Header2 & Header3 \\ 
% \hline
% \endhead

% \hline \multicolumn{3}{r}{Continued on next page} \\ 
% \endfoot

% \hline
% \endlastfoot

% A1 & B1 & C1 \\
% A2 & B2 & C2 \\
% A3 & B3 & C3 \\
% \end{longtable}
% =====================  example =====================
% =====================
% End of class
% =====================
\endinput
% =====================