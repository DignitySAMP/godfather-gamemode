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
#define GODFATHER_VERSION "0.1.0"

enum
{
    ADMIN_LEVEL_TRIAL = 1,
    ADMIN_LEVEL_MOD,
    ADMIN_LEVEL_ADMIN,
    ADMIN_LEVEL_MANAGER,
    ADMIN_LEVEL_DEVELOPER = 1337,
    ADMIN_LEVEL_OWNER = 1338
}

#define CMD_FLAG_LEVEL_MASK (2047)
#define CMD_FLAG_PRELOGIN (65536)

#define COLOR_GRAD1 (0xB4B5B7FF)
#define COLOR_GRAD2 (0xBFC0C2FF)
#define COLOR_GRAD3 (0xCBCCCEFF)
#define COLOR_GRAD4 (0xD8D8D8FF)
#define COLOR_GRAD5 (0xE3E3E3FF)
#define COLOR_GRAD6 (0xF0F0F0FF)
#define COLOR_GREY (0xAFAFAFAA)
#define COLOR_GREEN (0x33AA33AA)
#define COLOR_RED (0xAA3333AA)
#define COLOR_LIGHTRED (0xFF6347AA)
#define COLOR_LIGHTBLUE (0x33CCFFAA)
#define COLOR_LIGHTGREEN (0x9ACD32AA)
#define COLOR_YELLOW (0xFFFF00AA)
#define COLOR_YELLOW2 (0xF5DEB3AA)
#define COLOR_WHITE (0xFFFFFFAA)
#define COLOR_FADE1 (0xE6E6E6E6)
#define COLOR_FADE2 (0xC8C8C8C8)
#define COLOR_FADE3 (0xAAAAAAAA)
#define COLOR_FADE4 (0x8C8C8C8C)
#define COLOR_FADE5 (0x6E6E6E6E)
#define COLOR_PURPLE (0xC2A2DAAA)
#define COLOR_DBLUE (0x2641FEAA)
#define COLOR_ALLDEPT (0xFF8282AA)
#define COLOR_NEWS (0xFFA500AA)
#define COLOR_OOC (0xE0FFFFAA)
#define COLOR_SPEC (0xBFC0C200)
#define TEAM_GREEN_COLOR (0xFFFFFFAA)
#define TEAM_HIT_COLOR (0xFFFFFF00)
#define TEAM_BLUE_COLOR (0x8D8DFF00)
#define TEAM_GROVE_COLOR (0x00D900C8)
#define TEAM_BALLAS_COLOR (0xD900D3C8)
#define TEAM_AZTECAS_COLOR (0x01FCFFC8)
#define TEAM_CYAN_COLOR (0xFF8282AA)

#define TEAM_CYAN (1)
#define TEAM_BLUE (2)
#define TEAM_GREEN (3)
#define TEAM_ORANGE (4)
#define TEAM_COR (5)
#define TEAM_HIT (10)
#define TEAM_ADMIN (11)

