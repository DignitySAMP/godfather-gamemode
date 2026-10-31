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
    bcrypt_set_thread_limit(2);
    Chat_RegisterInterceptor("Account_ChatMuted", CHAT_SLOT_MUTED);
    Chat_RegisterInterceptor("Account_ChatRegistration", CHAT_SLOT_REGISTRATION);
    Command_SetSecret("login");
    Command_SetSecret("register");
    Command_SetDenial("stats", E_COMMAND_DENIAL_LOGIN, COLOR_GRAD1, "   You are not Logged in !");
    Command_SetDenial("logout", E_COMMAND_DENIAL_LEVEL, COLOR_GRAD1, "   You are not authorized to use that command !");
    Command_SetDenial("logoutpl", E_COMMAND_DENIAL_LEVEL, COLOR_GRAD1, "   You are not authorized to use that command !");
    Command_SetDenial("logoutall", E_COMMAND_DENIAL_LEVEL, COLOR_GRAD1, "   You are not authorized to use that command !");
}

hook OnMigrationRun()
{
    Migration_Add("account-1-players", "CREATE TABLE IF NOT EXISTS players (id INT UNSIGNED NOT NULL AUTO_INCREMENT, name VARCHAR(24) NOT NULL, password_hash CHAR(60) NOT NULL, level INT NOT NULL DEFAULT 0, admin_level INT NOT NULL DEFAULT 0, donate_rank INT NOT NULL DEFAULT 0, reg TINYINT NOT NULL DEFAULT 0, sex TINYINT NOT NULL DEFAULT 0, age INT NOT NULL DEFAULT 0, origin TINYINT NOT NULL DEFAULT 0, ck INT NOT NULL DEFAULT 0, muted TINYINT NOT NULL DEFAULT 0, respect INT NOT NULL DEFAULT 0, cash INT NOT NULL DEFAULT 1000, kills INT NOT NULL DEFAULT 0, deaths INT NOT NULL DEFAULT 0, char_skin INT NOT NULL DEFAULT 0, health FLOAT NOT NULL DEFAULT 50, interior INT NOT NULL DEFAULT 15, local_area INT NOT NULL DEFAULT 255, team INT NOT NULL DEFAULT 3, model INT NOT NULL DEFAULT 264, pos_x FLOAT NOT NULL DEFAULT 2246.6, pos_y FLOAT NOT NULL DEFAULT -1161.9, pos_z FLOAT NOT NULL DEFAULT 1029.7, tutorial TINYINT NOT NULL DEFAULT 0, warnings INT NOT NULL DEFAULT 0, adjustable TINYINT NOT NULL DEFAULT 0, registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, last_login_at DATETIME NULL, last_ip VARCHAR(45) NULL, PRIMARY KEY (id), UNIQUE KEY idx_name (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
