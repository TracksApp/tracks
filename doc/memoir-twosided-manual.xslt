<?xml version='1.0' encoding='utf-8'?>

<!-- XHTML-to-Memoir converter by Fletcher Penney
	specifically designed for use with MultiMarkdown created XHTML

	Uses the LaTeX memoir class for output with the twoside option
	
	MultiMarkdown Version 2.0.b3
	
	$Id: memoir-twosided.xslt 400 2007-05-26 18:42:49Z fletcher $
-->

<!-- 
# Copyright (C) 2005-2007  Fletcher T. Penney <fletcher@fletcherpenney.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA
-->

	
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="1.0">

	<xsl:import href="memoir.xslt"/>
	
	<xsl:output method='text' encoding='utf-8'/>

	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<xsl:apply-templates select="html:html/html:head"/>
		<xsl:apply-templates select="html:html/html:body"/>
		<xsl:call-template name="latex-footer"/>
	</xsl:template>

	<xsl:template name="latex-document-class">
		<xsl:text>\documentclass[10pt,twoside]{memoir}
\usepackage{layouts}[2001/04/29]

\usepackage{palatino} 
\usepackage{color,calc} 
\newsavebox{\ChpNumBox} 
\definecolor{ChapBlue}{rgb}{0.00,0.65,0.65} 
\makeatletter 
\newcommand*{\thickhrulefill}{% 
\leavevmode\leaders\hrule height 1\p@ \hfill \kern \z@} 
\newcommand*\BuildChpNum[2]{% 
\begin{tabular}[t]{@{}c@{}} 
\makebox[0pt][c]{#1\strut} \\[.5ex] 
\colorbox{ChapBlue}{% 
\rule[-10em]{0pt}{0pt}% 
\rule{1ex}{0pt}\color{black}#2\strut 
\rule{1ex}{0pt}}% 
\end{tabular}} 
\makechapterstyle{BlueBox}{% 
\renewcommand{\chapnamefont}{\large\scshape} 
\renewcommand{\chapnumfont}{\Huge\bfseries} 
\renewcommand{\chaptitlefont}{\raggedright\Huge\bfseries} 
\setlength{\beforechapskip}{20pt} 
\setlength{\midchapskip}{26pt} 
\setlength{\afterchapskip}{40pt} 
\renewcommand{\printchaptername}{} 
\renewcommand{\chapternamenum}{} 
\renewcommand{\printchapternum}{% 
\sbox{\ChpNumBox}{% 
\BuildChpNum{\chapnamefont\@chapapp}% 
{\chapnumfont\thechapter}}} 
\renewcommand{\printchapternonum}{% 
\sbox{\ChpNumBox}{% 
\BuildChpNum{\chapnamefont\vphantom{\@chapapp}}% 
{\chapnumfont\hphantom{\thechapter}}}} 
\renewcommand{\afterchapternum}{} 
\renewcommand{\printchaptertitle}[1]{% 
\usebox{\ChpNumBox}\hfill 
\parbox[t]{\hsize-\wd\ChpNumBox-1em}{% 
\vspace{\midchapskip}% 
\thickhrulefill\par 
\chaptitlefont ##1\par}}% 
} 
\chapterstyle{BlueBox}

\setsecheadstyle{\sffamily\bfseries\Large}
\setsubsecheadstyle{\sffamily\bfseries\normal}

\makepagestyle{myruledpagestyle}
\makeevenhead{myruledpagestyle}{\thepage}{}{\leftmark}
\makeoddhead{myruledpagestyle}{\rightmark}{}{\thepage}
\makeatletter
\makepsmarks{myruledpagestyle}{
  \def\chaptermark##1{\markboth{%
        \ifnum \value{secnumdepth} > -1
          \if@mainmatter
            \chaptername\ \thechapter\ --- %
          \fi
        \fi
        ##1}{}}
  \def\sectionmark##1{\markright{%
        \ifnum \value{secnumdepth} > 0
          \thesection. \ %
        \fi
        ##1}}
}
\makeatother

\makerunningwidth{myruledpagestyle}{1.1\textwidth}
\makeheadposition{myruledpagestyle}{flushright}{flushleft}{flushright}{flushleft}
\makeheadrule{myruledpagestyle}{1.1\textwidth}{\normalrulethickness}

\makeglossary
\makeindex

\def\mychapterstyle{BlueBox}
\def\mypagestyle{myruledpagestyle}
\def\revision{}
</xsl:text>
	</xsl:template>


</xsl:stylesheet>