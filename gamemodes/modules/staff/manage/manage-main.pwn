/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnGameModeInit()
{
    Command_SetDenial("asellbiz",E_COMMAND_DENIAL_LEVEL,COLOR_WHITE,"You are not an admin.");
    Command_SetDenial("asellsbiz",E_COMMAND_DENIAL_LEVEL,COLOR_WHITE,"You are not an admin.");
    Command_SetDenial("asellhouse",E_COMMAND_DENIAL_LEVEL,COLOR_WHITE,"You are not an admin.");
    Command_SetDenial("resethousecars",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("edithousecar",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("edit",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("createhouse",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("createbiz",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("movehouse",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("movebiz",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("deletehouse",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("deletebiz",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
    Command_SetDenial("nearestinterior",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD2,"   You are not an Admin !");
}
