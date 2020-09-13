<?php
session_start();
require_once "helpers.php";

$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
$logged_user = $check['logged_user'];
$user_is_admin = $check['user_is_admin'];
$user_locked = $check['user_locked'];
$guest = $check['guest'];
?>

<!DOCTYPE html>
<html lang="de">

<head>
    <?php echo boilerplate_head("Themenübersicht"); ?>
</head>
<body>
    <div id="header">
        <h1>Mein Forum</h1>
        <p>Test-Forum zum Assignment "Forum" für DBA20 [AKAD]</p>
    </div>

    <div id="topnav">
        <div class="curr_user">
            <?php
            echo "Willkommen <b>$logged_user</b>. ";
            if ($user_is_admin) {
                echo "<a href=\"".HOMEDIR."users.php\" class=\"btn btn-default btn-sm\">[ Benutzer verwalten ]</a>";
            }
            if ($guest) {
                echo "<a href=\"".HOMEDIR."login.php\" class=\"btn btn-default btn-sm\">[ Einloggen ]</a>";
            } else {
                echo "<a href=\"".HOMEDIR."logout.php\" class=\"btn btn-default btn-sm\">[ Ausloggen ]</a>";
            }
            ?>
        </div>
    </div>

    <div id="container">
        <div id="btn_new_thread">
            <?php
            if (!$guest && !$user_locked) {
                echo "<a href=\"".HOMEDIR."newthread.php\" class=\"btn btn-default btn-sm\">Neues Thema</a>";
            }
            ?>
        </div>
        <table class="even_rows">
            <tr>
                <th class="<?php echo ($user_is_admin)? "table_threads_short" : "table_threads" ?>">Thema</th>
                <th class="table_starter">Gestartet</th>
                <th class="table_last_entry">Letzter Eintrag</th>
                <?php
                    if ($user_is_admin) {
                        echo "<th class=\"table_adv_controls\"></th>";
                        echo "<th class=\"table_adv_controls\"></th>";
                    }
                ?>
            </tr>
            <?php

            $sql = "SELECT thread.id, thread.name, thread.locked, thread.msg_count,
                        CONVERT_TZ(thread.started_on,'+00:00','".TIMEOFFSET."') AS 'started_on',
                        CONVERT_TZ(msg.datetime,'+00:00','".TIMEOFFSET."') AS 'last_entry',
                        user_a.username AS 'starter', user_b.username AS 'last_user',
                        user_a.locked AS 'starter_lock', user_b.locked AS 'last_user_lock'
                    FROM thread
                    INNER JOIN user AS user_a ON thread.user_id=user_a.id
                    INNER JOIN msg ON thread.id=msg.thread_id
                    INNER JOIN user AS user_b ON msg.user_id=user_b.id
                    WHERE msg.datetime = (SELECT MAX(msg.datetime) FROM msg
                                            WHERE msg.thread_id=thread.id)
                    ORDER BY msg.datetime DESC";

            $result = $mysqli->query($sql);
            if (!$result) {
                err_msg("sql query", $mysqli->error);
            } elseif ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    echo "
                    <tr>
                    <td class=\"left\">";
                    if ($row["locked"]) {
                        echo "
                        <img src=\"".INDEXFILES."lock.png\" alt=\"Thema gesperrt\" title=\"Thema gesperrt\"/>";
                    }
                    echo "
                        <a href=\"".HOMEDIR."viewthread.php/?id=" . $row["id"] . "\">" . $row["name"] ."</a> "
                        ."<span class=\"hint\">[" . $row["msg_count"] . " Beiträge]</span>
                    </td>
                    <td><b>" . ($row["starter_lock"]? LOCKED:$row["starter"]).  "</b> am " . $row["started_on"] . "</td>";

                    $last = "<b>" .($row["last_user_lock"]? LOCKED:$row["last_user"]). "</b> am " . $row["last_entry"];
                    echo "
                    <td>$last</td>";

                    if ($user_is_admin) {
                        $id = $row["id"];
                        if ($row["locked"]) {
                            echo "<td class=\"center\"><a class=\"lock\" href=\"".HOMEDIR."managethread.php/?id=$id&unlock\" title=\"Thema entsperren\"></a></td>";
                        } else {
                            echo "<td class=\"center\"><a class=\"unlock\" href=\"".HOMEDIR."managethread.php/?id=$id&lock\" title=\"Thema sperren\"></a></td>";
                        }
                        echo "<td class=\"center\"><a class=\"trash\" href=\"".HOMEDIR."managethread.php/?id=$id&del\" title=\"Thema löschen\"></a></td>";
                    }
                    echo "
                    </tr>";
                }
            } else {
                echo "<tr><td>keine Themen gefunden</td></tr>";
            }
            ?>

        </table>
    </div>

    <hr class="footer_space" />
    <div id="footer">
        Diese Webseite benutzt Cookies.<br />
        <?php
        echo "php: ";
        echo phpversion();
        echo " | ";
        $result = $mysqli->query("SELECT @@version");
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo "sql: ";
            echo $row["@@version"];
        }
        ?>
        | <a href="http://getbootstrap.com">Bootstrap</a> v3.3.7
    </div>

</body>
</html>
