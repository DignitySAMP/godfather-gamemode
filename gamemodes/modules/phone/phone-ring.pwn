/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define PHONE_SOUND_RING_A (1138)
#define PHONE_SOUND_RING_B (1137)
#define PHONE_SOUND_BEEP (1139)

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
stock Phone_StepRing(playerid)
{
    new tone = Phone_GetRingTone(playerid);

    if (!Phone_IsRingReverse(playerid))
    {
        if (tone != 6 && tone != 0 && tone < 11)
        {
            tone--;
            PlayerPlaySound(playerid,PHONE_SOUND_RING_A,0.0,0.0,0.0);
        }

        if (tone == 6)
        {
            tone--;
        }

        if (tone == PHONE_RING_SMS)
        {
            tone--;
            PlayerPlaySound(playerid,PHONE_SOUND_BEEP,0.0,0.0,0.0);
        }

        Phone_SetRingTone(playerid,tone);
        Phone_SetRingReverse(playerid,true);
        return;
    }

    if (tone != 5 && tone != 0 && tone < 10)
    {
        tone--;
        PlayerPlaySound(playerid,PHONE_SOUND_RING_B,0.0,0.0,0.0);
    }

    if (tone == 5)
    {
        tone--;
    }

    if (tone == 19)
    {
        PlayerPlaySound(playerid,PHONE_SOUND_BEEP,0.0,0.0,0.0);
        tone = 0;
    }

    Phone_SetRingTone(playerid,tone);
    Phone_SetRingReverse(playerid,false);
}

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

hook Law_OnFreed(playerid)
{
    Phone_Beep(playerid);
}
