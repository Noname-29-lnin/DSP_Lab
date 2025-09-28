\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{my-class}[2025/08/11 HCMUT Report Class - Layout Only]

% =====================
% Options & Base Class
% =====================
\newcommand{\mycall@language}{english}
\DeclareOption{language=vietnam}{\renewcommand{\mycall@language}{vietnamese}}
\DeclareOption{language=english}{\renewcommand{\mycall@language}{english}}
\DeclareOption*{\PackageWarning{my-class}{Unknown option: \CurrentOption ignored.}}

\ProcessOptions\relax

\LoadClass[12pt,a4paper]{article}

% =====================
% Packages for layout
% =====================
\RequirePackage[utf8]{inputenc}       % UTF-8 input
\RequirePackage[T5]{fontenc}          % Vietnamese font encoding
\ifx\myclass@language v vietnam
  \usepackage[vietnam]{babel}
\else
  \usepackage[english]{babel}
\fi

\RequirePackage{anyfontsize,amsmath,amssymb}
\RequirePackage{geometry,graphicx,indentfirst,setspace}
\RequirePackage{booktabs}
\RequirePackage[center]{caption}
\RequirePackage{fancyhdr,hyperref}
\RequirePackage[super,square,sort]{natbib}
\RequirePackage{tabularx,tabulary}
\RequirePackage{lastpage}
\RequirePackage{ifthen}

% =====================
% Page geometry
% =====================
\geometry{
  paper=a4paper,
  left=2cm,
  right=2cm,
  vmargin=2cm,
  includeheadfoot=true,
  headheight=35pt
}

% =====================
% Text spacing & layout
% =====================
\onehalfspacing                   % 1.5 line spacing
\raggedbottom                     % No stretching between paragraphs
\setlength{\parindent}{1cm}       % Indent first line
\renewcommand{\arraystretch}{1.2} % Table row spacing

% =====================
% Section & TOC settings
% =====================
\setcounter{secnumdepth}{3} % Numbering depth for sections
\setcounter{tocdepth}{3}    % Depth for TOC

% Number equations, tables, figures by section
\AtBeginDocument{\counterwithin{equation}{section}}
\AtBeginDocument{\counterwithin{table}{section}}
\AtBeginDocument{\counterwithin{figure}{section}}
\AtBeginDocument{\renewcommand*\bibname{References}}

% =====================
% Hyperref setup
% =====================
\hypersetup{
  colorlinks=true,
  linkcolor=black,
  citecolor=red,
  urlcolor=blue
}

% =====================
% Header & Footer
% =====================
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
  {\centering \section*{Acknowledgementt}}
  \addcontentsline{toc}{section}{Acknowledgement}
  \input{#1}
}
\newcommand{\Myref}[1]{%
  \section*{References}%
  \addcontentsline{toc}{section}{References}%
  \bibliographystyle{IEEEtran}%
  \bibliography{#1}%
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
            \ClassWarning{my-class}{Invalid argument for \MycountPages: use 'roman' or 'number'}%
        }%
    }%
}
% Initialize page numbering (default to arabic)
\newcommand{\InitPageNumbering}{%
    \renewcommand{\thepage}{\arabic{page}}%
    \setcounter{page}{1}%
    \fancyfoot[R]{\thepage\ |\ \pageref{LastPage}}%
}

% =====================
% End of class
% =====================
\endinput
% =====================