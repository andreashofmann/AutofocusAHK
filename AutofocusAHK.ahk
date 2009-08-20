#Persistent

SetTimer,UPDATEDSCRIPT,1000

Return

UPDATEDSCRIPT:
FileGetAttrib,attribs,%A_ScriptFullPath%
IfInString,attribs,A
{
FileSetAttrib,-A,%A_ScriptFullPath%
SplashTextOn,,,Updated AutofocusAHK,
Sleep,500
SplashTextOff
Reload
}
Return 