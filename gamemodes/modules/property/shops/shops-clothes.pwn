/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:clothes(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new member = Factions_GetMember(playerid);

    if (member < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in a Force / Organisation !");
        return 1;
    }

    if (!IsAtClothShop(playerid) && Business_GetTypedAt(playerid,BUSINESS_TYPE_CLOTHES) == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a Clothing Shop !");
        return 1;
    }

    new chosen = Factions_GetChosenSkinFor(member), shown = Factions_GetPreviewSkinFor(member);

    if (chosen == 0)
    {
        return 1;
    }

    Factions_SetChosenSkin(playerid,chosen);
    SetPlayerSkin(playerid,shown);
    Factions_BeginCharSelect(playerid,true);
    return 1;
}
