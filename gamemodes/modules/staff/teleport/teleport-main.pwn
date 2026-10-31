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
    Command_SetDenial("dn",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an Admin !");
    Command_SetDenial("up",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an Admin !");
    Command_SetDenial("fly",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an Admin !");
    Command_SetDenial("lt",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an Admin !");
    Command_SetDenial("rt",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an Admin !");
    Command_SetDenial("setint",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not authorized to use that command !");
    Command_SetDenial("gotols",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not authorized to use that command !");
}
