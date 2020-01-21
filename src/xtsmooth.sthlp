{smcl}
{* *! version 0.1.0 17jan2020}{...}
{vieweralsosee "[R] smooth" "help smooth"}{...}
{vieweralsosee "[TS] tssmooth" "help tssmooth"}{...}
{title:Title}

{p2colset 1 15 17 2}{...}
{p2col:{bf:[R] smooth} {hline 2}}Panel-data version of -smooth-, a robust nonlinear smoother based on Tukey's EDA{p_end}
{p2col:}({help R smooth:View complete help file for smooth}){p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:xtsmooth}
{varname}
{ifin}
{cmd:,}
{opth g:enerate(newvarname)}
{opt s:moother(string)}
{opt t:wice}

See smooth help file for more details.

{title:Notes}

{pmore} - Supports datasets that have been xtset or tsset (panel data){p_end}
{pmore} - If some obs. are missing, the command will split the data instead of fail{p_end}
{pmore} - Even-span smoothers are not supported{p_end}
{pmore} - {opt s:moother()} allows spaces, as it's more readable: "4 3RSR 2 H" vs "43RSR2H" (as per the manual, 3RSR is just a 3 repeated that avoids flat regions){p_end}
